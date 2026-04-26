# Getting started with matchpointR

``` r
library(matchpointR)
```

## Overview

`matchpointR` turns the public pages of
[wtatennis.com](https://www.wtatennis.com) into tidy data frames:

| Function                                                                                                    | Purpose                                                 |
|-------------------------------------------------------------------------------------------------------------|---------------------------------------------------------|
| [`wta_player_url()`](https://angnar-97.github.io/matchpointR/reference/wta_player_url.md)                   | Build canonical player URLs.                            |
| [`wta_get_player_basics()`](https://angnar-97.github.io/matchpointR/reference/wta_get_player_basics.md)     | One-row tibble with bio parsed from the page’s JSON-LD. |
| [`wta_get_player_overview()`](https://angnar-97.github.io/matchpointR/reference/wta_get_player_overview.md) | Career highlights (ranks, titles, prize money).         |
| [`wta_get_player_matches()`](https://angnar-97.github.io/matchpointR/reference/wta_get_player_matches.md)   | One row per match across the full career.               |
| [`wta_get_rankings()`](https://angnar-97.github.io/matchpointR/reference/wta_get_rankings.md)               | Current singles / doubles leaderboard.                  |

Every function that hits the network opens (and closes) its own headless
Chrome session through `chromote`. Where the WTA site exposes structured
schema.org JSON-LD data, `matchpointR` reads from that in preference to
CSS selectors — this is substantially more resilient against site
redesigns.

## A worked example: Kateřina Siniaková

``` r
url <- wta_player_url(320301, "katerina-siniakova")

bio <- wta_get_player_basics(url, download_images = FALSE)
bio
```

`download_images = TRUE` (the default) additionally downloads the
headshot into a `magick-image` list-column — set it to `FALSE` when you
only need the metadata.

### Career highlights

``` r
wta_get_player_overview(url)
```

Returns a long tibble with one row per metric: `singles_rank`,
`doubles_rank`, `singles_career_titles`, `doubles_career_titles`,
`career_prize_money`, `career_high`.

### Full match history

``` r
matches_url <- wta_player_url(320301, "katerina-siniakova", "matches")
matches <- wta_get_player_matches(matches_url)
head(matches)
```

[`wta_get_player_matches()`](https://angnar-97.github.io/matchpointR/reference/wta_get_player_matches.md)
clicks the *Show more* button repeatedly until no more matches are
loaded. Raise `max_clicks` only if you hit the safety cap on a very long
career.

## Tour-wide data

### Live rankings

``` r
wta_get_rankings("singles", top = 50)
wta_get_rankings("doubles", top = 50)
```

## Tips

- **Coercion.** All columns are returned as character to stay faithful
  to the rendered page. Cast to numeric/date downstream.
- **Selector drift.** If a function suddenly returns zero rows, the
  site’s CSS classes have probably been renamed — open an issue.
- **Rate limiting.** `chromote` hits the site as a real browser; be
  considerate if you are iterating over many players.

## Not yet covered

Tour-wide statistics leaderboards (aces, winners, break-points
converted, …) are tracked in [issue
\#1](https://github.com/Angnar-97/matchpointR/issues/1) for a future
release. The WTA site reshuffled its `/stats` hub and we are waiting for
a stable URL pattern before committing to an API.
