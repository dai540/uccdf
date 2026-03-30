docs_dir <- "docs"
logo_path <- file.path("man", "figures", "logo.svg")
favicon_svg_path <- file.path(docs_dir, "favicon.svg")

if (!dir.exists(docs_dir)) {
  stop("docs directory not found.", call. = FALSE)
}

file.copy(logo_path, favicon_svg_path, overwrite = TRUE)
file.copy(logo_path, file.path(docs_dir, "logo.svg"), overwrite = TRUE)
if (dir.exists(file.path(docs_dir, "reference", "figures"))) {
  file.copy(logo_path, file.path(docs_dir, "reference", "figures", "logo.svg"), overwrite = TRUE)
}

html_files <- list.files(docs_dir, pattern = "\\.html$", recursive = TRUE, full.names = TRUE)

rewrite_html <- function(path) {
  rel_prefix <- if (grepl("[/\\\\](articles|reference)[/\\\\]", path)) "../" else ""
  txt <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  txt <- gsub(
    "<!-- favicons -->.*?<meta property=\"og:image\"",
    sprintf("<!-- favicons --><link rel=\"icon\" type=\"image/svg+xml\" href=\"%sfavicon.svg\"><meta property=\"og:image\"", rel_prefix),
    txt
  )
  writeLines(txt, path, useBytes = TRUE)
}

invisible(lapply(html_files, rewrite_html))

for (path in c(
  file.path(docs_dir, "apple-touch-icon.png"),
  file.path(docs_dir, "favicon-96x96.png"),
  file.path(docs_dir, "favicon.ico"),
  file.path(docs_dir, "web-app-manifest-192x192.png"),
  file.path(docs_dir, "web-app-manifest-512x512.png")
)) {
  if (file.exists(path)) {
    unlink(path)
  }
}

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
  file.path(docs_dir, "site.webmanifest"),
  useBytes = TRUE
)
