# Build Canonical Views

Build Canonical Views

## Usage

``` r
build_views(data, schema, columns = NULL, latent_dims = 4L)
```

## Arguments

- data:

  A data frame.

- schema:

  A schema produced by
  [`infer_schema()`](https://dai540.github.io/uccdf/reference/infer_schema.md).

- columns:

  Optional active columns.

- latent_dims:

  Number of latent dimensions.

## Value

A list with `mixed_distance` and `mixed_latent`.
