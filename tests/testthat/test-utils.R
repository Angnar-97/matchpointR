test_that("wta_player_url composes canonical URLs", {
  expect_equal(
    wta_player_url(320301, "katerina-siniakova"),
    "https://www.wtatennis.com/players/320301/katerina-siniakova#overview"
  )
  expect_equal(
    wta_player_url(320301),
    "https://www.wtatennis.com/players/320301#overview"
  )
  expect_equal(
    wta_player_url(320301, "katerina-siniakova", "matches"),
    "https://www.wtatennis.com/players/320301/katerina-siniakova#matches"
  )
  expect_error(wta_player_url(320301, section = "foo"))
})

test_that(".abs_url resolves relative and absolute URLs", {
  expect_equal(
    matchpointR:::.abs_url("/flags/cz.svg"),
    "https://www.wtatennis.com/flags/cz.svg"
  )
  expect_equal(
    matchpointR:::.abs_url("https://cdn.example.com/x.png"),
    "https://cdn.example.com/x.png"
  )
  expect_true(is.na(matchpointR:::.abs_url(NA_character_)))
  expect_true(is.na(matchpointR:::.abs_url("")))
})

test_that(".text_or_na returns NA for missing nodes", {
  page <- xml2::read_html("<html><body><p class='x'>hi</p></body></html>")
  expect_equal(matchpointR:::.text_or_na(page, ".x"), "hi")
  expect_true(is.na(matchpointR:::.text_or_na(page, ".does-not-exist")))
})

test_that(".attr_or_na returns NA for missing nodes", {
  page <- xml2::read_html(
    "<html><body><img class='y' src='/foo.png' /></body></html>"
  )
  expect_equal(matchpointR:::.attr_or_na(page, ".y", "src"), "/foo.png")
  expect_true(is.na(matchpointR:::.attr_or_na(page, ".missing", "src")))
})
