// One-time movie_facts warmer: pre-fetches TMDB facts for every film already
// journaled, so existing users' first post-update journal doesn't pay a big
// first-call TMDB fan-out inside journal-insights.
//
// Defense in depth, not a dependency: the Edge Function's lazy miss-fill is
// the correctness guarantee. Idempotent — already-cached ids are skipped, so
// re-running after a partial failure only fetches what's still missing.
//
// Run (after the migration + function deploy, before announcing the update):
//   SUPABASE_URL=https://<ref>.supabase.co \
//   SB_SECRET_KEY=<service-role-or-secret-key> \
//   TMDB_ACCESS_TOKEN=<v4 bearer> \
//   deno run --allow-net --allow-env scripts/warm_movie_facts.ts

import { createClient } from "npm:@supabase/supabase-js@2";

function requireEnv(...names: string[]): string {
  for (const n of names) {
    const v = Deno.env.get(n);
    if (v) return v;
  }
  throw new Error(`none of these env vars are set: ${names.join(", ")}`);
}

const SUPABASE_URL = requireEnv("SUPABASE_URL");
const SECRET_KEY = requireEnv("SB_SECRET_KEY", "SUPABASE_SERVICE_ROLE_KEY");
const TMDB_TOKEN = requireEnv("TMDB_ACCESS_TOKEN");

interface Person {
  id: number;
  name: string;
}

interface MovieFacts {
  tmdb_id: number;
  directors: Person[];
  cast: Person[];
  genre_ids: number[];
  countries: string[];
  release_year: number | null;
}

// Same shape the journal-insights function fetches and caches (kept in sync
// by hand — the function's lazy fill would paper over any drift anyway).
async function fetchTmdbFacts(tmdbId: number): Promise<MovieFacts | null> {
  const res = await fetch(
    `https://api.themoviedb.org/3/movie/${tmdbId}?append_to_response=credits`,
    { headers: { Authorization: `Bearer ${TMDB_TOKEN}` } },
  );
  if (!res.ok) return null;
  // deno-lint-ignore no-explicit-any
  const m: any = await res.json();

  const directors: Person[] = (m.credits?.crew ?? [])
    .filter((c: { job?: string }) => c.job === "Director")
    .map((c: { id: number; name: string }) => ({ id: c.id, name: c.name }));

  const cast: Person[] = (m.credits?.cast ?? [])
    .slice()
    .sort(
      (a: { order?: number }, b: { order?: number }) =>
        (a.order ?? 999) - (b.order ?? 999),
    )
    .slice(0, 10)
    .map((c: { id: number; name: string }) => ({ id: c.id, name: c.name }));

  const origin: string[] = m.origin_country ?? [];
  const countries: string[] = origin.length > 0
    ? origin
    : (m.production_countries ?? []).map(
      (c: { iso_3166_1: string }) => c.iso_3166_1,
    );

  const yearMatch = /^(\d{4})/.exec(m.release_date ?? "");
  const release_year = yearMatch ? parseInt(yearMatch[1], 10) : null;

  return {
    tmdb_id: tmdbId,
    directors,
    cast,
    genre_ids: (m.genres ?? []).map((g: { id: number }) => g.id),
    countries,
    release_year,
  };
}

const admin = createClient(SUPABASE_URL, SECRET_KEY);

const { data: journalRows, error: jErr } = await admin
  .from("journals")
  .select("tmdb_id");
if (jErr) throw new Error(`journals read failed: ${jErr.message}`);

const allIds = [...new Set((journalRows ?? []).map((r) => r.tmdb_id))];

const { data: cachedRows, error: cErr } = await admin
  .from("movie_facts")
  .select("tmdb_id")
  .in("tmdb_id", allIds);
if (cErr) throw new Error(`movie_facts read failed: ${cErr.message}`);

const cached = new Set((cachedRows ?? []).map((r) => r.tmdb_id));
const misses = allIds.filter((id) => !cached.has(id));
console.log(
  `${allIds.length} distinct films journaled, ${cached.size} cached, ${misses.length} to fetch`,
);

let fetched = 0;
let failed = 0;
let next = 0;
async function worker() {
  while (next < misses.length) {
    const id = misses[next++];
    try {
      const facts = await fetchTmdbFacts(id);
      if (!facts) {
        failed++;
        console.warn(`tmdb ${id}: fetch returned not-ok, skipped`);
        continue;
      }
      const { error } = await admin.from("movie_facts").upsert(facts);
      if (error) {
        failed++;
        console.warn(`tmdb ${id}: upsert failed: ${error.message}`);
      } else {
        fetched++;
      }
    } catch (e) {
      failed++;
      console.warn(`tmdb ${id}: ${(e as Error).message}`);
    }
  }
}
await Promise.all(Array.from({ length: Math.min(8, misses.length) }, worker));

console.log(`done: ${fetched} cached, ${failed} failed (re-run to retry)`);
if (failed > 0) Deno.exit(1);
