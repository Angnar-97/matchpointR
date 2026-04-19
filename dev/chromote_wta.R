

# -------------------------------------------------------------------------
#  Utilities ----------------------------------------------------------------

#' @title Memoised versions of expensive calls
#' @keywords internal
memoise_wta_get_player_basics   <- memoise::memoise(wta_get_player_basics)
memoise_wta_get_player_overview <- memoise::memoise(wta_get_player_overview)

library(chromote)
library(xml2)
library(rvest)
library(purrr)
library(dplyr)

# 1) Nuevo extractor que scroll + clic
wta_chromote_html <- function(url, wait_initial = 5, wait_click = 2) {
  ss <- ChromoteSession$new()
  on.exit(ss$close(), add = TRUE)

  ss$Page$navigate(url)
  Sys.sleep(wait_initial)

  # Mientras haya botón "Show more", click + scroll
  repeat {
    has_more <- ss$Runtime$evaluate(
      "document.querySelector('.player-matches__more-button') !== null"
    )$result$value
    if (!isTRUE(has_more)) break

    ss$Runtime$evaluate(
      "document.querySelector('.player-matches__more-button').click();"
    )
    Sys.sleep(wait_click)
    ss$Runtime$evaluate("window.scrollTo(0, document.body.scrollHeight);")
    Sys.sleep(wait_click)
  }

  ss$Runtime$evaluate("document.documentElement.outerHTML")$result$value
}

# 2) Función de parsing: filas en `.player-matches__row`
wta_get_player_matches <- function(url) {
  html <- wta_chromote_html(url)
  page <- read_html(html)

  rows <- page %>% html_nodes(".player-matches__row")
  if (length(rows) == 0) {
    stop("No se encontró ningún partido: revisa tu extractor o el selector CSS.")
  }

  map_df(rows, function(r) {
    tibble(
      date       = r %>% html_node(".player-matches__match-date")        %>% html_text(trim = TRUE),
      tournament = r %>% html_node(".player-matches__tournament-title-link") %>% html_text(trim = TRUE),
      round      = r %>% html_node(".player-matches__match-round")       %>% html_text(trim = TRUE),
      opponent   = r %>% html_node(".player-matches__match-opponent-first") %>% html_text(trim = TRUE),
      score      = r %>% html_node(".player-matches__match-score")       %>% html_text(trim = TRUE)
    )
  })
}

# 3) Prueba rápida
matches <- wta_get_player_matches("https://www.wtatennis.com/players/320301/katerina-siniakova#matches")
print(matches)
