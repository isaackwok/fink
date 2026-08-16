---
name: supabase-data
description: This skill should be used when working with the permanent Supabase data layer — supabase/migrations/, RLS policies, column GRANTs, the username_available / claim_migrated_data RPCs, supabase_db_manager.dart's row translation, timestamp conversion (jiffyToUtcIso / pgTimestampToLocalNaive), debugging a 403 on insert/update, or adding a column to profiles/journals. Distinct from the transitional supabase-migration skill (the Firebase bridge runbook).
---

# Supabase data layer: schema, RLS, grants, and timestamps

Permanent Supabase behavior. The *transitional* Firebase→Supabase bridge is a different skill (`supabase-migration`).

## Schema, RLS, and grants

- `supabase/migrations/` — versioned schema (`profiles`, `journals`, `sync_tombstones`, `firebase_identity_map`), RLS on every table, tombstone triggers, and the `username_available` / `claim_migrated_data` RPCs. `supabase/tests/rls_smoke.sql` holds 63 pgTAP assertions; run with `supabase test db`.
- `supabase/functions/delete-account/` — deletes the caller's account server-side. The `auth.users` delete cascades to profiles and journals, so unlike the old client-side flow there is no window where data is gone but the account remains.
- **RLS scopes rows; GRANTs scope columns.** A policy like `journals_update_own` proves `auth.uid() = user_id` and says nothing about *which columns* the UPDATE touches — that is the GRANT's job, and `grant update on table` means all of them. `20260725071500_lock_migration_control_columns.sql` therefore replaces the blanket INSERT/UPDATE grants with **column allowlists that mirror `lib/supabase_db_manager.dart` exactly**. Consequences worth knowing before you debug a 403:
  - **Adding a column to `journalToRow()` (or the profiles writers) without adding it to that migration makes the write fail with 403**, not silently drop the column.
  - `user_id` *is* in the journals UPDATE allowlist — `journalToRow()` always sends it, even on edit. `WITH CHECK` is what stops it pointing at another user; the grant never was.
  - `created_at` is *not* in the journals UPDATE allowlist, so "an edit preserves `created_at`" is now a database guarantee rather than a client convention.
  - Ungranted to clients on both tables: `firestore_id`, `migrated_updated_at`, `raw`, `firebase_uid`, `journals.id`. These belong to the delta-sync. The reason is not tidiness: a client that could set its own `firestore_id` and then delete the row would make the `AFTER DELETE` trigger write a tombstone against **another user's** Firestore doc, and `import_data.ts` reads `sync_tombstones` as "deleted in the new app" and skips it for the rest of the window.
- **`alter default privileges … revoke execute on functions` does not work on Supabase Postgres 17.6** (measured; the table equivalent in `20260725033216` does). New functions still come out `proacl = NULL`, i.e. EXECUTE to PUBLIC, i.e. anon-callable. So **every new function in `public` needs an explicit `revoke execute … from public, anon`**. `rls_smoke.sql` enforces this: one assertion fails if any callable function is anon-executable, another pins the exact set callable by `authenticated`. Both name the offending function in the failure output.

## Timestamps

Journals store `Jiffy.toString()`, a **naive local** string with no zone. Postgres stores `timestamptz`, so the boundary must convert both ways, and `SupabaseDbManager` is the only place that happens:

- **Write**: `jiffyToUtcIso()` → absolute UTC. Never `jiffy.toString()` — Postgres would read that as UTC and shift every timestamp by 8 hours.
- **Read**: `pgTimestampToLocalNaive()` → local wall time. `JournalState.fromJson` feeds the value straight into `Jiffy.parse`, so handing it a UTC instant would render every journal 8 hours early. Pinned by `test/supabase_db_manager_test.dart`.

`JournalState` stays untouched — `toMap()`/`fromMap()` (with `fromJson` as a thin decode-then-`fromMap` wrapper) remain the serialization seam, and all snake_case ↔ camelCase translation happens in the manager layer. `rowToJournal` hands the row map straight to `fromMap` — no per-row `jsonEncode`/`jsonDecode` round trip.
