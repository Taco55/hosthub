import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

import { buildCorsHeaders } from "./http.ts";

/** Mirrors public.site_member_role. */
export type SiteMemberRole = "owner" | "editor" | "viewer";

const ROLE_RANK: Record<SiteMemberRole, number> = {
  owner: 3,
  editor: 2,
  viewer: 1,
};

function rank(value: unknown): number {
  return typeof value === "string" && value in ROLE_RANK
    ? ROLE_RANK[value as SiteMemberRole]
    : 0;
}

/**
 * Resolve a user's effective Lodgify API key by reading the tables directly.
 *
 * This is the equivalent of the public.get_effective_lodgify_api_key RPC, but
 * called against the tables via a service-role client (which bypasses RLS). We
 * avoid the RPC because its PostgREST schema-cache exposure has proven
 * unreliable on this project (intermittent PGRST202 "function not found in
 * schema cache"), whereas the table endpoints are stable.
 *
 * Resolution order mirrors the RPC:
 *  1. The user's own stored key.
 *  2. The key of the owner of a site the user belongs to (earliest membership).
 *
 * [minRole] is the membership required to borrow the *owner's* key. Reads are
 * fine for any member, but a call that changes something in the owner's Lodgify
 * account is not: without this, a `viewer` on one of the owner's sites could
 * PATCH their reservations. A user's own key is never gated — it is theirs.
 */
export async function resolveEffectiveLodgifyApiKey(
  adminClient: SupabaseClient,
  userId: string,
  options: { minRole?: SiteMemberRole } = {},
): Promise<{ data: string | null; error: unknown }> {
  const minRank = ROLE_RANK[options.minRole ?? "viewer"];

  const own = await adminClient
    .from("lodgify_api_keys")
    .select("api_key")
    .eq("profile_id", userId)
    .maybeSingle();
  if (own.error) return { data: null, error: own.error };
  const ownKey =
    typeof own.data?.api_key === "string" ? own.data.api_key.trim() : "";
  if (ownKey) return { data: ownKey, error: null };

  const memberships = await adminClient
    .from("site_members")
    .select("site_id, role, created_at, sites(owner_profile_id)")
    .eq("profile_id", userId)
    .order("created_at", { ascending: true });
  if (memberships.error) return { data: null, error: memberships.error };

  for (const row of memberships.data ?? []) {
    if (rank((row as { role?: unknown }).role) < minRank) continue;

    const site = (row as {
      sites?:
        | { owner_profile_id?: string | null }
        | Array<{ owner_profile_id?: string | null }>;
    }).sites;
    const ownerId = Array.isArray(site)
      ? site[0]?.owner_profile_id
      : site?.owner_profile_id;
    if (!ownerId) continue;

    const ownerKey = await adminClient
      .from("lodgify_api_keys")
      .select("api_key")
      .eq("profile_id", ownerId)
      .maybeSingle();
    if (ownerKey.error) return { data: null, error: ownerKey.error };
    const key =
      typeof ownerKey.data?.api_key === "string"
        ? ownerKey.data.api_key.trim()
        : "";
    if (key) return { data: key, error: null };
  }

  return { data: null, error: null };
}

const NULL_BODY_STATUSES = new Set([204, 205, 304]);

/**
 * Passes a Lodgify response back to the caller.
 *
 * Keeps `Retry-After` when Lodgify rate-limits us. Lodgify's limits are tight
 * and the console retries on its own; without this header it has nothing to base
 * a delay on and a 429 turns into a retry loop that keeps the limit tripped.
 */
export async function proxyLodgifyResponse(
  lodgifyResponse: Response,
  corsOptions: {
    origin?: string;
    methods?: string[];
    headers?: string[];
  } = {},
): Promise<Response> {
  const status = lodgifyResponse.status;
  const headers = buildCorsHeaders({
    ...corsOptions,
    contentType: "application/json; charset=utf-8",
  });
  const retryAfter = lodgifyResponse.headers.get("Retry-After");
  if (retryAfter) headers["Retry-After"] = retryAfter;

  const body = await lodgifyResponse.text();
  const respond = (payload: unknown, code = status) =>
    // 204/205/304 may not carry a body; handing one to Response throws, which
    // would turn a perfectly ordinary empty Lodgify reply into a crash.
    NULL_BODY_STATUSES.has(code)
      ? new Response(null, { status: code, headers })
      : new Response(JSON.stringify(payload), { status: code, headers });

  if (!body) return respond({});

  try {
    return respond(JSON.parse(body));
  } catch (_) {
    if (status === 429) {
      // A rate-limit body is not always JSON, and turning it into a 502 would
      // hide the one status the caller has to react to.
      return respond({ error: "Lodgify rate limit reached." }, 429);
    }
    return respond({ error: "Invalid JSON returned by Lodgify." }, 502);
  }
}
