alter table public.journals
  add column rating smallint not null default 0,
  add constraint journals_rating_range check (rating between 0 and 10);

-- Journal writes use column-level allowlists. New columns are not writable
-- until explicitly added here, even though the row-level policy permits them.
grant insert (rating) on public.journals to authenticated;
grant update (rating) on public.journals to authenticated;
