# -------------------------------------------------------------------------
#  Player basic info -------------------------------------------------------

#' Get basic bio for a WTA player
#'
#' Scrapes the profile header of a WTA player page and returns a one-row
#' tibble with name, nationality, birth date, birth place, height and
#' handedness, together with optional `magick-image` list-columns for the
#' headshot and the nationality flag.
#'
#' @param player_url Character. Full URL to a player page (either the
#'   overview or matches section). Build it with [wta_player_url()] if
#'   you only have the numeric id.
#' @param download_images Logical. When `TRUE` (default) the headshot and
#'   flag are downloaded into `magick-image` objects. Set to `FALSE` to
#'   return only the URLs and avoid network I/O.
#'
#' @return A one-row [tibble::tibble()] with columns:
#' \describe{
#'   \item{`name`}{Player display name.}
#'   \item{`birth_date`}{Date of birth as shown on the profile (character).}
#'   \item{`nationality`}{Nationality label.}
#'   \item{`birth_place`}{Birth place string.}
#'   \item{`height`}{Height as shown (usually `cm / feet-inches`).}
#'   \item{`handedness`}{Dominant hand.}
#'   \item{`player_image_url` / `player_image`}{Headshot URL and
#'     (optionally) its `magick-image`.}
#'   \item{`nationality_flag_url` / `nationality_flag`}{Flag URL and
#'     (optionally) the parsed SVG.}
#' }
#' @export
#' @examplesIf interactive()
#' wta_get_player_basics(wta_player_url(320301, "katerina-siniakova"))
#' @importFrom rvest html_node html_nodes html_text html_attr
#' @importFrom tibble tibble
#' @importFrom stringr str_squish
wta_get_player_basics <- function(player_url, download_images = TRUE) {
  page <- .read_html_dynamic(player_url)
  .parse_player_basics(page, download_images = download_images)
}

#' Parse a WTA player profile header
#'
#' Internal parser that takes a pre-fetched `xml_document` for a player page
#' and returns the basics tibble. Kept separate from [wta_get_player_basics()]
#' so it can be unit-tested against local fixtures without launching Chrome.
#'
#' @param page An `xml2::xml_document` as returned by [xml2::read_html()].
#' @param download_images Logical, see [wta_get_player_basics()].
#' @keywords internal
#' @noRd
.parse_player_basics <- function(page, download_images = TRUE) {
  name <- .text_or_na(page, ".profile-header-info .profile-header__name")

  photo_url <- .attr_or_na(page, ".profile-header-headshot.full-body img", "src")
  if (is.na(photo_url)) {
    photo_url <- .attr_or_na(page, ".fade-in-on-load.is-loaded", "src")
  }
  photo_url <- .abs_url(photo_url)

  nationality <- .text_or_na(page, ".profile-header-info__nationality")
  flag_url <- .abs_url(.attr_or_na(page, ".profile-header-info__nationalityFlag", "src"))

  stats <- page |>
    rvest::html_nodes(".profile-header-info__detail-stat--small") |>
    rvest::html_text(trim = TRUE) |>
    stringr::str_squish()
  stats <- c(stats, rep(NA_character_, max(0L, 4L - length(stats))))

  out <- tibble::tibble(
    name                 = name,
    birth_date           = stats[3],
    nationality          = nationality,
    birth_place          = stats[4],
    height               = stats[1],
    handedness           = stats[2],
    player_image_url     = photo_url,
    nationality_flag_url = flag_url
  )

  if (download_images) {
    out$player_image     <- list(.safe_image_read(photo_url))
    out$nationality_flag <- list(.safe_image_read_svg(flag_url))
  }
  out
}

#' @keywords internal
#' @noRd
.safe_image_read <- function(url) {
  if (is.na(url)) return(NA)
  tryCatch(magick::image_read(url), error = function(e) NA)
}

#' @keywords internal
#' @noRd
.safe_image_read_svg <- function(url) {
  if (is.na(url)) return(NA)
  if (!requireNamespace("rsvg", quietly = TRUE)) return(NA)
  tryCatch(magick::image_read_svg(url), error = function(e) NA)
}

# -------------------------------------------------------------------------
#  Player overview (Singles & Doubles) ------------------------------------

