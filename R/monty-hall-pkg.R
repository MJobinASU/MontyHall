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
#' @return Integer in {1,2,3}.
#' @examples
#' select_door()      # random
#' select_door(2)     # choose door 2
#' @export
select_door <- function(pick = NULL) {
  if (is.null(pick)) return(sample(1:3, 1))
  stopifnot(pick %in% 1:3)
  pick
}

#' Host opens a goat door
#'
#' @description Given the game layout and the player's initial pick, the host
#' opens one *goat* door that the player didn't pick.
#' @param game Character vector from [create_game()].
#' @param initial_pick Integer in {1,2,3}.
#' @return Integer door index opened by host.
#' @examples
#' set.seed(1)
#' g <- create_game()
#' i <- select_door(1)
#' open_goat_door(g, i)
#' @export
open_goat_door <- function(game, initial_pick) {
  stopifnot(length(game) == 3, initial_pick %in% 1:3)
  candidates <- setdiff(1:3, initial_pick)
  goat_doors <- candidates[game[candidates] == "goat"]
  sample(goat_doors, 1)
}

#' Change (or keep) the player's door
#'
#' @param stay Logical. If `TRUE`, keep the initial pick; if `FALSE`, switch.
#' @param initial_pick Integer in {1,2,3}.
#' @param opened_door Integer in {1,2,3} opened by the host.
#' @return Integer final door index chosen by the player.
#' @examples
#' change_door(stay = TRUE,  initial_pick = 2, opened_door = 1)
#' change_door(stay = FALSE, initial_pick = 2, opened_door = 1)
#' @export
change_door <- function(stay, initial_pick, opened_door) {
  stopifnot(is.logical(stay), initial_pick %in% 1:3, opened_door %in% 1:3)
  if (stay) return(initial_pick)
  setdiff(1:3, c(initial_pick, opened_door))
}

#' Play one Monty Hall game
#'
#' @description Runs a single game: create layout, initial pick, host opens goat,
#' and player either stays or switches.
#' @param strategy Character: `"stay"` or `"switch"`.
#' @param initial_pick Optional integer pick (1–3); if `NULL`, picks randomly.
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
  od <- open_goat_door(game, ip)
  fp <- change_door(stay = (strategy == "stay"), initial_pick = ip, opened_door = od)
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
simulate_n_games <- function(n = 1000, strategy = c("stay", "switch")) {
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
