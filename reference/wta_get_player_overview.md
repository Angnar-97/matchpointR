# Get a WTA player's career highlights

Returns the structured "additional properties" block from the page's
JSON-LD: current singles and doubles rank, career titles, career prize
money. Supplements with the career-high singles rank read from the bio
side panel.

## Usage

``` r
wta_get_player_overview(player_url)
```

## Arguments

- player_url:

  Character. URL to the player overview page.

## Value

A long-format
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with columns `metric` and `value`. Rows include `singles_rank`,
`doubles_rank`, `singles_career_titles`, `doubles_career_titles`,
`career_prize_money`, `career_high`.

## Examples

``` r
if (FALSE) { # interactive()
wta_get_player_overview(wta_player_url(320301, "katerina-siniakova"))
}
```
