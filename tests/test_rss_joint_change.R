source("R/rss_joint_change.R")
d <- data.frame(stratum=rep(c("A","B"),each=4),
  gain=c(0,.2,.1,.3,0,.5,0,.5),
  loss=c(.4,.1,.2,0,.5,0,.5,0))
f <- data.frame(stratum=c("A","B"),Nh=c(100,200))
r <- rss_joint_change(d,f,"gain","loss")
stopifnot(abs(r$proportion["net"]-(r$proportion["gain"]-r$proportion["loss"]))<1e-12,
 abs(r$variance["net"]-(r$variance["gain"]+r$variance["loss"]-
 2*r$covariance_gain_loss))<1e-12,
 abs(r$variance["net"]-sum(r$by_stratum$v_net_direct))<1e-12)
cat("Joint gain loss covariance tests: PASS\n")
