#' @export
print.uccdf_fit <- function(x, ...) {
  cat("uccdf fit\n")
  cat(sprintf("- samples: %s\n", nrow(x$data)))
  cat(sprintf("- active columns: %s\n", sum(x$schema$role == "active")))
  cat(sprintf("- selected_k: %s\n", x$selected_k))
  cat(sprintf("- detected_structure: %s\n", x$selection$detected_structure))
  cat(sprintf("- best_exploratory_k: %s\n", x$selection$best_exploratory_k))
  cat(sprintf("- global_p_value: %.4f\n", x$selection$global_p_value))
  invisible(x)
}
