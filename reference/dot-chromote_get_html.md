# Fetch fully-rendered HTML with chromote

Opens a headless Chrome session via chromote, waits for the page to
settle, optionally clicks a "load more" button and/or scrolls, and
returns the complete page source.

## Usage

``` r
.chromote_get_html(
  url,
  wait = 8,
  click_more_selector = NULL,
  scroll = TRUE,
  max_clicks = 50L,
  session = NULL
)
```

## Arguments

- url:

  Character. Destination URL.

- wait:

  Numeric. Seconds to wait after initial navigation. Default 8.

- click_more_selector:

  Optional CSS selector for a "load more" button that should be clicked
  repeatedly until it disappears.

- scroll:

  Logical. Scroll to the bottom after each click? Default TRUE.

- max_clicks:

  Integer. Safety cap for the click loop. Default 50.

- session:

  Optional pre-existing
  [`chromote::ChromoteSession`](https://rstudio.github.io/chromote/reference/ChromoteSession.html).
  When supplied it is reused (callers are responsible for closing it).

## Value

A character string containing the full page source.
