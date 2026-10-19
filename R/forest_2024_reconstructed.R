# Reconstructed formula from historical summary; synthetic-only public tests.
# Input: one row per stratum, with Nh, nh, mean, sample variance (s2).
forest2024_from_strata <- function(tab) {
  required <- c("stratum", "Nh", "nh", "mean", "s2")
  if (!is.data.frame(tab) || !all(required %in% names(tab))) stop("Missing required columns")
  if (anyNA(tab[,required]) || anyDuplicated(as.character(tab$stratum))) stop("Missing or duplicate strata")
  for (v in c("Nh","nh","mean","s2"))
    if (!is.numeric(tab[[v]]) || any(!is.finite(tab[[v]]))) stop(paste("Invalid",v))
  if (any(tab$Nh < 2 | tab$nh < 2 | tab$nh > tab$Nh) ||
      any(tab$Nh != floor(tab$Nh) | tab$nh != floor(tab$nh)) ||
      any(tab$mean < 0 | tab$mean > 1 | tab$s2 < 0))
    stop("Out-of-range stratum statistics")
  N <- sum(tab$Nh)
  if (!is.finite(N) || N <= 0) stop("Invalid population")
  w <- tab$Nh / N
  contrib_p <- w * tab$mean
  contrib_v <- w^2 * tab$s2 / tab$nh * (1-tab$nh/tab$Nh)
  p <- sum(contrib_p)
  v <- sum(contrib_v)
  ans <- tab
  ans$weight <- w
  ans$estimate_contribution <- contrib_p
  ans$variance_contribution <- contrib_v
  list(proportion=p, variance=v, se=sqrt(v),
       ci95=c(lower=p-1.96*sqrt(v),upper=p+1.96*sqrt(v)),
       population_n=N, sample_n=sum(tab$nh), by_stratum=ans)
}
# Sample-level input: continuous forest fraction per observation (not binary).
forest2024_from_samples <- function(obs, frame) {
  if (!is.data.frame(obs) || !is.data.frame(frame) ||
      !all(c("stratum","forest_fraction") %in% names(obs)) ||
      !all(c("stratum","Nh") %in% names(frame)))
    stop("Required columns missing")
  if (anyNA(obs[,c("stratum","forest_fraction")]) ||
      anyNA(frame[,c("stratum","Nh")]) ||
      !is.numeric(obs$forest_fraction) ||
      any(!is.finite(obs$forest_fraction)) ||
      any(obs$forest_fraction < 0 | obs$forest_fraction > 1))
    stop("Invalid forest fractions or strata")
  if (anyDuplicated(as.character(frame$stratum)) ||
      !setequal(as.character(obs$stratum), as.character(frame$stratum)))
    stop("Missing/duplicated frame strata")
  rows <- lapply(seq_len(nrow(frame)), function(i) {
    key <- as.character(frame$stratum[i])
    y <- obs$forest_fraction[as.character(obs$stratum)==key]
    if (length(y) < 2L) stop(paste("Too few observations in",key))
    data.frame(stratum=key,Nh=frame$Nh[i],nh=length(y),mean=mean(y),
               s2=stats::var(y))
  })
  forest2024_from_strata(do.call(rbind,rows))
}
