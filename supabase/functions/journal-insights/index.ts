// Computes the caller's "achievements" for one candidate film: per dimension
// (director / actor / country / genre / decade), how many DISTINCT films the
// user has journaled sharing that value with the candidate.
//
// Keyed on tmdb_id, not journal_id, so the result is identical whether the
// candidate journal row exists yet or not — the candidate id is unioned into
// every per-dimension set either way. That is what lets the client prefetch
// while the user is still writing.
//
// Facts come from the movie_facts cache table (service-role only); misses are
// fetched from TMDB and upserted so any film is fetched at most once, ever,
// across all users.

import { createClient } from "npm:@supabase/supabase-js@2";

// The plan flagged both of these names as "verify at deploy". Local Supabase
// injects the legacy SUPABASE_* names; projects created with the newer API key
// format may expose SB_PUBLISHABLE_KEY / SB_SECRET_KEY instead. Accept either
// rather than betting on one and failing at runtime with an opaque 500.
function requireEnv(...names: string[]): string {
  for (const n of names) {
    const v = Deno.env.get(n);
    if (v) return v;
  }
  throw new Error(`none of these env vars are set: ${names.join(", ")}`);
}

const SUPABASE_URL = requireEnv("SUPABASE_URL");
const PUBLISHABLE_KEY = requireEnv("SUPABASE_ANON_KEY", "SB_PUBLISHABLE_KEY");
const SECRET_KEY = requireEnv("SUPABASE_SERVICE_ROLE_KEY", "SB_SECRET_KEY");
const TMDB_TOKEN = requireEnv("TMDB_ACCESS_TOKEN");

interface Person {
  id: number;
  name: string;
}

interface MovieFacts {
  tmdb_id: number;
  directors: Person[];
  cast: Person[]; // top 10 by billing order
  genre_ids: number[];
  countries: string[]; // ISO 3166-1 alpha-2
  release_year: number | null;
}

export interface Achievement {
  kind: "director" | "actor" | "country" | "genre" | "decade";
  key: string; // stable: person id / genre id / ISO code / decade start year
  name: string; // display name for people; client localizes the rest from key
  count: number; // distinct films, candidate included
}

// ---------------------------------------------------------------- TMDB fetch

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

// Bounded-concurrency map: TMDB tolerates bursts, but a user with hundreds of
// journals should not open hundreds of sockets at once.
async function mapConcurrent<T, R>(
  items: T[],
  limit: number,
  fn: (item: T) => Promise<R>,
): Promise<R[]> {
  const results: R[] = new Array(items.length);
  let next = 0;
  async function worker() {
    while (next < items.length) {
      const i = next++;
      results[i] = await fn(items[i]);
    }
  }
  await Promise.all(
    Array.from({ length: Math.min(limit, items.length) }, worker),
  );
  return results;
}

// ------------------------------------------------------------- achievements

// Per-dimension index: value key -> { name, set of distinct tmdb ids }.
function buildIndex(
  films: MovieFacts[],
): Map<Achievement["kind"], Map<string, { name: string; films: Set<number> }>> {
  const index = new Map<
    Achievement["kind"],
    Map<string, { name: string; films: Set<number> }>
  >();
  const add = (
    kind: Achievement["kind"],
    key: string,
    name: string,
    tmdbId: number,
  ) => {
    let dim = index.get(kind);
    if (!dim) index.set(kind, dim = new Map());
    let entry = dim.get(key);
    if (!entry) dim.set(key, entry = { name, films: new Set() });
    entry.films.add(tmdbId);
  };

  for (const f of films) {
    for (const d of f.directors) add("director", String(d.id), d.name, f.tmdb_id);
    for (const c of f.cast) add("actor", String(c.id), c.name, f.tmdb_id);
    for (const iso of f.countries) add("country", iso, iso, f.tmdb_id);
    for (const g of f.genre_ids) add("genre", String(g), String(g), f.tmdb_id);
    if (f.release_year != null) {
      // Era buckets split at 2020: recent films count per YEAR (key = the
      // year, shown as "2024"), older films per DECADE (key = the decade
      // start, shown as "1990s"). Key ranges cannot collide: year keys are
      // always >= 2020, decade keys always <= 2010.
      const bucket = f.release_year >= 2020
        ? f.release_year
        : Math.floor(f.release_year / 10) * 10;
      add("decade", String(bucket), String(bucket), f.tmdb_id);
    }
  }
  return index;
}

