#' Build a WTA player URL
#'
#' Convenience wrapper to assemble a canonical player URL from a numeric id
#' and an optional slug.
#'
#' @param id Character or integer. The WTA numeric player id (e.g. `320301`).
#' @param slug Optional character. Player slug (e.g. `"katerina-siniakova"`).
#'   When omitted the URL still resolves — WTA redirects to the canonical one.
#' @param section Optional character. Page section to append as a path
#'   segment, one of `"overview"`, `"matches"`. Defaults to `"overview"`,
#'   which maps to the bare player URL.
#'
#' @return A single character string with the full URL.
#' @export
#' @examples
#' wta_player_url(320301, "katerina-siniakova")
#' wta_player_url(320301, "katerina-siniakova", "matches")
wta_player_url <- function(id, slug = NULL, section = c("overview", "matches")) {
  section <- match.arg(section)
  base <- sprintf("https://www.wtatennis.com/players/%s", id)
  if (!is.null(slug) && nzchar(slug)) base <- paste(base, slug, sep = "/")
  if (section == "overview") base else paste(base, section, sep = "/")
}

# -------------------------------------------------------------------------
#  Internal: dynamic HTML fetching ----------------------------------------

#' Fetch fully-rendered HTML with chromote
#'
#' Opens a headless Chrome session via \pkg{chromote}, waits for the page to
#' settle, optionally clicks a "load more" button and/or scrolls, and returns
#' the complete page source.
#'
#' @param url Character. Destination URL.
#' @param wait Numeric. Seconds to wait after initial navigation. Default 8.
#' @param click_more_selector Optional CSS selector for a "load more" button
#'   that should be clicked repeatedly until it disappears.
#' @param scroll Logical. Scroll to the bottom after each click? Default TRUE.
#' @param max_clicks Integer. Safety cap for the click loop. Default 50.
#' @param session Optional pre-existing `chromote::ChromoteSession`. When
#'   supplied it is reused (callers are responsible for closing it).
#'
#' @return A character string containing the full page source.
#' @keywords internal
#' @importFrom chromote ChromoteSession
.chromote_get_html <- function(url,
                               wait = 8,
                               click_more_selector = NULL,
                               scroll = TRUE,
                               max_clicks = 50L,
                               session = NULL) {
  ss <- session %||% chromote::ChromoteSession$new()
  if (is.null(session)) on.exit(try(ss$close(), silent = TRUE), add = TRUE)

  try(ss$Page$navigate(url, wait_ = FALSE), silent = TRUE)
  Sys.sleep(wait)

  if (scroll) {
    for (i in seq_len(3L)) {
      try(ss$Runtime$evaluate(
        "window.scrollTo(0, document.body.scrollHeight)"
      ), silent = TRUE)
      Sys.sleep(1)
    }
  }

  if (!is.null(click_more_selector)) {
    for (i in seq_len(max_clicks)) {
      present <- ss$Runtime$evaluate(
        sprintf("document.querySelector('%s') !== null", click_more_selector)
      )$result$value
      if (!isTRUE(present)) break
      ss$Runtime$evaluate(
        sprintf("document.querySelector('%s').click()", click_more_selector)
      )
      Sys.sleep(1.5)
      if (scroll) {
        ss$Runtime$evaluate("window.scrollTo(0, document.body.scrollHeight)")
        Sys.sleep(1)
      }
    }
  }

  ss$Runtime$evaluate("document.documentElement.outerHTML")$result$value
}

#' Read dynamic HTML into an xml2 document
#'
#' Thin wrapper around [`.chromote_get_html()`] that parses the rendered HTML
#' with [`xml2::read_html()`].
#'
#' @inheritParams .chromote_get_html
#' @return An `xml2::xml_document`.
#' @keywords internal
#' @importFrom xml2 read_html
.read_html_dynamic <- function(url, wait = 8, click_more_selector = NULL,
                               scroll = TRUE, max_clicks = 50L, session = NULL) {
  html <- .chromote_get_html(
    url = url, wait = wait,
    click_more_selector = click_more_selector,
    scroll = scroll, max_clicks = max_clicks, session = session
  )
  xml2::read_html(html)
}

