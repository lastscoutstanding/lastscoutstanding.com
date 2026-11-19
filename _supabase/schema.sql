-- Database for the reunion site (reunie25/). Run once in the Supabase SQL editor.
-- Safe to run again: it only creates what is missing and replaces functions/policies.
--
-- Security model:
--   * Every visitor uses the public (publishable/anon) key; what they can do is decided
--     here by row level security, not by the website.
--   * A participant can read, change and delete only their own row.
--   * Visitors see other participants only through publieke_deelnemers(), which returns
--     null for every field the person chose to hide. E-mail addresses never leave the database.
--   * Comité members (table beheerders) get extra rights via is_beheerder().
--   * A beheerder with rol 'hoofdbeheerder' can also add and remove ordinary beheerders
--     on the site. Hoofdbeheerders themselves are only set here, in the SQL editor.
-- This folder starts with "_", so GitHub Pages does not publish it.

-- ---------------------------------------------------------------- tables

create table if not exists public.deelnemers (
  id              uuid primary key references auth.users (id) on delete cascade,
  email           text not null,
  voornaam        text not null check (char_length(voornaam) between 1 and 60),
  achternaam      text not null default '' check (char_length(achternaam) <= 80),
  bijnaam         text not null default '' check (char_length(bijnaam) <= 40),
  geboortejaar    int  not null check (geboortejaar between 1930 and 2030),
  -- [{ "speltak": "Welpen", "rol": "lid" | "leiding", "van": 2003, "tot": 2006 | null }]
  takken          jsonb not null default '[]' check (jsonb_typeof(takken) = 'array' and jsonb_array_length(takken) <= 30),
  toon_voornaam   boolean not null default true,
  toon_achternaam boolean not null default false,
  toon_bijnaam    boolean not null default true,
  toon_leeftijd   boolean not null default true,
  toon_takken     boolean not null default true,
  sinds           date not null default current_date,
  aangemaakt      timestamptz not null default now(),
  bijgewerkt      timestamptz not null default now()
);

-- Columns added after the first version (no-ops on a fresh install).
alter table public.deelnemers add column if not exists bijnaam text not null default '' check (char_length(bijnaam) <= 40);
alter table public.deelnemers add column if not exists toon_bijnaam boolean not null default true;
-- Date the comité saw the payment; null = not paid yet. Only comité members can change it.
alter table public.deelnemers add column if not exists betaald_op date;

-- E-mail addresses of comité members. No policies: not readable through the API at all.
create table if not exists public.beheerders (
  email text primary key
);
alter table public.beheerders add column if not exists rol text not null default 'beheerder'
  check (rol in ('beheerder', 'hoofdbeheerder'));
alter table public.beheerders add column if not exists toegevoegd_door text;  -- null = via the SQL editor
alter table public.beheerders add column if not exists toegevoegd_op date not null default current_date;

alter table public.deelnemers enable row level security;
alter table public.beheerders enable row level security;

-- ---------------------------------------------------------------- helpers

create or replace function public.is_beheerder()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (select 1 from beheerders where lower(email) = lower(auth.jwt() ->> 'email'));
$$;

-- Role of the logged-in user: 'beheerder', 'hoofdbeheerder' or null.
create or replace function public.mijn_rol()
returns text
language sql stable security definer set search_path = public
as $$
  select rol from beheerders where lower(email) = lower(auth.jwt() ->> 'email') limit 1;
$$;

create or replace function public.is_hoofdbeheerder()
returns boolean
language sql stable security definer set search_path = public
as $$ select coalesce(public.mijn_rol() = 'hoofdbeheerder', false); $$;

-- Keep email in sync with the login and stamp updates; the client cannot change them.
create or replace function public.deelnemers_stempel()
returns trigger
language plpgsql security definer set search_path = public
as $$
declare
  betaald date := new.betaald_op;
