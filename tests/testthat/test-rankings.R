read_ranking_fixture <- function() {
  xml2::read_html(testthat::test_path("fixtures", "rankings_singles.html"))
}

test_that(".parse_rankings extracts rows from the real tbody structure", {
  page <- read_ranking_fixture()
  out  <- matchpointR:::.parse_rankings(page)

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 3L)
  expect_equal(out$rank,      c("1", "2", "3"))
  expect_equal(out$player_id, c("320760", "321091", "324166"))
  expect_equal(out$player,
               c("Aryna Sabalenka", "Iga Swiatek", "Elena Rybakina"))
  expect_equal(out$country,   c("BLR", "POL", "KAZ"))
  expect_equal(out$age,       c("27", "24", "26"))
  expect_equal(out$tournaments_played, c("20", "22", "18"))
  expect_equal(out$points,    c("11,025", "8,108", "6,450"))
})

test_that(".parse_rankings aborts on empty page", {
  page <- xml2::read_html("<html><body></body></html>")
  expect_error(matchpointR:::.parse_rankings(page), "No ranking rows")
})