# -------------------------------------------------------------------------
#  Internal: JSON-LD extraction -------------------------------------------

#' Extract a JSON-LD block of a given schema.org type
#'
#' The WTA site embeds several `<script type="application/ld+json">` blocks
#' per page. This helper parses each one and returns the first whose
#' `@type` equals `type`.
#'
#' @param page An `xml2::xml_document`.
#' @param type Character. schema.org type (e.g. `"Person"`).
#' @return A list parsed from JSON, or `NULL` if not found.
#' @keywords internal
#' @noRd
.extract_jsonld <- function(page, type) {
  nodes <- rvest::html_nodes(page, 'script[type="application/ld+json"]')
  for (n in nodes) {
    txt <- rvest::html_text(n)
    if (!nzchar(txt)) next
    parsed <- tryCatch(
      jsonlite::fromJSON(txt, simplifyVector = FALSE),
      error = function(e) NULL
    )
    if (is.null(parsed)) next
    t <- parsed[["@type"]]
    if (!is.null(t) && identical(t, type)) return(parsed)
  }
  NULL
}

# -------------------------------------------------------------------------
#  Internal: small helpers ------------------------------------------------

#' Null-coalescing operator
#' @keywords internal
#' @noRd
`%||%` <- function(a, b) if (is.null(a)) b else a

#' Safe text extraction from a single node
#' @keywords internal
#' @noRd
.text_or_na <- function(node, selector) {
  n <- rvest::html_node(node, selector)
  if (inherits(n, "xml_missing") || is.na(n)) return(NA_character_)
  stringr::str_squish(rvest::html_text(n, trim = TRUE))
}

#' Safe attribute extraction
#' @keywords internal
#' @noRd
.attr_or_na <- function(node, selector, attr) {
  n <- rvest::html_node(node, selector)
  if (inherits(n, "xml_missing") || is.na(n)) return(NA_character_)
  rvest::html_attr(n, attr)
}

#' Resolve a possibly-relative URL against the WTA base
#' @keywords internal
#' @noRd
.abs_url <- function(src, base = "https://www.wtatennis.com") {
  if (is.na(src) || !nzchar(src)) return(NA_character_)
  if (grepl("^https?://", src)) return(src)
  if (grepl("^//", src)) return(paste0("https:", src))
  paste0(base, src)
}

#' Pick the first non-empty value from `additionalProperty` by name
#'
#' @param props A list (as parsed from JSON-LD) of property-value objects.
#' @param nm Character. The `name` field to match.
#' @return Character scalar or `NA_character_`.
#' @keywords internal
#' @noRd
.prop_value <- function(props, nm) {
  if (is.null(props) || length(props) == 0L) return(NA_character_)
  for (p in props) {
    if (identical(p[["name"]], nm)) {
      v <- p[["value"]]
      if (!is.null(v) && length(v) == 1L && nzchar(as.character(v))) {
        return(as.character(v))
      }
    }
  }
  NA_character_
}

#' Extract the content of a `.profile-bio__info-block` by its title text
#'
#' @param page An `xml2::xml_document` or node.
#' @param title Character. Case-insensitive match against
#'   `.profile-bio__info-title`.
#' @return Character scalar or `NA_character_`.
#' @keywords internal
#' @noRd
.bio_info <- function(page, title) {
  blocks <- rvest::html_nodes(page, ".profile-bio__info-block")
  if (length(blocks) == 0L) return(NA_character_)
  titles <- vapply(blocks, .text_or_na, character(1),
                   selector = ".profile-bio__info-title")
  hit <- which(tolower(titles) == tolower(title))
  if (length(hit) == 0L) return(NA_character_)
  .text_or_na(blocks[[hit[1]]], ".profile-bio__info-content")
}
