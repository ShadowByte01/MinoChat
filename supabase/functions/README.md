# Mino Chat — Supabase Edge Functions

Deploy with the Supabase CLI:

```bash
supabase functions deploy fcm-token --no-verify-jwt
supabase functions deploy push-fanout
supabase functions deploy live-schedule
```

These functions are intentionally minimal. They run on the edge (Deno)
and are called by the Flutter client or by database webhooks.

Made by Lost Weeds (Abhinit) · X Hub · MIT License
