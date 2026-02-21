// comments in English
// Supabase Edge Function proxy. Keeps secrets server-side.
// Locally targets compose DNS (jsonizer:PORT) via JSONIZER_URL env.
// In production set JSONIZER_URL to your Fly app URL.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const JSONIZER_URL = Deno.env.get("JSONIZER_URL") || "http://jsonizer:8080/jsonize";

serve(async (req) => {
  if (req.method !== "POST") return new Response("Method Not Allowed", { status: 405 });
  try {
    const body = await req.json();
    const r = await fetch(JSONIZER_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
    const txt = await r.text();
    return new Response(txt, {
      status: r.status,
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: "proxy_error", detail: String(e) }), {
      status: 502,
      headers: { "Content-Type": "application/json" },
    });
  }
});
