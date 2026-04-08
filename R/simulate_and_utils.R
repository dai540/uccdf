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

.validate_single_string <- function(x, arg) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    stop(sprintf("`%s` must be a single non-empty string.", arg), call. = FALSE)
  }
}

.as_data_frame <- function(data) {
  if (inherits(data, "data.frame")) {
    return(data)
  }
  if (is.matrix(data)) {
    return(as.data.frame(data, stringsAsFactors = FALSE))
  }
  stop("`data` must be a data.frame or matrix-like object coercible to a data.frame.", call. = FALSE)
}

.coerce_ordinal <- function(x) {
  if (is.ordered(x)) {
    return(x)
  }
  if (is.factor(x)) {
    return(ordered(as.character(x), levels = levels(x)))
  }
  ordered(as.character(x))
}

.detect_type <- function(x) {
  x_obs <- x[!is.na(x)]
  if (!length(x_obs)) {
    return("exclude")
  }
  if (is.ordered(x)) {
    return("ordinal")
  }
  if (is.factor(x)) {
    n_levels <- length(levels(x))
    if (n_levels == 2L) {
      return("binary")
    }
    return("nominal")
  }
  if (is.logical(x)) {
    return("binary")
  }
  if (inherits(x, "Date") || inherits(x, "POSIXt")) {
    return("exclude")
  }
  if (is.numeric(x) || is.integer(x)) {
    ux <- unique(x_obs)
    if (length(ux) == 2L && all(sort(ux) %in% c(0, 1))) {
      return("binary")
    }
    return("continuous")
  }
  if (is.character(x)) {
    ux <- unique(x_obs)
    if (length(ux) == 2L) {
      return("binary")
    }
    return("nominal")
  }
  "exclude"
}

.infer_role <- function(name, x, id_column) {
  if (!is.null(id_column) && identical(name, id_column)) {
    return("id")
  }
  x_obs <- x[!is.na(x)]
  if (!length(x_obs)) {
    return("exclude")
  }
  if (length(unique(x_obs)) <= 1L) {
    return("exclude")
  }
  unique_ratio <- length(unique(x_obs)) / length(x_obs)
  if (is.character(x) && unique_ratio > 0.95) {
    return("exclude")
  }
  "active"
}

.robust_scale <- function(x) {
  x_obs <- x[!is.na(x)]
  if (length(x_obs) <= 1L) {
    return(1)
  }
  iqr <- diff(stats::quantile(x_obs, probs = c(0.25, 0.75), names = FALSE, type = 7))
  if (is.na(iqr) || iqr <= 0) {
    s <- stats::sd(x_obs)
    if (is.na(s) || s <= 0) {
      return(1)
    }
    return(s)
  }
  iqr
}

.sample_columns_by_type <- function(schema, fraction) {
  active <- schema[schema$role == "active", , drop = FALSE]
  if (!nrow(active)) {
    return(character(0))
  }
  out <- character(0)
  type_groups <- split(active$column_name, active$type)
  for (cols in type_groups) {
    n_take <- max(1L, ceiling(length(cols) * fraction))
    out <- c(out, sample(cols, size = min(length(cols), n_take), replace = FALSE))
  }
  unique(out)
}

