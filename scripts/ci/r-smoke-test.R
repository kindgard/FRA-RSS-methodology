# Environment test only. No FAO raw data are transferred or processed.
required <- c("tidyverse", "magrittr", "openxlsx", "readxl", "rmarkdown", "knitr")
for (pkg in required) {
  stopifnot(requireNamespace(pkg, quietly = TRUE))
  cat("OK: ", pkg, " ", as.character(utils::packageVersion(pkg)), "\n", sep = "")
}
cat("R version: ", R.version.string, "\n", sep = "")
# Minimal check that tidyverse and Excel creation work.
x <- tibble::tibble(group = c("A", "A", "B"), value = c(1, 2, 3))
out <- dplyr::summarise(dplyr::group_by(x, group), total = sum(value), .groups = "drop")
stopifnot(identical(as.numeric(out$total), c(3, 3)))
f <- tempfile(fileext = ".xlsx")
openxlsx::write.xlsx(out, f)
read_back <- readxl::read_excel(f)
stopifnot(identical(as.numeric(read_back$total), c(3, 3)))
cat("PASS: dependency and synthetic Excel smoke test\n")
