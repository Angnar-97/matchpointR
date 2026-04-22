# -------------------------------------------------------------------------
#  Player basic info -------------------------------------------------------

#' Get basic bio for a WTA player
#'
#' Parses the profile header of a WTA player page and returns a one-row
#' tibble with name, nationality, birth date, birth place, height and
#' handedness. The bulk of the data is read from the page's JSON-LD
#' (schema.org Person) block, which is more stable than the visual markup;
#' height is read from the profile bio block as a fallback.
#'
#' @param player_url Character. Full URL to a player page. Build it with
#'   [wta_player_url()] if you only have the numeric id.
#' @param download_images Logical. When `TRUE` (default) the headshot is
#'   downloaded into a `magick-image` object. Set to `FALSE` to skip the
#'   network round-trip and return only the image URL.
#'
#' @return A one-row [tibble::tibble()] with columns:
#' \describe{
#'   \item{`player_id`}{Numeric WTA id parsed from `@id`.}
#'   \item{`name`, `given_name`, `family_name`}{Name fields.}
#'   \item{`birth_date`}{Date of birth (ISO 8601 character).}
#'   \item{`nationality`, `birth_place`, `birth_country`}{Geography fields.}
#'   \item{`height`}{Height string as shown on the bio (e.g. `5' 9" (1.74m)`).}
#'   \item{`handedness`}{Dominant hand (`"Right-Handed"` / `"Left-Handed"`).}
#'   \item{`nationality_code`}{3-letter IOC/ISO code extracted from the flag
#'     image (e.g. `"CZE"`, `"USA"`).}
#'   \item{`player_image_url`, `nationality_flag_url`}{Headshot and flag URLs.}
#'   \item{`player_image`}{`magick-image` of the headshot, when
#'     `download_images = TRUE`.}
#'   \item{`nationality_flag`}{`magick-image` of the flag SVG, when
#'     `download_images = TRUE` and the suggested package \pkg{rsvg} is
#'     installed (otherwise `NA`).}
#' }
#' @export
#' @examplesIf interactive()
#' wta_get_player_basics(wta_player_url(320301, "katerina-siniakova"))
#' @importFrom rvest html_node html_nodes html_text html_attr
#' @importFrom tibble tibble
#' @importFrom stringr str_squish str_extract
wta_get_player_basics <- function(player_url, download_images = TRUE) {
  page <- .read_html_dynamic(player_url)
  .parse_player_basics(page, download_images = download_images)
}

#' Parse a WTA player profile from a pre-fetched page
#'
#' Internal parser so unit tests can hit local fixtures without launching
#' Chrome.
#'
#' @param page An `xml2::xml_document`.
#' @param download_images Logical, see [wta_get_player_basics()].
#' @keywords internal
#' @noRd
.parse_player_basics <- function(page, download_images = TRUE) {
  person <- .extract_jsonld(page, "Person")

  player_id <- NA_character_
  if (!is.null(person) && !is.null(person[["@id"]])) {
    player_id <- stringr::str_extract(person[["@id"]], "\\d+")
  }

  name        <- person[["name"]]        %||% NA_character_
  given_name  <- person[["givenName"]]   %||% NA_character_
  family_name <- person[["familyName"]]  %||% NA_character_
  birth_date  <- person[["birthDate"]]   %||% NA_character_
  nationality <- person[["nationality"]][["name"]]  %||% NA_character_
  addr        <- person[["birthPlace"]][["address"]]
  birth_place <- addr[["addressLocality"]] %||% NA_character_
  birth_ctry  <- addr[["addressCountry"]]  %||% NA_character_
  image_url   <- person[["image"]]       %||% NA_character_
  handedness  <- .prop_value(person[["additionalProperty"]], "Plays")

  height <- .bio_info(page, "Height")

  ## final safety net: fall back to HTML header if JSON-LD missing
  if (is.na(name)) {
    name <- .text_or_na(page, ".profile-header__name")
  }

  ## nationality flag (served as SVG from wtatennis.com)
  flag_url  <- .abs_url(.attr_or_na(page,
    ".profile-header__flag .flag__img, .profile-header-info__nationalityFlag",
    "src"))
  flag_code <- .attr_or_na(page,
    ".profile-header__flag .flag__img, .profile-header-info__nationalityFlag",
    "alt")

  out <- tibble::tibble(
    player_id            = player_id,
    name                 = as.character(name),
    given_name           = as.character(given_name),
    family_name          = as.character(family_name),
    birth_date           = as.character(birth_date),
    nationality          = as.character(nationality),
    nationality_code     = as.character(flag_code),
    birth_place          = as.character(birth_place),
    birth_country        = as.character(birth_ctry),
    height               = as.character(height),
    handedness           = as.character(handedness),
    player_image_url     = .abs_url(as.character(image_url)),
    nationality_flag_url = flag_url
  )

  if (download_images) {
    out$player_image     <- list(.safe_image_read(out$player_image_url))
    out$nationality_flag <- list(.safe_image_read_svg(out$nationality_flag_url))
  }
  out
}

#' @keywords internal
#' @noRd
.safe_image_read <- function(url) {
  if (is.na(url)) return(NA)
  tryCatch(magick::image_read(url), error = function(e) NA)
}

#' Read an SVG URL into a magick-image via \pkg{rsvg} (suggests)
#' @keywords internal
#' @noRd
.safe_image_read_svg <- function(url) {
  if (is.na(url)) return(NA)
  if (!requireNamespace("rsvg", quietly = TRUE)) return(NA)
  tryCatch(magick::image_read_svg(url), error = function(e) NA)
}

