source("R/rss_calibration_variance.R")
covmat <- matrix(c(.04,.01,.01,.01,.09,.02,.01,.02,.16),3,3)
r <- rss_calibration_delta(c(3,1,2),covmat)
stopifnot(abs(r$calibrated-1.5)<1e-12,r$variance>0)
c2 <- covmat;c2[1,2]<-0;c2[2,1]<-0
stopifnot(abs(r$variance-rss_calibration_delta(c(3,1,2),c2)$variance)>1e-6)
cat("Synthetic calibration covariance: PASS\n")
