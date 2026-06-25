-- Google OAuth provider setup for Mino Chat.
-- Run this in the Supabase SQL editor after creating your project.

-- 1. In Supabase dashboard → Authentication → Providers → Google:
--    - Enable Google provider
--    - Add your Google Cloud OAuth Web client ID + secret
--    - Set redirect URL to: https://YOUR-PROJECT.supabase.co/auth/v1/callback

-- 2. Verify the auth.users table is being populated on Google sign-in:
--    select id, email, raw_user_meta_data from auth.users order by created_at desc limit 5;

-- 3. Make sure new auth.users get a row in public.users automatically:
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, display_name, email, avatar_url, status, last_seen)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1), 'Mino user'),
    new.email,
    new.raw_user_meta_data->>'avatar_url',
    'online',
    now()
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_on_auth_user_created on auth.users;
create trigger trg_on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
