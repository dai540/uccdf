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
