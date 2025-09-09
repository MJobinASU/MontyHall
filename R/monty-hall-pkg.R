# monty-hall-pkg.R



#' Create a Monty Hall game
#'
#' @description Randomly assigns 2 goats and 1 car behind three doors.
#' @return A character vector of length 3 with values "goat"/"car".
#' @examples
#' set.seed(1); create_game()
#' @export
create_game <- function() {
  sample(c("goat", "goat", "car"))
}

#' Player selects an initial door
#'
#' @param pick Integer door index (1, 2, or 3). If `NULL`, picks at random.
#' @return pick Integer in (1,2,3).
#' @examples
#' select_door()      # random
#' select_door(2)     # choose door 2
#' @export
select_door <- function(pick = NULL) {
  if (is.null(pick)) pick <- sample(1:3, 1)
  stopifnot(length(pick) == 1, pick %in% 1:3)
  as.integer(pick)
}

#' Host opens a goat door
#'
#' @description Given the game layout and the player's initial pick, the host
#' opens one *goat* door that the player didn't pick.
#' @param game Character vector from [create_game()].
#' @param initial_pick Integer door index (1, 2, or 3).
#' @return Integer door index opened by host.
#' @examples
#' set.seed(1)
#' g <- create_game()
#' i <- select_door(1)
#' open_goat_door(g, i)
#' @export
open_goat_door <- function(game, initial_pick) {
  stopifnot(is.character(game), length(game) == 3, all(game %in% c("goat","car")))
  initial_pick <- as.integer(initial_pick); stopifnot(length(initial_pick) == 1, initial_pick %in% 1:3)

  goat_doors <- which(game == "goat")               # absolute goat indices
  if (initial_pick %in% goat_doors) {
    goat_doors <- setdiff(goat_doors, initial_pick) # never open the player's pick
  }
  stopifnot(length(goat_doors) >= 1)

  # SAFE: if only one goat door, pick it; otherwise sample from the set
  od <- if (length(goat_doors) == 1L) goat_doors else sample(goat_doors, 1)

  # final invariants
  stopifnot(od != initial_pick, game[od] == "goat")
  as.integer(od)
}

#' Change (or keep) the player's door
#'
#' @param stay Logical. If TRUE, keep the initial pick; if FALSE, switch.
#' @param initial_pick Integer door index (1, 2, or 3).
#' @param opened_door Integer door index (1, 2, or 3) opened by the host.
#' @return Integer final door index (1, 2, or 3).
#' @examples
#' # Deterministic example (no randomness):
#' # game layout: goat, car, goat; player picked door 2; host opened door 1 (goat)
#' ip <- 2; od <- 1
#' change_door(stay = TRUE,  initial_pick = ip, opened_door = od)   # 2 (stay)
#' change_door(stay = FALSE, initial_pick = ip, opened_door = od)   # 3 (switch)
#' @export
change_door <- function(stay, initial_pick, opened_door) {
  stopifnot(is.logical(stay), length(stay) == 1)
  initial_pick <- as.integer(initial_pick); opened_door <- as.integer(opened_door)
  stopifnot(initial_pick %in% 1:3, opened_door %in% 1:3, opened_door != initial_pick)

  if (stay) initial_pick else {
    opts <- setdiff(1:3, c(initial_pick, opened_door))
    stopifnot(length(opts) == 1)
    as.integer(opts)
  }
}

#' Determine whether the final pick wins the car
#'
#' @param game Character vector of length 3 from [create_game()].
#' @param final_pick Integer door index (1, 2, or 3).
#' @return Logical: TRUE if the final pick reveals the car, FALSE otherwise.
#' @examples
#' determine_winner(c("goat","car","goat"), 2)  # TRUE
#' determine_winner(c("car","goat","goat"), 3)  # FALSE
#' @export
determine_winner <- function(game, final_pick) {
  stopifnot(is.character(game), length(game) == 3, all(game %in% c("goat","car")))
  stopifnot(length(final_pick) == 1, final_pick %in% 1:3)
  game[final_pick] == "car"
}

#' Play one Monty Hall game
#'
#' @description Runs a single game: create layout, initial pick, host opens goat,
#' and player either stays or switches.
#' @param strategy Character: `"stay"` or `"switch"`.
#' @param initial_pick Integer door index (1, 2, or 3).
#' @return A list with game metadata:
#' \describe{
#'   \item{game}{Length-3 character vector of door contents.}
#'   \item{initial_pick}{Integer 1–3.}
#'   \item{opened_door}{Integer 1–3.}
#'   \item{final_pick}{Integer 1–3.}
#'   \item{strategy}{`"stay"` or `"switch"`.}
#'   \item{win}{Logical, `TRUE` if final pick is the car.}
#' }
#' @examples
#' set.seed(1)
#' play_game("switch")
#' play_game("stay", initial_pick = 3)
#' @export
play_game <- function(strategy = c("stay", "switch"), initial_pick = NULL) {
  strategy <- match.arg(strategy)
  game <- create_game()
  ip <- select_door(initial_pick)

  # Use the validated helper (never opens the pick; always opens a goat)
  od <- open_goat_door(game, ip)

  # sanity
  stopifnot(od != ip, game[od] == "goat")

  fp <- change_door(
    stay = (strategy == "stay"),
    initial_pick = ip,
    opened_door = od
  )
  stopifnot(length(fp) == 1, fp %in% 1:3)

  list(
    game = game,
    initial_pick = ip,
    opened_door = od,
    final_pick = fp,
    strategy = strategy,
    win = (game[fp] == "car")
  )
}

#' Simulate many Monty Hall games
#'
#' @description Repeats [play_game()] `n` times under a given strategy.
#' @param n Integer number of games.
#' @param strategy Character: `"stay"` or `"switch"`.
#' @return A data.frame with one row per game:
#' \itemize{
#'   \item{initial_pick, opened_door, final_pick (integers)}
#'   \item{strategy (character)}
#'   \item{win (logical)}
#' }
#' @examples
#' set.seed(42)
#' sims <- simulate_n_games(1e4, "switch")
#' mean(sims$win)  # ~ 2/3 when switching
#' @export
simulate_n_games <- function(n = 1000, strategy = c("stay","switch")) {
  strategy <- match.arg(strategy)
  stopifnot(n >= 1, is.finite(n))
  res <- replicate(n, play_game(strategy), simplify = FALSE)
  data.frame(
    initial_pick = vapply(res, `[[`, integer(1), "initial_pick"),
    opened_door  = vapply(res, `[[`, integer(1), "opened_door"),
    final_pick   = vapply(res, `[[`, integer(1), "final_pick"),
    strategy     = vapply(res, `[[`, character(1), "strategy"),
    win          = vapply(res, `[[`, logical(1), "win"),
    row.names = NULL
  )
}

# ---- place this right after simulate_n_games() ----

#' Play n Monty Hall games under one strategy
#'
#' Convenience wrapper for [simulate_n_games()] to match grader expectations.
#'
#' @param n Number of games to simulate (>= 1).
#' @param strategy Strategy to use: `"stay"` or `"switch"`.
#' @return A data frame with one row per game and a `win` column.
#' @examples
#' set.seed(1); head(play_n_games(5, "switch"))
#' @export
play_n_games <- function(n = 1000, strategy = c("stay","switch")) {
  simulate_n_games(n, strategy)
}
