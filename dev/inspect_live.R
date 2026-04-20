suppressPackageStartupMessages({
  library(chromote)
  library(rvest)
  library(xml2)
})

options(chromote.timeout = 30)

inspect <- function(url, wait = 8) {
  cat("\n============================================================\n")
  cat("URL:", url, "\n")
  cat("------------------------------------------------------------\n")
  ss <- ChromoteSession$new()
  on.exit(try(ss$close(), silent = TRUE), add = TRUE)

  ss$Page$navigate(url)
  Sys.sleep(wait)

  final_url <- ss$Runtime$evaluate("window.location.href")$result$value
  cat("Final URL after load:", final_url, "\n")

  title <- ss$Runtime$evaluate("document.title")$result$value
  cat("Title: ", title, "\n")

  body_len <- ss$Runtime$evaluate(
    "document.body ? document.body.innerText.length : -1"
  )$result$value
  cat("body.innerText length:", body_len, "\n")

  first_text <- ss$Runtime$evaluate(
    "document.body ? document.body.innerText.substring(0, 500) : 'NO BODY'"
  )$result$value
  cat("first 500 chars:\n")
  cat(first_text, "\n")

  html <- ss$Runtime$evaluate("document.documentElement.outerHTML")$result$value
  cat("outerHTML length:", nchar(html), "\n")

  ## look for common class prefixes actually present
  page <- read_html(html)
  all_classes <- page |>
    html_elements("[class]") |>
    html_attr("class")
  tokens <- unique(unlist(strsplit(all_classes, "\\s+")))
  tokens <- tokens[nzchar(tokens)]
  interesting <- grep(
    "(profile|player|rank|stats|match|header|toggle)",
    tokens, value = TRUE, ignore.case = TRUE
  )
  cat("Distinct class tokens related to profile/player/etc:",
      length(interesting), "\n")
  if (length(interesting) > 0) {
    cat(" first 40:\n")
    print(head(interesting, 40))
  }
}

inspect("https://www.wtatennis.com/players/320301/katerina-siniakova")
inspect("https://www.wtatennis.com/rankings/singles")
inspect("https://www.wtatennis.com/stats/aces")
