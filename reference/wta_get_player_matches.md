# Get the match history for a WTA player

Walks the dynamic "Matches" page of a player profile, clicking the "Show
more" button until the full history is loaded, and returns one row per
match with tournament, round, opponent, score and result.

## Usage

``` r
wta_get_player_matches(player_url, max_clicks = 50L)
```

## Arguments

- player_url:

  Character. URL to the player page; the function normalises to the
  `/matches` path automatically.

- max_clicks:

  Integer. Safety cap for the "Show more" click loop. Defaults to 50.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with one row per match and columns: `tournament`, `tournament_date`,
`round`, `opponent`, `opponent_seed`, `opponent_country`,
`opponent_rank`, `score`, `result`.

## Examples

``` r
if (FALSE) { # interactive()
url <- wta_player_url(320301, "katerina-siniakova", "matches")
wta_get_player_matches(url)
}
```
