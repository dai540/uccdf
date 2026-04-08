# uccdf <img src="man/figures/logo.svg" align="right" height="84" alt="uccdf logo" />

[![pkgdown](https://img.shields.io/badge/docs-pkgdown-315c86)](https://dai540.github.io/uccdf/)
[![R-CMD-check](https://github.com/dai540/uccdf/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dai540/uccdf/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

`uccdf` provides typed consensus clustering for structured mixed-type data
frames.

The package is designed for the following workflow:

- validate a tabular input object
- infer a simple column schema
- build more than one clustering representation of the same table
- aggregate clustering runs across resamples and learners
- run a global null test for non-trivial cluster structure
- select the best supported `K`
- return row-level labels, confidence, ambiguity, and exploratory assignments

Documentation website:

- <https://dai540.github.io/uccdf/>

Current scope:

- `continuous`
- `binary`
- `nominal`
- `ordinal`

## Installation

Install from GitHub with `pak`:

```r
install.packages("pak")
pak::pak("dai540/uccdf")
```

Or with `remotes`:

```r
install.packages("remotes")
remotes::install_github("dai540/uccdf")
```

Or from a source tarball:

```r
install.packages("path/to/uccdf_0.1.0.tar.gz", repos = NULL, type = "source")
```

## Minimal example

```r
library(uccdf)

fit <- fit_uccdf(
  toy_mixed_data,
  id_column = "sample_id",
  candidate_k = 1:4,
  n_resamples = 20,
  n_null = 99,
  seed = 42
)

fit$selection
select_k(fit)
head(augment(fit))
plot(fit, type = "selection")
plot_embedding(fit, color_by = "selected")
plot_consensus_heatmap(fit)
```

The practical readout is:

- `fit$selection` for the global decision
- `select_k(fit)` for the per-`K` support table
- `augment(fit)` for row-level assignments
- `plot_embedding(fit)` for latent separation
- `plot_consensus_heatmap(fit)` for hierarchical agreement structure

## Main functions

- `validate_input()`
- `infer_schema()`
- `build_views()`
- `fit_uccdf()`
- `select_k()`
- `augment()`
- `report()`
- `plot_embedding()`
- `plot_consensus_heatmap()`
- `simulate_mixed_data()`

## Selection design

`uccdf` separates two decisions:

1. whether the table shows evidence of non-trivial cluster structure
2. which `K` is the best supported solution conditional on that detection

When the global null is not rejected:

- `selected_k` is `1`
- `cluster` remains `1`
- `confidence` and `ambiguity` are `NA`
- `exploratory_cluster` stores the strongest unsupported split

This avoids overstating unsupported multi-cluster solutions while still exposing
structure that may be worth inspecting.

## Returned object

The main return value is a `uccdf_fit` object containing:

- inferred schema
- mixed-distance and mixed-latent views
- run-level metadata
- consensus matrices by candidate `K`
- null-score summaries
- selected and exploratory assignments

`confidence` is a consensus-derived assignment stability score. It is not a
Bayesian posterior probability.

## Built-in example datasets

Core example data:

- `toy_mixed_data`

Bundled real-data panels:

- `all_gene_panel`, derived from the Bioconductor `ALL` leukemia dataset
- `airway_gene_panel`, derived from the Bioconductor `airway` RNA-seq dataset
- `bladder_gene_panel`, derived from the Bioconductor `bladderbatch` dataset
- `golub_gene_panel`, derived from `multtest::golub`
- `pima_biomarker_panel`, derived from `mlbench::PimaIndiansDiabetes2`

## Website structure

The pkgdown site is organized into:

- `Get Started`
- `Reference`
- `Articles`

The article collection includes:

- design and method notes
- comparison with existing consensus clustering toolkits
- real-data analyses covering clinical, biomarker, and omics examples

Real-data articles currently include:

- `airquality`
- `CO2`
- `Indometh`
- `InsectSprays`
- `survey`
- `Cars93`
- `iris`
- `mtcars`
- `ChickWeight`
- `attitude`
- `USJudgeRatings`
- `golub`
- `ALL`
- `bladderEset`
- `PimaIndiansDiabetes2`

## Current limits

Version `0.1.0` is intentionally narrow.

- no first-class support for text, image, or graph data
- no dedicated `datetime` feature handling
- no advanced copula-style null generators
- no default `k-prototypes` or `KAMILA` workflow
