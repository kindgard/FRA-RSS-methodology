# Design-based joint covariance and stratified bootstrap of a ratio calibrated total.
# x: hexagon parent fraction, y: centroid subclass indicator, z: centroid parent indicator.
# A=x*y/z estimates are recalculated within each bootstrap replication.
# Synthetic experiments ONLY: bootstrap ignores finite population correction.
rss_calibration_compare <- function(data,frame,n_boot=500L,seed=1L,area_km2=.3962) {
  cols<-c("stratum","hex_parent","centroid_subclass","centroid_parent")
  if(!is.data.frame(data)||!is.data.frame(frame)||
     !all(cols%in%names(data))||!all(c("stratum","Nh")%in%names(frame))||
     anyNA(data[,cols])||anyNA(frame[,c("stratum","Nh")])||
     !all(vapply(data[cols[-1]],is.numeric,logical(1)))||
     any(vapply(data[cols[-1]],function(x)any(!is.finite(x)|x<0|x>1),logical(1)))||
     any(data$centroid_subclass>data$centroid_parent)||
     anyDuplicated(as.character(frame$stratum))||
     !setequal(as.character(data$stratum),as.character(frame$stratum)))
    stop("Invalid joint paired calibration data")
  if(!is.numeric(frame$Nh)||any(!is.finite(frame$Nh)|frame$Nh<2)||
     !is.numeric(n_boot)||length(n_boot)!=1||n_boot<30||
     n_boot!=floor(n_boot))stop("Invalid frame or bootstrap count")
  keys<-as.character(frame$stratum)
  subsets<-lapply(keys,function(k) as.matrix(data[as.character(data$stratum)==k,
    cols[-1],drop=FALSE]))
  ns<-vapply(subsets,nrow,integer(1)); Nh<-frame$Nh
  if(any(ns<2|ns>Nh))stop("Invalid within-stratum size")
  N<-sum(Nh); w<-Nh/N
  joint<-function(draws) {
    means<-vapply(draws,colMeans,numeric(3))
    as.numeric((means%*%w)*N*area_km2)
  }
  observed<-joint(subsets)
  if(observed[3]<=0)stop("Centroid parent denominator zero")
  # Covariance of three estimated AREA TOTALS, including cross-support covariance.
  covariance<-matrix(0,3,3)
  for(i in seq_along(subsets)) {
    covariance<-covariance+(Nh[i]*area_km2)^2*
      (1-ns[i]/Nh[i])*stats::cov(subsets[[i]])/ns[i]
  }
  if(!exists("rss_calibration_delta",mode="function"))
    stop("Source R/rss_calibration_variance.R first")
  linearized<-rss_calibration_delta(observed,covariance)
  set.seed(seed)
  replicates<-rep(NA_real_,n_boot)
  for(b in seq_len(n_boot)) {
    draws<-lapply(subsets,function(a)a[sample.int(nrow(a),nrow(a),replace=TRUE),,drop=FALSE])
    theta<-joint(draws)
    if(theta[3]>0) replicates[b]<-theta[1]*theta[2]/theta[3]
  }
  if(sum(is.finite(replicates))<30)stop("Too many bootstrap zero denominators")
  list(point_estimate=linearized$calibrated,
       delta_variance=linearized$variance,
       bootstrap_variance=stats::var(replicates,na.rm=TRUE),
       bootstrap_ci=stats::quantile(replicates,c(.025,.975),na.rm=TRUE),
       finite_bootstrap=sum(is.finite(replicates)),
       covariance=covariance,
       diagnostic="bootstrap-with-replacement (no FPC), not official calibrated CI")
}
