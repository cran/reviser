## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, warning=FALSE, message=FALSE--------------------------------------
# The packages used in this vignette
library(reviser)
library(dplyr)
library(tsbox)

## -----------------------------------------------------------------------------
# Example long-format US GDP data
data("gdp")
gdp_us_short <- gdp |>
  dplyr::filter(id == "US") |>
  ts_pc() |>
  filter(
    pub_date >= as.Date("2007-01-01"),
    pub_date < as.Date("2009-01-01"),
    time  >= as.Date("2007-01-01"),
    time < as.Date("2009-01-01")
  )

# Example long-format EA GDP data
gdp_ea_short <- gdp |>
  dplyr::filter(id == "EA") |>
  ts_pc() |>
  filter(
    pub_date >= as.Date("2007-01-01"),
    pub_date < as.Date("2009-01-01"),
    time  >= as.Date("2007-01-01"),
    time < as.Date("2009-01-01")
  )

head(gdp_ea_short)

## -----------------------------------------------------------------------------
# Convert wide-format data to long format
wide_ea_short <- vintages_wide(gdp_ea_short)
head(wide_ea_short)

## -----------------------------------------------------------------------------
# Convert back to long format
long_ea_short <- vintages_long(wide_ea_short)
long_ea_short

## -----------------------------------------------------------------------------
gdp_short <- bind_rows(
  gdp_ea_short |> mutate(id = "EA"),
  gdp_us_short |> mutate(id = "US")
)
gdp_wide_short <- vintages_wide(gdp_short)
head(gdp_wide_short)

## -----------------------------------------------------------------------------
# Get the first release and check in wide format
gdp_releases <- get_nth_release(gdp_short, n = 0)
vintages_wide(gdp_releases)

# The function uses the pub_date column by default to define columns in wide
# format. Specifying the `names_from` argument allows to use the release column.
gdp_releases <- get_nth_release(gdp_short, n = 0:1)
vintages_wide(gdp_releases, names_from = "release")

## -----------------------------------------------------------------------------
# Get the latest release
gdp_final <- get_nth_release(gdp_short, n = "latest")
vintages_wide(gdp_final)

## -----------------------------------------------------------------------------
gdp_ea_longer <- gdp |>
  dplyr::filter(id == "EA") |>
  ts_pc() |>
  filter(
    time >= as.Date("2000-01-01"),
    time < as.Date("2006-01-01"),
    pub_date >= as.Date("2000-01-01"),
    pub_date <= as.Date("2006-01-01")
  )

# Get the release from October four years after the initial release
gdp_releases <- get_fixed_release(
  gdp_ea_longer,
  years = 4,
  month = "October"
)
gdp_releases

## -----------------------------------------------------------------------------
# Line plot showing GDP vintages over the publication date dimension
plot_vintages(
  gdp_us_short,
  title = "Real-time GDP Estimates for the US",
  subtitle = "Growth Rate in %"
)

# Line plot showing GDP vintages over the release dimension
gdp_releases <- get_nth_release(gdp_us_short, n = 0:3)
plot_vintages(gdp_releases, dim_col = "release")

## -----------------------------------------------------------------------------
# Line plot showing GDP vintages over the publication date dimension
plot_vintages(
  gdp_ea_longer,
  type = "boxplot",
  title = "Real-time GDP Estimates for the Euro Area",
  subtitle = "Growth Rate in %"
)

# Line plot showing GDP vintages over id dimension
plot_vintages(
  gdp |>
    ts_pc() |>
    get_latest_release() |>
    na.omit(),
  dim_col = "id",
  title = "Recent GDP Estimates",
  subtitle = "Growth Rate in %"
)

