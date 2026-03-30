# Build Canonical UCCDF Views

Constructs the mixed-distance and mixed-latent views used by
[`fit_uccdf()`](https://dai540.github.io/uccdf/reference/fit_uccdf.md).

## Usage

``` r
build_views(data, schema, columns = NULL, latent_dims = 5L)
```

## Arguments

- data:

  A data frame.

- schema:

  A schema produced by
  [`infer_schema()`](https://dai540.github.io/uccdf/reference/infer_schema.md).

- columns:

  Optional subset of active columns.

- latent_dims:

  Number of latent dimensions to retain.

## Value

A named list containing `mixed_distance` and `mixed_latent`.

## Examples

``` r
dat <- simulate_mixed_data(n = 30, k = 3, seed = 2)
schema <- infer_schema(dat, id_column = "sample_id")
views <- build_views(dat, schema)
names(views)
#> [1] "mixed_distance" "mixed_latent"  
```