begin
  -- No login: SQL editor or table editor in the Supabase dashboard. Trusted, leave as is.
  if auth.uid() is null then return new; end if;
  -- Someone else's row: only zet_betaald() (comité) gets here. Change nothing but betaald_op.
  if tg_op = 'UPDATE' and old.id <> auth.uid() then
    new := old;
    new.betaald_op := betaald;
    new.bijgewerkt := now();
    return new;
  end if;
  new.email := auth.jwt() ->> 'email';
  new.bijgewerkt := now();
  if tg_op = 'UPDATE' then
    new.id := old.id; new.sinds := old.sinds; new.aangemaakt := old.aangemaakt;
    if not public.is_beheerder() then new.betaald_op := old.betaald_op; end if;
  else
    new.sinds := current_date; new.aangemaakt := now();
    new.betaald_op := null;
  end if;
  return new;
end;
$$;

drop trigger if exists deelnemers_stempel on public.deelnemers;
create trigger deelnemers_stempel before insert or update on public.deelnemers
  for each row execute function public.deelnemers_stempel();

-- ---------------------------------------------------------------- row level security

drop policy if exists "eigen rij of comite lezen" on public.deelnemers;
create policy "eigen rij of comite lezen" on public.deelnemers
  for select to authenticated using (id = auth.uid() or public.is_beheerder());

drop policy if exists "eigen rij maken" on public.deelnemers;
create policy "eigen rij maken" on public.deelnemers
  for insert to authenticated with check (id = auth.uid());

drop policy if exists "eigen rij wijzigen" on public.deelnemers;
create policy "eigen rij wijzigen" on public.deelnemers
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "eigen rij of comite verwijderen" on public.deelnemers;
create policy "eigen rij of comite verwijderen" on public.deelnemers
  for delete to authenticated using (id = auth.uid() or public.is_beheerder());

-- ---------------------------------------------------------------- public functions

-- Everyone who shows at least something, with hidden fields as null. Oldest first.
-- Dropped first because the returned columns changed (bijnaam); grants are set again below.
drop function if exists public.publieke_deelnemers();
create function public.publieke_deelnemers()
returns table (voornaam text, achternaam text, bijnaam text, geboortejaar int, takken jsonb)
language sql stable security definer set search_path = public
as $$
  select case when toon_voornaam then voornaam end,
         case when toon_achternaam and achternaam <> '' then achternaam end,
         case when toon_bijnaam and bijnaam <> '' then bijnaam end,
         case when toon_leeftijd then geboortejaar end,
         case when toon_takken and jsonb_array_length(takken) > 0 then takken end
  from deelnemers
  where toon_voornaam or (toon_achternaam and achternaam <> '') or (toon_bijnaam and bijnaam <> '') or toon_leeftijd
     or (toon_takken and jsonb_array_length(takken) > 0)
  order by aangemaakt;
$$;

create or replace function public.aantal_deelnemers()
returns int
language sql stable security definer set search_path = public
as $$ select count(*)::int from deelnemers; $$;

-- Unsubscribe: removes the login itself; the deelnemers row goes with it (on delete cascade).
create or replace function public.verwijder_mij()
returns void
language sql security definer set search_path = public
as $$ delete from auth.users where id = auth.uid(); $$;

-- Comité: mark a registration as paid (today) or not paid. Returns the new date or null.
create or replace function public.zet_betaald(deelnemer uuid, betaald boolean)
returns date
language plpgsql security definer set search_path = public
as $$
declare
  datum date;
begin
  if not is_beheerder() then raise exception 'alleen voor het comité' using errcode = '42501'; end if;
  update deelnemers set betaald_op = case when betaald then coalesce(betaald_op, current_date) end
    where id = deelnemer returning betaald_op into datum;
  return datum;
end;
$$;

-- Comité: list of comité members, with the name if they registered for the reunion.
create or replace function public.comite()
returns table (email text, rol text, toegevoegd_door text, toegevoegd_op date, naam text)
language plpgsql stable security definer set search_path = public
as $$
#variable_conflict use_column
begin
  if not is_beheerder() then raise exception 'alleen voor het comité' using errcode = '42501'; end if;
  return query
    select b.email, b.rol, b.toegevoegd_door, b.toegevoegd_op,
           (select nullif(trim(d.voornaam || ' ' || d.achternaam), '') from deelnemers d
             where lower(d.email) = lower(b.email) limit 1)
    from beheerders b
    order by b.rol desc, b.toegevoegd_op, b.email;
