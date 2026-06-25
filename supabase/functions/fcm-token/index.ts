// Mino Chat — save FCM token for the current user.
// POST /functions/v1/fcm-token  { "token": "…" }
// Authorization: Bearer <supabase access token>

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceKey  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const authHeader   = Deno.env.get("Authorization") ?? "";

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("Method Not Allowed", { status: 405 });
  try {
    const jwt = authHeader.replace("Bearer ", "");
    if (!jwt) return new Response("Unauthorized", { status: 401 });

    const userClient = createClient(supabaseUrl, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: `Bearer ${jwt}` } },
    });
    const { data: { user }, error } = await userClient.auth.getUser();
    if (error || !user) return new Response("Unauthorized", { status: 401 });

    const { token } = await req.json();
    if (!token || typeof token !== "string") return new Response("Bad request", { status: 400 });

    const admin = createClient(supabaseUrl, serviceKey);
    const { error: e } = await admin
      .from("users")
      .update({ fcm_token: token })
      .eq("id", user.id);

    if (e) return new Response(JSON.stringify(e), { status: 500 });
    return new Response(JSON.stringify({ ok: true }), { headers: { "Content-Type": "application/json" } });
  } catch (err) {
    return new Response(String(err), { status: 500 });
  }
});
