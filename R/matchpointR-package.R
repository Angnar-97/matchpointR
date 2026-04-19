#' matchpointR: Tidy Access to Women's Tennis Association (WTA) Data
#'
#' `matchpointR` is a small scraper toolkit that turns the public pages of
#' <https://www.wtatennis.com> into tidy data frames. It ships helpers for
#' player biographies, singles and doubles overviews, full match histories,
#' live rankings and aggregate tour statistics.
#'
#' Dynamic content is rendered through a headless Chrome session using the
#' \pkg{chromote} package, so JavaScript-generated sections (matches,
#' rankings, stats) are fully captured before parsing.
#'
#' @section Main functions:
#' * [wta_get_player_basics()]
#' * [wta_get_player_overview()]
#' * [wta_get_player_matches()]
#' * [wta_get_rankings()]
#' * [wta_get_stats()]
#'
#' @section Author:
#' Alejandro Navas González (Angnar).
#'
#' @keywords internal
"_PACKAGE"

## Silence R CMD check for tidyverse-style NSE columns.
utils::globalVariables(c(
  ".", "singles", "doubles"
))
