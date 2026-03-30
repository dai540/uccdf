#' Extract the K Selection Table
#'
#' Returns the null-calibrated K summary from a fitted `uccdf` object.
#'
#' @param fit A fitted object from [fit_uccdf()].
#'
#' @return A data frame with per-K stability and selection statistics.
#' @examples
#' dat <- simulate_mixed_data(n = 40, k = 2, seed = 1)
#' fit <- fit_uccdf(dat, id_column = "sample_id", n_resamples = 10, n_null = 39, seed = 1)
#' select_k(fit)
#' @export
select_k <- function(fit) {
  if (!inherits(fit, "uccdf_fit")) {
    stop("`fit` must inherit from `uccdf_fit`.", call. = FALSE)
  }
  fit$k_table
}
