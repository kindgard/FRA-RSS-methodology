source("R/forest_2024_synthetic.R")
# All inputs below are invented exclusively for software tests.
s <- data.frame(stratum=rep(c("A", "B"), each=4),
                forest_2024=c(1,1,0,0, 1,0,0,0))
frame <- data.frame(stratum=c("A","B"), area_ha=c(100,200))
r <- forest_2024_estimate(s, frame)
stopifnot(isTRUE(all.equal(r$forest_area_ha, 100)),
          isTRUE(all.equal(r$forest_proportion, 1/3)),
          isTRUE(all.equal(r$variance_ha2, 10000/3/4 + 40000*0.25/4)),
          isTRUE(all.equal(r$se_ha^2, r$variance_ha2)),
          isTRUE(all.equal(sum(r$by_stratum$forest_area_ha), r$forest_area_ha)),
          r$ci95_normal_ha["lower"] < r$forest_area_ha,
          r$ci95_normal_ha["upper"] > r$forest_area_ha)
# Exact finite population correction: full census means zero sampling variance.
frame_census <- transform(frame, population_n=c(4,4))
r_census <- forest_2024_estimate(s, frame_census)
stopifnot(r_census$variance_ha2 == 0)
# Unrecognized labels, missing strata, insufficient observations must fail closed.
fails <- function(expr) inherits(try(suppressWarnings(expr), silent=TRUE),"try-error")
bad <- s; bad$forest_2024[1] <- 2
stopifnot(fails(forest_2024_estimate(bad,frame)))
stopifnot(fails(forest_2024_estimate(s[s$stratum=="A",],frame)))
stopifnot(fails(forest_2024_estimate(s[-1:-3,],frame)))
cat("Forest 2024 synthetic estimator tests: PASS\n")
print(r[c("forest_area_ha","variance_ha2","se_ha","ci95_normal_ha")])
