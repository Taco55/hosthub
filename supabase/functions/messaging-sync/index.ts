// Pull guest conversations from the messaging source into message_threads /
// messages.
//
// Thread discovery goes through bookings, and that is a design decision rather
// than a workaround: Lodgify's public API has exactly one messaging endpoint,
// `GET /v2/messaging/{threadGuid}`, and no way to list threads. The GUID sits
// in the booking payload, so the sync walks
// `GET /v2/reservations/bookings` → thread GUID → `GET /v2/messaging/{guid}`.
//
// The consequence is that only conversations attached to a booking or an
// enquiry arrive. That covers virtually everything an owner has to answer; it
// is recorded here and in the adapter rather than shown in the UI, because a
// permanent property of the source is not news to the reader of an inbox.
//
// Writes are upserts keyed on (source, source_thread_id) and
// (thread_id, source_message_id): re-syncing never duplicates, and our own read
// state, snooze and archive columns are left untouched.

import { createClient } from "npm:@supabase/supabase-js@2";
import { env } from "../_shared/env.ts";
import { buildCorsHeaders, jsonError, jsonResponse } from "../_shared/http.ts";
import { resolveEffectiveLodgifyApiKey } from "../_shared/lodgify.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error("Missing Supabase configuration for messaging-sync.");
}

const adminClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const SOURCE = "lodgify";
const LODGIFY_BOOKINGS_URL =
  "https://api.lodgify.com/v2/reservations/bookings";
const LODGIFY_THREAD_URL = "https://api.lodgify.com/v2/messaging";
const BOOKING_PAGE_SIZE = 50;

const allowHeaders = [
  "authorization",
  "x-client-info",
  "apikey",
  "content-type",
];

type CorsOptions = { origin: string; methods: string[]; headers: string[] };

type SyncPayload = {
  propertyIds?: number[];
  /** Sync exactly one thread — the webhook path. */
  sourceThreadId?: string;
};

type ThreadSeed = {
  sourceThreadId: string;
  propertyId: number;
  reservationId: string | null;
  guestName: string | null;
  guestLocale: string | null;
  channel: string;
  raw: Record<string, unknown>;
};

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("Origin") ?? "*";
  const corsOptions: CorsOptions = {
    origin,
    methods: ["POST", "OPTIONS"],
    headers: allowHeaders,
  };
  const corsHeaders = buildCorsHeaders(corsOptions);

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonError(405, "Method not allowed", corsOptions);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonError(401, "Missing Authorization header", corsOptions);
    }
    const token = authHeader.replace("Bearer ", "").trim();
    if (!token) {
      return jsonError(401, "Invalid Authorization header", corsOptions);
    }

    const { data: { user }, error: authError } = await adminClient.auth.getUser(
      token,
    );
    if (authError || !user) {
      return jsonError(401, "Invalid or expired token", corsOptions);
    }

    const body = await req.json().catch(() => ({})) as SyncPayload;
    const requestedIds = (body.propertyIds ?? [])
      .map((id) => Number(id))
      .filter((id) => Number.isFinite(id));
    if (requestedIds.length === 0) {
      return jsonError(400, "Missing propertyIds", corsOptions);
    }

    const properties = await loadAccessibleProperties(user.id, requestedIds);
    if (properties.length === 0) {
      return jsonResponse(
        { threads: 0, messages: 0, skippedProperties: requestedIds },
        200,
        corsOptions,
      );
    }

    const { data: key, error: keyError } = await resolveEffectiveLodgifyApiKey(
      adminClient,
      user.id,
    );
    if (keyError) {
      console.error("[messaging-sync] key lookup failed", keyError);
      return jsonError(500, "Failed to resolve source credentials", corsOptions);
    }
    const apiKey = typeof key === "string" ? key.trim() : "";
    if (!apiKey) {
      return jsonError(
        400,
        "Missing Lodgify API key. Add one under Account.",
        corsOptions,
      );
    }

    const onlyThread = body.sourceThreadId?.trim();
    const seeds = await discoverThreads(properties, apiKey, onlyThread);

    let threadCount = 0;
    let messageCount = 0;
    const failed: string[] = [];

    for (const seed of seeds) {
      try {
        messageCount += await syncThread(seed, apiKey);
        threadCount++;
      } catch (error) {
        console.error(
          `[messaging-sync] thread ${seed.sourceThreadId} failed`,
          error,
        );
        failed.push(seed.sourceThreadId);
      }
    }

    return jsonResponse(
      { threads: threadCount, messages: messageCount, failed },
      200,
      corsOptions,
    );
  } catch (error) {
    console.error("[messaging-sync] error", error);
    return jsonError(500, (error as Error).message, corsOptions);
  }
});

