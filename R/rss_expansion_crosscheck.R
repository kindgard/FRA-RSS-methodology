# Public, independent algebraic cross-check of raw expansion estimates.
# This is NOT an execution of Oliver Stoner's original country estimator.
rss_expansion_crosscheck <- function(raw, variables, weight="EFKm2",
                                     key="SubRegGEZNstr", tol=1e-7) {
  if(!is.data.frame(raw)||!all(c(weight,key,variables)%in%names(raw)))
    stop("Missing input fields")
  w<-raw[[weight]];k<-as.character(raw[[key]])
  if(!is.numeric(w)||anyNA(w)||any(!is.finite(w)|w<=0)||
     anyNA(k))stop("Invalid weights or strata")
  ans<-lapply(variables,function(v){
    y<-raw[[v]]
    if(!is.numeric(y)||anyNA(y)||any(!is.finite(y)|y<0|y>1))
      stop(paste("Invalid/missing values for",v))
    direct<-sum(y*w)/10000
    groups<-split(seq_along(y),k)
    grouped<-sum(vapply(groups,function(i)
      sum(w[i])*sum(y[i]*w[i])/sum(w[i]),numeric(1)))/10000
    data.frame(variable=v,direct_Mha=direct,grouped_Mha=grouped,
               abs_diff_Mha=abs(direct-grouped),
               pass=abs(direct-grouped)<=tol)
  })
  do.call(rbind,ans)
}
