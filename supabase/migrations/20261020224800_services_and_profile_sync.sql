-- Perfil de la moto y servicios sincronizados. El correo y el rol admin
-- los fija el servidor; el cliente no puede cambiarlos.

alter table public.profiles
  add column if not exists email text,
  add column if not exists name text not null default '',
  add column if not exists bike_model text not null default '',
  add column if not exists bike_plate text not null default '',
  add column if not exists bike_year text not null default '',
  add column if not exists bike_vin text not null default '',
  add column if not exists profile_image text not null default '',
  add column if not exists updated_at timestamptz not null default now();

create or replace function public.protect_profile()
returns trigger
language plpgsql
security definer
set search_path to 'public', 'auth'
as $$
declare
  user_email text;
begin
  if tg_op = 'INSERT' then
    select email into user_email from auth.users where id = new.id;
    new.is_admin := user_email = 'admin@casaracing.com';
    new.email := user_email;
    return new;
  end if;
  new.is_admin := old.is_admin;
  new.email := old.email;
  return new;
end;
$$;

-- El token y la fecha de aceite no deben ganar un conflicto de perfil.
create or replace function public.touch_profile_content()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    new.updated_at := now();
    return new;
  end if;
  if new.name is distinct from old.name
     or new.bike_model is distinct from old.bike_model
     or new.bike_plate is distinct from old.bike_plate
     or new.bike_year is distinct from old.bike_year
     or new.bike_vin is distinct from old.bike_vin
     or new.profile_image is distinct from old.profile_image
     or new.email is distinct from old.email then
    new.updated_at := now();
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_touch_content on public.profiles;
create trigger profiles_touch_content
  before insert or update on public.profiles
  for each row execute function public.touch_profile_content();

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path to 'public'
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid() and is_admin
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

create table if not exists public.services (
  id uuid primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  type text not null,
  service_date text not null,
  mileage integer not null check (mileage >= 0),
  notes text not null default '',
  category text not null,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index if not exists services_user_id_idx on public.services (user_id);

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists services_touch on public.services;
create trigger services_touch
  before insert or update on public.services
  for each row execute function public.touch_updated_at();

alter table public.services enable row level security;

grant select, insert, update on public.services to authenticated;

drop policy if exists profiles_select_admin on public.profiles;
create policy profiles_select_admin
  on public.profiles
  for select
  using (public.is_admin());

drop policy if exists services_select on public.services;
create policy services_select
  on public.services
  for select
  using (user_id = auth.uid() or public.is_admin());

drop policy if exists services_insert on public.services;
create policy services_insert
  on public.services
  for insert
  with check (user_id = auth.uid());

drop policy if exists services_update on public.services;
create policy services_update
  on public.services
  for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
