#' Simulate Mixed-Type Data
#'
#' @param n Number of rows.
#' @param k Number of groups.
#' @param seed Random seed.
#'
#' @return A data frame.
#' @export
simulate_mixed_data <- function(n = 120, k = 3, seed = 123) {
  set.seed(seed)
  grp <- rep(seq_len(k), length.out = n)
  grp <- sample(grp, n)
  data.frame(
    sample_id = sprintf("S%03d", seq_len(n)),
    x1 = stats::rnorm(n, grp * 1.2, 0.6),
    x2 = stats::rnorm(n, grp * 0.8, 0.7),
    binary = factor(ifelse(stats::runif(n) < grp / (k + 1), "yes", "no")),
    ordinal = ordered(pmin(grp, 3), levels = 1:3),
    nominal = factor(c("A", "B", "C", "D")[1 + ((grp + sample(0:1, n, TRUE)) %% 4)]),
    stringsAsFactors = FALSE
  )
}

.assert_fit <- function(fit) {
  if (!inherits(fit, "uccdf_fit")) {
    stop("`fit` must inherit from `uccdf_fit`.", call. = FALSE)
  }
}

.as_data_frame <- function(data) {
  if (inherits(data, "data.frame")) {
    return(data)
  }
  if (is.matrix(data)) {
    return(as.data.frame(data, stringsAsFactors = FALSE))
  }
  stop("`data` must be a data.frame or matrix-like object.", call. = FALSE)
}

.detect_type <- function(x) {
  obs <- x[!is.na(x)]
  if (!length(obs)) return("exclude")
  if (is.ordered(x)) return("ordinal")
  if (is.factor(x)) return(if (length(levels(x)) == 2L) "binary" else "nominal")
  if (is.logical(x)) return("binary")
  if (is.numeric(x) || is.integer(x)) return("continuous")
  if (is.character(x)) return(if (length(unique(obs)) == 2L) "binary" else "nominal")
  "exclude"
}

.infer_role <- function(name, x, id_column) {
  if (!is.null(id_column) && identical(name, id_column)) return("id")
  obs <- x[!is.na(x)]
  if (!length(obs) || length(unique(obs)) <= 1L) return("exclude")
  "active"
}

.compute_row_ids <- function(data, id_column = NULL) {
  ids <- if (!is.null(id_column)) as.character(data[[id_column]]) else rownames(data)
  if (is.null(ids)) ids <- sprintf("row_%s", seq_len(nrow(data)))
  ids
}

.robust_scale <- function(x) {
  obs <- x[!is.na(x)]
  if (length(obs) <= 1L) return(1)
  s <- stats::sd(obs)
  if (is.na(s) || s <= 0) 1 else s
}

.expand_mixed_matrix <- function(data, schema, columns) {
  blocks <- list()
  for (nm in columns) {
    type <- schema$type[match(nm, schema$column_name)]
    x <- data[[nm]]
    if (identical(type, "continuous")) {
      v <- as.numeric(x)
      v[is.na(v)] <- stats::median(v, na.rm = TRUE)
      blocks[[nm]] <- matrix((v - mean(v)) / (.robust_scale(v) + 1e-8), ncol = 1, dimnames = list(NULL, nm))
    } else if (identical(type, "ordinal")) {
      v <- as.numeric(x)
      v[is.na(v)] <- stats::median(v, na.rm = TRUE)
      blocks[[nm]] <- matrix(v, ncol = 1, dimnames = list(NULL, nm))
    } else {
      f <- factor(ifelse(is.na(x), "missing", as.character(x)), exclude = NULL)
      mm <- stats::model.matrix(~ f - 1)
      colnames(mm) <- paste0(nm, "::", levels(f))
      blocks[[nm]] <- mm
    }
  }
  do.call(cbind, blocks)
}

