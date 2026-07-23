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

// A site's effective Lodgify key is its owner's key (see the
// get_site_lodgify_api_key RPC / lodgify_api_keys table). Read via the service
// client because the key is RLS-protected.
async function getSiteLodgifyApiKey(siteId: string | null): Promise<string | null> {
  if (!siteId) return null;
  const supabase = getServiceClient();
  if (!supabase) return null;
  try {
    const { data, error } = await supabase.rpc("get_site_lodgify_api_key", {
      p_site_id: siteId,
    });
    if (error) return null;
    return typeof data === "string" && data.trim() ? data.trim() : null;
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
