#' Validate a Structured Input Table
#'
#' Checks that an input object can be treated as a tabular clustering input.
#'
#' @param data A data frame or matrix-like object.
#' @param id_column Optional identifier column name.
#' @param min_rows Minimum number of rows required.
#'
#' @return A validated data frame with class `uccdf_validated`.
#' @examples
#' dat <- simulate_mixed_data(n = 20, k = 2, seed = 1)
#' validated <- validate_input(dat, id_column = "sample_id")
#' nrow(validated)
#' @export
validate_input <- function(data, id_column = NULL, min_rows = 5L) {
  data <- .as_data_frame(data)
  if (!is.null(id_column)) {
    .validate_single_string(id_column, "id_column")
    if (!id_column %in% names(data)) {
      stop("`id_column` was not found in `data`.", call. = FALSE)
    }
    ids <- data[[id_column]]
    if (anyDuplicated(ids)) {
      stop("`id_column` must be unique.", call. = FALSE)
    }
  }
  if (anyDuplicated(names(data))) {
    stop("Column names must be unique.", call. = FALSE)
  }
  if (nrow(data) < min_rows) {
    stop("`data` does not meet the minimum row requirement.", call. = FALSE)
  }
  class(data) <- c("uccdf_validated", class(data))
  data
}

#' Infer a Simple Column Schema
#'
#' Infers coarse variable types and clustering roles for a structured data frame.
#'
#' @param data A validated data frame or raw input table.
#' @param id_column Optional identifier column name.
#' @param ordinal_columns Optional character vector of columns to force as ordinal.
#'
#' @return A data frame describing the inferred schema.
#' @examples
#' dat <- simulate_mixed_data(n = 20, k = 2, seed = 1)
#' schema <- infer_schema(dat, id_column = "sample_id")
#' schema[, c("column_name", "type", "role")]
#' @export
infer_schema <- function(data, id_column = NULL, ordinal_columns = NULL) {
  data <- validate_input(data, id_column = id_column)
  out <- data.frame(
    column_name = names(data),
    type = character(ncol(data)),
    role = character(ncol(data)),
    weight_init = numeric(ncol(data)),
    missing_rate = numeric(ncol(data)),
    unique_ratio = numeric(ncol(data)),
    exclude_flag = logical(ncol(data)),
    stringsAsFactors = FALSE
  )
  for (i in seq_along(data)) {
    nm <- names(data)[i]
    x <- data[[i]]
    inferred <- .detect_type(x)
    if (!is.null(ordinal_columns) && nm %in% ordinal_columns) {
      inferred <- "ordinal"
    }
    role <- .infer_role(nm, x, id_column)
    x_obs <- x[!is.na(x)]
    unique_ratio <- if (length(x_obs)) length(unique(x_obs)) / length(x_obs) else 0
    out$type[i] <- inferred
    out$role[i] <- role
    out$weight_init[i] <- if (identical(role, "active")) 1 else 0
    out$missing_rate[i] <- mean(is.na(x))
    out$unique_ratio[i] <- unique_ratio
    out$exclude_flag[i] <- identical(role, "exclude")
  }
  class(out) <- c("uccdf_schema", class(out))
  out
}

#' Build Canonical UCCDF Views
#'
#' Constructs the mixed-distance and mixed-latent views used by `fit_uccdf()`.
#'
#' @param data A data frame.
#' @param schema A schema produced by [infer_schema()].
#' @param columns Optional subset of active columns.
#' @param latent_dims Number of latent dimensions to retain.
#'
#' @return A named list containing `mixed_distance` and `mixed_latent`.
#' @examples
#' dat <- simulate_mixed_data(n = 30, k = 3, seed = 2)
#' schema <- infer_schema(dat, id_column = "sample_id")
#' views <- build_views(dat, schema)
#' names(views)
#' @export
build_views <- function(data, schema, columns = NULL, latent_dims = 5L) {
  data <- .as_data_frame(data)
  if (is.null(columns)) {
    columns <- schema$column_name[schema$role == "active"]
  }
  list(
    mixed_distance = .compute_mixed_distance(data, schema, columns),
    mixed_latent = .build_latent_view(data, schema, columns, dims = latent_dims)
  )
}

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

#' Write a Compact UCCDF Report
#'
#' Writes a short markdown or html summary of a fitted `uccdf` analysis.
#'
#' @param fit A fitted object from [fit_uccdf()].
#' @param file Output file path.
#' @param format Either `"md"` or `"html"`.
#'
#' @return Invisibly returns `file`.
#' @examples
#' dat <- simulate_mixed_data(n = 30, k = 2, seed = 1)
#' fit <- fit_uccdf(dat, id_column = "sample_id", n_resamples = 10, n_null = 39, seed = 1)
#' tmp <- tempfile(fileext = ".md")
#' report(fit, tmp, format = "md")
#' file.exists(tmp)
#' @export
report <- function(fit, file, format = c("md", "html")) {
  if (!inherits(fit, "uccdf_fit")) {
    stop("`fit` must inherit from `uccdf_fit`.", call. = FALSE)
  }
  format <- match.arg(format)
  lines <- .compact_report_lines(fit)
  if (identical(format, "html")) {
    body <- paste(sprintf("<p>%s</p>", gsub("^# ", "", lines)), collapse = "\n")
    lines <- c("<html><body>", body, "</body></html>")
  }
  writeLines(lines, con = file, useBytes = TRUE)
  invisible(file)
}
