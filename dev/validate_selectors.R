# Live validation of CSS selectors against wtatennis.com.
# Not part of the installed package; sits in `dev/` which is in
# `.Rbuildignore`. Run ad-hoc to refresh selector coverage before release.

suppressPackageStartupMessages({
  library(chromote)
  library(rvest)
  library(xml2)
})

options(chromote.timeout = 30)

devtools::load_all(".")

probe <- function(url, selectors, wait = 6, click_more = NULL, max_clicks = 3) {
  cat("\n== ", url, "\n", sep = "")
  html <- matchpointR:::.chromote_get_html(
    url,
    wait = wait,
    click_more_selector = click_more,
    max_clicks = max_clicks
  )
  page <- read_html(html)
  for (s in selectors) {
    n <- length(html_nodes(page, s))
    cat(sprintf("  [%s] %-60s -> %d node(s)\n",
                if (n > 0) "OK " else "MISS", s, n))
  }
  invisible(page)
}

## 1) Player profile -------------------------------------------------------
probe(
  url = "https://www.wtatennis.com/players/320301/katerina-siniakova",
  selectors = c(
    ".profile-header-info .profile-header__name",
    ".profile-header-info__nationality",
    ".profile-header-info__nationalityFlag",
    ".profile-header-info__detail-stat--small",
    ".profile-header-headshot.full-body img",
    ".fade-in-on-load.is-loaded",
    ".profile-header-toggle__switch-selector",
    ".profile-header-stats__value"
  )
)

## 2) Player matches -------------------------------------------------------
probe(
  url = "https://www.wtatennis.com/players/320301/katerina-siniakova#matches",
  click_more = ".player-matches__more-button",
  selectors = c(
    ".player-matches__row",
    ".player-matches__match-date",
    ".player-matches__tournament-title-link",
    ".player-matches__match-round",
    ".player-matches__match-opponent-first",
    ".player-matches__match-score",
    ".player-matches__more-button"
  )
)

## 3) Rankings -------------------------------------------------------------
probe(
  url = "https://www.wtatennis.com/rankings/singles",
  selectors = c(
    ".rankings-item",                ".rankings__row",
    ".rankings-item__ranking",       ".rankings__rank",
    ".rankings-item__name",          ".rankings__name",
    ".rankings-item__country",       ".rankings__country",
    ".rankings-item__age",           ".rankings__age",
    ".rankings-item__points",        ".rankings__points",
    ".rankings-item__tournaments",   ".rankings__tournaments",
    ".rankings-item__movement",      ".rankings__movement",
    ".rankings__load-more",          ".rankings-load-more"
  )
)

## 4) Stats ----------------------------------------------------------------
probe(
  url = "https://www.wtatennis.com/stats/aces",
  selectors = c(
    ".stats-item",                   ".stats__row",
    ".stats-item__rank",             ".stats__rank",
    ".stats-item__name",             ".stats__name",
    ".stats-item__country",          ".stats__country",
    ".stats-item__value",            ".stats__value",
    ".stats__load-more",             ".stats-load-more"
  )
)

cat("\nDone. Update the internal selectors in R/rankings.R and R/stats.R\n",
    "with whichever rows report OK above.\n", sep = "")
