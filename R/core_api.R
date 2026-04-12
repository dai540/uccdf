#' Validate a Structured Input Table
#'
#' @param data A data frame or matrix-like object.
#' @param id_column Optional identifier column name.
#' @param min_rows Minimum number of rows required.
#'
#' @return A validated data frame.
#' @export
validate_input <- function(data, id_column = NULL, min_rows = 5L) {
  data <- .as_data_frame(data)
  if (!is.null(id_column)) {
    if (!id_column %in% names(data)) {
      stop("`id_column` was not found in `data`.", call. = FALSE)
    }
    if (anyDuplicated(data[[id_column]])) {
      stop("`id_column` must be unique.", call. = FALSE)
    }
  }
  if (anyDuplicated(names(data))) {
    stop("Column names must be unique.", call. = FALSE)
  }
  if (nrow(data) < min_rows) {
    stop("`data` does not meet the minimum row requirement.", call. = FALSE)
  }
  data
}

#' Infer a Simple Column Schema
#'
#' @param data A data frame.
#' @param id_column Optional identifier column name.
#'
#' @return A data frame describing inferred column roles and types.
#' @export
infer_schema <- function(data, id_column = NULL) {
  data <- validate_input(data, id_column = id_column)
  out <- data.frame(
    column_name = names(data),
    type = vapply(data, .detect_type, character(1)),
    role = vapply(names(data), function(nm) .infer_role(nm, data[[nm]], id_column), character(1)),
    stringsAsFactors = FALSE
  )
  out$weight_init <- ifelse(out$role == "active", 1, 0)
  out$missing_rate <- vapply(data, function(x) mean(is.na(x)), numeric(1))
  out$unique_ratio <- vapply(data, function(x) {
    obs <- x[!is.na(x)]
    if (!length(obs)) 0 else length(unique(obs)) / length(obs)
  }, numeric(1))
  out$exclude_flag <- out$role == "exclude"
  out
}

#' Build Canonical Views
#'
#' @param data A data frame.
#' @param schema A schema produced by [infer_schema()].
#' @param columns Optional active columns.
#' @param latent_dims Number of latent dimensions.
#'
#' @return A list with `mixed_distance` and `mixed_latent`.
#' @export
build_views <- function(data, schema, columns = NULL, latent_dims = 4L) {
  data <- .as_data_frame(data)
  if (is.null(columns)) {
    columns <- schema$column_name[schema$role == "active"]
  }
  list(
    mixed_distance = .compute_mixed_distance(data, schema, columns),
    mixed_latent = .build_latent_view(data, schema, columns, latent_dims)
  )
}

#' Fit Consensus Clustering
#'
#' @param data A data frame or matrix-like object.
#' @param id_column Optional identifier column name.
#' @param candidate_k Candidate cluster counts.
#' @param n_resamples Number of resamples.
#' @param row_fraction Fraction of rows per resample.
#' @param col_fraction Fraction of active columns per resample.
#' @param latent_dims Number of latent dimensions.
#' @param seed Random seed.
#'
#' @return An object of class `uccdf_fit`.
#' @export
fit_uccdf <- function(data,
                      id_column = NULL,
                      candidate_k = 2:4,
                      n_resamples = 20L,
                      row_fraction = 0.8,
                      col_fraction = 0.8,
                      latent_dims = 4L,
                      seed = 123) {
  set.seed(seed)
  data <- validate_input(data, id_column = id_column)
  schema <- infer_schema(data, id_column = id_column)
  views <- build_views(data, schema, latent_dims = latent_dims)
  row_ids <- .compute_row_ids(data, id_column)
  rownames(data) <- row_ids
  ks <- sort(unique(candidate_k[candidate_k >= 2]))
  if (!length(ks)) {
    stop("`candidate_k` must contain at least one value >= 2.", call. = FALSE)
  }
  fit <- .compute_consensus_from_runs(
    data = data,
    schema = schema,
    id_column = id_column,
    ks = ks,
    n_resamples = n_resamples,
    row_fraction = row_fraction,
    col_fraction = col_fraction,
    latent_dims = latent_dims
  )
  best_idx <- which.max(fit$stability)
  selected_k <- ks[best_idx]
  final <- .finalize_from_consensus(fit$consensus_by_k[[as.character(selected_k)]], selected_k)
  assignments <- data.frame(
    row_id = row_ids,
    cluster = final$labels,
    confidence = final$confidence,
    ambiguity = final$ambiguity,
    stringsAsFactors = FALSE
  )
  out <- list(
    data = data,
    schema = schema,
    views = views,
    consensus_by_k = fit$consensus_by_k,
    k_table = data.frame(k = ks, stability = as.numeric(fit$stability), stringsAsFactors = FALSE),
    selected_k = selected_k,
    assignments = assignments
  )
  class(out) <- "uccdf_fit"
  out
}

#' Return the K Selection Table
#'
#' @param fit A `uccdf_fit` object.
#'
#' @return A data frame.
#' @export
select_k <- function(fit) {
  .assert_fit(fit)
  fit$k_table
}

#' Return Sample-Level Assignments
#'
#' @param fit A `uccdf_fit` object.
#'
#' @return A data frame.
#' @export
augment <- function(fit) {
  .assert_fit(fit)
  fit$assignments
}

#' Write a Compact Report
#'
#' @param fit A `uccdf_fit` object.
#' @param file Output file path.
#' @param format Either `"md"` or `"html"`.
#'
#' @return Invisibly returns the output path.
#' @export
report <- function(fit, file, format = c("md", "html")) {
  .assert_fit(fit)
  format <- match.arg(format)
  lines <- c(
    "# uccdf report",
    "",
    sprintf("- rows: %s", nrow(fit$data)),
    sprintf("- selected_k: %s", fit$selected_k),
    "",
    "## K table",
    paste(sprintf("- K=%s stability=%.3f", fit$k_table$k, fit$k_table$stability), collapse = "\n")
  )
  if (identical(format, "html")) {
    lines <- c("<html><body>", sprintf("<p>%s</p>", lines), "</body></html>")
  }
  writeLines(lines, file, useBytes = TRUE)
  invisible(file)
}
