// Mino Chat — close stale live rooms.
// Triggered by Supabase scheduled function (cron) every 5 minutes.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceKey  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

Deno.serve(async () => {
  const admin = createClient(supabaseUrl, serviceKey);
  const { data, error } = await admin
    .from("live_rooms")
    .update({ is_live: false, ended_at: new Date().toISOString() })
    .lt("started_at", new Date(Date.now() - 4 * 60 * 60 * 1000).toISOString()) // 4h cap
    .eq("is_live", true);

  if (error) return new Response(JSON.stringify(error), { status: 500 });
  return new Response(JSON.stringify({ closed: (data ?? []).length }), {
    headers: { "Content-Type": "application/json" },
  });
});
