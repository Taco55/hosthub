import { createClient } from "npm:@supabase/supabase-js@2";
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

export interface PushNotificationOptions {
  userId: string;
  title: string;
  body: string;
  data?: Record<string, unknown>;
}

/**
 * Minimal helper to send a push notification via Firebase Cloud Messaging.
 * Fetches the user's `fcm_token` from the `profiles` table and sends the
 * notification using the `FCM_SERVER_KEY` environment variable.
 */
export async function sendPushNotification({
  userId,
  title,
  body,
  data,
}: PushNotificationOptions): Promise<void> {
  const { data: profile } = await supabase
    .from("profiles")
    .select("fcm_token")
    .eq("id", userId)
    .maybeSingle();

  const fcmToken = profile?.fcm_token as string | undefined;

  if (!fcmToken) {
    console.log("sendPushNotification: no fcm_token for user", userId);
    return;
  }

  const serverKey = Deno.env.get("FCM_SERVER_KEY");
  if (!serverKey) {
    console.log("sendPushNotification: missing FCM_SERVER_KEY env var");
    return;
  }

  const message = {
    to: fcmToken,
    notification: { title, body },
    data,
  };

  const res = await fetch("https://fcm.googleapis.com/fcm/send", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `key=${serverKey}`,
    },
    body: JSON.stringify(message),
  });

  if (!res.ok) {
    console.error(
      "Failed to send push notification:",
      await res.text(),
    );
  }
}
