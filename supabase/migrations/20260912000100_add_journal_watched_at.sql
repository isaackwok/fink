-- A watch day is independent of immutable creation and modification timestamps.
-- NULL on legacy rows lets clients fall back to the local creation day without
-- guessing the user's timezone in a server-side backfill.
alter table public.journals add column watched_at date;

grant insert (watched_at) on public.journals to authenticated;
grant update (watched_at) on public.journals to authenticated;
