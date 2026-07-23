import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

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
 */
export async function resolveEffectiveLodgifyApiKey(
  adminClient: SupabaseClient,
  userId: string,
): Promise<{ data: string | null; error: unknown }> {
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
    .select("site_id, created_at, sites(owner_profile_id)")
    .eq("profile_id", userId)
    .order("created_at", { ascending: true });
  if (memberships.error) return { data: null, error: memberships.error };

  for (const row of memberships.data ?? []) {
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
