## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

rebuild_vignette_results <- identical(
  tolower(Sys.getenv("REVISER_REBUILD_VIGNETTE_RESULTS")),
  "true"
)

vignette_result_path <- function(name) {
  candidates <- c(
    file.path("vignettes", "precomputed", name),
    file.path("precomputed", name)
  )
  existing <- candidates[file.exists(candidates)]

  if (length(existing) > 0) {
    existing[[1]]
  } else {
    candidates[[1]]
  }
}

load_or_build_vignette_result <- function(name, builder) {
  path <- vignette_result_path(name)

  if (!rebuild_vignette_results) {
    if (!file.exists(path)) {
      stop("Missing precomputed vignette result: ", basename(path))
    }

    return(readRDS(path))
  }

  result <- builder()
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  saveRDS(result, path)
  result
}

## ----warning = FALSE, message = FALSE-----------------------------------------
library(reviser)
library(dplyr)
library(tidyr)
library(tsbox)
library(ggplot2)

gdp_growth <- reviser::gdp |>
  tsbox::ts_pc() |>
  dplyr::filter(
    id == "EA",
    time >= min(pub_date),
    time <= as.Date("2020-01-01")
  ) |>
  tidyr::drop_na()

df <- get_nth_release(gdp_growth, n = 0:3)
df

## ----warning = FALSE, message = FALSE-----------------------------------------
fit_jvn <- load_or_build_vignette_result(
  "nowcasting-revisions-jvn-fit.rds",
  function() {
    jvn_nowcast(
      df = df,
      e = 4,
      ar_order = 2,
      h = 0,
      include_news = TRUE,
      include_noise = TRUE,
      include_spillovers = TRUE,
      spillover_news = TRUE,
      spillover_noise = TRUE,
      method = "MLE",
      standardize = FALSE,
      solver_options = list(
        method = "L-BFGS-B",
        maxiter = 100,
        se_method = "hessian"
      )
    )
  }
)

summary(fit_jvn)

## ----warning = FALSE, message = FALSE-----------------------------------------
fit_jvn$params

## ----warning = FALSE, message = FALSE-----------------------------------------
fit_jvn$states |>
  dplyr::filter(
    state == "true_lag_0",
    filter == "smoothed"
  ) |>
  dplyr::slice_tail(n = 8)

## ----warning = FALSE, message = FALSE-----------------------------------------
plot(fit_jvn)

## ----warning = FALSE, message = FALSE-----------------------------------------
fit_jvn$states |>
  dplyr::filter(
    filter == "smoothed",
    grepl("news|noise", state)
  ) |>
  ggplot(aes(x = time, y = estimate, color = state)) +
  geom_line() +
  labs(
    title = "Smoothed news and noise states",
    x = NULL,
    y = "State estimate"
  ) +
  theme_minimal()

## ----eval = FALSE-------------------------------------------------------------
# fit_news <- jvn_nowcast(
#   df = df,
#   e = 4,
#   ar_order = 2,
#   include_news = TRUE,
#   include_noise = FALSE,
#   include_spillovers = FALSE
# )
# 
# fit_noise <- jvn_nowcast(
#   df = df,
#   e = 4,
#   ar_order = 2,
#   include_news = FALSE,
#   include_noise = TRUE,
#   include_spillovers = FALSE
# )

