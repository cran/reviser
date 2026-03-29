## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----warning=FALSE, message=FALSE---------------------------------------------
library(reviser)
library(dplyr)
library(tsbox)

gdp <- reviser::gdp |>
  ts_pc() |>
  filter(id == "EA") |>
  na.omit()

df <- get_nth_release(gdp, 0:1)
final_release <- get_latest_release(gdp)

results <- get_revision_analysis(
  df,
  final_release,
  degree = 1
)

results

## ----warning=FALSE------------------------------------------------------------
results <- get_revision_analysis(
  df,
  final_release,
  degree = 2
)

head(results)

## ----warning=FALSE------------------------------------------------------------
results <- get_revision_analysis(
  df,
  final_release,
  degree = 3
)

head(results)

## ----warning=FALSE------------------------------------------------------------
results <- get_revision_analysis(
  df,
  final_release,
  degree = 4
)

head(results)

## ----warning=FALSE------------------------------------------------------------
df <- gdp |>
  filter(pub_date %in% c("2024-04-01", "2024-07-01"))


results <- get_revision_analysis(
  df,
  final_release,
  degree = 5
)

results

## ----warning=FALSE, eval=FALSE------------------------------------------------
# # Get unique sorted publication dates
# pub_dates <- gdp |>
#   distinct(pub_date) |>
#   arrange(pub_date) |>
#   pull(pub_date)
# 
# # Run the function for each pair of consecutive publication dates
# results <- purrr::map_dfr(seq_along(pub_dates[-length(pub_dates)]),
#   function(i) {
#     df <- gdp |>
#       filter(pub_date %in% pub_dates[i])
# 
#     final_release <- gdp |>
#       filter(pub_date %in% pub_dates[i + 1])
# 
#     get_revision_analysis(df, final_release, degree = 5)
#   }
# )
# 
# head(results)

