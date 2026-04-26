<!-- README.md is generated from README.Rmd. Please edit that file -->

# matchpointR <a href="https://github.com/Angnar-97/matchpointR"><img src="man/figures/logo.png" align="right" height="120" alt="matchpointR logo"/></a>

<!-- badges: start -->
[![R-CMD-check](https://github.com/Angnar-97/matchpointR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Angnar-97/matchpointR/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/matchpointR)](https://CRAN.R-project.org/package=matchpointR)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**matchpointR** turns the public pages of the Women's Tennis Association
(<https://www.wtatennis.com>) into tidy data frames. It ships helpers for
player biographies, career highlights, full match histories and live
rankings.

Dynamic content (matches, rankings) is rendered through a headless
Chrome session via [`chromote`](https://cran.r-project.org/package=chromote),
so JavaScript-generated sections are fully captured before parsing. Where
the WTA site exposes structured `schema.org` JSON-LD data, `matchpointR`
reads from that in preference to CSS selectors for resilience against
site redesigns.

## Installation

You can install the development version of `matchpointR` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Angnar-97/matchpointR")
```

Or, once it lands on CRAN:

``` r
install.packages("matchpointR")
```

You will also need a working Chrome/Chromium install for the dynamic
scrapers, which is managed automatically by `chromote`.

## Usage

``` r
library(matchpointR)

# Build a canonical player URL from id + slug
url <- wta_player_url(320301, "katerina-siniakova")

# Player biography (name, nationality, headshot, flag, ...)
wta_get_player_basics(url, download_images = FALSE)

# Career highlights (ranks, titles, prize money)
wta_get_player_overview(url)

# Full match history (walks the "Show more" button)
matches_url <- wta_player_url(320301, "katerina-siniakova", "matches")
wta_get_player_matches(matches_url)

# Live rankings
wta_get_rankings("singles", top = 50)
```

## Terms of service and fair use

`matchpointR` reads **publicly accessible** pages of
<https://www.wtatennis.com> using a single headless browser session per
call. Before using this package — especially at scale — you are
responsible for checking and complying with the WTA website's
[Terms and Conditions](https://www.wtatennis.com/terms-and-conditions).
The package does **not** bypass paywalls, authentication walls or any
technical access controls, does not interact with user accounts, and
exposes no bulk-download helpers. Please scrape considerately: the
`chromote` session hits the site as a real browser, so iterating over
many players or rankings days back-to-back is equivalent to a human
browsing the site rapidly. Add explicit `Sys.sleep()` between calls in
loops.

## Scope and caveats

- HTML selectors may drift as the site is redesigned. Where possible
  `matchpointR` reads from the page's `schema.org` JSON-LD block for
  stability. File an issue on GitHub if a function stops returning data.
- Functions return everything as character to stay faithful to the
  rendered page; cast to numeric or date in a follow-up step.
- Tour-wide statistics leaderboards are not yet implemented; tracked in
  [issue #1](https://github.com/Angnar-97/matchpointR/issues/1).

## License

[Apache License (>= 2)](https://www.apache.org/licenses/LICENSE-2.0).

## Author

Alejandro Navas González (Angnar).
