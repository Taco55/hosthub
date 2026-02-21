import { createClient } from 'npm:@supabase/supabase-js@2';
import { env } from "../_shared/env.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error("Missing required Supabase configuration.");
}

Deno.serve(async (req) => {
  const { fullKey, thumbnailKey } = await req.json();

  console.log("Received request to delete:");
  console.log("  fullKey:", fullKey);
  console.log("  thumbnailKey:", thumbnailKey);

  const supabase = createClient(
    SUPABASE_URL,
    SUPABASE_SERVICE_ROLE_KEY,
  );

  if (fullKey) {
    const { error } = await supabase.storage.from("images").remove([fullKey]);
    if (error) console.error("Error deleting fullKey:", error.message);
    else console.log("Deleted fullKey:", fullKey);
  }

  if (thumbnailKey) {
    const { error } = await supabase.storage.from("images").remove([thumbnailKey]);
    if (error) console.error("Error deleting thumbnailKey:", error.message);
    else console.log("Deleted thumbnailKey:", thumbnailKey);
  }

  return new Response("OK", { status: 200 });
});
