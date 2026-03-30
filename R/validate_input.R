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
