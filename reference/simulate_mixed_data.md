# Simulate a Mixed-Type Clustering Table

Generates a small mixed-type table with known cluster structure.

## Usage

``` r
simulate_mixed_data(n = 120, k = 3, seed = 123)
```

## Arguments

- n:

  Number of rows.

- k:

  Number of latent groups.

- seed:

  Random seed.

## Value

A data frame with a sample identifier and mixed columns.

## Examples

``` r
dat <- simulate_mixed_data(n = 12, k = 2, seed = 1)
dat
#>    sample_id      age     score smoker stage subtype
#> 1       S001 54.69162 1.5157309     no     I       B
#> 2       S002 59.87891 2.8432842     no    II       D
#> 3       S003 49.47306 1.6474954     no     I       C
#> 4       S004 58.55891 1.1521955     no     I       B
#> 5       S005 58.94922 0.8074538     no    II       C
#> 6       S006 47.89380 1.5338780     no     I       C
#> 7       S007 39.92650 1.0607099    yes     I       C
#> 8       S008 62.62465 2.0909431     no    II       D
#> 9       S009 56.77533 1.1704733     no    II       C
#> 10      S010 50.91905 0.7652950     no     I       B
#> 11      S011 61.71918 2.4925591     no    II       C
#> 12      S012 61.10611 3.1510757     no    II       D
```
