# Plot a Consensus Heatmap

Draws a hierarchical clustering heatmap of a consensus matrix.

## Usage

``` r
plot_consensus_heatmap(fit, k = NULL, ...)
```

## Arguments

- fit:

  A fitted object from
  [`fit_uccdf()`](https://dai540.github.io/uccdf/reference/fit_uccdf.md).

- k:

  Optional `K` to display. Defaults to the selected `K` when available,
  otherwise the largest fitted `K`.

- ...:

  Additional arguments passed to
  [`stats::heatmap()`](https://rdrr.io/r/stats/heatmap.html).

## Value

Invisibly returns `fit`.

## Examples

``` r
fit <- fit_uccdf(toy_mixed_data, id_column = "sample_id", n_resamples = 8, n_null = 39, seed = 1)
plot_consensus_heatmap(fit)
```
