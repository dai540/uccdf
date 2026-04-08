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
  favicon_line <- sprintf("<!-- favicons --><link rel=\"icon\" type=\"image/svg+xml\" href=\"%sfavicon.svg\">", rel_prefix)
  txt <- paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  if (grepl("<!-- favicons -->", txt, fixed = TRUE) && grepl("<script", txt, fixed = TRUE)) {
    txt <- sub(
      "(?s)<!-- favicons -->.*?<script",
      paste0(favicon_line, "\n<script"),
      txt,
      perl = TRUE
    )
  } else {
    lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
    title_idx <- grep("</title>", lines, fixed = TRUE)
    if (length(title_idx)) {
      lines <- append(lines, favicon_line, after = title_idx[1])
    } else {
      head_idx <- grep("<head>", lines, fixed = TRUE)
      insert_after <- if (length(head_idx)) head_idx[1] else 1L
      lines <- append(lines, favicon_line, after = insert_after)
    }
    txt <- paste(lines, collapse = "\n")
  }

  txt <- gsub(
    "<link rel=\"icon\" type=\"[^\"]*\" href=\"[^\"]*\">\\s*<link rel=\"icon\" type=\"[^\"]*\" href=\"[^\"]*\">",
    favicon_line,
    txt,
    perl = TRUE
  )

  writeLines(txt, path, useBytes = TRUE)
}

invisible(lapply(html_files, rewrite_html))

for (path in c(
  file.path(docs_dir, "apple-touch-icon.png"),
  file.path(docs_dir, "favicon-96x96.png"),
  file.path(docs_dir, "favicon.ico"),
  file.path(docs_dir, "site.webmanifest"),
  file.path(docs_dir, "web-app-manifest-192x192.png"),
  file.path(docs_dir, "web-app-manifest-512x512.png")
)) {
  if (file.exists(path)) {
    unlink(path)
  }
}

md_files <- list.files(docs_dir, pattern = "\\.md$", recursive = TRUE, full.names = TRUE)
if (length(md_files)) {
  unlink(md_files)
}

tutorials_dir <- file.path(docs_dir, "tutorials")
if (dir.exists(tutorials_dir)) {
  unlink(tutorials_dir, recursive = TRUE)
}
