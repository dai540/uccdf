#' Simulate a Mixed-Type Clustering Table
#'
#' Generates a small mixed-type table with known cluster structure.
#'
#' @param n Number of rows.
#' @param k Number of latent groups.
#' @param seed Random seed.
#'
#' @return A data frame with a sample identifier and mixed columns.
#' @examples
#' dat <- simulate_mixed_data(n = 12, k = 2, seed = 1)
#' dat
#' @export
simulate_mixed_data <- function(n = 120, k = 3, seed = 123) {
  set.seed(seed)
  grp <- rep(seq_len(k), length.out = n)
  grp <- sample(grp, size = n, replace = FALSE)
  age <- stats::rnorm(n, mean = 45 + grp * 6, sd = 5)
  score <- stats::rnorm(n, mean = grp * 1.1, sd = 0.7)
  smoker <- ifelse(stats::runif(n) < (0.12 + grp * 0.08), "yes", "no")
  stage_levels <- c("I", "II", "III")
  stage <- stage_levels[pmin(length(stage_levels), pmax(1, grp))]
  subtype <- c("A", "B", "C", "D")[1 + ((grp + sample(0:1, n, replace = TRUE)) %% 4)]
  dat <- data.frame(
    sample_id = sprintf("S%03d", seq_len(n)),
    age = age,
    score = score,
    smoker = factor(smoker, levels = c("no", "yes")),
    stage = ordered(stage, levels = stage_levels),
    subtype = factor(subtype),
    stringsAsFactors = FALSE
  )
  miss_idx <- sample(seq_len(n), size = floor(0.05 * n))
  dat$score[miss_idx] <- NA_real_
  dat
}