/** The requested properties this user may actually see, with their source id. */
async function loadAccessibleProperties(
  userId: string,
  propertyIds: number[],
): Promise<{ id: number; lodgifyId: string }[]> {
  const { data, error } = await adminClient
    .from("properties")
    .select("id, lodgify_id, owner_profile_id")
    .in("id", propertyIds);
  if (error) throw new Error(error.message);

  const accessByOwner = new Map<string, boolean>();
  const allowed: { id: number; lodgifyId: string }[] = [];

  for (const row of data ?? []) {
    const lodgifyId = typeof row.lodgify_id === "string"
      ? row.lodgify_id.trim()
      : "";
    // A property with no source id has nothing to fetch — it exists here but
    // not at the source yet.
    if (!lodgifyId) continue;

    const owner = row.owner_profile_id as string | null;
    if (!owner) continue;

    if (!accessByOwner.has(owner)) {
      const { data: hasAccess, error: accessError } = await adminClient.rpc(
        "has_account_access",
        { check_owner_profile_id: owner, check_user_id: userId },
      );
      if (accessError) throw new Error(accessError.message);
      accessByOwner.set(owner, hasAccess === true);
    }
    if (accessByOwner.get(owner) !== true) continue;

    allowed.push({ id: row.id as number, lodgifyId });
  }

  return allowed;
}

/** Walk each property's bookings and collect the thread GUIDs they carry. */
async function discoverThreads(
  properties: { id: number; lodgifyId: string }[],
  apiKey: string,
  onlySourceThreadId?: string,
): Promise<ThreadSeed[]> {
  const seeds = new Map<string, ThreadSeed>();

  for (const property of properties) {
    let page = 1;
    while (true) {
      const url = new URL(LODGIFY_BOOKINGS_URL);
      url.searchParams.set("property_id", property.lodgifyId);
      url.searchParams.set("stayFilter", "All");
      url.searchParams.set("page", page.toString());
      url.searchParams.set("size", BOOKING_PAGE_SIZE.toString());

      const response = await fetchLodgify(url, apiKey);
      if (!response.ok) {
        // A property whose bookings cannot be read contributes no threads; the
        // rest of the account still syncs.
        console.error(
          `[messaging-sync] bookings ${property.lodgifyId} → ${response.status}`,
        );
        break;
      }
      const payload = await response.json().catch(() => null);
      const bookings = extractList(payload, [
        "items",
        "bookings",
        "data",
        "results",
        "reservations",
      ]);
      if (bookings.length === 0) break;

      for (const booking of bookings) {
        const sourceThreadId = readThreadId(booking);
        if (!sourceThreadId) continue;
        if (onlySourceThreadId && sourceThreadId !== onlySourceThreadId) {
          continue;
        }
        // The newest booking wins for the shared fields; bookings come back
        // newest-first, so the first sighting is already the right one.
        if (seeds.has(sourceThreadId)) continue;

        seeds.set(sourceThreadId, {
          sourceThreadId,
          propertyId: property.id,
          reservationId: readString(booking, [
            "id",
            "booking_id",
            "bookingId",
            "reservation_id",
            "reservationId",
          ]),
          guestName: readGuestName(booking),
          guestLocale: readString(booking, [
            "language",
            "locale",
            "guest_language",
            "guestLanguage",
          ]),
          channel: normalizeChannel(
            readString(booking, [
              "source",
              "source_text",
              "sourceText",
              "channel",
              "channel_name",
              "channelName",
            ]),
          ),
          raw: booking,
        });
      }

      if (bookings.length < BOOKING_PAGE_SIZE) break;
      page++;
    }
  }

  return [...seeds.values()];
}

