# Plot the Mixed-Latent Embedding

Draws a low-dimensional scatter plot from the mixed-latent view stored
in a fitted `uccdf` object.

## Usage

``` r
plot_embedding(
  fit,
  dims = c(1, 2),
  color_by = c("auto", "selected", "exploratory"),
  show_labels = FALSE,
  ...
)
```

## Arguments

- fit:

  A fitted object from
  [`fit_uccdf()`](https://dai540.github.io/uccdf/reference/fit_uccdf.md).

- dims:

  Two latent dimensions to plot.

- color_by:

  Either `"auto"`, `"selected"`, or `"exploratory"`.

- show_labels:

  Logical; if `TRUE`, draw row labels.

- ...:

  Additional arguments passed to
  [`graphics::plot()`](https://rdrr.io/r/graphics/plot.default.html).

## Value

Invisibly returns `fit`.

## Examples

``` r
fit <- fit_uccdf(toy_mixed_data, id_column = "sample_id", n_resamples = 8, n_null = 39, seed = 1)
plot_embedding(fit)
```
