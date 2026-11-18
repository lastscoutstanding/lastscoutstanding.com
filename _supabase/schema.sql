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
-- This folder starts with "_", so GitHub Pages does not publish it.

-- ---------------------------------------------------------------- tables

create table if not exists public.deelnemers (
  id              uuid primary key references auth.users (id) on delete cascade,
  email           text not null,
  voornaam        text not null check (char_length(voornaam) between 1 and 60),
  achternaam      text not null default '' check (char_length(achternaam) <= 80),
  geboortejaar    int  not null check (geboortejaar between 1930 and 2030),
  -- [{ "speltak": "Welpen", "rol": "lid" | "leiding", "van": 2003, "tot": 2006 | null }]
  takken          jsonb not null default '[]' check (jsonb_typeof(takken) = 'array' and jsonb_array_length(takken) <= 30),
  toon_voornaam   boolean not null default true,
  toon_achternaam boolean not null default false,
  toon_leeftijd   boolean not null default true,
  toon_takken     boolean not null default true,
  sinds           date not null default current_date,
  aangemaakt      timestamptz not null default now(),
  bijgewerkt      timestamptz not null default now()
);

-- E-mail addresses of comité members. No policies: not readable through the API at all.
create table if not exists public.beheerders (
  email text primary key
);

alter table public.deelnemers enable row level security;
alter table public.beheerders enable row level security;

-- ---------------------------------------------------------------- helpers

create or replace function public.is_beheerder()
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (select 1 from beheerders where lower(email) = lower(auth.jwt() ->> 'email'));
$$;

-- Keep email in sync with the login and stamp updates; the client cannot change them.
create or replace function public.deelnemers_stempel()
returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  new.email := auth.jwt() ->> 'email';
  new.bijgewerkt := now();
  if tg_op = 'UPDATE' then
    new.id := old.id; new.sinds := old.sinds; new.aangemaakt := old.aangemaakt;
  else
    new.sinds := current_date; new.aangemaakt := now();
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
create or replace function public.publieke_deelnemers()
returns table (voornaam text, achternaam text, geboortejaar int, takken jsonb)
language sql stable security definer set search_path = public
as $$
  select case when toon_voornaam then voornaam end,
         case when toon_achternaam and achternaam <> '' then achternaam end,
         case when toon_leeftijd then geboortejaar end,
         case when toon_takken and jsonb_array_length(takken) > 0 then takken end
  from deelnemers
  where toon_voornaam or (toon_achternaam and achternaam <> '') or toon_leeftijd
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

-- Supabase grants new functions to anon and authenticated by default: take that away
-- first, then grant only what each role needs.
revoke all on function public.publieke_deelnemers() from public, anon, authenticated;
revoke all on function public.aantal_deelnemers() from public, anon, authenticated;
revoke all on function public.verwijder_mij() from public, anon, authenticated;
revoke all on function public.is_beheerder() from public, anon, authenticated;
revoke all on function public.deelnemers_stempel() from public, anon, authenticated;
grant execute on function public.publieke_deelnemers() to anon, authenticated;
grant execute on function public.aantal_deelnemers() to anon, authenticated;
grant execute on function public.verwijder_mij() to authenticated;
grant execute on function public.is_beheerder() to authenticated;

-- Comité members (add or remove later with insert/delete):
-- insert into public.beheerders (email) values ('naam@example.com');
