-- SKY CHAT database schema
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'SKY Member',
  avatar_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.rooms (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 60),
  topic text not null default '',
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.room_messages (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 1000),
  created_at timestamptz not null default now()
);

-- Admin roles are deliberately separate; clients cannot grant themselves admin.
create table if not exists public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('admin','moderator'))
);

alter table public.profiles enable row level security;
alter table public.rooms enable row level security;
alter table public.room_messages enable row level security;
alter table public.user_roles enable row level security;

create policy "profiles readable by signed-in users" on public.profiles
for select to authenticated using (true);
create policy "users create own profile" on public.profiles
for insert to authenticated with check (auth.uid() = id);
create policy "users update own profile" on public.profiles
for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

create policy "signed-in users read rooms" on public.rooms
for select to authenticated using (true);
create policy "users create rooms as themselves" on public.rooms
for insert to authenticated with check (auth.uid() = created_by);
create policy "room host updates room" on public.rooms
for update to authenticated using (auth.uid() = created_by) with check (auth.uid() = created_by);
create policy "room host deletes room" on public.rooms
for delete to authenticated using (auth.uid() = created_by);

create policy "signed-in users read room messages" on public.room_messages
for select to authenticated using (true);
create policy "users send messages as themselves" on public.room_messages
for insert to authenticated with check (auth.uid() = user_id);

create policy "users can read own role" on public.user_roles
for select to authenticated using (auth.uid() = user_id);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles(id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'display_name','SKY Member'))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Enable Supabase Realtime for room messages.
alter publication supabase_realtime add table public.room_messages;
