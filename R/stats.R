#' Get WTA tour statistics leaderboards
#'
#' Scrapes the public stats hub at
#' <https://www.wtatennis.com/stats> and returns the leaderboard for the
#' requested metric as a tidy tibble.
#'
#' @param metric Character. Stat slug as used by the WTA site (e.g.
#'   `"aces"`, `"first-serve-percentage"`, `"break-points-converted"`,
#'   `"winners"`, `"unforced-errors"`). The full path is
#'   `https://www.wtatennis.com/stats/<metric>`.
#' @param top Integer. Limit to the top `N` rows. `NULL` (default) returns
#'   every row rendered by the site.
#'
#' @return A [tibble::tibble()] with columns: `rank`, `player`, `country`,
#'   `value`.
#' @export
#' @examplesIf interactive()
#' wta_get_stats("aces", top = 25)
#' @importFrom rvest html_nodes html_node html_text
#' @importFrom purrr map list_rbind
#' @importFrom tibble tibble
#' @importFrom stringr str_squish
wta_get_stats <- function(metric = "aces", top = NULL) {
  if (!is.character(metric) || length(metric) != 1L || !nzchar(metric)) {
    cli::cli_abort("{.arg metric} must be a non-empty character string.")
  }

  url <- sprintf("https://www.wtatennis.com/stats/%s", metric)

  page <- .read_html_dynamic(
    url,
    wait = 6,
    click_more_selector = ".stats__load-more, .stats-load-more",
    max_clicks = 50L
  )

  rows <- rvest::html_nodes(page, ".stats-item, .stats__row")
  if (length(rows) == 0L) {
    cli::cli_abort(c(
      "No stats rows were found at {.url {url}}.",
      "i" = "Check the metric slug or inspect the page markup in DevTools."
    ))
  }

  out <- purrr::list_rbind(purrr::map(rows, function(r) {
    tibble::tibble(
      rank    = .text_or_na(r, ".stats-item__rank, .stats__rank"),
      player  = .text_or_na(r, ".stats-item__name, .stats__name"),
      country = .text_or_na(r, ".stats-item__country, .stats__country"),
      value   = .text_or_na(r, ".stats-item__value, .stats__value")
    )
  }))

  if (!is.null(top)) out <- utils::head(out, top)
  out
}
