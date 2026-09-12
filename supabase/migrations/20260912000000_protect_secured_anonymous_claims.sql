-- A retained Firebase token must never reclaim a secured Supabase account.
-- Keep the service-role-only grant and serialize the ownership/identity check.
-- Orphan cleanup is deferred: deleting auth users after commit races with linking.
create or replace function public.claim_anonymous_data(
  p_firebase_uid text,
  p_new_user_id uuid
)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare
  v_old_id uuid;
  v_moved int := 0;
begin
  if p_firebase_uid is null or p_new_user_id is null then
    raise exception 'firebase_uid and new_user_id are both required';
  end if;

  -- Idempotent: re-running after a dropped response must not error. The app
  -- retries on every cold start until it succeeds.
  if exists (select 1 from public.profiles where id = p_new_user_id) then
    return jsonb_build_object('status', 'already_claimed');
  end if;

  select id into v_old_id
  from public.profiles
  where firebase_uid = p_firebase_uid;

  if v_old_id is null then
    return jsonb_build_object('status', 'no_premigrated_profile');
  end if;

  -- Lock the auth row before inspecting identities. Linking needs a FK lock
  -- on it, so a concurrent link cannot slip between this check and the move.
  perform 1 from auth.users where id = v_old_id for update;
  -- Serialize repeated claims and re-check the owner after acquiring the lock.
  perform 1 from public.profiles
    where id = v_old_id and firebase_uid = p_firebase_uid for update;
  if not found then
    raise exception 'profile ownership changed; retry recovery';
  end if;
  if exists (select 1 from auth.identities where user_id = v_old_id
             and provider <> 'anonymous') then
    return jsonb_build_object('status', 'account_secured');
  end if;

  -- Move data atomically, preserving firebase_uid and avoiding tombstones.
  -- Leave the old auth row for cleanup that verifies it is still unsecured.
  update public.journals set user_id = p_new_user_id where user_id = v_old_id;
  get diagnostics v_moved = row_count;

  -- Keeps firebase_uid on the row, so the daily delta-sync continues to match
  -- this user's Firestore docs to their (now real) Supabase account.
  update public.profiles set id = p_new_user_id where id = v_old_id;

  return jsonb_build_object(
    'status', 'claimed',
    'journals_moved', v_moved
  );
end;
$$;

revoke execute on function public.claim_anonymous_data(text, uuid)
  from public, anon, authenticated;
grant execute on function public.claim_anonymous_data(text, uuid) to service_role;
