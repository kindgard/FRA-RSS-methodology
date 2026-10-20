# Experimental linearization for a ratio-calibrated centroid subclass.
# x = hexagon parent total; y = centroid subclass; z = centroid parent.
# These three estimated totals must have a JOINT design covariance matrix.
rss_calibration_delta <- function(est, covmat) {
  stopifnot(is.numeric(est),length(est)==3L,
            is.matrix(covmat),all(dim(covmat)==c(3L,3L)))
  if(any(!is.finite(est))||any(!is.finite(covmat))||
     est[3]<=0||max(abs(covmat-t(covmat)))>1e-10)
    stop("Invalid calibration estimates or covariance matrix")
  x<-est[1];y<-est[2];z<-est[3]
  grad<-c(y/z,x/z,-x*y/(z*z))
  v<-as.numeric(t(grad)%*%covmat%*%grad)
  if(v< -1e-10)stop("Negative delta variance")
  list(calibrated=x*y/z,variance=max(v,0),se=sqrt(max(v,0)),
       gradient=grad,status="EXPERIMENTAL_NOT_OFFICIAL")
}
