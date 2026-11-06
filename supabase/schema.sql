-- Kansai Travel Journal: one-owner / public-read-only
-- Run this entire script in Supabase SQL Editor.
create table if not exists public.trip_state (
  id boolean primary key default true check (id = true),
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.trip_state enable row level security;

grant select on public.trip_state to anon, authenticated;
grant insert, update on public.trip_state to authenticated;

drop policy if exists "Anyone can view trip" on public.trip_state;
create policy "Anyone can view trip"
on public.trip_state for select
to anon, authenticated
using (true);

drop policy if exists "Owner can insert trip" on public.trip_state;
create policy "Owner can insert trip"
on public.trip_state for insert
to authenticated
with check (auth.uid() = '1e651fd0-6631-492d-abdb-b41fa1cd4abc'::uuid);

drop policy if exists "Owner can update trip" on public.trip_state;
create policy "Owner can update trip"
on public.trip_state for update
to authenticated
using (auth.uid() = '1e651fd0-6631-492d-abdb-b41fa1cd4abc'::uuid)
with check (auth.uid() = '1e651fd0-6631-492d-abdb-b41fa1cd4abc'::uuid);

drop policy if exists "Owner can delete trip" on public.trip_state;
create policy "Owner can delete trip"
on public.trip_state for delete
to authenticated
using (auth.uid() = '1e651fd0-6631-492d-abdb-b41fa1cd4abc'::uuid);

create or replace function public.set_trip_state_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trip_state_updated_at on public.trip_state;
create trigger trip_state_updated_at
before update on public.trip_state
for each row execute function public.set_trip_state_updated_at();

insert into public.trip_state (id, data)
values (true, '{}'::jsonb)
on conflict (id) do nothing;
