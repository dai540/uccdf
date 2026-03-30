#' Build Canonical UCCDF Views
#'
#' Constructs the mixed-distance and mixed-latent views used by `fit_uccdf()`.
#'
#' @param data A data frame.
#' @param schema A schema produced by [infer_schema()].
#' @param columns Optional subset of active columns.
#' @param latent_dims Number of latent dimensions to retain.
#'
#' @return A named list containing `mixed_distance` and `mixed_latent`.
#' @examples
#' dat <- simulate_mixed_data(n = 30, k = 3, seed = 2)
#' schema <- infer_schema(dat, id_column = "sample_id")
#' views <- build_views(dat, schema)
#' names(views)
#' @export
build_views <- function(data, schema, columns = NULL, latent_dims = 5L) {
  data <- .as_data_frame(data)
  if (is.null(columns)) {
    columns <- schema$column_name[schema$role == "active"]
  }
  list(
    mixed_distance = .compute_mixed_distance(data, schema, columns),
    mixed_latent = .build_latent_view(data, schema, columns, dims = latent_dims)
  )
}
