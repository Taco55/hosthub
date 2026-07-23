import "server-only";

import { getServiceClient } from "./supabase/service";

// Per-site configuration stored on public.sites (see migration
// 20260723120000_add_per_site_config.sql). Resolved by site_id, which the shared
// worker derives from the request domain via runtime-site-context.
export type SiteSettings = {
  name: string | null;
  contactEmail: string | null;
  emailFromName: string | null;
  lodgifyPropertyId: string | null;
  lodgifyRoomTypeId: string | null;
};

const str = (v: unknown): string | null => {
  if (typeof v !== "string") return null;
  const t = v.trim();
  return t ? t : null;
};

/**
 * Fetch per-site settings for the given site. Returns null when the site is
 * unknown or the service client is unavailable, so callers fall back to env.
 */
export async function getSiteSettings(
  siteId: string | null,
): Promise<SiteSettings | null> {
  if (!siteId) return null;
  const client = getServiceClient();
  if (!client) return null;

  try {
    const { data, error } = await client
      .from("sites")
      .select(
        "name, contact_email, email_from_name, lodgify_property_id, lodgify_room_type_id",
      )
      .eq("id", siteId)
      .maybeSingle();

    if (error || !data) return null;

    return {
      name: str(data.name),
      contactEmail: str(data.contact_email),
      emailFromName: str(data.email_from_name),
      lodgifyPropertyId: str(data.lodgify_property_id),
      lodgifyRoomTypeId: str(data.lodgify_room_type_id),
    };
  } catch {
    return null;
  }
}
