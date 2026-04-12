#' @export
print.uccdf_fit <- function(x, ...) {
  cat("uccdf fit\n")
  cat(sprintf("- rows: %s\n", nrow(x$data)))
  cat(sprintf("- active columns: %s\n", sum(x$schema$role == "active")))
  cat(sprintf("- selected_k: %s\n", x$selected_k))
  invisible(x)
}

#' @export
plot.uccdf_fit <- function(x, type = c("selection", "confidence"), ...) {
  type <- match.arg(type)
  if (identical(type, "selection")) {
    graphics::plot(x$k_table$k, x$k_table$stability, type = "b", pch = 19,
      xlab = "K", ylab = "Stability", ...
    )
    graphics::abline(v = x$selected_k, lty = 2, col = "firebrick")
    return(invisible(x))
  }
  graphics::boxplot(x$assignments$confidence, horizontal = TRUE, xlab = "Confidence", ...)
  invisible(x)
}

#' Plot the Latent Embedding
#'
#' @param fit A `uccdf_fit` object.
#' @param dims Two dimensions to plot.
#' @param ... Additional arguments passed to [graphics::plot()].
#'
#' @return Invisibly returns `fit`.
#' @export
plot_embedding <- function(fit, dims = c(1, 2), ...) {
  .assert_fit(fit)
  z <- fit$views$mixed_latent
  cls <- fit$assignments$cluster
  cols <- grDevices::hcl.colors(length(unique(cls)), "Set 2")[match(cls, sort(unique(cls)))]
  graphics::plot(z[, dims[1]], z[, dims[2]],
    col = cols, pch = 19,
    xlab = paste0("LV", dims[1]),
    ylab = paste0("LV", dims[2]),
    ...
  )
  invisible(fit)
}

#' Plot a Consensus Heatmap
#'
#' @param fit A `uccdf_fit` object.
#' @param k Optional `K`.
#' @param ... Additional arguments passed to [stats::heatmap()].
#'
#' @return Invisibly returns `fit`.
#' @export
plot_consensus_heatmap <- function(fit, k = NULL, ...) {
  .assert_fit(fit)
  if (is.null(k)) {
    k <- fit$selected_k
  }
  consensus <- fit$consensus_by_k[[as.character(k)]]
  ord <- stats::hclust(stats::as.dist(1 - consensus), method = "average")
  stats::heatmap(
    consensus,
    Rowv = stats::as.dendrogram(ord),
    Colv = stats::as.dendrogram(ord),
    symm = TRUE,
    scale = "none",
    col = grDevices::hcl.colors(32, "YlGnBu", rev = TRUE),
    margins = c(6, 6),
    ...
  )
  invisible(fit)
}