.expand_mixed_matrix <- function(data, schema, columns) {
  if (!length(columns)) {
    stop("No columns were selected for the mixed-latent view.", call. = FALSE)
  }
  blocks <- list()
  for (nm in columns) {
    type <- schema$type[match(nm, schema$column_name)]
    x <- data[[nm]]
    if (identical(type, "continuous")) {
      v <- as.numeric(x)
      med <- stats::median(v, na.rm = TRUE)
      if (is.na(med)) {
        med <- 0
      }
      v[is.na(v)] <- med
      sc <- .robust_scale(v)
      blocks[[nm]] <- matrix((v - mean(v)) / (sc + 1e-8), ncol = 1L, dimnames = list(NULL, nm))
    } else if (identical(type, "binary") || identical(type, "nominal")) {
      f <- factor(ifelse(is.na(x), "missing", as.character(x)), exclude = NULL)
      if (length(levels(f)) == 1L) {
        mm <- matrix(1, nrow = length(f), ncol = 1L)
        colnames(mm) <- paste0(nm, "::", levels(f))
      } else {
        mm <- stats::model.matrix(~ f - 1)
        colnames(mm) <- paste0(nm, "::", levels(f))
      }
      blocks[[nm]] <- mm
    } else if (identical(type, "ordinal")) {
      f <- .coerce_ordinal(x)
      codes <- as.numeric(f)
      med <- stats::median(codes, na.rm = TRUE)
      if (is.na(med)) {
        med <- 1
      }
      codes[is.na(codes)] <- med
      L <- max(codes, na.rm = TRUE)
      blocks[[nm]] <- matrix(codes / max(1, L - 1), ncol = 1L, dimnames = list(NULL, nm))
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
    alpha <- schema$weight_init[match(nm, schema$column_name)]
    x <- data[[nm]]
    obs <- !is.na(x)
    if (!any(obs)) {
      next
    }
    if (identical(type, "continuous")) {
      v <- as.numeric(x)
      scale_j <- .robust_scale(v)
      delta <- abs(outer(v, v, "-")) / (scale_j + 1e-8)
      mask <- outer(obs, obs, "&")
      delta[!mask] <- 0
    } else if (identical(type, "ordinal")) {
      codes <- as.numeric(.coerce_ordinal(x))
      L <- max(codes, na.rm = TRUE)
      delta <- abs(outer(codes, codes, "-")) / max(1, L - 1)
      mask <- outer(obs, obs, "&")
      delta[!mask] <- 0
    } else {
      chars <- as.character(x)
      delta <- outer(chars, chars, FUN = function(a, b) as.numeric(a != b))
      mask <- outer(obs, obs, "&")
      delta[!mask] <- 0
    }
    D <- D + alpha * delta
    W <- W + alpha * outer(obs, obs, "&")
  }
  out <- D / (W + 1e-8)
  diag(out) <- 0
  out
}

.build_latent_view <- function(data, schema, columns, dims = 5L) {
  X <- .expand_mixed_matrix(data, schema, columns)
  rank_max <- min(nrow(X) - 1L, ncol(X), dims)
  if (rank_max < 1L) {
    z <- matrix(0, nrow(X), 1L)
    rownames(z) <- rownames(data)
    colnames(z) <- "LV1"
    return(z)
  }
  pca <- stats::prcomp(X, center = TRUE, scale. = FALSE, rank. = rank_max)
  z <- pca$x[, seq_len(rank_max), drop = FALSE]
  colnames(z) <- paste0("LV", seq_len(ncol(z)))
  z
}

.run_learner <- function(view, learner, k) {
  if (identical(learner, "pam")) {
    fit <- cluster::pam(stats::as.dist(view), k = k, diss = TRUE)
    return(fit$clustering)
  }
  if (identical(learner, "hierarchical")) {
    hc <- stats::hclust(stats::as.dist(view), method = "average")
    return(stats::cutree(hc, k = k))
  }
  if (identical(learner, "kmeans")) {
    fit <- stats::kmeans(view, centers = k, nstart = 5)
    return(fit$cluster)
  }
  stop(sprintf("Unknown learner: %s", learner), call. = FALSE)
}

.pair_entropy_stability <- function(consensus) {
  if (nrow(consensus) <= 1L) {
    return(1)
  }
  upper <- consensus[upper.tri(consensus)]
  upper <- pmin(pmax(upper, 1e-8), 1 - 1e-8)
  h <- -upper * log(upper) - (1 - upper) * log(1 - upper)
  1 - mean(h) / log(2)
}

.compute_row_ids <- function(data, id_column = NULL) {
  row_ids <- if (!is.null(id_column)) as.character(data[[id_column]]) else rownames(data)
  if (is.null(row_ids)) {
    row_ids <- sprintf("row_%s", seq_len(nrow(data)))
  }
  row_ids
}

.compute_consensus_from_runs <- function(data,
                                         schema,
                                         id_column,
                                         ks,
                                         n_resamples,
                                         row_fraction,
                                         col_fraction,
                                         use_views,
                                         learners,
                                         latent_dims,
                                         store_runs = FALSE) {
  row_ids <- .compute_row_ids(data, id_column = id_column)
  rownames(data) <- row_ids
  grid <- .make_run_grid(use_views, learners)
  if (!length(grid)) {
    stop("No compatible learner-view pairs were selected.", call. = FALSE)
  }

  consensus_num <- lapply(ks, function(k) {
    matrix(0, nrow(data), nrow(data), dimnames = list(row_ids, row_ids))
  })
  consensus_den <- lapply(ks, function(k) {
    matrix(0, nrow(data), nrow(data), dimnames = list(row_ids, row_ids))
  })
  names(consensus_num) <- as.character(ks)
  names(consensus_den) <- as.character(ks)

  runs <- if (store_runs) {
    vector("list", length = n_resamples * length(grid) * length(ks))
  } else {
    NULL
  }
  run_idx <- 1L

  for (b in seq_len(n_resamples)) {
    row_take <- max(2L, ceiling(nrow(data) * row_fraction))
    rows <- sort(sample(seq_len(nrow(data)), size = row_take, replace = FALSE))
    cols <- .sample_columns_by_type(schema, col_fraction)
    if (!length(cols)) {
      next
    }
    sub_data <- data[rows, c(if (!is.null(id_column)) id_column, cols), drop = FALSE]
    sub_schema <- schema[schema$column_name %in% names(sub_data), , drop = FALSE]
    views <- build_views(sub_data, sub_schema, columns = cols, latent_dims = latent_dims)
    active_grid <- sample(grid, length(grid), replace = FALSE)
    if (length(active_grid) > 1L) {
      drop_n <- floor(length(active_grid) * 0.1)
      if (drop_n > 0L) {
        active_grid <- active_grid[seq_len(length(active_grid) - drop_n)]
      }
    }

    for (ga in active_grid) {
      view_obj <- if (identical(ga$view, "mixed_distance")) views$mixed_distance else views$mixed_latent
      for (k in ks) {
        part <- as.integer(.run_learner(view_obj, ga$learner, k = k))
        k_chr <- as.character(k)
        same <- outer(part, part, FUN = "==") * 1
        consensus_num[[k_chr]][rows, rows] <- consensus_num[[k_chr]][rows, rows] + same
        consensus_den[[k_chr]][rows, rows] <- consensus_den[[k_chr]][rows, rows] + 1
        if (store_runs) {
          runs[[run_idx]] <- list(
            resample = b,
            view = ga$view,
            learner = ga$learner,
            k = k,
            row_ids = row_ids[rows],
            partition = part,
            columns = cols
          )
          run_idx <- run_idx + 1L
        }
      }
    }
  }

  consensus_by_k <- list()
  stability <- numeric(length(ks))
  names(stability) <- as.character(ks)
  for (k in ks) {
    k_chr <- as.character(k)
    consensus <- consensus_num[[k_chr]] / (consensus_den[[k_chr]] + 1e-8)
    diag(consensus) <- 1
    consensus_by_k[[k_chr]] <- consensus
    stability[k_chr] <- .pair_entropy_stability(consensus)
  }

  list(
    row_ids = row_ids,
    grid = grid,
    runs = if (store_runs) Filter(Negate(is.null), runs) else NULL,
    consensus_by_k = consensus_by_k,
    stability = stability
  )
}

.finalize_from_consensus <- function(consensus, k) {
  if (k <= 1L) {
    labels <- rep(1L, nrow(consensus))
  } else {
    hc <- stats::hclust(stats::as.dist(1 - consensus), method = "average")
    labels <- stats::cutree(hc, k = k)
  }
  confidence <- numeric(length(labels))
  for (i in seq_along(labels)) {
    same <- labels == labels[i]
    same[i] <- FALSE
    if (!any(same)) {
      confidence[i] <- 1
    } else {
      confidence[i] <- mean(consensus[i, same], na.rm = TRUE)
    }
  }
  confidence[is.na(confidence)] <- 0
  ambiguity <- 1 - confidence
  list(labels = labels, confidence = confidence, ambiguity = ambiguity)
}

.generate_null_data <- function(data, schema, family = "independence_marginal_null") {
  out <- data
  active <- schema$column_name[schema$role == "active"]
  for (nm in active) {
    x <- data[[nm]]
    miss <- is.na(x)
    obs <- x[!miss]
    if (!length(obs)) {
      next
    }
    sampled_obs <- switch(
      family,
      independence_marginal_null = sample(obs, length(obs), replace = FALSE),
      bootstrap_marginal_null = sample(obs, length(obs), replace = TRUE),
      type_stratified_permutation_null = sample(obs, length(obs), replace = FALSE),
      stop(sprintf("Unknown null family: %s", family), call. = FALSE)
    )
    if (is.factor(x)) {
      x0 <- x
      x0[!miss] <- sampled_obs
      x0[miss] <- NA
      sampled_chr <- as.character(x0)
      sampled_chr[is.na(x0)] <- NA_character_
      x0 <- factor(sampled_chr, levels = levels(x), ordered = is.ordered(x))
    } else if (inherits(x, "Date")) {
      x0 <- x
      x0[!miss] <- sampled_obs
      x0[miss] <- as.Date(NA)
    } else {
      x0 <- x
      x0[!miss] <- sampled_obs
      x0[miss] <- NA
    }
    out[[nm]] <- x0
  }
  out
}

.compute_selection_table <- function(stability,
                                     null_scores,
                                     ks,
                                     consensus_by_k,
                                     alpha,
                                     lambda_logk,
                                     gamma_small_cluster,
                                     min_cluster_size) {
  null_mean <- colMeans(null_scores, na.rm = TRUE)
  null_sd <- apply(null_scores, 2, stats::sd, na.rm = TRUE)
  stability_excess <- as.numeric(stability) - as.numeric(null_mean)
  z_score <- stability_excess / (null_sd + 1e-8)
  p_value <- vapply(seq_along(ks), function(i) {
    (1 + sum(null_scores[, i] >= as.numeric(stability)[i], na.rm = TRUE)) / (nrow(null_scores) + 1)
  }, numeric(1))

  objective <- vapply(seq_along(ks), function(i) {
    final_tmp <- .finalize_from_consensus(consensus_by_k[[as.character(ks[i])]], ks[i])
    counts <- table(final_tmp$labels)
    z_score[i] - lambda_logk * log(ks[i]) - gamma_small_cluster * sum(counts < min_cluster_size)
  }, numeric(1))

  supported <- p_value <= alpha
  global_observed <- max(stability_excess)
  global_null <- apply(sweep(null_scores, 2, null_mean, "-"), 1, max, na.rm = TRUE)
  global_p_value <- (1 + sum(global_null >= global_observed, na.rm = TRUE)) / (nrow(null_scores) + 1)
  best_exploratory_idx <- which.max(objective)
  supported_idx <- which(supported)
  best_supported_idx <- if (length(supported_idx)) supported_idx[which.max(objective[supported_idx])] else NA_integer_

  list(
    k_table = data.frame(
      k = ks,
      stability = as.numeric(stability),
      null_mean = as.numeric(null_mean),
      null_sd = as.numeric(null_sd),
      stability_excess = as.numeric(stability_excess),
      z_score = as.numeric(z_score),
      p_value = as.numeric(p_value),
      supported = supported,
      objective = as.numeric(objective),
      stringsAsFactors = FALSE
    ),
    global_p_value = global_p_value,
    detected_structure = global_p_value <= alpha,
    best_exploratory_idx = best_exploratory_idx,
    best_supported_idx = best_supported_idx
  )
}

.build_assignment_table <- function(row_ids,
                                    selected,
                                    exploratory,
                                    selected_k,
                                    exploratory_k,
                                    assignment_mode) {
  data.frame(
    row_id = row_ids,
    cluster = selected$labels,
    confidence = selected$confidence,
    ambiguity = selected$ambiguity,
    exploratory_cluster = exploratory$labels,
    exploratory_confidence = exploratory$confidence,
    exploratory_ambiguity = exploratory$ambiguity,
    assignment_mode = rep(assignment_mode, length(row_ids)),
    selected_k = rep(selected_k, length(row_ids)),
    exploratory_k = rep(exploratory_k, length(row_ids)),
    stringsAsFactors = FALSE
  )
}

.resolve_plot_clusters <- function(fit, color_by = c("auto", "selected", "exploratory")) {
  color_by <- match.arg(color_by)
  assignments <- fit$assignments
  detected <- isTRUE(fit$selection$detected_structure)
  if (identical(color_by, "selected")) {
    return(list(
      clusters = assignments$cluster,
      mode = "selected",
      k = fit$selected_k
    ))
  }
  if (identical(color_by, "exploratory")) {
    return(list(
      clusters = assignments$exploratory_cluster,
      mode = "exploratory",
      k = unique(assignments$exploratory_k)[1]
    ))
  }
  if (detected || all(assignments$exploratory_cluster == assignments$cluster)) {
    return(list(
      clusters = assignments$cluster,
      mode = "selected",
      k = fit$selected_k
    ))
  }
  list(
    clusters = assignments$exploratory_cluster,
    mode = "exploratory",
    k = unique(assignments$exploratory_k)[1]
  )
}

.make_run_grid <- function(use_views, learners) {
  compat <- list(
    mixed_distance = c("pam", "hierarchical"),
    mixed_latent = c("kmeans")
  )
  grid <- list()
  idx <- 1L
  for (view in use_views) {
    ok <- intersect(learners, compat[[view]])
    for (learner in ok) {
      grid[[idx]] <- list(view = view, learner = learner)
      idx <- idx + 1L
    }
  }
  grid
}

.compact_report_lines <- function(fit) {
  out <- c(
    "# uccdf report",
    "",
    sprintf("- selected_k: %s", fit$selected_k),
    sprintf("- detected_structure: %s", fit$selection$detected_structure),
    sprintf("- global_p_value: %.4f", fit$selection$global_p_value),
    sprintf("- best_exploratory_k: %s", fit$selection$best_exploratory_k),
    sprintf("- n_rows: %s", nrow(fit$data)),
    sprintf("- n_active_columns: %s", sum(fit$schema$role == "active")),
    "",
    "## K summary",
    ""
  )
  ks <- fit$k_table
  for (i in seq_len(nrow(ks))) {
    out <- c(
      out,
      sprintf(
        "- K=%s stability=%.3f excess=%.3f z=%.3f p=%.4f supported=%s objective=%.3f",
        ks$k[i], ks$stability[i], ks$stability_excess[i], ks$z_score[i], ks$p_value[i], ks$supported[i], ks$objective[i]
      )
    )
  }
  out
}
