#' matchpointR: Tidy Access to Women's Tennis Association (WTA) Data
#'
#' `matchpointR` is a small scraper toolkit that turns the public pages of
#' <https://www.wtatennis.com> into tidy data frames. It ships helpers for
#' player biographies, career highlights, full match histories and live
#' rankings.
#'
#' Dynamic content is rendered through a headless Chrome session using the
#' \pkg{chromote} package, so JavaScript-generated sections (matches,
#' rankings) are fully captured before parsing. Where possible the package
#' reads structured JSON-LD (schema.org) data instead of scraping CSS
#' classes, for resilience against site redesigns.
#'
#' @section Main functions:
#' * [wta_player_url()]
#' * [wta_get_player_basics()]
#' * [wta_get_player_overview()]
#' * [wta_get_player_matches()]
#' * [wta_get_rankings()]
#'
#' @section Author:
#' Alejandro Navas González (Angnar).
#'
#' @keywords internal
"_PACKAGE"
