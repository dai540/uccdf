# uccdf <img src="man/figures/logo.svg" align="right" height="84" alt="uccdf logo" />

[![pkgdown](https://img.shields.io/badge/docs-pkgdown-315c86)](https://dai540.github.io/uccdf/)
[![R-CMD-check](https://github.com/dai540/uccdf/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dai540/uccdf/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

`uccdf` is an R package for typed consensus clustering on structured mixed-type
data frames.

It is built for a narrow but common exploratory problem:

- start from a `data.frame`
- infer a simple column schema
- build more than one reasonable representation of the same table
- fit multiple clustering runs across resamples
- run a global null test for "no cluster structure"
- choose the best supported `K`
- return sample-level labels, confidence, and exploratory assignments

The quickest way to understand a fit is to inspect these three views together:

- the `K` selection table from `select_k()`
- the cluster-colored latent scatter from `plot_embedding()`
- the hierarchical consensus heatmap from `plot_consensus_heatmap()`

The pkgdown site includes:

- a method-and-design article placed first in the tutorial flow
- a method comparison article positioning `uccdf` against existing consensus clustering toolkits
- a multi-dataset article collection built on real data
- dataset analyses for `airquality`, `CO2`, `Indometh`, `InsectSprays`, `survey`, `Cars93`, `iris`, `mtcars`, `ChickWeight`, `attitude`, `USJudgeRatings`, `golub`, `ALL`, `bladderEset`, and `PimaIndiansDiabetes2`

Version `0.1.0` is intentionally conservative. It focuses on structured tabular
data with four core column types:

- `continuous`
- `binary`
- `nominal`
- `ordinal`

## Installation

Install from GitHub:

```r
install.packages("pak")
pak::pak("dai540/uccdf")
```

Or:

```r
install.packages("remotes")
remotes::install_github("dai540/uccdf")
```

Or install from a source tarball:

```r
install.packages("path/to/uccdf_0.1.0.tar.gz", repos = NULL, type = "source")
```

Then load the package:

```r
library(uccdf)
```

## Fastest way to use it

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

## What changed in the selection logic

`uccdf` now separates two decisions:

1. is there evidence for clustering at all?
2. if yes, which `K` is the best supported solution?

This fixes the earlier failure mode where examples could collapse to `K = 1`
simply because `n_null` was too small to support meaningful Monte Carlo
p-values.

When the global null is not rejected:

- `cluster` remains 1
- `confidence` and `ambiguity` are `NA`
- `exploratory_cluster` exposes the strongest unsupported multi-cluster split

That keeps the reported result honest without hiding structure from the analyst.

## Core workflow

`uccdf` uses a four-layer design:

1. `Schema layer`
2. `Representation layer`
3. `Ensemble layer`
4. `Calibration layer`

In practice, the package is doing this:

- `validate_input()` checks identifier integrity and structural assumptions
- `infer_schema()` marks columns as `id`, `active`, or `exclude`
- `build_views()` creates:
  - a Gower-like mixed-distance matrix
  - a low-dimensional mixed-latent embedding
- `fit_uccdf()` runs multiple clustering jobs and builds consensus matrices
- `select_k()` returns the stability and null-calibrated ranking table
- `augment()` returns row-level selected and exploratory assignments
- `report()` writes a compact markdown or html summary
- `plot_embedding()` shows low-dimensional separation
- `plot_consensus_heatmap()` shows hierarchical agreement structure

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

## What the package returns

The main output is a fitted `uccdf_fit` object with:

- inferred schema
- run-level metadata
- consensus matrices by candidate `K`
- a null-score table
- the selected `K`
- row-level selected assignments
- row-level exploratory assignments

`confidence` is interpreted as a consensus-derived assignment stability score,
not as a Bayesian posterior probability.

## Example data

`toy_mixed_data` is bundled for examples, tests, and vignettes. It includes:

- two continuous columns
- one binary column
- one ordered factor
- one nominal factor

Additional bundled real-data example tables include:

- `all_gene_panel`, a compact leukemia expression panel derived from the Bioconductor `ALL` dataset
- `airway_gene_panel`, a compact RNA-seq derived panel from the Bioconductor `airway` dataset
- `bladder_gene_panel`, a compact bladder cancer expression panel derived from the Bioconductor `bladderbatch` dataset
- `golub_gene_panel`, an omics expression panel derived from `multtest::golub`
- `pima_biomarker_panel`, a clinical biomarker table derived from `mlbench::PimaIndiansDiabetes2`

## Website structure

The pkgdown site is organized around:

- `Get Started`
  - package overview
  - first clustering run
- `Articles`
  - method and design notes
  - real dataset analyses with dataset-specific background, objective, results, discussion, and interpretation
- `Reference`
  - main API
  - plotting and reporting helpers

## Current scope limits

Version `0.1.0` is intentionally narrow.

- It does not directly support text, image, or graph data.
- It does not treat `datetime` as a first-class typed feature.
- It does not yet ship advanced null generators such as copula-based nulls.
- It does not yet include `k-prototypes` or `KAMILA` in the default workflow.

The goal of the first release is a stable and readable foundation for typed
consensus clustering on structured tables.
