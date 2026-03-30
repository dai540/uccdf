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
