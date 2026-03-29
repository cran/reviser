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

efficient_release <- load_or_build_vignette_result(
  "nowcasting-revisions-kk-efficient-release.rds",
  function() get_first_efficient_release(df, final_release)
)
summary(efficient_release)

data_kk <- efficient_release$data
e <- efficient_release$e

## ----warning = FALSE, message = FALSE-----------------------------------------
fit_kk <- load_or_build_vignette_result(
  "nowcasting-revisions-kk-fit.rds",
  function() {
    kk_nowcast(
      df = data_kk,
      e = e,
      model = "KK",
      method = "MLE",
      solver_options = list(
        method = "L-BFGS-B",
        maxiter = 100,
        se_method = "hessian"
      )
    )
  }
)

summary(fit_kk)

## ----warning = FALSE, message = FALSE-----------------------------------------
fit_kk$params

## ----warning = FALSE, message = FALSE-----------------------------------------
fit_kk$states |>
  dplyr::filter(filter == "smoothed") |>
  dplyr::slice_tail(n = 8)

## ----warning = FALSE, message = FALSE-----------------------------------------
plot(fit_kk)

## ----eval = FALSE-------------------------------------------------------------
# fit_howrey <- kk_nowcast(
#   df = data_kk,
#   e = e,
#   model = "Howrey",
#   method = "MLE"
# )
# 
# fit_classical <- kk_nowcast(
#   df = data_kk,
#   e = e,
#   model = "Classical",
#   method = "MLE"
# )

