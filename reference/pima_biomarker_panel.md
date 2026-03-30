# Clinical Biomarker Panel from `PimaIndiansDiabetes2`

A compact mixed-type table derived from
[`mlbench::PimaIndiansDiabetes2`](https://rdrr.io/pkg/mlbench/man/PimaIndiansDiabetes.html).
The table combines numeric biomarker measurements with an ordinal age
band and the observed diabetes status for post hoc interpretation.

## Usage

``` r
pima_biomarker_panel
```

## Format

A data frame with 392 rows and 10 variables:

- sample_id:

  Sample identifier.

- glucose:

  Plasma glucose concentration.

- pressure:

  Diastolic blood pressure.

- triceps:

  Triceps skin fold thickness.

- insulin:

  Two-hour serum insulin.

- mass:

  Body mass index.

- pedigree:

  Diabetes pedigree function.

- age:

  Age in years.

- age_band:

  Ordinal age band.

- diabetes:

  Observed diabetes status.

## Source

Derived from
[`mlbench::PimaIndiansDiabetes2`](https://rdrr.io/pkg/mlbench/man/PimaIndiansDiabetes.html).
