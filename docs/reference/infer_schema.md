# Infer a Simple Column Schema

Infers coarse variable types and clustering roles for a structured data
frame.

## Usage

``` r
infer_schema(data, id_column = NULL, ordinal_columns = NULL)
```

## Arguments

- data:

  A validated data frame or raw input table.

- id_column:

  Optional identifier column name.

- ordinal_columns:

  Optional character vector of columns to force as ordinal.

## Value

A data frame describing the inferred schema.

## Examples

``` r
dat <- simulate_mixed_data(n = 20, k = 2, seed = 1)
schema <- infer_schema(dat, id_column = "sample_id")
schema[, c("column_name", "type", "role")]
#>   column_name       type   role
#> 1   sample_id    nominal     id
#> 2         age continuous active
#> 3       score continuous active
#> 4      smoker     binary active
#> 5       stage    ordinal active
#> 6     subtype    nominal active
```
