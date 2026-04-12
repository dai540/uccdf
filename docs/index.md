# uccdf

`uccdf` is a compact R package for consensus clustering on tabular data
frames.

The package is intentionally narrow. It is designed for situations where
the input is already a structured table and the goal is to obtain a
stable cluster assignment without introducing a large dependency
surface, large bundled data, or a complex project layout.

This repository has been rebuilt around four practical goals:

1.  keep the package source small
2.  keep the code readable
3.  keep the generated site simple
4.  keep the example footprint limited to built-in datasets

## What the package does

The workflow is:

1.  validate a `data.frame`
2.  infer a coarse schema
3.  build two clustering views
4.  fit repeated clustering runs
5.  aggregate them into consensus matrices
6.  choose a supported `K`
7.  return row-level assignments and confidence summaries

The implementation is minimal by design. It provides a single compact
workflow for small to medium tabular analyses, not a broad clustering
framework.

## Main functions

- [`validate_input()`](https://dai540.github.io/uccdf/reference/validate_input.md)
- [`infer_schema()`](https://dai540.github.io/uccdf/reference/infer_schema.md)
- [`build_views()`](https://dai540.github.io/uccdf/reference/build_views.md)
- [`fit_uccdf()`](https://dai540.github.io/uccdf/reference/fit_uccdf.md)
- [`select_k()`](https://dai540.github.io/uccdf/reference/select_k.md)
- [`augment()`](https://dai540.github.io/uccdf/reference/augment.md)
- [`report()`](https://dai540.github.io/uccdf/reference/report.md)
- [`plot_embedding()`](https://dai540.github.io/uccdf/reference/plot_embedding.md)
- [`plot_consensus_heatmap()`](https://dai540.github.io/uccdf/reference/plot_consensus_heatmap.md)
- [`simulate_mixed_data()`](https://dai540.github.io/uccdf/reference/simulate_mixed_data.md)

## Installation

Install from GitHub:

``` r

install.packages("pak")
pak::pak("dai540/uccdf")
```

Or:

``` r

install.packages("remotes")
remotes::install_github("dai540/uccdf")
```

## Minimal example

``` r

library(uccdf)

fit <- fit_uccdf(
  iris,
  candidate_k = 2:4,
  n_resamples = 20,
  seed = 42
)

fit
select_k(fit)
head(augment(fit))
plot_embedding(fit)
plot_consensus_heatmap(fit)
```

## Design

The package deliberately limits scope.

- Input is a `data.frame` or matrix-like object.
- Column types are inferred coarsely as continuous, binary, nominal,
  ordinal, or excluded.
- Two views are constructed:
  - a mixed-distance view
  - a low-dimensional latent view
- Clustering is aggregated across a small learner set.

This package does not attempt to support text, images, graphs, large
external omics downloads, or highly specialized clustering backends.

## Output

The fitted object stores:

- the validated input
- the inferred schema
- the latent and distance views
- consensus matrices by `K`
- a selection table
- row-level cluster assignments

`confidence` is an empirical assignment stability score derived from the
consensus matrix. It is not a posterior probability.

## Documentation website

The pkgdown site is organized into four sections:

- Getting Started
- Guides
- Tutorials
- Reference

The tutorials use only datasets that are available in base R or
recommended packages so that the repository remains lightweight.

A minimal `sphinx/` source tree is also included for environments that
prefer a plain static documentation build with the same four sections.

## Repository structure

The repository is intentionally minimal:

- `R/` contains the package source
- `man/` contains generated Rd files
- `tests/` contains testthat tests
- `vignettes/` contains the pkgdown articles
- `docs/` contains the built pkgdown site
- `.github/workflows/` contains CI and site publishing workflows

Removed on purpose:

- bundled large datasets
- temporary generation directories
- local build artifacts
- unused helper scripts

## Development notes

Typical local verification:

``` r

roxygen2::roxygenise(".")
pkgdown::build_site(".")
```

Or from the shell:

``` sh
R CMD build .
R CMD check --no-manual uccdf_0.1.0.tar.gz
```

Generated `.tar.gz` files and `*.Rcheck/` directories should not be
committed.
