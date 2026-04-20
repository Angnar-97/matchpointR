test_that("wta_player_url composes canonical URLs", {
  expect_equal(
    wta_player_url(320301, "katerina-siniakova"),
    "https://www.wtatennis.com/players/320301/katerina-siniakova"
  )
  expect_equal(
    wta_player_url(320301),
    "https://www.wtatennis.com/players/320301"
  )
  expect_equal(
    wta_player_url(320301, "katerina-siniakova", "matches"),
    "https://www.wtatennis.com/players/320301/katerina-siniakova/matches"
  )
  expect_error(wta_player_url(320301, section = "stats"))
})

test_that(".abs_url resolves relative, protocol-relative and absolute URLs", {
  expect_equal(
    matchpointR:::.abs_url("/flags/cz.svg"),
    "https://www.wtatennis.com/flags/cz.svg"
  )
  expect_equal(
    matchpointR:::.abs_url("//cdn.example.com/x.png"),
    "https://cdn.example.com/x.png"
  )
  expect_equal(
    matchpointR:::.abs_url("https://cdn.example.com/x.png"),
    "https://cdn.example.com/x.png"
  )
  expect_true(is.na(matchpointR:::.abs_url(NA_character_)))
  expect_true(is.na(matchpointR:::.abs_url("")))
})

test_that(".text_or_na / .attr_or_na return NA for missing nodes", {
  page <- xml2::read_html(
    "<html><body><p class='x'>hi</p><img class='y' src='/f.png'/></body></html>"
  )
  expect_equal(matchpointR:::.text_or_na(page, ".x"), "hi")
  expect_true(is.na(matchpointR:::.text_or_na(page, ".missing")))
  expect_equal(matchpointR:::.attr_or_na(page, ".y", "src"), "/f.png")
  expect_true(is.na(matchpointR:::.attr_or_na(page, ".missing", "src")))
})

test_that(".extract_jsonld finds the right schema.org block", {
  page <- xml2::read_html(paste0(
    '<html><head>',
    '<script type="application/ld+json">{"@type":"Organization","name":"X"}</script>',
    '<script type="application/ld+json">{"@type":"Person","name":"Y"}</script>',
    '</head><body></body></html>'
  ))
  person <- matchpointR:::.extract_jsonld(page, "Person")
  expect_equal(person$name, "Y")
  org <- matchpointR:::.extract_jsonld(page, "Organization")
  expect_equal(org$name, "X")
  expect_null(matchpointR:::.extract_jsonld(page, "Event"))
})

test_that(".prop_value picks the named value from additionalProperty", {
  props <- list(
    list(name = "Plays", value = "Right-Handed"),
    list(name = "WTA Singles Rank", value = "42")
  )
  expect_equal(matchpointR:::.prop_value(props, "Plays"), "Right-Handed")
  expect_equal(matchpointR:::.prop_value(props, "WTA Singles Rank"), "42")
  expect_true(is.na(matchpointR:::.prop_value(props, "Missing")))
  expect_true(is.na(matchpointR:::.prop_value(NULL, "Plays")))
})

test_that(".bio_info reads content by title", {
  page <- xml2::read_html(testthat::test_path("fixtures", "player_profile.html"))
  expect_equal(matchpointR:::.bio_info(page, "Height"), "5' 9\" (1.74m)")
  expect_equal(matchpointR:::.bio_info(page, "Career High"), "27")
  expect_true(is.na(matchpointR:::.bio_info(page, "Missing")))
})
