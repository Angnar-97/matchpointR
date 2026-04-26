# Build a WTA player URL

Convenience wrapper to assemble a canonical player URL from a numeric id
and an optional slug.

## Usage

``` r
wta_player_url(id, slug = NULL, section = c("overview", "matches"))
```

## Arguments

- id:

  Character or integer. The WTA numeric player id (e.g. `320301`).

- slug:

  Optional character. Player slug (e.g. `"katerina-siniakova"`). When
  omitted the URL still resolves — WTA redirects to the canonical one.

- section:

  Optional character. Page section to append as a path segment, one of
  `"overview"`, `"matches"`. Defaults to `"overview"`, which maps to the
  bare player URL.

## Value

A single character string with the full URL.

## Examples

``` r
wta_player_url(320301, "katerina-siniakova")
#> [1] "https://www.wtatennis.com/players/320301/katerina-siniakova"
wta_player_url(320301, "katerina-siniakova", "matches")
#> [1] "https://www.wtatennis.com/players/320301/katerina-siniakova/matches"
```
