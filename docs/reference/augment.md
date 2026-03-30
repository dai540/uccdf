# Extract Sample-Level Cluster Assignments

Returns row-level selected and exploratory assignments from a fitted
object.

## Usage

``` r
augment(fit)
```

## Arguments

- fit:

  A fitted object from
  [`fit_uccdf()`](https://dai540.github.io/uccdf/reference/fit_uccdf.md).

## Value

A data frame with one row per sample. When the global null is not
rejected, `cluster` remains 1 while `exploratory_*` columns expose the
best unsupported multi-cluster split.

## Examples

``` r
dat <- simulate_mixed_data(n = 40, k = 2, seed = 1)
fit <- fit_uccdf(dat, id_column = "sample_id", n_resamples = 10, n_null = 39, seed = 1)
head(augment(fit))
#>      row_id cluster confidence    ambiguity exploratory_cluster
#> S001   S001       1  0.9485380 5.146199e-02                   1
#> S002   S002       2  1.0000000 5.593150e-10                   2
#> S003   S003       2  1.0000000 5.699666e-10                   2
#> S004   S004       1  0.7244848 2.755152e-01                   1
#> S005   S005       2  1.0000000 5.551379e-10                   2
#> S006   S006       1  0.9602339 3.976608e-02                   1
#>      exploratory_confidence exploratory_ambiguity assignment_mode selected_k
#> S001              0.9485380          5.146199e-02        selected          2
#> S002              1.0000000          5.593150e-10        selected          2
#> S003              1.0000000          5.699666e-10        selected          2
#> S004              0.7244848          2.755152e-01        selected          2
#> S005              1.0000000          5.551379e-10        selected          2
#> S006              0.9602339          3.976608e-02        selected          2
#>      exploratory_k
#> S001             2
#> S002             2
#> S003             2
#> S004             2
#> S005             2
#> S006             2
```
