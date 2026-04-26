# Get the current WTA rankings

Scrapes the rankings table at
<https://www.wtatennis.com/rankings/singles> (or `/doubles`) and returns
a tidy tibble. The initial page renders the first 50 rows; increase the
browser dwell time with `wait` if the widget hasn't hydrated yet.

## Usage

``` r
wta_get_rankings(type = c("singles", "doubles"), top = NULL, wait = 12)
```

## Arguments

- type:

  Character. One of `"singles"`, `"doubles"`. Defaults to `"singles"`.

- top:

  Integer. Limit the output to the top `N` ranked players. `NULL`
  (default) keeps every row rendered by the page.

- wait:

  Numeric. Seconds to wait for the rankings widget to hydrate after
  navigation. Defaults to 12.

## Value

A
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with one row per player and columns: `rank`, `player_id`, `player`,
`country`, `age`, `tournaments_played`, `points`.

## Examples

``` r
if (FALSE) { # interactive()
wta_get_rankings("singles", top = 50)
}
```
