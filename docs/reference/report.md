# Write a Compact UCCDF Report

Writes a short markdown or html summary of a fitted `uccdf` analysis.

## Usage

``` r
report(fit, file, format = c("md", "html"))
```

## Arguments

- fit:

  A fitted object from
  [`fit_uccdf()`](https://dai540.github.io/uccdf/reference/fit_uccdf.md).

- file:

  Output file path.

- format:

  Either `"md"` or `"html"`.

## Value

Invisibly returns `file`.

## Examples

``` r
dat <- simulate_mixed_data(n = 30, k = 2, seed = 1)
fit <- fit_uccdf(dat, id_column = "sample_id", n_resamples = 10, n_null = 39, seed = 1)
tmp <- tempfile(fileext = ".md")
report(fit, tmp, format = "md")
file.exists(tmp)
#> [1] TRUE
```
