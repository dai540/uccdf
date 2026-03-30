# Fit Typed Consensus Clustering

Runs a compact typed consensus clustering workflow for a structured data
frame. The workflow infers a schema, builds mixed-distance and
mixed-latent views, aggregates partitions across resamples and learners,
calibrates stability against simple null tables, selects `K`, and
returns row-level labels with confidence and ambiguity.

## Usage

``` r
fit_uccdf(
  data,
  id_column = NULL,
  candidate_k = 1:6,
  n_resamples = 50L,
  row_fraction = 0.8,
  col_fraction = 0.7,
  use_views = c("mixed_distance", "mixed_latent"),
  learners = c("pam", "hierarchical", "kmeans"),
  n_null = 99L,
  null_family = "independence_marginal_null",
  alpha = 0.05,
  lambda_logk = 0.2,
  gamma_small_cluster = 1,
  min_cluster_size = 5L,
  latent_dims = 5L,
  seed = 123
)
```

## Arguments

- data:

  A data frame or matrix-like object.

- id_column:

  Optional identifier column name.

- candidate_k:

  Integer vector of candidate cluster counts. Values below 2 are ignored
  during fitting; the method can still return `K = 1` if the global null
  is not rejected.

- n_resamples:

  Number of bootstrap-like resamples.

- row_fraction:

  Fraction of rows sampled per resample.

- col_fraction:

  Fraction of active columns sampled within each type.

- use_views:

  Character vector containing any of `"mixed_distance"` and
  `"mixed_latent"`.

- learners:

  Character vector of learners. Supported values are `"pam"`,
  `"hierarchical"`, and `"kmeans"`.

- n_null:

  Number of null replicates.

- null_family:

  Null family. The default is `"independence_marginal_null"`.

- alpha:

  Significance level used for the global null test and per-K support.

- lambda_logk:

  Complexity penalty on large K.

- gamma_small_cluster:

  Penalty for clusters smaller than `min_cluster_size`.

- min_cluster_size:

  Minimum acceptable cluster size in the final partition.

- latent_dims:

  Number of latent dimensions for the mixed-latent view.

- seed:

  Random seed.

## Value

An object of class `uccdf_fit`.

## Examples

``` r
dat <- simulate_mixed_data(n = 50, k = 3, seed = 1)
fit <- fit_uccdf(
  dat,
  id_column = "sample_id",
  n_resamples = 12,
  n_null = 39,
  candidate_k = 1:4,
  seed = 1
)
fit
#> uccdf fit
#> - samples: 50
#> - active columns: 5
#> - selected_k: 1
#> - detected_structure: FALSE
#> - best_exploratory_k: 4
#> - global_p_value: 0.0750
head(augment(fit))
#>      row_id cluster confidence ambiguity exploratory_cluster
#> S001   S001       1         NA        NA                   1
#> S002   S002       1         NA        NA                   2
#> S003   S003       1         NA        NA                   3
#> S004   S004       1         NA        NA                   1
#> S005   S005       1         NA        NA                   2
#> S006   S006       1         NA        NA                   1
#>      exploratory_confidence exploratory_ambiguity assignment_mode selected_k
#> S001              0.7208900             0.2791100   null_retained          1
#> S002              0.7981859             0.2018141   null_retained          1
#> S003              0.8767361             0.1232639   null_retained          1
#> S004              0.6190949             0.3809051   null_retained          1
#> S005              0.8015306             0.1984694   null_retained          1
#> S006              0.7123866             0.2876134   null_retained          1
#>      exploratory_k
#> S001             4
#> S002             4
#> S003             4
#> S004             4
#> S005             4
#> S006             4
```
