# Comparison with Existing Consensus Clustering Methods

## Background

Consensus clustering is not one method but a family of related
strategies. Some packages focus on representing and combining
partitions, some focus on repeated resampling across algorithms, and
some focus on calibrating the existence of structure against a null
baseline. `uccdf` was built because, in practice, analysts often need
all of those pieces at once on a mixed-type dataframe.

## Objective

The goal of this article is to position `uccdf` relative to several
widely used consensus clustering toolkits:

- `clue`
- `diceR`
- `M3C`
- `sharp`

The comparison is intentionally practical. The question is not which
package is “best” in the abstract, but which problem each package is
actually designed to solve.

## High-level comparison

The most important distinction is the unit of design.

- `clue` is a general cluster ensemble framework. It provides the data
  structures, agreement measures, and consensus operations needed to
  work with sets of partitions and hierarchies.
- `diceR` is an end-to-end consensus clustering workflow for generating
  diverse clustering solutions across algorithms, resamples, and cluster
  sizes.
- `M3C` is aimed at null-calibrated consensus clustering, especially in
  genomics-style matrix settings where overestimation of `K` is a known
  risk.
- `sharp` emphasizes automated calibration and stability-based consensus
  clustering under a weighted distance framework.
- `uccdf` is designed as a typed dataframe workflow that combines schema
  inference, multiple representations, ensemble clustering, and
  null-calibrated selection in one package.

## Comparison table

| Package | Main design target | Input style | Mixed-type dataframe awareness | Null calibration | Typical strength |
|:---|:---|:---|:---|:---|:---|
| `clue` | Cluster ensemble data structures and consensus operations | Partitions, hierarchies, ensemble objects | No built-in typed schema layer | No built-in global null test | Extremely flexible ensemble tooling |
| `diceR` | Diverse ensemble generation across algorithms and resamples | Mostly matrix-like tabular input | Limited, depends on user preprocessing | Not the main focus | Strong multi-algorithm consensus workflow |
| `M3C` | Monte Carlo reference-based consensus clustering | Continuous expression-like matrices | Not built for general mixed-type tables | Yes, central feature | Guards against false positive cluster discovery |
| `sharp` | Stability and calibration of weighted consensus clustering | Distance-based or weighted clustering workflows | Not a general dataframe typing system | Yes, through calibrated stability procedures | Hyper-parameter and weighting calibration |
| `uccdf` | Typed consensus clustering for structured dataframes | `data.frame` with mixed columns | Yes, explicit schema and role inference | Yes, two-stage detection and `K` selection | Unified workflow for mixed-type tables |

## Where the methods overlap

There is real overlap between these tools, especially once a user
manually preprocesses a table into a numeric matrix.

`uccdf` overlaps with:

- `clue` on the idea of aggregating multiple clustering results into a
  consensus object
- `diceR` on the idea of algorithm diversity, repeated resampling, and
  consensus-by-`K`
- `M3C` on the idea that a consensus score alone is not enough and
  should be compared with a null baseline
- `sharp` on the idea that stability and calibration matter as much as
  the raw clustering output

So the difference is not that `uccdf` invents consensus clustering from
scratch. The difference is that it packages several of these ideas into
a dataframe-first workflow.

## Where `uccdf` is intentionally different

`uccdf` makes four choices that separate it from the existing packages
above.

### 1. Typed schema is part of the workflow

`uccdf` starts from a structured dataframe and explicitly infers:

- which columns are active
- which are identifiers
- which should be excluded
- which are continuous, binary, nominal, or ordinal

That step is not the main concern of `clue`, `diceR`, `M3C`, or `sharp`,
but it is a recurring practical problem in mixed-table analysis.

### 2. Multiple views are first-class

Instead of committing to one representation, `uccdf` combines:

- a mixed-distance view
- a mixed-latent view

This matters because mixed tables often admit more than one defensible
geometry. Some existing methods can be made to use multiple
representations, but that is usually the analyst’s responsibility rather
than the package’s core contract.

### 3. Detection and selection are separated

`uccdf` distinguishes between:

1.  is there evidence for structure at all?
2.  if yes, which `K` is best supported?

This is closest in spirit to `M3C`, which also treats null calibration
as a central concern. The main practical advantage is that `uccdf` can
report a conservative `K = 1` while still exposing an exploratory split
for inspection.

### 4. Output is designed for downstream tabular analysis

The main row-level output of `uccdf` is not just a partition. It is a
dataframe augmentation containing:

- selected cluster
- confidence
- ambiguity
- exploratory cluster when the global null is not rejected

This makes the package easier to drop into reporting pipelines built
around tables rather than only around partition objects.

## When to use each package

### Use `clue` when

- you already have several partitions or hierarchies
- you want a mature ensemble object system
- you care about partition comparison, matching, and consensus
  operations more than about preprocessing or null calibration

### Use `diceR` when

- you want a broad consensus workflow across many algorithms
- you are comfortable preparing the input matrix yourself
- you want diversity of cluster solutions to be the central driver

### Use `M3C` when

- false positive structure detection is your main concern
- your data are naturally represented as a continuous matrix
- you specifically want Monte Carlo reference-based calibration of
  consensus clustering

### Use `sharp` when

- weighted distance design and calibration are central to the problem
- you want automated stability-based tuning of consensus clustering
  settings

### Use `uccdf` when

- your starting point is a mixed-type dataframe
- you want schema handling, multiple representations, consensus, and
  null-aware selection in one package
- you need row-level confidence and ambiguity outputs for downstream
  tabular reporting

## Practical conclusion

`uccdf` should be read as a package that sits between classic ensemble
tooling and null-calibrated stability methods.

It is not trying to replace:

- the general ensemble machinery of `clue`
- the algorithm-diversity workflow of `diceR`
- the matrix-focused null calibration of `M3C`
- the calibration strategy of `sharp`

Instead, it tries to unify the parts of those ideas that are most useful
when an analyst starts from a real mixed-type dataframe rather than from
a clean expression matrix or a precomputed ensemble object.

## References

- `clue`: [CRAN package page](https://CRAN.R-project.org/package=clue)
  and [JSS article](https://www.jstatsoft.org/v14/i12/)
- `diceR`: [CRAN package page](https://CRAN.R-project.org/package=diceR)
- `M3C`: [Scientific Reports
  article](https://www.nature.com/articles/s41598-020-58766-1)
- `sharp`: [CRAN package page](https://CRAN.R-project.org/package=sharp)
