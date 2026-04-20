suppressPackageStartupMessages({
  library(chromote)
})

options(chromote.timeout = 60)

dir.create("dev/snapshots", showWarnings = FALSE, recursive = TRUE)

snap <- function(url, out, wait_initial = 14, click_passes = 3, post_sleep = 2) {
  cat("\n--", out, "--\n")
  ss <- ChromoteSession$new()
  on.exit(try(ss$close(), silent = TRUE), add = TRUE)

  try(ss$Page$navigate(url, wait_ = FALSE), silent = TRUE)
  Sys.sleep(wait_initial)

  for (i in seq_len(4)) {
    try(ss$Runtime$evaluate("window.scrollTo(0, document.body.scrollHeight)"), silent = TRUE)
    Sys.sleep(1.5)
  }

  for (i in seq_len(click_passes)) {
    try(ss$Runtime$evaluate(
      "document.querySelectorAll('button,a').forEach(function(b){ var t=(b.innerText||'').toLowerCase(); if(t.match(/show more|load more/)) b.click(); })"
    ), silent = TRUE)
    Sys.sleep(post_sleep)
    try(ss$Runtime$evaluate("window.scrollTo(0, document.body.scrollHeight)"), silent = TRUE)
    Sys.sleep(1.5)
  }

  final_url <- tryCatch(
    ss$Runtime$evaluate("window.location.href")$result$value,
    error = function(e) NA_character_
  )
  cat(" final URL:", final_url, "\n")

  html <- tryCatch(
    ss$Runtime$evaluate("document.documentElement.outerHTML")$result$value,
    error = function(e) NA_character_
  )
  if (!is.na(html)) {
    writeLines(html, file.path("dev/snapshots", out), useBytes = TRUE)
    cat(" wrote", file.path("dev/snapshots", out), "(", nchar(html), "bytes)\n")
  }
}

snap("https://www.wtatennis.com/players/320301/katerina-siniakova/matches",
     "player_matches2.html", wait_initial = 14, click_passes = 5)

snap("https://www.wtatennis.com/stats",
     "stats_root.html", wait_initial = 14, click_passes = 1)
