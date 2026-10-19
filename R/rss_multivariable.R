# Public generic module for stratified hexagon fractions, NO institutional values.
rss_multivariable <- function(data,frame,variables,domain=NULL, area_km2=0.3962) {
  if (!is.data.frame(data)||!is.data.frame(frame)||!length(variables)||
      !all(c("stratum","Nh")%in%names(frame))||
      !all(c("stratum",variables)%in%names(data))) stop("Missing input fields")
  if(anyDuplicated(as.character(frame$stratum))||anyNA(frame[,c("stratum","Nh")])||
     !is.numeric(frame$Nh)||any(frame$Nh<2))stop("Invalid population frame")
  if(!is.null(domain) && (!is.character(domain)||length(domain)!=1L||
     !domain%in%names(data)))stop("Invalid domain field")
  if(!is.numeric(area_km2)||length(area_km2)!=1L||!is.finite(area_km2)||
     area_km2<=0)stop("Invalid hexagon area")
  if(anyNA(data$stratum)||!setequal(as.character(data$stratum),as.character(frame$stratum)))
    stop("Stratum mismatch")
  if(!is.null(domain)) stop("Domain inference not yet implemented: requires approved design-based variance specification")
  res <- lapply(variables,function(v) {
    y <- data[[v]]
    if(!is.numeric(y)||anyNA(y)||any(!is.finite(y)|y<0|y>1))
      stop(paste("Missing/invalid data for",v,"; explicit policy required"))
    rows <- lapply(seq_len(nrow(frame)),function(i) {
      key <- as.character(frame$stratum[i])
      z <- y[as.character(data$stratum)==key]
      if(length(z)<2L||length(z)>frame$Nh[i])stop("Invalid sample size")
      data.frame(stratum=key,Nh=frame$Nh[i],nh=length(z),mean=mean(z),
                 s2=stats::var(z))
    })
    tab <- do.call(rbind,rows)
    n <- sum(tab$Nh)
    w <- tab$Nh/n
    p <- sum(w*tab$mean)
    variance <- sum(w^2*tab$s2/tab$nh*(1-tab$nh/tab$Nh))
    data.frame(variable=v,proportion=p,variance=variance,se=sqrt(variance),
       lower=p-1.96*sqrt(variance),upper=p+1.96*sqrt(variance),
       area_km2=p*n*area_km2,se_area_km2=sqrt(variance)*n*area_km2,
       n_samples=sum(tab$nh),N_population=n)
  })
  do.call(rbind,res)
}