/** Fetch one thread and upsert it with its messages. Returns messages written. */
async function syncThread(seed: ThreadSeed, apiKey: string): Promise<number> {
  const url = new URL(
    `${LODGIFY_THREAD_URL}/${encodeURIComponent(seed.sourceThreadId)}`,
  );
  const response = await fetchLodgify(url, apiKey);
  if (!response.ok) {
    throw new Error(`thread fetch failed: ${response.status}`);
  }
  const payload = await response.json().catch(() => null);
  if (!payload || typeof payload !== "object") {
    throw new Error("thread fetch returned no object");
  }
  const thread = payload as Record<string, unknown>;

  const rawMessages = extractList(thread, ["messages", "items", "data"]);
  const messages = rawMessages
    .map((message, index) => normalizeMessage(message, index, seed.channel))
    .filter((message): message is NormalizedMessage => message !== null)
    .sort((a, b) => a.sentAt.localeCompare(b.sentAt));

  const last = messages.at(-1);
  const syncedAt = new Date().toISOString();

  const { data: upserted, error: threadError } = await adminClient
    .from("message_threads")
    .upsert({
      property_id: seed.propertyId,
      source: SOURCE,
      source_thread_id: seed.sourceThreadId,
      channel: seed.channel,
      reservation_id: seed.reservationId,
      guest_name: readString(thread, ["guest_name", "guestName"]) ??
        seed.guestName,
      guest_locale: readString(thread, ["language", "locale"]) ??
        seed.guestLocale,
      last_message_at: last?.sentAt ?? null,
      last_message_preview: last ? preview(last.body) : null,
      // The only honest definition: the last word is the guest's.
      awaiting_host: last?.direction === "inbound",
      raw: { booking: seed.raw, thread },
      synced_at: syncedAt,
    }, { onConflict: "source,source_thread_id" })
    .select("id")
    .single();
  if (threadError) throw new Error(threadError.message);

  const threadId = upserted.id as string;
  if (messages.length === 0) return 0;

  const { error: messageError } = await adminClient
    .from("messages")
    .upsert(
      messages.map((message) => ({
        thread_id: threadId,
        source_message_id: message.sourceMessageId,
        direction: message.direction,
        body: message.body,
        sent_at: message.sentAt,
        author_name: message.authorName,
        delivery_state: "sent",
        raw: message.raw,
      })),
      { onConflict: "thread_id,source_message_id" },
    );
  if (messageError) throw new Error(messageError.message);

  return messages.length;
}

type NormalizedMessage = {
  sourceMessageId: string;
  direction: "inbound" | "outbound";
  body: string;
  sentAt: string;
  authorName: string | null;
  raw: Record<string, unknown>;
};

function normalizeMessage(
  value: unknown,
  index: number,
  _channel: string,
): NormalizedMessage | null {
  if (!value || typeof value !== "object") return null;
  const message = value as Record<string, unknown>;

  const body = readString(message, [
    "message",
    "body",
    "text",
    "content",
    "subject",
  ]);
  if (!body) return null;

  const sentAtRaw = readString(message, [
    "created_at",
    "createdAt",
    "date",
    "sent_at",
    "sentAt",
    "timestamp",
  ]);
  const sentAt = sentAtRaw ? new Date(sentAtRaw).toISOString() : null;
  if (!sentAt || Number.isNaN(Date.parse(sentAt))) return null;

  return {
    // Falls back to position + timestamp so a source that numbers nothing still
    // upserts idempotently instead of appending a copy on every sync.
    sourceMessageId: readString(message, ["id", "uid", "message_id", "guid"]) ??
      `${index}:${sentAt}`,
    direction: resolveDirection(message),
    body,
    sentAt,
    authorName: readString(message, [
      "author",
      "author_name",
      "sender_name",
      "senderName",
      "from",
      "name",
    ]),
    raw: message,
  };
}

