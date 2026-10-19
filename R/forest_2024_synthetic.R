# Prototype only. NOT an approved FRA RSS estimator.
# Stratified SRS with independent observations and optional finite population correction.
# Required columns: stratum, forest_2024 (0/1); stratum frame: stratum, area_ha.
forest_2024_estimate <- function(samples, frame) {
  required_samples <- c("stratum", "forest_2024")
  required_frame <- c("stratum", "area_ha")
  stopifnot(is.data.frame(samples), is.data.frame(frame))
  if (!all(required_samples %in% names(samples)) ||
      !all(required_frame %in% names(frame))) stop("Required columns missing")
  if (anyNA(samples[, required_samples]) || anyNA(frame[, required_frame]))
    stop("Missing stratum, forest class, or area")
  if (anyDuplicated(frame$stratum)) stop("Duplicate frame strata")
  if (any(!samples$forest_2024 %in% c(0, 1)))
    stop("forest_2024 must contain only 0 or 1")
  if (!is.numeric(frame$area_ha) || any(!is.finite(frame$area_ha)) ||
      any(frame$area_ha <= 0)) stop("Invalid stratum area")
  if (!setequal(as.character(samples$stratum), as.character(frame$stratum)))
    stop("Sample and frame strata differ")
  if ("population_n" %in% names(frame)) {
    if (!is.numeric(frame$population_n) || anyNA(frame$population_n) ||
        any(!is.finite(frame$population_n)) ||
        any(frame$population_n < 2) ||
        any(frame$population_n != floor(frame$population_n)))
      stop("Invalid population_n")
  }
  details <- lapply(seq_len(nrow(frame)), function(i) {
    key <- as.character(frame$stratum[i])
    y <- samples$forest_2024[as.character(samples$stratum) == key]
    n <- length(y)
    if (n < 2) stop(paste("Need >= 2 samples per stratum:", key))
    A <- frame$area_ha[i]
    f <- if ("population_n" %in% names(frame)) n / frame$population_n[i] else 0
    if (f > 1) stop(paste("Sample larger than population:", key))
    p <- mean(y)
    variance <- A^2 * (1 - f) * stats::var(y) / n
    data.frame(stratum=key, n=n, area_ha=A, forest_prop=p,
               forest_area_ha=A*p, variance_ha2=variance, fpc=1-f)
  })
  by_stratum <- do.call(rbind, details)
  estimate <- sum(by_stratum$forest_area_ha)
  variance <- sum(by_stratum$variance_ha2)
  se <- sqrt(variance)
  z <- stats::qnorm(0.975)
  list(
    method="PROTOTYPE: stratified SRS; independent observations",
    forest_area_ha=estimate,
    forest_proportion=estimate/sum(frame$area_ha),
    variance_ha2=variance,
    se_ha=se,
    ci95_normal_ha=c(lower=estimate-z*se, upper=estimate+z*se),
    by_stratum=by_stratum
  )
}
