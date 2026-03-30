#' Fit Typed Consensus Clustering
#'
#' Runs a compact typed consensus clustering workflow for a structured data
#' frame. The workflow infers a schema, builds mixed-distance and mixed-latent
#' views, aggregates partitions across resamples and learners, calibrates
#' stability against simple null tables, selects `K`, and returns row-level
#' labels with confidence and ambiguity.
#'
#' @param data A data frame or matrix-like object.
#' @param id_column Optional identifier column name.
#' @param candidate_k Integer vector of candidate cluster counts. Values below 2
#'   are ignored during fitting; the method can still return `K = 1` if the
#'   global null is not rejected.
#' @param n_resamples Number of bootstrap-like resamples.
#' @param row_fraction Fraction of rows sampled per resample.
#' @param col_fraction Fraction of active columns sampled within each type.
#' @param use_views Character vector containing any of `"mixed_distance"` and
#'   `"mixed_latent"`.
#' @param learners Character vector of learners. Supported values are `"pam"`,
#'   `"hierarchical"`, and `"kmeans"`.
#' @param n_null Number of null replicates.
#' @param null_family Null family. The default is `"independence_marginal_null"`.
#' @param alpha Significance level used for the global null test and per-K support.
#' @param lambda_logk Complexity penalty on large K.
#' @param gamma_small_cluster Penalty for clusters smaller than `min_cluster_size`.
#' @param min_cluster_size Minimum acceptable cluster size in the final partition.
#' @param latent_dims Number of latent dimensions for the mixed-latent view.
#' @param seed Random seed.
#'
#' @return An object of class `uccdf_fit`.
#' @examples
#' dat <- simulate_mixed_data(n = 50, k = 3, seed = 1)
#' fit <- fit_uccdf(
#'   dat,
#'   id_column = "sample_id",
#'   n_resamples = 12,
#'   n_null = 39,
#'   candidate_k = 1:4,
#'   seed = 1
#' )
#' fit
#' head(augment(fit))
#' @export
fit_uccdf <- function(data,
                      id_column = NULL,
                      candidate_k = 1:6,
                      n_resamples = 50L,
                      row_fraction = 0.8,
                      col_fraction = 0.7,
                      use_views = c("mixed_distance", "mixed_latent"),
                      learners = c("pam", "hierarchical", "kmeans"),
                      n_null = 99L,
                      null_family = "independence_marginal_null",
                      alpha = 0.05,
                      lambda_logk = 0.20,
                      gamma_small_cluster = 1.0,
                      min_cluster_size = 5L,
                      latent_dims = 5L,
                      seed = 123) {
  set.seed(seed)
  if (n_null < 39L) {
    warning(
      "`n_null` is very small. Values below 39 often make the global null test unstable; ",
      "use 99 or more for examples and reports.",
      call. = FALSE
    )
  }
  data <- validate_input(data, id_column = id_column)
  schema <- infer_schema(data, id_column = id_column)
  full_views <- build_views(data, schema, latent_dims = latent_dims)
  row_ids <- .compute_row_ids(data, id_column = id_column)
  rownames(data) <- row_ids
  ks <- sort(unique(candidate_k[candidate_k >= 2]))
  if (!length(ks)) {
    ks <- 2L
  }
  observed <- .compute_consensus_from_runs(
    data = data,
    schema = schema,
    id_column = id_column,
    ks = ks,
    n_resamples = n_resamples,
    row_fraction = row_fraction,
    col_fraction = col_fraction,
    use_views = use_views,
    learners = learners,
    latent_dims = latent_dims,
    store_runs = TRUE
  )
  runs <- observed$runs
  consensus_by_k <- observed$consensus_by_k
  stability <- observed$stability

  null_scores <- matrix(NA_real_, nrow = n_null, ncol = length(ks), dimnames = list(NULL, paste0("K", ks)))
  null_resamples <- max(10L, floor(n_resamples / 2L))
  for (r in seq_len(n_null)) {
    null_data <- .generate_null_data(data, schema, family = null_family)
    null_fit <- .compute_consensus_from_runs(
      data = null_data,
      schema = schema,
      id_column = id_column,
      ks = ks,
      n_resamples = null_resamples,
      row_fraction = row_fraction,
      col_fraction = col_fraction,
      use_views = use_views,
      learners = learners,
      latent_dims = latent_dims,
      store_runs = FALSE
    )
    null_scores[r, ] <- as.numeric(null_fit$stability)
  }

  selection_stats <- .compute_selection_table(
    stability = stability,
    null_scores = null_scores,
    ks = ks,
    consensus_by_k = consensus_by_k,
    alpha = alpha,
    lambda_logk = lambda_logk,
    gamma_small_cluster = gamma_small_cluster,
    min_cluster_size = min_cluster_size
  )
  k_table <- selection_stats$k_table
  exploratory_k <- ks[selection_stats$best_exploratory_idx]
  exploratory <- .finalize_from_consensus(consensus_by_k[[as.character(exploratory_k)]], exploratory_k)

  if (!selection_stats$detected_structure) {
    selected_k <- 1L
    final <- list(
      labels = rep(1L, nrow(data)),
      confidence = rep(NA_real_, nrow(data)),
      ambiguity = rep(NA_real_, nrow(data))
    )
    assignment_mode <- "null_retained"
  } else {
    best_supported_idx <- selection_stats$best_supported_idx
    if (is.na(best_supported_idx)) {
      best_supported_idx <- selection_stats$best_exploratory_idx
    }
    selected_k <- ks[best_supported_idx]
    final <- .finalize_from_consensus(consensus_by_k[[as.character(selected_k)]], selected_k)
    assignment_mode <- "selected"
  }

  assignments <- .build_assignment_table(
    row_ids = row_ids,
    selected = final,
    exploratory = exploratory,
    selected_k = selected_k,
    exploratory_k = exploratory_k,
    assignment_mode = assignment_mode
  )

  out <- list(
    data = data,
    schema = schema,
    views = full_views,
    runs = runs,
    consensus_by_k = consensus_by_k,
    null_scores = null_scores,
    k_table = k_table,
    selected_k = selected_k,
    assignments = assignments,
    selection = list(
      alpha = alpha,
      global_p_value = selection_stats$global_p_value,
      null_family = null_family,
      detected_structure = selection_stats$detected_structure,
      best_exploratory_k = exploratory_k,
      best_supported_k = if (is.na(selection_stats$best_supported_idx)) NA_integer_ else ks[selection_stats$best_supported_idx]
    ),
    call = match.call()
  )
  class(out) <- "uccdf_fit"
  out
}
