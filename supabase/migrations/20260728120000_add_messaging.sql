-- Guest messaging: threads and messages, stored per property.
--
-- Bookings are proxied live and nothing is kept. Messaging cannot work that
-- way: read state, snoozing, archiving and (once a source opens it up)
-- outgoing messages are *our* state, and one GET per thread per render blows
-- through the source's rate limits at forty threads. So the console keeps its
-- own copy, refreshed by the `messaging-sync` Edge Function.
--
-- `unique (source, source_thread_id)` is the whole idempotency story: syncing
-- again upserts, it never duplicates. Drafts deliberately do NOT live in
-- `messages` — they stay in the cubit until they are sent, the same model the
-- website editor uses for an unsaved draft.

-- ---------------------------------------------------------------------------
-- 1. Which account a property belongs to
-- ---------------------------------------------------------------------------

-- The messaging tables hang off properties, and their policies need the
-- account behind a property id. One function, so the two policies below cannot
-- drift apart from each other or from public.has_account_access.
create or replace function public.property_account_owner(check_property_id integer)
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select owner_profile_id from public.properties where id = check_property_id;
$$;

alter function public.property_account_owner(integer) owner to postgres;

-- Supabase grants every new function in `public` to anon and authenticated, and
-- `REVOKE ... FROM PUBLIC` does not undo that (see
-- 20260728140000_lock_down_security_definer_grants.sql). This one is SECURITY
-- DEFINER and returns *data* — which account a property belongs to — so anon
-- must not reach it. The policies below are `TO authenticated`, so anon never
-- evaluates them either.
revoke all on function public.property_account_owner(integer) from public, anon;
grant execute on function public.property_account_owner(integer)
  to authenticated;

-- ---------------------------------------------------------------------------
-- 2. Tables
-- ---------------------------------------------------------------------------

create table if not exists public.message_threads (
  id uuid primary key default gen_random_uuid(),
  property_id integer not null
    references public.properties(id) on delete cascade,
  -- Which messaging source this came from ('lodgify'). Not the channel: one
  -- Lodgify account delivers Airbnb, Booking.com and direct conversations.
  source text not null,
  source_thread_id text not null,
  channel text not null default 'other',
  reservation_id text,
  guest_name text,
  guest_locale text,
  last_message_at timestamptz,
  last_message_preview text,
  -- Derived at sync time from the direction of the last message, never a flag
  -- someone has to maintain.
  awaiting_host boolean not null default false,
  -- Our read state, not the source's: Lodgify's public API cannot set or read
  -- one, so this column is the only place "read" exists.
  read_at timestamptz,
  snoozed_until timestamptz,
  archived_at timestamptz,
  raw jsonb not null default '{}'::jsonb,
  synced_at timestamptz,
  created_at timestamptz not null default now(),
  constraint message_threads_source_thread_unique unique (source, source_thread_id)
);

create index if not exists idx_message_threads_property
  on public.message_threads(property_id);
create index if not exists idx_message_threads_last_message_at
  on public.message_threads(last_message_at desc nulls last);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null
    references public.message_threads(id) on delete cascade,
  -- Null for anything the console produced itself; a source message always
  -- carries its id so a re-sync updates rather than appends.
  source_message_id text,
  direction text not null check (direction in ('inbound', 'outbound')),
  body text not null,
  sent_at timestamptz not null,
  author_name text,
  delivery_state text not null default 'sent'
    check (delivery_state in ('pending', 'sent', 'failed')),
  raw jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint messages_source_message_unique unique (thread_id, source_message_id)
);

create index if not exists idx_messages_thread_sent_at
  on public.messages(thread_id, sent_at);

-- ---------------------------------------------------------------------------
-- 3. RLS
-- ---------------------------------------------------------------------------

-- Same access model as public.properties: the whole account team reads, editors
-- and up write. The sync itself runs as service_role and is RLS-exempt.

alter table public.message_threads enable row level security;
alter table public.messages enable row level security;

drop policy if exists "Account can read threads" on public.message_threads;
create policy "Account can read threads" on public.message_threads
  for select to authenticated
  using (
    public.has_account_access(
      public.property_account_owner(property_id), auth.uid()
    )
  );

drop policy if exists "Account editors manage threads" on public.message_threads;
create policy "Account editors manage threads" on public.message_threads
  for all to authenticated
  using (
    public.has_account_access(
      public.property_account_owner(property_id),
      auth.uid(),
      'editor'::public.site_member_role
    )
  )
  with check (
    public.has_account_access(
      public.property_account_owner(property_id),
      auth.uid(),
      'editor'::public.site_member_role
    )
  );

drop policy if exists "Account can read messages" on public.messages;
create policy "Account can read messages" on public.messages
  for select to authenticated
  using (
    exists (
      select 1
        from public.message_threads t
       where t.id = thread_id
         and public.has_account_access(
               public.property_account_owner(t.property_id), auth.uid()
             )
    )
  );

drop policy if exists "Account editors manage messages" on public.messages;
create policy "Account editors manage messages" on public.messages
  for all to authenticated
  using (
    exists (
      select 1
        from public.message_threads t
       where t.id = thread_id
         and public.has_account_access(
               public.property_account_owner(t.property_id),
               auth.uid(),
               'editor'::public.site_member_role
             )
    )
  )
  with check (
    exists (
      select 1
        from public.message_threads t
       where t.id = thread_id
         and public.has_account_access(
               public.property_account_owner(t.property_id),
               auth.uid(),
               'editor'::public.site_member_role
             )
    )
  );

-- Guest conversations are never public: the website worker reads cms_* and
-- site_* only.
revoke all on table public.message_threads from anon;
revoke all on table public.messages from anon;
grant select, insert, update, delete
  on table public.message_threads, public.messages to authenticated;
