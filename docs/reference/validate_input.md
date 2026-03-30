# Validate a Structured Input Table

Checks that an input object can be treated as a tabular clustering
input.

## Usage

``` r
validate_input(data, id_column = NULL, min_rows = 5L)
```

## Arguments

- data:

  A data frame or matrix-like object.

- id_column:

  Optional identifier column name.

- min_rows:

  Minimum number of rows required.

## Value

A validated data frame with class `uccdf_validated`.

## Examples

``` r
dat <- simulate_mixed_data(n = 20, k = 2, seed = 1)
validated <- validate_input(dat, id_column = "sample_id")
nrow(validated)
#> [1] 20
```
