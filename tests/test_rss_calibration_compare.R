source("R/rss_calibration_variance.R")
source("R/rss_calibration_compare.R")
d <- data.frame(stratum=rep(c("A","B"),each=10),
 hex_parent=c(rep(.4,5),rep(.6,5),rep(.3,5),rep(.5,5)),
 centroid_parent=c(rep(1,7),rep(0,3),rep(1,6),rep(0,4)),
 centroid_subclass=c(rep(1,3),rep(0,7),rep(1,2),rep(0,8)))
f <- data.frame(stratum=c("A","B"),Nh=c(100,200))
r <- rss_calibration_compare(d,f,n_boot=100,seed=9)
stopifnot(r$point_estimate>0,r$delta_variance>=0,
 r$bootstrap_variance>=0,r$finite_bootstrap==100,
 all(dim(r$covariance)==c(3,3)))
cat("Paired calibration synthetic bootstrap: PASS\n")
