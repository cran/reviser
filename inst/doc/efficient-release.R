## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, warning=FALSE, message=FALSE--------------------------------------
library(reviser)
library(dplyr)

gdp <- reviser::gdp |>
  tsbox::ts_pc() |>
  dplyr::filter(
    id == "EA",
    time >= min(pub_date),
    time <= as.Date("2020-01-01")
  ) |>
  tidyr::drop_na()

df <- get_nth_release(gdp, n = 0:14)

final_release <- get_nth_release(gdp, n = 15)

efficient <- get_first_efficient_release(
  df,
  final_release
)

res <- summary(efficient)

head(res)


## ----warning=FALSE, message=FALSE---------------------------------------------
analysis <- get_revision_analysis(
  df,
  final_release,
  degree = 3
)
head(analysis)

