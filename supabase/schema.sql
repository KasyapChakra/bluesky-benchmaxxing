-- Bluesky Benchmaxxing — run once in the Supabase SQL editor of the gaze
-- project (vsqdeouzqonizokktdyb). Creates only benchmaxxing_* objects.
-- Anyone can read, submit and remove entries; there is no submit code.

create table if not exists public.benchmaxxing_scores (
  id             bigint generated always as identity primary key,
  created_at     timestamptz not null default now(),
  model_title    text not null,
  description    text not null default '',
  likes_loss     double precision not null check (likes_loss >= 0),
  followers_loss double precision not null check (followers_loss >= 0),
  submitted_by   text
);

alter table public.benchmaxxing_scores enable row level security;

drop policy if exists "benchmaxxing public read" on public.benchmaxxing_scores;
create policy "benchmaxxing public read"
  on public.benchmaxxing_scores for select
  to anon, authenticated
  using (true);
-- Writes go through the functions below so the validation always runs.

-- remove the earlier code-checking versions, if present
drop function if exists public.benchmaxxing_submit(text, text, text, double precision, double precision, text);
drop function if exists public.benchmaxxing_delete(text, bigint);
drop table if exists public.benchmaxxing_secrets;

create or replace function public.benchmaxxing_submit(
  p_model_title    text,
  p_description    text,
  p_likes_loss     double precision,
  p_followers_loss double precision,
  p_submitted_by   text default null
) returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id bigint;
begin
  if p_model_title is null or length(trim(p_model_title)) = 0 then
    raise exception 'model title is required';
  end if;
  if p_likes_loss is null or p_likes_loss < 0 or p_followers_loss is null or p_followers_loss < 0 then
    raise exception 'both losses must be numbers >= 0';
  end if;
  insert into public.benchmaxxing_scores (model_title, description, likes_loss, followers_loss, submitted_by)
  values (trim(p_model_title), coalesce(p_description, ''), p_likes_loss, p_followers_loss, nullif(trim(coalesce(p_submitted_by, '')), ''))
  returning id into v_id;
  return v_id;
end
$$;

create or replace function public.benchmaxxing_delete(p_id bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.benchmaxxing_scores where id = p_id;
end
$$;

revoke all on function public.benchmaxxing_submit(text, text, double precision, double precision, text) from public;
revoke all on function public.benchmaxxing_delete(bigint) from public;
grant execute on function public.benchmaxxing_submit(text, text, double precision, double precision, text) to anon, authenticated;
grant execute on function public.benchmaxxing_delete(bigint) to anon, authenticated;
