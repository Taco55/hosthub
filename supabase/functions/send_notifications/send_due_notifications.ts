import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { sendPushNotification } from "./send_push_notification.ts";
import { env } from "../_shared/env.ts";

const SUPABASE_URL = env("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = env(
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_SECRET_KEY",
);

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error("Missing required Supabase configuration.");
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (_req) => {
  const { data, error } = await supabase
    .from("due_field_value_notifications")
    .select("field_value_id, notify_at, item_id, list_id");

  if (error) {
    console.error("Error fetching due notifications:", error.message);
    return new Response("Error fetching notifications", { status: 500 });
  }

  for (const notif of data) {
    try {
      // Fetch target user(s) (for now we just assume a single owner)
      const { data: item, error: itemError } = await supabase
        .from("items")
        .select("user_id, name")
        .eq("id", notif.item_id)
        .single();

      if (itemError || !item) {
        console.error("Error fetching item:", itemError?.message);
        continue;
      }

      // Send FCM notification
      await sendPushNotification({
        userId: item.user_id,
        title: "⏰ Reminder",
        body: `Don't forget: ${item.name}`,
        data: {
          item_id: notif.item_id,
          list_id: notif.list_id,
        },
      });

      // Clear notify_at from field_value JSONB
      const { error: updateError } = await supabase
        .rpc("clear_notify_at", { field_value_id: notif.field_value_id });

      if (updateError) {
        console.error("Failed to clear notify_at:", updateError.message);
      }

    } catch (err) {
      console.error("Notification failed:", err);
    }
  }

  return new Response("Notifications processed", { status: 200 });
});
