#' RNA-seq Derived Gene Panel from `airway`
#'
#' A compact mixed-type table derived from the Bioconductor `airway` RNA-seq
#' dataset. The table stores log-scale expression values for a small set of
#' highly variable genes together with dexamethasone treatment and cell-line
#' metadata.
#'
#' @format A data frame with 8 rows and 9 variables:
#' \describe{
#'   \item{sample_id}{Sample identifier.}
#'   \item{RPS4Y1}{Log-scale expression value.}
#'   \item{XIST}{Log-scale expression value.}
#'   \item{USP9Y}{Log-scale expression value.}
#'   \item{DDX3Y}{Log-scale expression value.}
#'   \item{TXLNG2P}{Log-scale expression value.}
#'   \item{KDM5D}{Log-scale expression value.}
#'   \item{dex}{Treatment status.}
#'   \item{cell}{Cell-line identifier.}
#' }
#' @source Derived from the Bioconductor experiment package `airway`.
"airway_gene_panel"

#' Microarray-Derived Gene Panel from `golub`
#'
#' A compact omics table derived from `multtest::golub`, a leukemia expression
#' dataset. The table stores expression values for a small set of high-variance
#' genes together with lineage annotations for interpretation.
#'
#' @format A data frame with 38 rows and 11 variables:
#' \describe{
#'   \item{sample_id}{Sample identifier.}
#'   \item{TCL1}{Expression value.}
#'   \item{TCRB_1}{Expression value.}
#'   \item{CTRL_M}{Expression value.}
#'   \item{CTRL_5}{Expression value.}
#'   \item{IL8}{Expression value.}
#'   \item{TCRB_2}{Expression value.}
#'   \item{MAL}{Expression value.}
#'   \item{CTRL_3}{Expression value.}
#'   \item{lineage}{Observed leukemia lineage.}
#'   \item{lineage_band}{Ordinal lineage label for interpretation.}
#' }
#' @source Derived from `multtest::golub`.
"golub_gene_panel"

#' Clinical Biomarker Panel from `PimaIndiansDiabetes2`
#'
#' A compact mixed-type table derived from `mlbench::PimaIndiansDiabetes2`.
#' The table combines numeric biomarker measurements with an ordinal age band
#' and the observed diabetes status for post hoc interpretation.
#'
#' @format A data frame with 392 rows and 10 variables:
#' \describe{
#'   \item{sample_id}{Sample identifier.}
#'   \item{glucose}{Plasma glucose concentration.}
#'   \item{pressure}{Diastolic blood pressure.}
#'   \item{triceps}{Triceps skin fold thickness.}
#'   \item{insulin}{Two-hour serum insulin.}
#'   \item{mass}{Body mass index.}
#'   \item{pedigree}{Diabetes pedigree function.}
#'   \item{age}{Age in years.}
#'   \item{age_band}{Ordinal age band.}
#'   \item{diabetes}{Observed diabetes status.}
#' }
#' @source Derived from `mlbench::PimaIndiansDiabetes2`.
"pima_biomarker_panel"