end;
$$;

-- Hoofdbeheerder: add an ordinary beheerder. Does nothing if the address is already in the list.
create or replace function public.comite_toevoegen(adres text)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  a text := lower(trim(adres));
begin
  if not is_hoofdbeheerder() then raise exception 'alleen voor hoofdbeheerders' using errcode = '42501'; end if;
  if a !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' then raise exception 'ongeldig e-mailadres' using errcode = '22023'; end if;
  if exists (select 1 from beheerders where lower(email) = a) then return; end if;
  insert into beheerders (email, rol, toegevoegd_door)
    values (a, 'beheerder', coalesce((select nullif(trim(voornaam), '') from deelnemers where id = auth.uid()),
                                     auth.jwt() ->> 'email'));
end;
$$;

-- Hoofdbeheerder: remove an ordinary beheerder. Hoofdbeheerders can only be removed in the SQL editor.
create or replace function public.comite_weghalen(adres text)
returns void
language plpgsql security definer set search_path = public
as $$
begin
  if not is_hoofdbeheerder() then raise exception 'alleen voor hoofdbeheerders' using errcode = '42501'; end if;
  delete from beheerders where lower(email) = lower(trim(adres)) and rol = 'beheerder';
end;
$$;

-- Login page: comité members may log in without a registration, so their login is created
-- on first use. Tells only whether an address is on the comité list.
create or replace function public.is_comite_adres(adres text)
returns boolean
language sql stable security definer set search_path = public
as $$ select exists (select 1 from beheerders where lower(email) = lower(trim(adres))); $$;

-- Supabase grants new functions to anon and authenticated by default: take that away
-- first, then grant only what each role needs.
revoke all on function public.publieke_deelnemers() from public, anon, authenticated;
revoke all on function public.aantal_deelnemers() from public, anon, authenticated;
revoke all on function public.verwijder_mij() from public, anon, authenticated;
revoke all on function public.is_beheerder() from public, anon, authenticated;
revoke all on function public.deelnemers_stempel() from public, anon, authenticated;
revoke all on function public.zet_betaald(uuid, boolean) from public, anon, authenticated;
revoke all on function public.mijn_rol() from public, anon, authenticated;
revoke all on function public.is_hoofdbeheerder() from public, anon, authenticated;
revoke all on function public.comite() from public, anon, authenticated;
revoke all on function public.comite_toevoegen(text) from public, anon, authenticated;
revoke all on function public.comite_weghalen(text) from public, anon, authenticated;
revoke all on function public.is_comite_adres(text) from public, anon, authenticated;
grant execute on function public.publieke_deelnemers() to anon, authenticated;
grant execute on function public.aantal_deelnemers() to anon, authenticated;
grant execute on function public.verwijder_mij() to authenticated;
grant execute on function public.is_beheerder() to authenticated;
grant execute on function public.zet_betaald(uuid, boolean) to authenticated;
grant execute on function public.mijn_rol() to authenticated;
grant execute on function public.is_hoofdbeheerder() to authenticated;
grant execute on function public.comite() to authenticated;
grant execute on function public.comite_toevoegen(text) to authenticated;
grant execute on function public.comite_weghalen(text) to authenticated;
grant execute on function public.is_comite_adres(text) to anon, authenticated;

-- Comité members: hoofdbeheerders add ordinary beheerders on the site (Beheer > Comité).
-- Hoofdbeheerders are set here only:
-- insert into public.beheerders (email, rol) values ('naam@example.com', 'hoofdbeheerder')
--   on conflict (email) do update set rol = 'hoofdbeheerder';
-- Removing one: delete from public.beheerders where email = 'naam@example.com';
