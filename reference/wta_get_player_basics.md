# Get basic bio for a WTA player

Parses the profile header of a WTA player page and returns a one-row
tibble with name, nationality, birth date, birth place, height and
handedness. The bulk of the data is read from the page's JSON-LD
(schema.org Person) block, which is more stable than the visual markup;
height is read from the profile bio block as a fallback.

## Usage

``` r
wta_get_player_basics(player_url, download_images = TRUE)
```

## Arguments

- player_url:

  Character. Full URL to a player page. Build it with
  [`wta_player_url()`](https://angnar-97.github.io/matchpointR/reference/wta_player_url.md)
  if you only have the numeric id.

- download_images:

  Logical. When `TRUE` (default) the headshot is downloaded into a
  `magick-image` object. Set to `FALSE` to skip the network round-trip
  and return only the image URL.

## Value

A one-row
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html)
with columns:

- `player_id`:

  Numeric WTA id parsed from `@id`.

- `name`, `given_name`, `family_name`:

  Name fields.

- `birth_date`:

  Date of birth (ISO 8601 character).

- `nationality`, `birth_place`, `birth_country`:

  Geography fields.

- `height`:

  Height string as shown on the bio (e.g. `5' 9" (1.74m)`).

- `handedness`:

  Dominant hand (`"Right-Handed"` / `"Left-Handed"`).

- `nationality_code`:

  3-letter IOC/ISO code extracted from the flag image (e.g. `"CZE"`,
  `"USA"`).

- `player_image_url`, `nationality_flag_url`:

  Headshot and flag URLs.

- `player_image`:

  `magick-image` of the headshot, when `download_images = TRUE`.

- `nationality_flag`:

  `magick-image` of the flag SVG, when `download_images = TRUE` and the
  suggested package rsvg is installed (otherwise `NA`).

## Examples

``` r
if (FALSE) { # interactive()
wta_get_player_basics(wta_player_url(320301, "katerina-siniakova"))
}
```
