# Read dynamic HTML into an xml2 document

Thin wrapper around
[`.chromote_get_html()`](https://angnar-97.github.io/matchpointR/reference/dot-chromote_get_html.md)
that parses the rendered HTML with
[`xml2::read_html()`](http://xml2.r-lib.org/reference/read_xml.md).

## Usage

``` r
.read_html_dynamic(
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

An `xml2::xml_document`.
