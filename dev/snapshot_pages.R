suppressPackageStartupMessages({
  library(chromote)
})

options(chromote.timeout = 60)

dir.create("dev/snapshots", showWarnings = FALSE, recursive = TRUE)

snap <- function(url, out, wait_initial = 10, extra_scripts = list(),
                 post_sleep = 2) {
  cat("\n--", out, "--\n")
  ss <- tryCatch(ChromoteSession$new(), error = function(e) {
    cat("ChromoteSession failed:", conditionMessage(e), "\n"); NULL
  })
  if (is.null(ss)) return(invisible(NULL))
  on.exit(try(ss$close(), silent = TRUE), add = TRUE)

  tryCatch({
    ss$Page$navigate(url, wait_ = FALSE)
  }, error = function(e) cat("navigate error:", conditionMessage(e), "\n"))

  Sys.sleep(wait_initial)

  ## scroll to trigger lazy loading
  for (i in 1:4) {
    try(ss$Runtime$evaluate("window.scrollTo(0, document.body.scrollHeight)"),
        silent = TRUE)
    Sys.sleep(1.5)
  }

  for (s in extra_scripts) {
    try(ss$Runtime$evaluate(s), silent = TRUE)
    Sys.sleep(post_sleep)
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
  } else {
    cat(" NO HTML captured\n")
  }
}

## Player profile
snap("https://www.wtatennis.com/players/320301/katerina-siniakova",
     "player_profile.html",
     wait_initial = 12)

## Player matches — click Show more a few times
snap("https://www.wtatennis.com/players/320301/katerina-siniakova#matches",
     "player_matches.html",
     wait_initial = 15,
     extra_scripts = list(
       "document.querySelectorAll('button,a').forEach(function(b){ if((b.innerText||'').match(/show more/i)) b.click(); })",
       "document.querySelectorAll('button,a').forEach(function(b){ if((b.innerText||'').match(/show more/i)) b.click(); })"
     ))

## Rankings
snap("https://www.wtatennis.com/rankings/singles",
     "rankings_singles.html",
     wait_initial = 18)

## Stats
snap("https://www.wtatennis.com/stats/aces",
     "stats_aces.html",
     wait_initial = 18)

cat("\nSnapshots done.\n")
