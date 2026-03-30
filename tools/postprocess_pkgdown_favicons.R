docs_dir <- "docs"
logo_path <- file.path("man", "figures", "logo.svg")
favicon_svg_path <- file.path(docs_dir, "favicon.svg")

if (!dir.exists(docs_dir)) {
  stop("docs directory not found.", call. = FALSE)
}

file.copy(logo_path, favicon_svg_path, overwrite = TRUE)

html_files <- list.files(docs_dir, pattern = "\\.html$", recursive = TRUE, full.names = TRUE)

rewrite_html <- function(path) {
  txt <- readLines(path, warn = FALSE, encoding = "UTF-8")
  txt <- gsub(
    "<!-- favicons -->.*?<link rel=\"manifest\" href=\"site\\.webmanifest\">",
    "<!-- favicons --><link rel=\"icon\" type=\"image/svg+xml\" href=\"favicon.svg\">",
    txt
  )
  txt <- gsub(
    "<!-- favicons -->.*?<link rel=\"manifest\" href=\"\\.\\./site\\.webmanifest\">",
    "<!-- favicons --><link rel=\"icon\" type=\"image/svg+xml\" href=\"../favicon.svg\">",
    txt
  )
  writeLines(txt, path, useBytes = TRUE)
}

invisible(lapply(html_files, rewrite_html))

manifest_path <- file.path(docs_dir, "site.webmanifest")
writeLines(
  c(
    "{",
    "  \"name\": \"uccdf\",",
    "  \"short_name\": \"uccdf\",",
    "  \"icons\": [],",
    "  \"theme_color\": \"#ffffff\",",
    "  \"background_color\": \"#ffffff\",",
    "  \"display\": \"standalone\"",
    "}"
  ),
  manifest_path,
  useBytes = TRUE
)
