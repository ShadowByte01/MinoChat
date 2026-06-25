-- =====================================================================
-- Mino Chat — initial schema
-- Made by Lost Weeds (Abhinit) · X Hub
-- License: MIT
-- =====================================================================
-- This single migration creates the full schema + RLS + storage buckets
-- required to run the Mino Chat Flutter client end-to-end.
-- =====================================================================

create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ---------- USERS -----------------------------------------------------
create table if not exists public.users (
  id              uuid primary key references auth.users(id) on delete cascade,
  display_name    text not null default 'Mino user',
  email           text,
  phone           text,
  avatar_url      text,
  bio             text,
  status          text not null default 'offline', -- online | away | offline
  last_seen       timestamptz default now(),
  is_verified     boolean not null default false,
  fcm_token       text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
alter table public.users enable row level security;
create policy "users_read_all"  on public.users for select using (true);
create policy "users_update_self" on public.users for update using (auth.uid() = id);
create policy "users_insert_self" on public.users for insert with check (auth.uid() = id);

-- ---------- CHATS -----------------------------------------------------
create table if not exists public.chats (
  id                    uuid primary key default uuid_generate_v4(),
  type                  text not null default 'direct', -- direct | group | broadcast | channel | mesh
  title                 text not null default '',
  description           text,
  avatar_url            text,
  member_ids            uuid[] not null default '{}',
  admin_ids             uuid[] not null default '{}',
  last_message_id       uuid,
  last_message_preview  text,
  last_message_at       timestamptz,
  unread_count          int not null default 0,
  is_pinned             boolean not null default false,
  is_muted              boolean not null default false,
  is_archived           boolean not null default false,
  unread_by_user        jsonb not null default '{}'::jsonb,
  invite_code           text unique,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);
alter table public.chats enable row level security;
create policy "chats_member_read" on public.chats for select
  using (auth.uid() = any(member_ids));
create policy "chats_member_write" on public.chats for insert
  with check (auth.uid() = any(member_ids));
create policy "chats_member_update" on public.chats for update
  using (auth.uid() = any(member_ids));

-- ---------- MESSAGES --------------------------------------------------
create table if not exists public.messages (
  id                  uuid primary key default uuid_generate_v4(),
  chat_id             uuid not null references public.chats(id) on delete cascade,
  sender_id           uuid not null references public.users(id) on delete cascade,
  kind                text not null default 'text',
  text                text not null default '',
  attachment_url      text,
  attachment_name     text,
  attachment_size     int,
  attachment_mime     text,
  duration_sec        int,
  thumbnail_url       text,
  reply_to_id         uuid,
  reply_to_preview    text,
  forwarded_from_id   uuid,
  reactions           jsonb not null default '{}'::jsonb,
  read_by             uuid[] not null default '{}',
  delivered_to        uuid[] not null default '{}',
  status              text not null default 'sent',
  is_deleted          boolean not null default false,
  edited_at           timestamptz,
  metadata            jsonb,
  created_at          timestamptz not null default now()
);
create index if not exists idx_messages_chat_created on public.messages(chat_id, created_at desc);
alter table public.messages enable row level security;
create policy "msgs_read_in_member_chat" on public.messages for select
  using (exists (
    select 1 from public.chats c
    where c.id = messages.chat_id and auth.uid() = any(c.member_ids)
  ));
create policy "msgs_insert_self" on public.messages for insert
  with check (
    sender_id = auth.uid() and
    exists (
      select 1 from public.chats c
      where c.id = messages.chat_id and auth.uid() = any(c.member_ids)
    )
  );
create policy "msgs_update_self" on public.messages for update
  using (sender_id = auth.uid());

-- ---------- LIVE ROOMS ------------------------------------------------
create table if not exists public.live_rooms (
  id                uuid primary key default uuid_generate_v4(),
  title             text not null,
  description       text,
  host_id           uuid not null references public.users(id) on delete cascade,
  speaker_ids       uuid[] not null default '{}',
  audience_ids      uuid[] not null default '{}',
  raised_hand_ids   uuid[] not null default '{}',
  kind              text not null default 'audio', -- audio | video | screen
  is_recording      boolean not null default false,
  is_live           boolean not null default true,
  listener_count    int not null default 0,
  cover_url         text,
  invite_code       text unique,
  started_at        timestamptz not null default now(),
  ended_at          timestamptz
);
create index if not exists idx_live_live on public.live_rooms(is_live, started_at desc);
alter table public.live_rooms enable row level security;
create policy "live_read_all"   on public.live_rooms for select using (true);
create policy "live_insert_any" on public.live_rooms for insert with check (auth.uid() is not null);
create policy "live_update_host_or_self"
  on public.live_rooms for update using (
    host_id = auth.uid() or
    auth.uid() = any(speaker_ids) or
    auth.uid() = any(audience_ids)
  );

-- ---------- STORIES ---------------------------------------------------
create table if not exists public.stories (
  id              uuid primary key default uuid_generate_v4(),
  user_id         uuid not null references public.users(id) on delete cascade,
  kind            text not null default 'image', -- image | video | text
  media_url       text,
  text            text,
  background_color text,
  duration_sec    int not null default 5,
  viewed_by       uuid[] not null default '{}',
  reactions       jsonb not null default '{}'::jsonb,
  created_at      timestamptz not null default now(),
  expires_at      timestamptz not null default (now() + interval '24 hours')
);
create index if not exists idx_stories_active on public.stories(expires_at desc);
alter table public.stories enable row level security;
create policy "stories_read_all"    on public.stories for select using (expires_at > now());
create policy "stories_insert_self" on public.stories for insert with check (user_id = auth.uid());
create policy "stories_update_self" on public.stories for update using (user_id = auth.uid());

-- ---------- CHANNELS --------------------------------------------------
create table if not exists public.channels (
  id              uuid primary key default uuid_generate_v4(),
  name            text not null,
  handle          text unique,
  description     text,
  avatar_url      text,
  owner_id        uuid not null references public.users(id) on delete cascade,
  admin_ids       uuid[] not null default '{}',
  poster_ids      uuid[] not null default '{}',
  subscriber_count int not null default 0,
  is_verified     boolean not null default false,
  is_private      boolean not null default false,
  created_at      timestamptz not null default now()
);
alter table public.channels enable row level security;
create policy "channels_read_public" on public.channels for select using (not is_private);
create policy "channels_insert_self" on public.channels for insert with check (owner_id = auth.uid());
create policy "channels_update_owner" on public.channels for update using (owner_id = auth.uid());

-- ---------- STORAGE BUCKETS ------------------------------------------
insert into storage.buckets (id, name, public) values
  ('avatars',     'avatars',     true),
  ('attachments', 'attachments', true),
  ('voice_notes', 'voice_notes', true),
  ('stories',     'stories',     true),
  ('files',       'files',       true)
on conflict (id) do nothing;

-- Storage RLS — anyone can read (public buckets); only authenticated owner can write
create policy "avatars_read"   on storage.objects for select using (bucket_id = 'avatars');
create policy "avatars_write"  on storage.objects for insert with check (bucket_id = 'avatars'   and auth.role() = 'authenticated');
create policy "attach_read"    on storage.objects for select using (bucket_id = 'attachments');
create policy "attach_write"   on storage.objects for insert with check (bucket_id = 'attachments' and auth.role() = 'authenticated');
create policy "voice_read"     on storage.objects for select using (bucket_id = 'voice_notes');
create policy "voice_write"    on storage.objects for insert with check (bucket_id = 'voice_notes'  and auth.role() = 'authenticated');
create policy "stories_read"   on storage.objects for select using (bucket_id = 'stories');
create policy "stories_write"  on storage.objects for insert with check (bucket_id = 'stories'     and auth.role() = 'authenticated');
create policy "files_read"     on storage.objects for select using (bucket_id = 'files');
create policy "files_write"    on storage.objects for insert with check (bucket_id = 'files'       and auth.role() = 'authenticated');

-- ---------- RPC -------------------------------------------------------

-- find_or_create_direct_chat
create or replace function public.find_or_create_direct_chat(user_a uuid, user_b uuid)
returns public.chats as $$
declare
  existing public.chats;
  new_id uuid;
begin
  select * into existing from public.chats
    where type = 'direct'
      and user_a = any(member_ids)
      and user_b = any(member_ids)
    limit 1;
  if found then return existing; end if;
  new_id := uuid_generate_v4();
  insert into public.chats (id, type, title, member_ids, created_at, updated_at)
    values (new_id, 'direct', 'Direct', array[user_a, user_b], now(), now());
  return (select * from public.chats where id = new_id);
end;
$$ language plpgsql security definer;

-- mark_chat_read
create or replace function public.mark_chat_read(p_chat_id uuid, p_user_id uuid)
returns void as $$
begin
  update public.chats set unread_by_user = jsonb_set(unread_by_user, p_user_id::text, '0'::jsonb)
    where id = p_chat_id;
end;
$$ language plpgsql security definer;

-- react_to_message
create or replace function public.react_to_message(p_message_id uuid, p_user_id uuid, p_emoji text)
returns void as $$
declare
  current jsonb;
  users text;
begin
  select reactions into current from public.messages where id = p_message_id;
  users := coalesce(current->>p_emoji, '');
  if position(p_user_id::text in users) > 0 then
    users := btrim(regexp_replace(users, '(^|,)' || p_user_id::text || '(,|$)', ','), ',');
  else
    users := case when users = '' then p_user_id::text else users || ',' || p_user_id::text end;
  end if;
  if users = '' then
    update public.messages set reactions = current - p_emoji where id = p_message_id;
  else
    update public.messages set reactions = jsonb_set(current, p_emoji, to_jsonb(users)) where id = p_message_id;
  end if;
end;
$$ language plpgsql security definer;

-- ---------- TRIGGERS --------------------------------------------------
create or replace function public.touch_chat()
returns trigger as $$
begin
  update public.chats
    set updated_at = now(),
        last_message_id = new.id,
        last_message_preview = left(coalesce(new.text, new.attachment_name, ''), 80),
        last_message_at = new.created_at
    where id = new.chat_id;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_touch_chat on public.messages;
create trigger trg_touch_chat after insert on public.messages
  for each row execute function public.touch_chat();
