# Microarray-Derived Gene Panel from `golub`

A compact omics table derived from
[`multtest::golub`](https://rdrr.io/pkg/multtest/man/golub.html), a
leukemia expression dataset. The table stores expression values for a
small set of high-variance genes together with lineage annotations for
interpretation.

## Usage

``` r
golub_gene_panel
```

## Format

A data frame with 38 rows and 11 variables:

- sample_id:

  Sample identifier.

- TCL1:

  Expression value.

- TCRB_1:

  Expression value.

- CTRL_M:

  Expression value.

- CTRL_5:

  Expression value.

- IL8:

  Expression value.

- TCRB_2:

  Expression value.

- MAL:

  Expression value.

- CTRL_3:

  Expression value.

- lineage:

  Observed leukemia lineage.

- lineage_band:

  Ordinal lineage label for interpretation.

## Source

Derived from
[`multtest::golub`](https://rdrr.io/pkg/multtest/man/golub.html).
