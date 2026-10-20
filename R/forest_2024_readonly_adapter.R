# Read-only input adapter; NO corrections, NO BNC85 selection.
# Supports a CSV exported privately from the definitive workbook.
# Input schema is configurable because the definitive workbook is not yet available.
forest2024_readonly_adapter <- function(data, mapping, frame,
                                       expected_rows=NULL) {
  required <- c("stratum","forest_fraction")
  if (!is.data.frame(data) || !is.list(mapping) ||
      !all(required %in% names(mapping))) stop("Provide a data frame and explicit mapping")
  fields <- unlist(mapping[required],use.names=FALSE)
  if (length(fields)!=2L || anyNA(fields) || any(!fields %in% names(data)))
    stop("Mapped columns are missing")
  if (identical(fields[1],fields[2])) stop("Mapping reuses column")
  if (!is.null(expected_rows) && nrow(data)!=expected_rows)
    stop("Unexpected row count: input may be incomplete")
  if (anyNA(data[[fields[1]]])) stop("Missing stratum values")
  if (!is.numeric(data[[fields[2]]]))
    stop("Forest fraction must be numeric; confirm units and conversions upstream")
  y <- data[[fields[2]]]
  if (any(!is.na(y) & (!is.finite(y) | y<0 | y>1)))
    stop("Forest fractions must be 0..1; inspect original units")
  out <- data.frame(stratum=as.character(data[[fields[1]]]),
                    forest_fraction=y)
  if (!is.data.frame(frame) || !all(c("stratum","Nh") %in% names(frame)) ||
      anyDuplicated(as.character(frame$stratum)))
    stop("Invalid authoritative population frame")
  if (!setequal(out$stratum,as.character(frame$stratum)))
    stop("Input strata and frame differ")
  status <- data.frame(stratum=as.character(frame$stratum),
    n_records=integer(nrow(frame)),n_valid=integer(nrow(frame)),
    n_missing=integer(nrow(frame)),stringsAsFactors=FALSE)
  for(i in seq_len(nrow(frame))) {
    z <- out$forest_fraction[out$stratum==status$stratum[i]]
    status$n_records[i] <- length(z)
    status$n_valid[i] <- sum(!is.na(z))
    status$n_missing[i] <- sum(is.na(z))
  }
  list(observations=out,integrity=status,
       full_n=nrow(out),valid_n=sum(!is.na(out$forest_fraction)),
       missing_n=sum(is.na(out$forest_fraction)))
}

# Optional candidate estimator with explicit missing policy.
# NEVER assumes that complete-case treatment is the official method.
forest2024_candidate_complete_case <- function(adapter,frame) {
  if (!is.list(adapter) || is.null(adapter$observations))
    stop("Invalid adapter output")
  obs <- adapter$observations
  obs <- obs[!is.na(obs$forest_fraction),,drop=FALSE]
  if (!exists("forest2024_from_samples",mode="function"))
    stop("Source R/forest_2024_reconstructed.R first")
  forest2024_from_samples(obs,frame)
}
