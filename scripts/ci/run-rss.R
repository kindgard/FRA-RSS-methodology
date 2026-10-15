#!/usr/bin/env Rscript
# FRA RSS execution wrapper. No institutional data or methodology bundled.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L) {
  stop("Usage: Rscript scripts/ci/run-rss.R <input.xlsx> <original.Rmd> <output-dir>")
}
input <- normalizePath(args[[1]], mustWork = TRUE)
source <- normalizePath(args[[2]], mustWork = TRUE)
output <- normalizePath(args[[3]], mustWork = FALSE)
dir.create(output, recursive = TRUE, showWarnings = FALSE)
stopifnot(grepl("\\.xlsx$", input, ignore.case=TRUE), grepl("\\.Rmd$", source, ignore.case=TRUE))
if (!requireNamespace("readxl", quietly=TRUE) || !requireNamespace("rmarkdown", quietly=TRUE)) {
  stop("Required R packages missing")
}
sheets <- readxl::excel_sheets(input)
if (!"RawData" %in% sheets) stop("Required sheet RawData not found")
if (!any(tolower(sheets) == "weights")) stop("Required sheet weights not found")
cat("Input file:", basename(input), "\n")
cat("File bytes:", file.info(input)$size, "\n")
cat("Sheets:", paste(sheets, collapse=", "), "\n")
# Isolate the Rmd and the input in expected relative paths. Do not change original Rmd content.
work <- tempfile("rss-run-")
dir.create(work)
dir.create(file.path(work,"Inputs"))
dir.create(file.path(work,"Outputs"))
file.copy(input, file.path(work, "Inputs", basename(input)))
rmd <- file.path(work, basename(source))
file.copy(source, rmd)
# Intentionally prohibit accidental execution with a mismatched file name:
# exact input path can be embedded in Oliver's original script.
source_lines <- readLines(rmd, warn=FALSE)
literal <- paste0('Inputs/', basename(input))
if (!any(grepl(literal, source_lines, fixed=TRUE))) {
  stop("Original Rmd does not reference supplied input filename. Review paths manually; no automatic edits.")
}
# Some existing original outputs have fixed paths; capture a copy after execution.
rmarkdown::render(input=rmd, output_file="FRA_RSS_render.html",
                  output_dir=file.path(work,"Outputs"), knit_root_dir=work,
                  envir=new.env(parent=globalenv()), quiet=FALSE)
generated <- list.files(file.path(work,"Outputs"), full.names=TRUE, recursive=TRUE)
if (!any(grepl("\\.xlsx$",generated, ignore.case=TRUE))) stop("Render completed without an Excel output")
file.copy(generated, output, overwrite=FALSE)
cat("PASS: Render completed. Outputs:", length(generated), "\n")
