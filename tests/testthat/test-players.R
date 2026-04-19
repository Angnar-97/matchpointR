fixture_path <- function(name) {
  testthat::test_path("fixtures", name)
}

test_that(".parse_player_basics extracts bio from static HTML", {
  page <- xml2::read_html(fixture_path("player_profile.html"))
  out  <- matchpointR:::.parse_player_basics(page, download_images = FALSE)

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 1L)
  expect_equal(out$name, "Katerina Siniakova")
  expect_equal(out$nationality, "Czech Republic")
  expect_equal(out$height, "178 cm")
  expect_equal(out$handedness, "Right")
  expect_equal(out$birth_date, "May 10, 1996")
  expect_equal(out$birth_place, "Hradec Kralove, Czech Republic")
  expect_equal(
    out$player_image_url,
    "https://photo-resources.wtatennis.com/siniakova.png"
  )
  expect_equal(
    out$nationality_flag_url,
    "https://www.wtatennis.com/flags/cz.svg"
  )
})

test_that(".parse_player_matches extracts one row per match", {
  page <- xml2::read_html(fixture_path("player_matches.html"))
  out  <- matchpointR:::.parse_player_matches(page)

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 2L)
  expect_equal(out$tournament, c("Adelaide International", "Australian Open"))
  expect_equal(out$opponent,   c("Iga Swiatek", "Aryna Sabalenka"))
  expect_equal(out$score,      c("6-3 6-4", "7-5 3-6 6-2"))
})

test_that(".parse_player_matches aborts when markup is missing", {
  page <- xml2::read_html("<html><body><p>nope</p></body></html>")
  expect_error(matchpointR:::.parse_player_matches(page),
               regexp = "No match rows")
})

test_that(".build_overview_tibble pads and shapes correctly", {
  s <- as.character(1:12)
  d <- as.character(101:112)
  out <- matchpointR:::.build_overview_tibble(s, d)

  expect_equal(nrow(out), 2L)
  expect_equal(out$stats, c("Singles", "Doubles"))
  expect_equal(out$current_ranking, c("1", "101"))
  expect_equal(out$career_high,     c("7", "107"))
  expect_equal(out$win_rate_career, c("11", "111"))
})

test_that(".build_overview_tibble tolerates short inputs", {
  out <- matchpointR:::.build_overview_tibble(character(0), character(0))
  expect_equal(nrow(out), 2L)
  expect_true(all(is.na(out$current_ranking)))
})
