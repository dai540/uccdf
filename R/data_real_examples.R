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
#'   \item{ENSG00000129824}{Log-scale expression value.}
#'   \item{ENSG00000229807}{Log-scale expression value.}
#'   \item{ENSG00000114374}{Log-scale expression value.}
#'   \item{ENSG00000067048}{Log-scale expression value.}
#'   \item{ENSG00000131002}{Log-scale expression value.}
#'   \item{ENSG00000012817}{Log-scale expression value.}
#'   \item{dex}{Treatment status.}
#'   \item{cell}{Cell-line identifier.}
#' }
#' @source Derived from the Bioconductor experiment package `airway`.
"airway_gene_panel"

#' Microarray-Derived Gene Panel from `ALL`
#'
#' A compact omics table derived from the Bioconductor `ALL` experiment
#' package. The panel keeps a small set of highly variable probe sets together
#' with immunophenotype, molecular subtype, sex, and age variables for post hoc
#' interpretation.
#'
#' @format A data frame with 128 rows and 13 variables:
#' \describe{
#'   \item{sample_id}{Sample identifier.}
#'   \item{38355_at}{Expression value.}
#'   \item{36638_at}{Expression value.}
#'   \item{38514_at}{Expression value.}
#'   \item{41214_at}{Expression value.}
#'   \item{36108_at}{Expression value.}
#'   \item{39318_at}{Expression value.}
#'   \item{38096_f_at}{Expression value.}
#'   \item{38319_at}{Expression value.}
#'   \item{bt}{Observed ALL immunophenotype.}
#'   \item{mol_biol}{Observed molecular subtype annotation.}
#'   \item{sex}{Observed sex.}
#'   \item{age}{Observed age.}
#'   \item{age_band}{Ordinal age band for interpretation.}
#' }
#' @source Derived from the Bioconductor experiment package `ALL`.
"all_gene_panel"

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

#' Microarray-Derived Gene Panel from `bladderEset`
#'
#' A compact omics table derived from `bladderbatch::bladderEset`, a bladder
#' cancer expression dataset illustrating biological heterogeneity and batch
#' effects. The panel stores a small set of high-variance probe sets together
#' with pathology and batch annotations for interpretation.
#'
#' @format A data frame with 57 rows and 12 variables:
#' \describe{
#'   \item{sample_id}{Sample identifier.}
#'   \item{202917_s_at}{Expression value.}
#'   \item{217022_s_at}{Expression value.}
#'   \item{207935_s_at}{Expression value.}
#'   \item{211430_s_at}{Expression value.}
#'   \item{202409_at}{Expression value.}
#'   \item{205916_at}{Expression value.}
#'   \item{214677_x_at}{Expression value.}
#'   \item{212768_s_at}{Expression value.}
#'   \item{outcome}{Observed pathology annotation.}
#'   \item{batch}{Observed processing batch.}
#'   \item{cancer}{Observed coarse cancer status.}
#' }
#' @source Derived from the Bioconductor experiment package `bladderbatch`.
"bladder_gene_panel"

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
