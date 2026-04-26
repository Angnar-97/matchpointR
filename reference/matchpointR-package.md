# matchpointR: Tidy Access to Women's Tennis Association (WTA) Data

`matchpointR` is a small scraper toolkit that turns the public pages of
<https://www.wtatennis.com> into tidy data frames. It ships helpers for
player biographies, career highlights, full match histories and live
rankings.

## Details

Dynamic content is rendered through a headless Chrome session using the
chromote package, so JavaScript-generated sections (matches, rankings)
are fully captured before parsing. Where possible the package reads
structured JSON-LD (schema.org) data instead of scraping CSS classes,
for resilience against site redesigns.

## Main functions

- [`wta_player_url()`](https://angnar-97.github.io/matchpointR/reference/wta_player_url.md)

- [`wta_get_player_basics()`](https://angnar-97.github.io/matchpointR/reference/wta_get_player_basics.md)

- [`wta_get_player_overview()`](https://angnar-97.github.io/matchpointR/reference/wta_get_player_overview.md)

- [`wta_get_player_matches()`](https://angnar-97.github.io/matchpointR/reference/wta_get_player_matches.md)

- [`wta_get_rankings()`](https://angnar-97.github.io/matchpointR/reference/wta_get_rankings.md)

## Author

Alejandro Navas González (Angnar).

## See also

Useful links:

- <https://github.com/Angnar-97/matchpointR>

- Report bugs at <https://github.com/Angnar-97/matchpointR/issues>

## Author

**Maintainer**: Alejandro Navas González <angnar@telaris.es> (Angnar)
