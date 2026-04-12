# Fit Consensus Clustering

Fit Consensus Clustering

## Usage

``` r
fit_uccdf(
  data,
  id_column = NULL,
  candidate_k = 2:4,
  n_resamples = 20L,
  row_fraction = 0.8,
  col_fraction = 0.8,
  latent_dims = 4L,
  seed = 123
)
```

## Arguments

- data:

  A data frame or matrix-like object.

- id_column:

  Optional identifier column name.

- candidate_k:

  Candidate cluster counts.

- n_resamples:

  Number of resamples.

- row_fraction:

  Fraction of rows per resample.

- col_fraction:

  Fraction of active columns per resample.

- latent_dims:

  Number of latent dimensions.

- seed:

  Random seed.

## Value

An object of class `uccdf_fit`.
