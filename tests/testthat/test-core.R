test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

test_that("host opens a goat, not the pick", {
  set.seed(1)
  for (i in 1:500) {
    g  <- create_game()
    ip <- select_door()
    od <- open_goat_door(g, ip)
    expect_true(od != ip)
    expect_identical(g[od], "goat")
  }
})

test_that("change_door returns a single valid other door when switching", {
  for (ip in 1:3) for (od in setdiff(1:3, ip)) {
    fp <- change_door(FALSE, ip, od)
    expect_length(fp, 1)
    expect_true(fp %in% 1:3)
    expect_true(fp != ip && fp != od)
  }
})

test_that("play_game returns a valid result structure", {
  res <- play_game("switch")
  expect_true(is.list(res))
  expect_named(res, c("game","initial_pick","opened_door","final_pick","strategy","win"))
  expect_length(res$game, 3)
  expect_true(res$initial_pick %in% 1:3)
  expect_true(res$opened_door %in% 1:3)
  expect_true(res$final_pick  %in% 1:3)
})

test_that("switching wins more often than staying", {
  set.seed(42)
  stay   <- simulate_n_games(2000, "stay")
  switch <- simulate_n_games(2000, "switch")
  expect_gt(mean(switch$win), mean(stay$win))
})
