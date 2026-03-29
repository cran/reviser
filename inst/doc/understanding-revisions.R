## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(dplyr)
library(reviser)
library(tsbox)

# Example dataset
gdp <- reviser::gdp |>
  ts_pc() |>
  na.omit()

revisions_interval <- get_revisions(gdp, interval = 1)

# Preview results
# How do the 2nd and 3rd release revise compared to previous quarter?
plot_vintages(
  revisions_interval |>
    filter(id == "US") |>
    get_nth_release(1:2),
  dim_col = "release",
  title = "Revisions of 2nd (release_1) and 3rd (release_2) release",
  subtitle = "For the US"
)

# Revisions of the latest release
plot_vintages(
  revisions_interval |> get_latest_release(),
  dim_col = "id",
  title = "Revisions of the latest release",
  subtitle = "For several countries"
)


## -----------------------------------------------------------------------------

revisions_date <- get_revisions(gdp, ref_date = as.Date("2005-10-01"))

# Preview results
# Revisions of the latest release
plot_vintages(
  revisions_date |> get_latest_release(),
  dim_col = "id",
  title = "Revisions of the latest release compared to Q4 2005",
  subtitle = "For several countries",
  type = "bar"
)

## -----------------------------------------------------------------------------
revisions_nth <- get_revisions(gdp, nth_release = 0)

# Preview results
# Revisions of the latest release
plot_vintages(
  revisions_nth |> get_latest_release(),
  dim_col = "id",
  title = "Revisions of the latest compared to first release",
  subtitle = "For several countries",
  type = "bar"
)

## -----------------------------------------------------------------------------

growthrates_q405 <- get_releases_by_date(gdp, as.Date("2005-10-01"))

# Preview results
plot_vintages(
  growthrates_q405,
  dim_col = "id",
  time_col = "pub_date",
  title = "Evolution of growth rates for GDP Q4 2005",
  subtitle = "For several countries",
  type = "line"
)