#' Get the Singles / Doubles overview panel for a player
#'
#' Clicks the Singles and Doubles tabs in the profile header and parses the
#' highlighted statistics (current ranking, career high, titles, win rate,
#' prize money).
#'
#' @param player_url Character. URL to the player overview page.
#'
#' @return A [tibble::tibble()] with two rows (`Singles`, `Doubles`) and
#'   columns: `current_ranking`, `career_high`, `win_rate_year`,
#'   `win_rate_career`, `year_titles`, `career_titles`, `prize_money_year`,
#'   `prize_money_career`.
#' @export
#' @examplesIf interactive()
#' wta_get_player_overview(wta_player_url(320301, "katerina-siniakova"))
#' @importFrom chromote ChromoteSession
#' @importFrom rvest html_nodes html_text
#' @importFrom xml2 read_html
#' @importFrom tibble tibble
#' @importFrom stringr str_squish
wta_get_player_overview <- function(player_url) {
  ss <- chromote::ChromoteSession$new()
  on.exit(try(ss$close(), silent = TRUE), add = TRUE)

  ss$Page$navigate(player_url)
  Sys.sleep(5)

  capture_tab <- function(idx) {
    ss$Runtime$evaluate(sprintf(
      "document.querySelectorAll('.profile-header-toggle__switch-selector')[%d].click()",
      idx - 1L
    ))
    Sys.sleep(1.5)
    ss$Runtime$evaluate("document.documentElement.outerHTML")$result$value
  }

  s <- .parse_overview_values(capture_tab(1L))
  d <- .parse_overview_values(capture_tab(2L))

  .build_overview_tibble(s, d)
}

#' @keywords internal
#' @noRd
.parse_overview_values <- function(html) {
  xml2::read_html(html) |>
    rvest::html_nodes(".profile-header-stats__value") |>
    rvest::html_text(trim = TRUE) |>
    stringr::str_squish()
}

#' @keywords internal
#' @noRd
.build_overview_tibble <- function(s, d) {
  pad <- function(x, n = 12L) c(x, rep(NA_character_, max(0L, n - length(x))))
  s <- pad(s); d <- pad(d)
  tibble::tibble(
    stats              = c("Singles", "Doubles"),
    current_ranking    = c(s[1],  d[1]),
    career_high        = c(s[7],  d[7]),
    win_rate_year      = c(s[5],  d[5]),
    win_rate_career    = c(s[11], d[11]),
    year_titles        = c(s[2],  d[2]),
    career_titles      = c(s[8],  d[8]),
    prize_money_year   = c(s[3],  d[3]),
    prize_money_career = c(s[9],  d[9])
  )
}

# -------------------------------------------------------------------------
#  Player matches ---------------------------------------------------------

#' Get the full match list for a WTA player
#'
#' Walks the dynamic "Matches" section of a player page, clicking the
#' "Show more" button until the full history is loaded, and returns one row
#' per match.
#'
#' @param player_url Character. Must point to the player page; the function
#'   appends `#matches` automatically when missing.
#' @param max_clicks Integer. Safety cap for the "Show more" click loop.
#'   Defaults to 50.
#'
#' @return A [tibble::tibble()] with one row per match and columns:
#'   `date`, `tournament`, `round`, `opponent`, `score`.
#' @export
#' @examplesIf interactive()
#' url <- wta_player_url(320301, "katerina-siniakova", "matches")
#' wta_get_player_matches(url)
#' @importFrom rvest html_nodes html_node html_text
#' @importFrom purrr map list_rbind
#' @importFrom tibble tibble
wta_get_player_matches <- function(player_url, max_clicks = 50L) {
  if (!grepl("#matches$", player_url)) {
    player_url <- sub("#.*$", "", player_url)
    player_url <- paste0(player_url, "#matches")
  }

  page <- .read_html_dynamic(
    player_url,
    click_more_selector = ".player-matches__more-button",
    max_clicks = max_clicks
  )

  .parse_player_matches(page, source_url = player_url)
}

#' @keywords internal
#' @noRd
.parse_player_matches <- function(page, source_url = NA_character_) {
  rows <- rvest::html_nodes(page, ".player-matches__row")
  if (length(rows) == 0L) {
    cli::cli_abort(c(
      "No match rows were found{ if (!is.na(source_url)) paste0(' at ', source_url) else '' }.",
      "i" = "WTA markup may have changed. Inspect {.code .player-matches__row} in DevTools."
    ))
  }

  purrr::list_rbind(purrr::map(rows, function(r) {
    tibble::tibble(
      date       = .text_or_na(r, ".player-matches__match-date"),
      tournament = .text_or_na(r, ".player-matches__tournament-title-link"),
      round      = .text_or_na(r, ".player-matches__match-round"),
      opponent   = .text_or_na(r, ".player-matches__match-opponent-first"),
      score      = .text_or_na(r, ".player-matches__match-score")
    )
  }))
}
