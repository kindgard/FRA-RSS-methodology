source("R/forest_2024_reconstructed.R")
source("R/forest_2024_audit.R")
# Synthetic stratum summaries only
d <- data.frame(stratum=c("X","Y"),Nh=c(100,200),nh=c(4,4),
                mean=c(.5,.25),s2=c(1/6,1/24))
expected <- list(proportion=1/3,population_n=300,sample_n=8)
ok <- forest2024_audit(d,expected)
stopifnot(ok$status=="PASS",nrow(ok$checks)==3)
# Deliberate regression must fail, with diagnostic.
bad <- forest2024_audit(d,list(proportion=.4))
stopifnot(bad$status=="FAIL",!bad$checks$pass[1])
# Independent per-stratum checks
r <- forest2024_from_strata(d)
named <- stats::setNames(r$by_stratum$variance_contribution,r$by_stratum$stratum)
stopifnot(forest2024_audit(d,list(variance_contribution_by_stratum=named))$status=="PASS")
named["X"] <- named["X"] + 0.001
stopifnot(forest2024_audit(d,list(variance_contribution_by_stratum=named))$status=="FAIL")
cat("Forest 2024 audit engine tests: PASS\n")
