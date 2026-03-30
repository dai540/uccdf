#' Plot the Mixed-Latent Embedding
#'
#' Draws a low-dimensional scatter plot from the mixed-latent view stored in a
#' fitted `uccdf` object.
#'
#' @param fit A fitted object from [fit_uccdf()].
#' @param dims Two latent dimensions to plot.
#' @param color_by Either `"auto"`, `"selected"`, or `"exploratory"`.
#' @param show_labels Logical; if `TRUE`, draw row labels.
#' @param ... Additional arguments passed to [graphics::plot()].
#'
#' @return Invisibly returns `fit`.
#' @examples
#' fit <- fit_uccdf(toy_mixed_data, id_column = "sample_id", n_resamples = 8, n_null = 39, seed = 1)
#' plot_embedding(fit)
#' @export
plot_embedding <- function(fit, dims = c(1, 2), color_by = c("auto", "selected", "exploratory"), show_labels = FALSE, ...) {
  if (!inherits(fit, "uccdf_fit")) {
    stop("`fit` must inherit from `uccdf_fit`.", call. = FALSE)
  }
  z <- fit$views$mixed_latent
  if (ncol(z) < max(dims)) {
    stop("Requested dimensions are not available in the latent view.", call. = FALSE)
  }
  cluster_info <- .resolve_plot_clusters(fit, color_by = color_by)
  cls <- cluster_info$clusters
  palette_name <- if (length(unique(cls)) <= 3L) "Dark 3" else "Set 3"
  cols <- grDevices::hcl.colors(length(unique(cls)), palette = palette_name)
  cls_levels <- sort(unique(cls))
  col_map <- cols[match(cls, cls_levels)]
  old_par <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old_par), add = TRUE)
  graphics::layout(matrix(c(1, 2), nrow = 1), widths = c(4.0, 2.0))
  on.exit(graphics::layout(1), add = TRUE)
  graphics::plot(
    z[, dims[1]],
    z[, dims[2]],
    col = col_map,
    pch = 19,
    xlab = paste0("LV", dims[1]),
    ylab = paste0("LV", dims[2]),
    ...
  )
  if (show_labels) {
    graphics::text(z[, dims[1]], z[, dims[2]], labels = fit$assignments$row_id, pos = 3, cex = 0.7)
  }
  graphics::par(mar = c(0, 0, 0, 0))
  graphics::plot.new()
  graphics::legend("topleft",
    inset = c(0.02, 0.02),
    legend = paste("Cluster", cls_levels),
    title = sprintf("%s coloring\nK = %s", tools::toTitleCase(cluster_info$mode), cluster_info$k),
    col = cols, pch = 19, bty = "n", cex = 0.95
  )
  invisible(fit)
}

#' Plot a Consensus Heatmap
#'
#' Draws a hierarchical clustering heatmap of a consensus matrix.
#'
#' @param fit A fitted object from [fit_uccdf()].
#' @param k Optional `K` to display. Defaults to the selected `K` when
#'   available, otherwise the largest fitted `K`.
#' @param ... Additional arguments passed to [stats::heatmap()].
#'
#' @return Invisibly returns `fit`.
#' @examples
#' fit <- fit_uccdf(toy_mixed_data, id_column = "sample_id", n_resamples = 8, n_null = 39, seed = 1)
#' plot_consensus_heatmap(fit)
#' @export
plot_consensus_heatmap <- function(fit, k = NULL, ...) {
  if (!inherits(fit, "uccdf_fit")) {
    stop("`fit` must inherit from `uccdf_fit`.", call. = FALSE)
  }
  if (is.null(k)) {
    k <- if (fit$selected_k > 1L) fit$selected_k else fit$selection$best_exploratory_k
  }
  k_chr <- as.character(k)
  if (!k_chr %in% names(fit$consensus_by_k)) {
    stop("Requested `k` is not available in `fit$consensus_by_k`.", call. = FALSE)
  }
  consensus <- fit$consensus_by_k[[k_chr]]
  ord <- stats::hclust(stats::as.dist(1 - consensus), method = "average")
  stats::heatmap(
    consensus,
    Rowv = stats::as.dendrogram(ord),
    Colv = stats::as.dendrogram(ord),
    symm = TRUE,
    scale = "none",
    col = grDevices::hcl.colors(64, "YlGnBu", rev = TRUE),
    margins = c(6, 6),
    ...
  )
  invisible(fit)
}
