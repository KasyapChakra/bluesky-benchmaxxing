# Bluesky Benchmaxxing

Live at https://blueskybenchmaxxing.com

Public leaderboard for the one-week English Bluesky simulation benchmark
(holdout week Sep 18–25 2026, 8 futures, two losses: per-liker Brier on likes
and size-band CRPS on daily follower counts).

Static site: `index.html` + `config.js`. No build step. Data lives in a
Supabase table; the page reads it with the public anon key and writes through
a database function that checks a submit code.

## Setup (once)

1. Supabase → the gaze project → SQL editor → paste `supabase/schema.sql` → Run.
   Change the submit code in that file first if you want a different one.
2. Deploy this repo as a Render static site (publish path `.`, no build command).

## Submitting a score

Click **Submit a score**, fill in the model title, the two losses, a
description of how the model works, and the submit code.
