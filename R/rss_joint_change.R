# Joint stratified estimation of gain, loss and net change on the SAME hexagons.
# Fractions are continuous 0..1. FPC and covariance are included by design.
rss_joint_change <- function(data, frame, gain, loss, hexagon_area_km2=0.3962) {
  required <- c("stratum",gain,loss)
  if (!is.data.frame(data)||!is.data.frame(frame)||
      !all(required %in% names(data))||
      !all(c("stratum","Nh")%in% names(frame))||
      anyDuplicated(as.character(frame$stratum))||
      anyNA(data[,required])||anyNA(frame[,c("stratum","Nh")]))
    stop("Invalid or missing joint inputs")
  for(v in c(gain,loss)) {
    y <- data[[v]]
    if(!is.numeric(y)||any(!is.finite(y)|y<0|y>1))
      stop(paste("Invalid",v))
  }
  if(!is.numeric(frame$Nh)||any(!is.finite(frame$Nh)|frame$Nh<2)||
     !setequal(as.character(data$stratum),as.character(frame$stratum))||
     !is.numeric(hexagon_area_km2)||length(hexagon_area_km2)!=1||
     !is.finite(hexagon_area_km2)||hexagon_area_km2<=0)
    stop("Invalid population frame or hexagon area")
  N <- sum(frame$Nh)
  calc <- lapply(seq_len(nrow(frame)),function(i) {
    key <- as.character(frame$stratum[i])
    d <- data[as.character(data$stratum)==key,,drop=FALSE]
    n <- nrow(d); Nh <- frame$Nh[i]
    if(n<2||n>Nh)stop("Invalid stratum size")
    g <- d[[gain]]; l <- d[[loss]]; z <- g-l
    weight <- Nh/N
    fpc <- 1-n/Nh
    data.frame(stratum=key,Nh=Nh,nh=n,weight=weight,
      gain=mean(g),loss=mean(l),net=mean(z),
      v_gain=weight^2*fpc*stats::var(g)/n,
      v_loss=weight^2*fpc*stats::var(l)/n,
      cov_gain_loss=weight^2*fpc*stats::cov(g,l)/n,
      v_net_direct=weight^2*fpc*stats::var(z)/n)
  })
  tab <- do.call(rbind,calc)
  Pgain <- sum(tab$weight*tab$gain)
  Ploss <- sum(tab$weight*tab$loss)
  vgain <- sum(tab$v_gain);vloss <- sum(tab$v_loss)
  covariance <- sum(tab$cov_gain_loss)
  vnet <- vgain+vloss-2*covariance
  if(vnet < -1e-12)stop("Negative net variance: input error")
  vnet <- max(0,vnet)
  if(abs(vnet-sum(tab$v_net_direct))>1e-10)
    stop("Covariance identity failed")
  area <- N*hexagon_area_km2
  list(proportion=c(gain=Pgain,loss=Ploss,net=Pgain-Ploss),
       variance=c(gain=vgain,loss=vloss,net=vnet),
       covariance_gain_loss=covariance,
       se=c(gain=sqrt(vgain),loss=sqrt(vloss),net=sqrt(vnet)),
       area_km2=c(gain=Pgain,loss=Ploss,net=Pgain-Ploss)*area,
       se_area_km2=c(gain=sqrt(vgain),loss=sqrt(vloss),net=sqrt(vnet))*area,
       by_stratum=tab)
}
