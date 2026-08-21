-- movie_facts: server-side cache of the TMDB facts the journal-insights Edge
-- Function needs (directors, top-billed cast, genres, countries, release year).
-- Written only by the service role; clients never read it. Without this cache
-- every insights invocation would re-fan-out one TMDB call per distinct film
-- the user has journaled. Once any user journals a film it is cached for
-- everyone, forever (fields are near-immutable for released films; fetched_at
-- enables a refresh policy later if that ever stops being true).

create table public.movie_facts (
  tmdb_id      integer primary key,
  directors    jsonb not null default '[]'::jsonb,  -- [{id, name}]
  "cast"       jsonb not null default '[]'::jsonb,  -- top 10 by billing order, [{id, name}]
  genre_ids    integer[] not null default '{}',
  countries    text[] not null default '{}',        -- ISO 3166-1 alpha-2
  release_year integer,
  fetched_at   timestamptz not null default now()
);

-- sync_tombstones pattern: RLS enabled, zero policies, zero client grants.
-- The Edge Function's admin client (service role) bypasses RLS; nothing else
-- can touch the table at all.
alter table public.movie_facts enable row level security;

-- The hardened default ACL (20260725033216) means a new table carries NO
-- grants for anyone — including service_role, which bypasses RLS but not
-- table privileges. The Edge Function reads the cache and upserts misses.
grant select, insert, update on public.movie_facts to service_role;
