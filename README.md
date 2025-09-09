# montyhall

<!-- badges: start -->
[![R-CMD-check](https://github.com/MJobinASU/MontyHall/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MJobinASU/MontyHall/actions/workflows/R-CMD-check.yaml)
[![Codecov](https://codecov.io/gh/MJobinASU/MontyHall/branch/main/graph/badge.svg)](https://codecov.io/gh/MJobinASU/MontyHall)
<!-- badges: end -->


This package provides functions to simulate and analyze the Monty Hall problem, a classic probability puzzle involving hidden prizes behind doors. Users can create games, make initial selections, reveal goat doors, and test outcomes under stay-or-switch strategies. The package also supports running repeated simulations to compare winning probabilities, making it a useful tool for teaching probability concepts, exploring decision-making under uncertainty, and replicating the well-known counterintuitive results of the Monty Hall problem.

## Installation

```r
# Option A: pak (fast)
# install.packages("pak")
pak::pak("MJobinASU/MontyHall")

# Option B: devtools
# install.packages("devtools")
devtools::install_github("MJobinASU/MontyHall")

```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
devtools::install_github("MJoibnASU/montyhall")
library(montyhall)
set.seed(42)
simulate_n_games(5000, "switch") |> (\(d) mean(d$win))()
simulate_n_games(5000, "stay") |> (\(d) mean(d$win))()

```

## Functions at a glance

- `create_game()` → Build a random 3-door layout (two `"goat"`, one `"car"`).  
  **Returns:** `character[3]`  
  **Example:** `create_game()`

- `select_door(pick = NULL)` → Choose an initial door (random if `NULL`).  
  **Key args:** `pick` (1, 2, or 3)  
  **Returns:** integer (1–3)  
  **Example:** `select_door()` or `select_door(2)`

- `open_goat_door(game, initial_pick)` → Host opens a goat door that isn’t the player’s pick.  
  **Key args:** `game` (from `create_game()`), `initial_pick` (1–3)  
  **Returns:** integer (1–3)  
  **Example:** 
  ```r
  g <- create_game(); ip <- select_door()
  open_goat_door(g, ip)
  
```

| Function | Purpose | Key args | Returns |
|---|---|---|---|
| `create_game()` | Random 3-door layout (2 goats, 1 car) | — | `character[3]` |
| `select_door()` | Pick an initial door (random if `NULL`) | `pick` | integer (1–3) |
| `open_goat_door()` | Host opens a goat, not your pick | `game`, `initial_pick` | integer (1–3) |
| `change_door()` | Keep or switch | `stay`, `initial_pick`, `opened_door` | integer (1–3) |
| `play_game()` | One complete game | `strategy`, `initial_pick` | list (incl. `win`) |
| `simulate_n_games()` | Many games under one strategy | `n`, `strategy` | data.frame |
