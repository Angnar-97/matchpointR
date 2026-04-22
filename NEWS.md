# matchpointR 0.1.0

First public release.

## Features

* `wta_player_url()` builds canonical player URLs from a WTA numeric id,
  an optional slug and a section (`"overview"` or `"matches"`).
* `wta_get_player_basics()` returns a one-row tibble with the player's
  name, nationality, birth date and place, height, handedness, headshot
  and nationality flag. Biographical data is read from the page's
  schema.org JSON-LD block (with a CSS-selector fallback) for resilience
  against site redesigns.
* `wta_get_player_overview()` returns a long tibble of career highlights
  (singles/doubles rank, career titles, career prize money, career-high
  singles rank).
* `wta_get_player_matches()` walks the "Matches" page, clicking *Show
  more* until the full history is loaded, and returns one row per match
  with tournament, tournament date, round, opponent, opponent seed and
  country code, opponent rank, score and win/loss result.
* `wta_get_rankings()` scrapes the current singles or doubles ranking
  table and returns a tidy tibble (rank, player id, player, country,
  age, tournaments played, points).

## Infrastructure

* Tests (`testthat` 3rd edition) run entirely against local HTML
  fixtures — no network, no headless browser required for CI.
* GitHub Actions workflows for `R CMD check` (Ubuntu / Windows / macOS
  × devel / release / oldrel-1) and pkgdown deployment.
* Vignette "Getting started with matchpointR".

## Not yet covered

* Tour-wide statistics leaderboards (aces, winners, break-points
  converted, …) are tracked in
  [issue #1](https://github.com/Angnar-97/matchpointR/issues/1) for a
  future release.
