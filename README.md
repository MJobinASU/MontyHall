[![R-CMD-check](https://github.com/MJobinASU/montyhall/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MJobinASU/montyhall/actions/workflows/R-CMD-check.yaml)
[![Codecov](https://codecov.io/gh/MJobinASU/montyhall/branch/main/graph/badge.svg)](https://codecov.io/gh/MJobinASU/montyhall)


# montyhall

<!-- badges: start -->
[![R-CMD-check](https://github.com/MJobinASU/MontyHall/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MJobinASU/MontyHall/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/MJobinASU/MontyHall/graph/badge.svg)](https://app.codecov.io/gh/MJobinASU/MontyHall)
<!-- badges: end -->

This package provides functions to simulate and analyze the Monty Hall problem, a classic probability puzzle involving hidden prizes behind doors. Users can create games, make initial selections, reveal goat doors, and test outcomes under stay-or-switch strategies. The package also supports running repeated simulations to compare winning probabilities, making it a useful tool for teaching probability concepts, exploring decision-making under uncertainty, and replicating the well-known counterintuitive results of the Monty Hall problem.

## Installation

You can install the development version of montyhall from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("MJobinASU/MontyHall")
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

