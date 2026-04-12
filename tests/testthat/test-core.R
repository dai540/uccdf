test_that("fit_uccdf returns a valid object", {
  fit <- fit_uccdf(iris, candidate_k = 2:4, n_resamples = 6, seed = 1)
  expect_s3_class(fit, "uccdf_fit")
  expect_true(is.data.frame(select_k(fit)))
  expect_true(is.data.frame(augment(fit)))
})

test_that("validate_input rejects duplicate ids", {
  x <- simulate_mixed_data(n = 20, k = 2, seed = 1)
  x$sample_id[2] <- x$sample_id[1]
  expect_error(validate_input(x, id_column = "sample_id"))
})
