.libPaths(c("C:/Users/daiki/Desktop/codex/.uccdf-rlib", .libPaths()))

make_airway_gene_panel <- function() {
  suppressPackageStartupMessages({
    library(airway)
    library(SummarizedExperiment)
  })

  data(airway, package = "airway")
  mat <- log2(assay(airway) + 1)
  vars <- apply(mat, 1, var)
  top <- names(sort(vars, decreasing = TRUE))[1:6]
  pd <- as.data.frame(colData(airway))

  data.frame(
    sample_id = rownames(pd),
    as.data.frame(t(mat[top, , drop = FALSE])),
    dex = pd$dex,
    cell = pd$cell,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

make_all_gene_panel <- function() {
  suppressPackageStartupMessages({
    library(ALL)
    library(Biobase)
  })

  data(ALL, package = "ALL")
  mat <- exprs(ALL)
  vars <- apply(mat, 1, var)
  top <- names(sort(vars, decreasing = TRUE))[1:8]
  pd <- pData(ALL)

  panel <- data.frame(
    sample_id = sampleNames(ALL),
    as.data.frame(t(mat[top, , drop = FALSE])),
    bt = pd$BT,
    mol_biol = pd$mol.biol,
    sex = pd$sex,
    age = pd$age,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  panel$age_band <- cut(
    panel$age,
    breaks = c(-Inf, 20, 40, 60, Inf),
    labels = c("<=20", "21-40", "41-60", "61+"),
    ordered_result = TRUE
  )
  panel
}

make_bladder_gene_panel <- function() {
  suppressPackageStartupMessages({
    library(bladderbatch)
    library(Biobase)
  })

  data(bladderdata, package = "bladderbatch")
  mat <- exprs(bladderEset)
  vars <- apply(mat, 1, var)
  top <- names(sort(vars, decreasing = TRUE))[1:8]
  pd <- pData(bladderEset)

  data.frame(
    sample_id = rownames(pd),
    as.data.frame(t(mat[top, , drop = FALSE])),
    outcome = pd$outcome,
    batch = factor(pd$batch, ordered = TRUE),
    cancer = pd$cancer,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

dir.create("data", showWarnings = FALSE)

airway_gene_panel <- make_airway_gene_panel()
all_gene_panel <- make_all_gene_panel()
bladder_gene_panel <- make_bladder_gene_panel()

save(airway_gene_panel, file = "data/airway_gene_panel.rda", compress = "bzip2")
save(all_gene_panel, file = "data/all_gene_panel.rda", compress = "bzip2")
save(bladder_gene_panel, file = "data/bladder_gene_panel.rda", compress = "bzip2")
