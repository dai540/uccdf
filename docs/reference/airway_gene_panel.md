# RNA-seq Derived Gene Panel from `airway`

A compact mixed-type table derived from the Bioconductor `airway`
RNA-seq dataset. The table stores log-scale expression values for a
small set of highly variable genes together with dexamethasone treatment
and cell-line metadata.

## Usage

``` r
airway_gene_panel
```

## Format

A data frame with 8 rows and 9 variables:

- sample_id:

  Sample identifier.

- RPS4Y1:

  Log-scale expression value.

- XIST:

  Log-scale expression value.

- USP9Y:

  Log-scale expression value.

- DDX3Y:

  Log-scale expression value.

- TXLNG2P:

  Log-scale expression value.

- KDM5D:

  Log-scale expression value.

- dex:

  Treatment status.

- cell:

  Cell-line identifier.

## Source

Derived from the Bioconductor experiment package `airway`.