/**
 * Who wrote a message.
 *
 * Anything the source attributes to the host is outbound; everything else —
 * including anything unlabelled — is inbound. That bias is deliberate: a guest
 * message misread as ours would quietly clear `awaiting_host`, which is exactly
 * the state this screen exists to make loud.
 */
function resolveDirection(
  message: Record<string, unknown>,
): "inbound" | "outbound" {
  const explicit = readString(message, ["direction"])?.toLowerCase();
  if (explicit === "outbound" || explicit === "inbound") return explicit;

  const isOwner = message.is_owner ?? message.isOwner;
  if (typeof isOwner === "boolean") return isOwner ? "outbound" : "inbound";

  const type = readString(message, [
    "type",
    "sender_type",
    "senderType",
    "author_type",
    "from",
  ])?.toLowerCase() ?? "";
  if (
    type.includes("owner") || type.includes("host") ||
    type.includes("staff") || type.includes("outgoing")
  ) {
    return "outbound";
  }
  return "inbound";
}

async function fetchLodgify(url: URL, apiKey: string): Promise<Response> {
  return await fetch(url, {
    method: "GET",
    headers: { Accept: "application/json", "X-APIKEY": apiKey },
  });
}

function preview(body: string): string {
  const flat = body.replace(/\s+/g, " ").trim();
  return flat.length <= 240 ? flat : `${flat.slice(0, 239)}…`;
}

/**
 * The channel a conversation arrived through — not the source it was fetched
 * from. One Lodgify account carries Airbnb, Booking.com and direct guests, and
 * that is precisely why an inbox is worth having.
 */
function normalizeChannel(source: string | null): string {
  const value = (source ?? "").toLowerCase();
  if (value.includes("airbnb")) return "airbnb";
  if (value.includes("booking")) return "booking_com";
  if (value.includes("vrbo") || value.includes("homeaway")) return "vrbo";
  if (value.includes("mail")) return "email";
  if (
    value.includes("direct") || value.includes("manual") ||
    value.includes("website") || value.includes("owner")
  ) {
    return "direct";
  }
  return "other";
}

function readThreadId(booking: Record<string, unknown>): string | null {
  return readString(booking, [
    "thread_uid",
    "threadUid",
    "thread_guid",
    "threadGuid",
    "thread_id",
    "threadId",
    "messaging_thread_uid",
    "conversation_id",
    "conversationId",
  ]);
}

function readGuestName(booking: Record<string, unknown>): string | null {
  const direct = readString(booking, [
    "guest_name",
    "guestName",
    "customer_name",
  ]);
  if (direct) return direct;

  const guest = booking.guest ?? booking.customer;
  if (guest && typeof guest === "object") {
    const nested = guest as Record<string, unknown>;
    const name = readString(nested, ["name", "full_name", "fullName"]);
    if (name) return name;
    const first = readString(nested, ["first_name", "firstName"]);
    const last = readString(nested, ["last_name", "lastName"]);
    const joined = [first, last].filter(Boolean).join(" ").trim();
    if (joined) return joined;
  }
  return null;
}

function readString(
  source: Record<string, unknown>,
  keys: string[],
): string | null {
  for (const key of keys) {
    const value = source[key];
    if (typeof value === "string" && value.trim().length > 0) {
      return value.trim();
    }
    if (typeof value === "number") return value.toString();
  }
  return null;
}

function extractList(
  payload: unknown,
  keys: string[],
): Record<string, unknown>[] {
  if (Array.isArray(payload)) {
    return payload.filter((item): item is Record<string, unknown> =>
      !!item && typeof item === "object"
    );
  }
  if (!payload || typeof payload !== "object") return [];
  const source = payload as Record<string, unknown>;
  for (const key of keys) {
    const nested = source[key];
    if (Array.isArray(nested)) return extractList(nested, keys);
  }
  return [];
}
