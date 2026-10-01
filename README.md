# Bluesky Benchmaxxing

Live at https://blueskybenchmaxxing.com

Public leaderboard for the one-week English Bluesky simulation benchmark
(holdout week Sep 18–25 2026, 8 futures). Three losses, each at two
timescales (six numbers per entry): per-liker Brier on likes, size-band CRPS
on follower counts, Poisson deviance on like counts; headline timescale
(likes: whole week, followers: per day) and 2-day windows (days 1–2 … 6–7,
averaged). Exact definitions: the "How the losses are computed" tab.

Static site: `index.html` + `config.js`. No build step. Data lives in a
Supabase table; the page reads it with the public anon key and writes through
a database function that checks all six losses are numbers >= 0.

## Setup (once)

1. Supabase → the gaze project → SQL editor → paste `supabase/schema.sql` → Run.
   Re-running it is safe (re-run once after the Sep 30 2026 six-loss change).
2. Deploy this repo as a Render static site (publish path `.`, no build command).

## Submitting a score

Click **Submit a score**, fill in the model title, the six losses and a
description of how the model works. No code needed.
