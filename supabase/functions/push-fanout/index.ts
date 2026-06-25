// Mino Chat — fan-out push notification when a new message is inserted.
// Triggered by a Supabase database webhook on `public.messages` insert.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceKey  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

Deno.serve(async (req) => {
  try {
    const body = await req.json();
    const record = body.record;
    if (!record) return new Response("ok", { status: 200 });

    const admin = createClient(supabaseUrl, serviceKey);

    // Fetch chat room to get all members
    const { data: chat } = await admin.from("chats").select("*").eq("id", record.chat_id).single();
    if (!chat) return new Response("ok", { status: 200 });

    // Fetch sender
    const { data: sender } = await admin.from("users").select("display_name").eq("id", record.sender_id).single();
    const senderName = sender?.display_name ?? "Mino user";

    // Fetch FCM tokens for all members except sender
    const { data: users } = await admin
      .from("users")
      .select("id, fcm_token")
      .in("id", chat.member_ids.filter((id: string) => id !== record.sender_id));

    const tokens = (users ?? []).map((u: any) => u.fcm_token).filter(Boolean);
    if (tokens.length === 0) return new Response("no tokens", { status: 200 });

    // Build FCM payload — replace with actual FCM send via firebase-admin if needed
    const preview = record.text
      ? record.text.slice(0, 80)
      : record.attachment_name ?? "Attachment";

    console.log(`[push] ${senderName} → ${tokens.length} recipients: ${preview}`);

    // In production, integrate firebase-admin here:
    // await admin.messaging().sendEachForMulticast({ tokens, notification: { title: senderName, body: preview } });

    return new Response(JSON.stringify({ sent: tokens.length }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error(err);
    return new Response(String(err), { status: 500 });
  }
});
