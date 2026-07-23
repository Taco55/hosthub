import "server-only";

import { createLodgifyClient } from "@/lib/lodgify/client";
import { resolveRuntimeSiteContext } from "@/lib/runtime-site-context";
import { getSiteSettings } from "@/lib/site-settings";
import { getServiceClient } from "@/lib/supabase/service";

export type LodgifyContext = {
  client: ReturnType<typeof createLodgifyClient>;
  propertyId: string | null;
  roomTypeId: string | null;
};

// A site's effective Lodgify key is its owner's key (lodgify_api_keys, keyed by
// the site's owner_profile_id). Read via the service client because the key is
// RLS-protected.
//
// We read the tables directly rather than via the get_site_lodgify_api_key RPC:
// that function's PostgREST schema-cache exposure has proven unreliable on this
// project (intermittent PGRST202 "function not found in schema cache"), whereas
// the table endpoints are stable. The service role bypasses RLS, so this is
// equivalent to what the SECURITY DEFINER function did.
async function getSiteLodgifyApiKey(siteId: string | null): Promise<string | null> {
  if (!siteId) return null;
  const supabase = getServiceClient();
  if (!supabase) return null;
  try {
    const { data: site, error: siteError } = await supabase
      .from("sites")
      .select("owner_profile_id")
      .eq("id", siteId)
      .maybeSingle();
    if (siteError || !site?.owner_profile_id) return null;

    const { data: keyRow, error: keyError } = await supabase
      .from("lodgify_api_keys")
      .select("api_key")
      .eq("profile_id", site.owner_profile_id)
      .maybeSingle();
    if (keyError || !keyRow) return null;

    const key =
      typeof keyRow.api_key === "string" ? keyRow.api_key.trim() : "";
    return key ? key : null;
  } catch {
    return null;
  }
}

/**
 * Resolve the Lodgify config for the current request's site: the per-consumer
 * API key + the site's property/room ids, each falling back to the worker env
 * for sites that have no values configured yet.
 *
 * Throws only when no API key can be resolved at all (site key nor env).
 * propertyId / roomTypeId may be null — callers that need them must check.
 */
export async function resolveLodgifyContext(): Promise<LodgifyContext> {
  const site = await resolveRuntimeSiteContext();
  const settings = await getSiteSettings(site.siteId);

  const apiKey =
    (await getSiteLodgifyApiKey(site.siteId)) ?? process.env.LODGIFY_API_KEY;
  if (!apiKey) {
    throw new Error("No Lodgify API key configured for this site.");
  }

  const baseUrl = process.env.LODGIFY_API_BASE ?? "https://api.lodgify.com";
  const client = createLodgifyClient({ apiKey, baseUrl });

  const propertyId =
    settings?.lodgifyPropertyId ?? process.env.LODGIFY_PROPERTY_ID ?? null;
  const roomTypeId =
    settings?.lodgifyRoomTypeId ?? process.env.LODGIFY_ROOM_TYPE_ID ?? null;

  return { client, propertyId, roomTypeId };
}
