#' Get the current WTA rankings
#'
#' Scrapes the rankings table at
#' <https://www.wtatennis.com/rankings/singles> (or `/doubles`) and returns
#' a tidy tibble. The initial page renders the first 50 rows; increase the
#' browser dwell time with `wait` if the widget hasn't hydrated yet.
#'
#' @param type Character. One of `"singles"`, `"doubles"`. Defaults to
#'   `"singles"`.
#' @param top Integer. Limit the output to the top `N` ranked players.
#'   `NULL` (default) keeps every row rendered by the page.
#' @param wait Numeric. Seconds to wait for the rankings widget to hydrate
#'   after navigation. Defaults to 12.
#'
#' @return A [tibble::tibble()] with one row per player and columns:
#'   `rank`, `player_id`, `player`, `country`, `age`,
#'   `tournaments_played`, `points`.
#' @export
#' @examplesIf interactive()
#' wta_get_rankings("singles", top = 50)
#' @importFrom rvest html_nodes html_node html_text html_attr
#' @importFrom purrr map list_rbind
#' @importFrom tibble tibble
#' @importFrom stringr str_squish str_extract
wta_get_rankings <- function(type = c("singles", "doubles"), top = NULL,
                             wait = 12) {
  type <- match.arg(type)
  url  <- sprintf("https://www.wtatennis.com/rankings/%s", type)

  page <- .read_html_dynamic(url, wait = wait)
  out  <- .parse_rankings(page)

  if (!is.null(top)) out <- utils::head(out, top)
  out
}

#' @keywords internal
#' @noRd
.parse_rankings <- function(page) {
  rows <- rvest::html_nodes(page, "tr.player-row")
  if (length(rows) == 0L) {
    cli::cli_abort(c(
      "No ranking rows were found.",
      "i" = "WTA markup may have changed. Inspect {.code tr.player-row} in DevTools."
    ))
  }

  purrr::list_rbind(purrr::map(rows, function(r) {
    flag_cls <- rvest::html_attr(
      rvest::html_node(r, ".flag, .player-cell__flag"), "class"
    ) %||% ""
    cc <- stringr::str_extract(flag_cls, "flag--[A-Z]{3}")
    cc <- sub("flag--", "", cc %||% NA_character_)

    tibble::tibble(
      rank               = .text_or_na(r, ".player-row__cell--rank .player-row__rank"),
      player_id          = rvest::html_attr(r, "data-player-id"),
      player             = rvest::html_attr(r, "data-player-name"),
      country            = cc,
      age                = .text_or_na(r, ".player-row__cell--age"),
      tournaments_played = .text_or_na(r, ".player-row__cell--tournaments"),
      points             = .text_or_na(r, ".player-row__cell--points")
    )
  }))
}
