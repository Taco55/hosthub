import "server-only";

import { createClient, type SupabaseClient } from "@supabase/supabase-js";

// Server-only Supabase client using the secret (service-role) key. Used to read
// per-site config that is RLS-protected. Prefer the new SUPABASE_SECRET_KEY
// naming; fall back to the legacy SUPABASE_SERVICE_ROLE_KEY.
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL?.trim() ?? "";
const SUPABASE_SECRET_KEY =
  process.env.SUPABASE_SECRET_KEY?.trim() ||
  process.env.SUPABASE_SERVICE_ROLE_KEY?.trim() ||
  "";

let cached: SupabaseClient | null = null;

/**
 * Returns a shared server-side Supabase client, or null when the secret key /
 * URL are not configured (callers should degrade gracefully in that case).
 */
export function getServiceClient(): SupabaseClient | null {
  if (!SUPABASE_URL || !SUPABASE_SECRET_KEY) return null;
  if (!cached) {
    cached = createClient(SUPABASE_URL, SUPABASE_SECRET_KEY, {
      auth: { autoRefreshToken: false, persistSession: false },
    });
  }
  return cached;
}
