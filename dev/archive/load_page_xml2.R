load_page_xml2 <- function(url) {

  content <- chromote_extractor(url)

  xml2::read_html(content)
}
