read_fixture <- function(name) {
  xml2::read_html(testthat::test_path("fixtures", name))
}

test_that(".parse_player_basics reads JSON-LD + bio", {
  page <- read_fixture("player_profile.html")
  out  <- matchpointR:::.parse_player_basics(page, download_images = FALSE)

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 1L)
  expect_equal(out$player_id,     "320301")
  expect_equal(out$name,          "Katerina Siniakova")
  expect_equal(out$given_name,    "Katerina")
  expect_equal(out$family_name,   "Siniakova")
  expect_equal(out$birth_date,    "1996-05-10")
  expect_equal(out$nationality,   "Czech Republic")
  expect_equal(out$birth_place,   "Hradec Kralove")
  expect_equal(out$birth_country, "Czech Republic")
  expect_equal(out$handedness,    "Right-Handed")
  expect_equal(out$height,        "5' 9\" (1.74m)")
  expect_equal(
    out$player_image_url,
    "https://wtafiles.blob.core.windows.net/images/headshots/320301.jpg"
  )
})

test_that(".parse_player_overview builds the metric/value long table", {
  page <- read_fixture("player_profile.html")
  out  <- matchpointR:::.parse_player_overview(page)

  expect_s3_class(out, "tbl_df")
  expect_equal(ncol(out), 2L)
  expect_setequal(out$metric, c(
    "singles_rank", "doubles_rank",
    "singles_career_titles", "doubles_career_titles",
    "career_prize_money", "career_high"
  ))
  expect_equal(out$value[out$metric == "singles_rank"],          "42")
  expect_equal(out$value[out$metric == "doubles_rank"],          "2")
  expect_equal(out$value[out$metric == "singles_career_titles"], "5")
  expect_equal(out$value[out$metric == "doubles_career_titles"], "35")
  expect_equal(out$value[out$metric == "career_prize_money"],    "$15,787,557")
  expect_equal(out$value[out$metric == "career_high"],           "27")
})

test_that(".parse_player_matches extracts matches per tournament", {
  page <- read_fixture("player_matches.html")
  out  <- matchpointR:::.parse_player_matches(page)

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 3L)
  expect_equal(out$tournament,
               c("Miami Open", "Miami Open", "BNP Paribas Open"))
  expect_equal(out$opponent,
               c("Jessica Pegula", "Paula Badosa", "Iga Swiatek"))
  expect_equal(out$opponent_country, c("USA", "ESP", "POL"))
  expect_equal(out$round,   c("F", "SF", "R16"))
  expect_equal(out$score,   c("6-3 6-4", "7-5 3-6 6-2", "4-6 3-6"))
  expect_equal(out$result,  c("W", "W", "L"))
  expect_equal(out$tournament_date[1], "2026-03-17")
})

test_that(".parse_player_matches aborts when no tournaments found", {
  page <- xml2::read_html("<html><body><p>nope</p></body></html>")
  expect_error(matchpointR:::.parse_player_matches(page),
               regexp = "No tournaments")
})