# -------------------------------------------------------------------------
#  Player overview (career highlights) -----------------------------------

#' Get a WTA player's career highlights
#'
#' Returns the structured "additional properties" block from the page's
#' JSON-LD: current singles and doubles rank, career titles, career prize
#' money. Supplements with the career-high singles rank read from the bio
#' side panel.
#'
#' @param player_url Character. URL to the player overview page.
#'
#' @return A long-format [tibble::tibble()] with columns `metric` and
#'   `value`. Rows include `singles_rank`, `doubles_rank`,
#'   `singles_career_titles`, `doubles_career_titles`,
#'   `career_prize_money`, `career_high`.
#' @export
#' @examplesIf interactive()
#' wta_get_player_overview(wta_player_url(320301, "katerina-siniakova"))
#' @importFrom tibble tibble
wta_get_player_overview <- function(player_url) {
  page <- .read_html_dynamic(player_url)
  .parse_player_overview(page)
}

#' @keywords internal
#' @noRd
.parse_player_overview <- function(page) {
  person <- .extract_jsonld(page, "Person")
  props  <- person[["additionalProperty"]]

  tibble::tibble(
    metric = c(
      "singles_rank", "doubles_rank",
      "singles_career_titles", "doubles_career_titles",
      "career_prize_money", "career_high"
    ),
    value = c(
      .prop_value(props, "WTA Singles Rank"),
      .prop_value(props, "WTA Doubles Rank"),
      .prop_value(props, "Singles Career Titles"),
      .prop_value(props, "Doubles Career Titles"),
      .prop_value(props, "Career Prize Money"),
      .bio_info(page, "Career High")
    )
  )
}

# -------------------------------------------------------------------------
#  Player matches ---------------------------------------------------------

#' Get the match history for a WTA player
#'
#' Walks the dynamic "Matches" page of a player profile, clicking the
#' "Show more" button until the full history is loaded, and returns one row
#' per match with tournament, round, opponent, score and result.
#'
#' @param player_url Character. URL to the player page; the function
#'   normalises to the `/matches` path automatically.
#' @param max_clicks Integer. Safety cap for the "Show more" click loop.
#'   Defaults to 50.
#'
#' @return A [tibble::tibble()] with one row per match and columns:
#'   `tournament`, `tournament_date`, `round`, `opponent`, `opponent_seed`,
#'   `opponent_country`, `opponent_rank`, `score`, `result`.
#' @export
#' @examplesIf interactive()
#' url <- wta_player_url(320301, "katerina-siniakova", "matches")
#' wta_get_player_matches(url)
#' @importFrom rvest html_nodes html_node html_text html_attr
#' @importFrom purrr map list_rbind
#' @importFrom tibble tibble
#' @importFrom stringr str_extract str_squish
wta_get_player_matches <- function(player_url, max_clicks = 50L) {
  player_url <- sub("#.*$", "", player_url)
  if (!grepl("/matches$", player_url)) {
    player_url <- paste0(sub("/$", "", player_url), "/matches")
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
  tournaments <- rvest::html_nodes(page, ".player-matches__tournament")
  if (length(tournaments) == 0L) {
    cli::cli_abort(c(
      "No tournaments were found{ if (!is.na(source_url)) paste0(' at ', source_url) else '' }.",
      "i" = "WTA markup may have changed. Inspect {.code .player-matches__tournament} in DevTools."
    ))
  }

  rows <- purrr::list_rbind(purrr::map(tournaments, function(tour) {
    tournament      <- .text_or_na(tour, ".player-matches__tournament-title-link")
    tournament_date <- .attr_or_na(tour, ".player-matches__tournament-date time", "date-time")
    if (is.na(tournament_date)) {
      tournament_date <- .text_or_na(tour, ".player-matches__tournament-date")
    }

    matches <- rvest::html_nodes(
      tour,
      ".player-matches__match:not(.player-matches__match--divider)"
    )
    if (length(matches) == 0L) return(tibble::tibble())

    purrr::list_rbind(purrr::map(matches, function(m) {
      flag_node <- rvest::html_node(m, ".player-matches__match-opponent-flag")
      cc <- NA_character_
      if (!inherits(flag_node, "xml_missing") && !is.na(flag_node)) {
        cls <- rvest::html_attr(flag_node, "class") %||% ""
        cc <- stringr::str_extract(cls,
          "player-matches__match-opponent-flag--[A-Z]{3}")
        cc <- sub("player-matches__match-opponent-flag--", "", cc %||% NA)
      }

      result <- NA_character_
      if (length(rvest::html_nodes(m, ".player-matches__match-cell-result--win")) > 0L) {
        result <- "W"
      } else if (length(rvest::html_nodes(m, ".player-matches__match-cell-result--loss")) > 0L) {
        result <- "L"
      }

      tibble::tibble(
        tournament       = tournament,
        tournament_date  = tournament_date,
        round            = .text_or_na(m, ".player-matches__match-round"),
        opponent         = .text_or_na(m, ".player-matches__match-opponent-name"),
        opponent_seed    = .text_or_na(m, ".player-matches__match-opponent-seed"),
        opponent_country = cc,
        opponent_rank    = .text_or_na(m, ".player-matches__match-cell--opp-rank"),
        score            = .text_or_na(m, ".player-matches__match-cell--score"),
        result           = result
      )
    }))
  }))

  rows
}
