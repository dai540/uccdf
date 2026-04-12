# Method Overview

## Workflow

`uccdf` follows four steps:

1.  validate the input table
2.  infer a simple schema
3.  build a distance view and a latent view
4.  aggregate repeated clustering results across candidate `K`

## Design limits

The package is intentionally minimal.

- no large bundled data
- no external data downloads in package examples
- no advanced model backends

## Intended use

The package is appropriate for lightweight exploratory clustering in an
R package setting where repository size matters.
