#' Get the current WTA rankings
#'
#' Scrapes the public rankings page at
#' <https://www.wtatennis.com/rankings> and returns a tidy tibble.
#'
#' @param type Character. One of `"singles"`, `"doubles"`. Defaults to
#'   `"singles"`.
#' @param top Integer. Limit the output to the top `N` ranked players.
#'   `NULL` (default) keeps every row rendered by the site.
#'
#' @return A [tibble::tibble()] with columns: `rank`, `player`, `country`,
#'   `age`, `points`, `tournaments_played`, `movement`.
#' @export
#' @examplesIf interactive()
#' wta_get_rankings("singles", top = 50)
#' @importFrom rvest html_nodes html_node html_text
#' @importFrom purrr map list_rbind
#' @importFrom tibble tibble
#' @importFrom stringr str_squish
wta_get_rankings <- function(type = c("singles", "doubles"), top = NULL) {
  type <- match.arg(type)
  url  <- sprintf("https://www.wtatennis.com/rankings/%s", type)

  page <- .read_html_dynamic(
    url,
    wait = 6,
    click_more_selector = ".rankings__load-more, .rankings-load-more",
    max_clicks = 50L
  )

  rows <- rvest::html_nodes(page, ".rankings-item, .rankings__row")
  if (length(rows) == 0L) {
    cli::cli_abort(c(
      "No rankings rows were found at {.url {url}}.",
      "i" = "WTA markup may have changed. Inspect the rankings grid in DevTools."
    ))
  }

  out <- purrr::list_rbind(purrr::map(rows, function(r) {
    tibble::tibble(
      rank               = .text_or_na(r, ".rankings-item__ranking, .rankings__rank"),
      player             = .text_or_na(r, ".rankings-item__name, .rankings__name"),
      country            = .text_or_na(r, ".rankings-item__country, .rankings__country"),
      age                = .text_or_na(r, ".rankings-item__age, .rankings__age"),
      points             = .text_or_na(r, ".rankings-item__points, .rankings__points"),
      tournaments_played = .text_or_na(r, ".rankings-item__tournaments, .rankings__tournaments"),
      movement           = .text_or_na(r, ".rankings-item__movement, .rankings__movement")
    )
  }))

  if (!is.null(top)) out <- utils::head(out, top)
  out
}