.compute_mixed_distance <- function(data, schema, columns) {
  n <- nrow(data)
  D <- matrix(0, n, n)
  W <- matrix(0, n, n)
  for (nm in columns) {
    type <- schema$type[match(nm, schema$column_name)]
    x <- data[[nm]]
    obs <- !is.na(x)
    if (!any(obs)) next
    if (identical(type, "continuous")) {
      v <- as.numeric(x)
      delta <- abs(outer(v, v, "-")) / (.robust_scale(v) + 1e-8)
    } else if (identical(type, "ordinal")) {
      v <- as.numeric(x)
      delta <- abs(outer(v, v, "-")) / max(1, max(v, na.rm = TRUE) - 1)
    } else {
      v <- as.character(x)
      delta <- outer(v, v, FUN = function(a, b) as.numeric(a != b))
    }
    mask <- outer(obs, obs, "&")
    delta[!mask] <- 0
    D <- D + delta
    W <- W + mask
  }
  out <- D / (W + 1e-8)
  diag(out) <- 0
  out
}

.build_latent_view <- function(data, schema, columns, dims) {
  X <- .expand_mixed_matrix(data, schema, columns)
  rank_max <- min(nrow(X) - 1L, ncol(X), dims)
  pca <- stats::prcomp(X, center = TRUE, scale. = FALSE, rank. = rank_max)
  z <- pca$x[, seq_len(rank_max), drop = FALSE]
  colnames(z) <- paste0("LV", seq_len(ncol(z)))
  z
}

.compute_consensus_from_runs <- function(data, schema, id_column, ks, n_resamples, row_fraction, col_fraction, latent_dims) {
  row_ids <- .compute_row_ids(data, id_column)
  rownames(data) <- row_ids
  consensus_num <- stats::setNames(lapply(ks, function(k) matrix(0, nrow(data), nrow(data), dimnames = list(row_ids, row_ids))), ks)
  consensus_den <- stats::setNames(lapply(ks, function(k) matrix(0, nrow(data), nrow(data), dimnames = list(row_ids, row_ids))), ks)

  for (b in seq_len(n_resamples)) {
    rows <- sort(sample(seq_len(nrow(data)), max(3L, ceiling(nrow(data) * row_fraction)), replace = FALSE))
    active <- schema$column_name[schema$role == "active"]
    cols <- sample(active, max(2L, ceiling(length(active) * col_fraction)), replace = FALSE)
    sub_data <- data[rows, c(if (!is.null(id_column)) id_column, cols), drop = FALSE]
    sub_schema <- schema[schema$column_name %in% names(sub_data), , drop = FALSE]
    views <- build_views(sub_data, sub_schema, columns = cols, latent_dims = latent_dims)
    for (k in ks) {
      pam_part <- cluster::pam(stats::as.dist(views$mixed_distance), k = k, diss = TRUE)$clustering
      km_part <- stats::kmeans(views$mixed_latent, centers = k, nstart = 3)$cluster
      for (part in list(pam_part, km_part)) {
        same <- outer(part, part, FUN = "==") * 1
        key <- as.character(k)
        consensus_num[[key]][rows, rows] <- consensus_num[[key]][rows, rows] + same
        consensus_den[[key]][rows, rows] <- consensus_den[[key]][rows, rows] + 1
      }
    }
  }

  consensus_by_k <- list()
  stability <- stats::setNames(numeric(length(ks)), ks)
  for (k in ks) {
    key <- as.character(k)
    consensus <- consensus_num[[key]] / (consensus_den[[key]] + 1e-8)
    diag(consensus) <- 1
    consensus_by_k[[key]] <- consensus
    upper <- consensus[upper.tri(consensus)]
    upper <- pmin(pmax(upper, 1e-8), 1 - 1e-8)
    h <- -upper * log(upper) - (1 - upper) * log(1 - upper)
    stability[key] <- 1 - mean(h) / log(2)
  }
  list(consensus_by_k = consensus_by_k, stability = stability)
}

.finalize_from_consensus <- function(consensus, k) {
  hc <- stats::hclust(stats::as.dist(1 - consensus), method = "average")
  labels <- stats::cutree(hc, k = k)
  confidence <- vapply(seq_along(labels), function(i) {
    same <- labels == labels[i]
    same[i] <- FALSE
    if (!any(same)) 1 else mean(consensus[i, same], na.rm = TRUE)
  }, numeric(1))
  list(labels = labels, confidence = confidence, ambiguity = 1 - confidence)
}
