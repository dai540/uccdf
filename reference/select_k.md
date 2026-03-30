# Extract the K Selection Table

Returns the null-calibrated K summary from a fitted `uccdf` object.

## Usage

``` r
select_k(fit)
```

## Arguments

- fit:

  A fitted object from
  [`fit_uccdf()`](https://dai540.github.io/uccdf/reference/fit_uccdf.md).

## Value

A data frame with per-K stability and selection statistics.

## Examples

``` r
dat <- simulate_mixed_data(n = 40, k = 2, seed = 1)
fit <- fit_uccdf(dat, id_column = "sample_id", n_resamples = 10, n_null = 39, seed = 1)
select_k(fit)
#>   k stability null_mean    null_sd stability_excess  z_score p_value supported
#> 1 2 0.8563102 0.2446532 0.06182794        0.6116570 9.892889   0.025      TRUE
#> 2 3 0.6254101 0.2962703 0.07149499        0.3291398 4.603676   0.025      TRUE
#> 3 4 0.7130688 0.4264682 0.07595015        0.2866006 3.773535   0.025      TRUE
#> 4 5 0.7514178 0.5401710 0.05618772        0.2112469 3.759663   0.025      TRUE
#> 5 6 0.8116152 0.6268799 0.04291495        0.1847352 4.304682   0.025      TRUE
#>   objective
#> 1  9.754259
#> 2  4.383953
#> 3  3.496276
#> 4  2.437775
#> 5  1.946330
```