const KIND_ORDER: Achievement["kind"][] = [
  "director",
  "actor",
  "decade",
  "country",
  "genre",
];

// Qualification + ordering. Indexing [candidate] alone yields exactly the
// candidate's own value set per dimension — through the same bucketing as the
// full index (notably the 2020 era split), so a value the candidate "has" is
// by construction a key the full index can count.
function computeAchievements(
  candidate: MovieFacts,
  index: ReturnType<typeof buildIndex>,
): Achievement[] {
  const out: Achievement[] = [];
  for (const [kind, candDim] of buildIndex([candidate])) {
    const dim = index.get(kind);
    if (!dim) continue;
    for (const [key, { name }] of candDim) {
      const count = dim.get(key)?.films.size ?? 0;
      // The candidate itself is in each set, so >= 2 means "at least one
      // OTHER distinct film shares this value".
      if (count >= 2) out.push({ kind, key, name, count });
    }
  }
  out.sort((a, b) =>
    KIND_ORDER.indexOf(a.kind) - KIND_ORDER.indexOf(b.kind) ||
    b.count - a.count ||
    // numeric:true keeps decade/genre keys in natural order ("9" < "12").
    a.name.localeCompare(b.name, undefined, { numeric: true })
  );
  return out;
}

// -------------------------------------------------------------------- serve

Deno.serve(async (req) => {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return new Response("Unauthorized", { status: 401 });

  const userClient = createClient(SUPABASE_URL, PUBLISHABLE_KEY, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: { user }, error } = await userClient.auth.getUser();
  if (error || !user) return new Response("Unauthorized", { status: 401 });

  let tmdbId: unknown;
  try {
    ({ tmdbId } = await req.json());
  } catch {
    return new Response("Bad Request", { status: 400 });
  }
  if (typeof tmdbId !== "number" || !Number.isInteger(tmdbId) || tmdbId <= 0) {
    return new Response("tmdbId must be a positive integer", { status: 400 });
  }

  // The user client reads journals, so RLS scopes the rows naturally — no
  // service role needed for this read.
  const { data: rows, error: selErr } = await userClient
    .from("journals")
    .select("tmdb_id");
  if (selErr) return new Response(selErr.message, { status: 500 });

  const ids = new Set<number>((rows ?? []).map((r) => r.tmdb_id));
  ids.add(tmdbId); // candidate unioned in — journal row may not exist yet

  const admin = createClient(SUPABASE_URL, SECRET_KEY);

  const { data: cached, error: cacheErr } = await admin
    .from("movie_facts")
    .select("tmdb_id, directors, cast, genre_ids, countries, release_year")
    .in("tmdb_id", [...ids]);
  if (cacheErr) return new Response(cacheErr.message, { status: 500 });

  const facts = new Map<number, MovieFacts>(
    (cached ?? []).map((f) => [f.tmdb_id, f as MovieFacts]),
  );

  const misses = [...ids].filter((id) => !facts.has(id));
  if (misses.length > 0) {
    const fetched = await mapConcurrent(misses, 8, async (id) => {
      // Per-id tolerance: a film that fails to fetch simply contributes
      // nothing this call; the next call retries it (it was never cached).
      try {
        return await fetchTmdbFacts(id);
      } catch (e) {
        console.warn(`TMDB fetch failed for ${id}:`, (e as Error).message);
        return null;
      }
    });
    const fresh = fetched.filter((f): f is MovieFacts => f !== null);
    for (const f of fresh) facts.set(f.tmdb_id, f);

    if (fresh.length > 0) {
      const { error: upErr } = await admin.from("movie_facts").upsert(fresh);
      // Non-fatal: the cache is an optimization, not the answer.
      if (upErr) console.error("movie_facts upsert failed:", upErr.message);
    }
  }

  const candidate = facts.get(tmdbId);
  // Candidate unfetchable -> no achievements (client hides the section).
  if (!candidate) return Response.json({ achievements: [] });

  const achievements = computeAchievements(candidate, buildIndex([...facts.values()]));
  return Response.json({ achievements });
});
