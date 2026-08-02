// Attaches a custom domain to a site — DNS, Worker route and `site_domains`
// row in one call.
//
// This cannot run in the console. Wiring a hostname to the sites Worker needs a
// Cloudflare API token with edit rights on the zone, and the console is a web
// app: anything it holds, its users hold. The token stays here, and the caller
// is checked against has_site_access(..., 'owner') before it is ever used.
//
// What it deliberately does not do: create the Cloudflare zone. A domain the
// customer has not delegated to Cloudflare yet cannot be fixed from this side —
// their registrar's nameservers have to change first — so an undelegated domain
// is refused with `zone_not_found` rather than written as a row that resolves
// nowhere and looks configured in the UI.
import { createClient } from "npm:@supabase/supabase-js@2";

import {
  CloudflareError,
  ensureDnsRecord,
  ensureWorkerRoute,
  findZone,
  normalizeHostname,
  zoneCandidates,
} from "../_shared/cloudflare.ts";
import { env } from "../_shared/env.ts";
import { buildCorsHeaders, jsonError, jsonResponse } from "../_shared/http.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SERVICE_ROLE_KEY = env("SUPABASE_SERVICE_ROLE_KEY", "SUPABASE_SECRET_KEY");
const CLOUDFLARE_API_TOKEN = env("CLOUDFLARE_API_TOKEN");
const SITES_WORKER = env("SITES_WORKER_NAME") ?? "hosthub-sites";

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  throw new Error("Missing Supabase configuration for manage_site_domain.");
}

const adminClient = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

type Payload = { siteId?: string; domain?: string };

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: buildCorsHeaders() });
  }
  if (req.method !== "POST") return jsonError(405, "Method not allowed");

  // ── Caller ──────────────────────────────────────────────────────────────
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return jsonError(401, "Missing Authorization header");

  const token = authHeader.replace("Bearer ", "").trim();
  const { data: { user: caller }, error: authError } = await adminClient.auth
    .getUser(token);
  if (authError || !caller) return jsonError(401, "Invalid or expired token");

  // ── Payload ─────────────────────────────────────────────────────────────
  let payload: Payload;
  try {
    payload = await req.json();
  } catch {
    return jsonError(400, "Invalid JSON payload");
  }

  const siteId = payload.siteId?.trim();
  if (!siteId) return jsonError(400, "Missing siteId");

  const domain = normalizeHostname(payload.domain ?? "");
  if (!domain) return jsonError(400, "invalid_domain");

  // ── Authorize ───────────────────────────────────────────────────────────
  // Deliberately the same test the site_domains RLS policy applies —
  // is_admin OR owner. This function is now the only way that table is
  // written, so being stricter than its policy would take away access the
  // schema grants rather than add safety.
  const [{ data: isOwner, error: accessError }, { data: isAdmin }] =
    await Promise.all([
      adminClient.rpc("has_site_access", {
        check_site_id: siteId,
        check_user_id: caller.id,
        min_role: "owner",
      }),
      adminClient.rpc("is_admin", { user_id: caller.id }),
    ]);
  if (accessError) {
    console.error("[manage_site_domain] access check failed", accessError);
    return jsonError(500, "Failed to verify site access");
  }
  if (!isOwner && !isAdmin) {
    return jsonError(403, "You must be a site owner to change the domain");
  }

  // ── Refuse a hostname that already belongs to another site ──────────────
  // The UNIQUE constraint would catch this too, but a 409 naming the conflict
  // is what the console can turn into a sentence.
  const { data: existing, error: existingError } = await adminClient
    .from("site_domains")
    .select("id, site_id, is_primary")
    .eq("domain", domain)
    .maybeSingle();
  if (existingError) {
    console.error("[manage_site_domain] domain lookup failed", existingError);
    return jsonError(500, "Failed to check the domain");
  }
  if (existing && existing.site_id !== siteId) {
    return jsonError(409, "domain_taken");
  }

  // ── Cloudflare ──────────────────────────────────────────────────────────
  if (!CLOUDFLARE_API_TOKEN) {
    console.error("[manage_site_domain] CLOUDFLARE_API_TOKEN is not configured");
    return jsonError(500, "dns_not_configured");
  }

  let dns: string;
  let route: string;
  try {
    const zone = await findZone(CLOUDFLARE_API_TOKEN, domain);
    if (!zone) {
      // The apex is the zone they have to delegate — the last candidate, since
      // zoneCandidates() runs most-specific first.
      const candidates = zoneCandidates(domain);
      return jsonResponse({
        error: "zone_not_found",
        zone: candidates[candidates.length - 1],
      }, 409);
    }
    dns = await ensureDnsRecord(CLOUDFLARE_API_TOKEN, zone.id, domain);
    route = await ensureWorkerRoute(
      CLOUDFLARE_API_TOKEN,
      zone.id,
      domain,
      SITES_WORKER,
    );
  } catch (error) {
    const message = error instanceof CloudflareError
      ? error.message
      : String(error);
    console.error("[manage_site_domain] cloudflare failed", message);
    return jsonError(502, "dns_failed");
  }

  // ── Promote to primary ──────────────────────────────────────────────────
  // Clear first: site_domains_one_primary_per_site is a unique partial index,
  // so two primaries never coexist, not even mid-transaction.
  const { error: demoteError } = await adminClient
    .from("site_domains")
    .update({ is_primary: false })
    .eq("site_id", siteId)
    .eq("is_primary", true)
    .neq("domain", domain);
  if (demoteError) {
    console.error("[manage_site_domain] demote failed", demoteError);
    return jsonError(500, "Failed to update the site's domains");
  }

  const { error: writeError } = existing
    ? await adminClient
      .from("site_domains")
      .update({ is_primary: true })
      .eq("id", existing.id)
    : await adminClient
      .from("site_domains")
      .insert({ site_id: siteId, domain, is_primary: true });
  if (writeError) {
    console.error("[manage_site_domain] write failed", writeError);
    return jsonError(500, "Failed to save the domain");
  }

  return jsonResponse({ domain, dns, route });
});
