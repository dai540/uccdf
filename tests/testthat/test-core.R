test_that("schema inference returns expected roles", {
  schema <- infer_schema(toy_mixed_data, id_column = "sample_id")
  expect_true("sample_id" %in% schema$column_name)
  expect_equal(schema$role[schema$column_name == "sample_id"], "id")
  expect_true(all(schema$role[schema$column_name != "sample_id"] %in% c("active", "exclude")))
})

test_that("build_views returns two expected views", {
  schema <- infer_schema(toy_mixed_data, id_column = "sample_id")
  views <- build_views(toy_mixed_data, schema)
  expect_true(all(c("mixed_distance", "mixed_latent") %in% names(views)))
  expect_equal(nrow(views$mixed_distance), nrow(toy_mixed_data))
  expect_equal(nrow(views$mixed_latent), nrow(toy_mixed_data))
})

test_that("fit_uccdf returns a fitted object and assignments", {
  fit <- fit_uccdf(
    toy_mixed_data,
    id_column = "sample_id",
    candidate_k = 1:4,
    n_resamples = 12,
    n_null = 39,
    seed = 1
  )
  expect_s3_class(fit, "uccdf_fit")
  expect_equal(nrow(augment(fit)), nrow(toy_mixed_data))
  expect_true(all(c("k", "stability", "p_value", "supported", "objective") %in% names(select_k(fit))))
  expect_gt(fit$selected_k, 1L)
  expect_true(isTRUE(fit$selection$detected_structure))
  expect_true(anyDuplicated(augment(fit)$row_id) == 0L)
  expect_true("exploratory_cluster" %in% names(augment(fit)))
})

test_that("pure null data keeps selected_k at one while preserving exploratory labels", {
  set.seed(11)
  null_dat <- data.frame(
    sample_id = sprintf("N%03d", seq_len(80)),
    age = rnorm(80, 50, 8),
    score = rnorm(80),
    smoker = factor(sample(c("no", "yes"), 80, replace = TRUE)),
    stage = ordered(sample(c("I", "II", "III"), 80, replace = TRUE), levels = c("I", "II", "III")),
    subtype = factor(sample(c("A", "B", "C"), 80, replace = TRUE)),
    stringsAsFactors = FALSE
  )
  fit <- fit_uccdf(
    null_dat,
    id_column = "sample_id",
    candidate_k = 1:4,
    n_resamples = 12,
    n_null = 39,
    seed = 11
  )
  aug <- augment(fit)
  expect_identical(fit$selected_k, 1L)
  expect_false(isTRUE(fit$selection$detected_structure))
  expect_true(all(aug$cluster == 1L))
  expect_true(all(is.na(aug$confidence)))
  expect_true(length(unique(aug$exploratory_cluster)) > 1L)
  expect_true(all(aug$assignment_mode == "null_retained"))
})
