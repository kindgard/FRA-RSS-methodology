# Public generic audit engine: never store institutional inputs in this repo.
# source("R/forest_2024_reconstructed.R") before invoking.
forest2024_audit <- function(strata, reference, tolerance=1e-10) {
  if (!is.data.frame(strata) || !is.list(reference) ||
      !is.numeric(tolerance) || length(tolerance)!=1 ||
      !is.finite(tolerance) || tolerance <= 0) stop("Invalid audit arguments")
  required <- c("stratum","Nh","nh","mean","s2")
  if (!all(required %in% names(strata))) stop("Missing stratum statistics")
  calc <- forest2024_from_strata(strata)
  validations <- data.frame(check=character(),pass=logical(),difference=numeric(),
                            tolerance=numeric(),stringsAsFactors=FALSE)
  check <- function(name,observed,expected) {
    if (!is.numeric(expected) || length(expected)!=1 || !is.finite(expected))
      stop(paste("Bad reference:",name))
    delta <- abs(observed-expected)
    validations <<- rbind(validations,data.frame(check=name,pass=delta <= tolerance,
                       difference=delta,tolerance=tolerance))
  }
  for (field in c("proportion","variance","se","population_n","sample_n")) {
    if (!is.null(reference[[field]])) check(field,calc[[field]],reference[[field]])
  }
  for (field in c("estimate_contribution","variance_contribution")) {
    reference_field <- paste0(field,"_by_stratum")
    if (!is.null(reference[[reference_field]])) {
      target <- reference[[reference_field]]
      if (is.null(names(target)) || anyDuplicated(names(target)) ||
          !setequal(names(target),as.character(calc$by_stratum$stratum)))
        stop(paste("Invalid reference stratum keys:",field))
      keys <- as.character(calc$by_stratum$stratum)
      for (i in seq_along(keys))
        check(paste(field,keys[i],sep=":"),calc$by_stratum[[field]][i],
              unname(target[keys[i]]))
    }
  }
  if (nrow(validations)==0) stop("No reference checks specified")
  list(status=if (all(validations$pass)) "PASS" else "FAIL",
       checks=validations,calculated=calc)
}
