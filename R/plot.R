#' @export
plot.uccdf_fit <- function(x, type = c("selection", "confidence"), ...) {
  type <- match.arg(type)
  old <- graphics::par(no.readonly = TRUE)
  on.exit(graphics::par(old))
  if (identical(type, "selection")) {
    tbl <- x$k_table
    graphics::plot(tbl$k, tbl$stability,
      type = "b", pch = 19, xlab = "K", ylab = "Stability", ...
    )
    graphics::abline(v = x$selected_k, lty = 2, col = "firebrick")
    return(invisible(x))
  }
  score <- if (all(is.na(x$assignments$confidence))) x$assignments$exploratory_confidence else x$assignments$confidence
  title <- if (all(is.na(x$assignments$confidence))) {
    "Exploratory assignment confidence"
  } else {
    "Assignment confidence"
  }
  graphics::boxplot(score,
    horizontal = TRUE, xlab = "Confidence",
    main = title, ...
  )
  invisible(x)
}
