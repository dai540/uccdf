#' Extract Sample-Level Cluster Assignments
#'
#' Returns row-level selected and exploratory assignments from a fitted object.
#'
#' @param fit A fitted object from [fit_uccdf()].
#'
#' @return A data frame with one row per sample. When the global null is not
#'   rejected, `cluster` remains 1 while `exploratory_*` columns expose the best
#'   unsupported multi-cluster split.
#' @examples
#' dat <- simulate_mixed_data(n = 40, k = 2, seed = 1)
#' fit <- fit_uccdf(dat, id_column = "sample_id", n_resamples = 10, n_null = 39, seed = 1)
#' head(augment(fit))
#' @export
augment <- function(fit) {
  if (!inherits(fit, "uccdf_fit")) {
    stop("`fit` must inherit from `uccdf_fit`.", call. = FALSE)
  }
  fit$assignments
}
