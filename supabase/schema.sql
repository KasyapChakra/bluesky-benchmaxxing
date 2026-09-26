-- Bluesky Benchmaxxing — run this once in the Supabase SQL editor of the
-- gaze project (vsqdeouzqonizokktdyb). It only creates new objects with the
-- prefix benchmaxxing_; it touches nothing else.

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
-- No insert/update/delete policies on purpose: writes go through the
-- functions below, which check the submit code.

create table if not exists public.benchmaxxing_secrets (
  k text primary key,
  v text not null
);
alter table public.benchmaxxing_secrets enable row level security;
-- No policies at all: only the database owner (and security-definer
-- functions) can read this table.

insert into public.benchmaxxing_secrets (k, v)
values ('submit_code', 'violet-ember-tundra-62')
on conflict (k) do update set v = excluded.v;

create or replace function public.benchmaxxing_submit(
  p_code           text,
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
  if p_code is null or p_code <> (select v from public.benchmaxxing_secrets where k = 'submit_code') then
    raise exception 'wrong submit code' using errcode = '28000';
  end if;
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

create or replace function public.benchmaxxing_delete(
  p_code text,
  p_id   bigint
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_code is null or p_code <> (select v from public.benchmaxxing_secrets where k = 'submit_code') then
    raise exception 'wrong submit code' using errcode = '28000';
  end if;
  delete from public.benchmaxxing_scores where id = p_id;
end
$$;

revoke all on function public.benchmaxxing_submit(text, text, text, double precision, double precision, text) from public;
revoke all on function public.benchmaxxing_delete(text, bigint) from public;
grant execute on function public.benchmaxxing_submit(text, text, text, double precision, double precision, text) to anon, authenticated;
grant execute on function public.benchmaxxing_delete(text, bigint) to anon, authenticated;
