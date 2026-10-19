# Faithful adaptation of Oliver Stoner's RSS Analysis 2025:
# Hexagon Calculations only. Public code / synthetic data only.
# Input: NC85 single sheet; EFKm2 is expansion area per sampled hexagon.
# Grouping: Subregion x GEZ x Nstr; sample variance / n for n>1, else zero.
# No finite population correction, matching the reference notebook.
rss_oliver_hexagon <- function(raw, variables, area_weight="EFKm2",
                               subregion="Subreg", gez="GEZ", stratum="Nstr0024",
                               na_policy="oliver", weight_tolerance=1e-6) {
  keys <- c(subregion,gez,stratum)
  if(!is.data.frame(raw)||!all(c(keys,area_weight,variables)%in%names(raw)))
    stop("Missing required NC85 fields")
  w<-raw[[area_weight]]
  if(!is.numeric(w)||anyNA(w)||any(!is.finite(w)|w<=0)||
     anyNA(raw[,keys]))stop("Invalid weights/strata")
  group<-interaction(raw[,keys],drop=TRUE,lex.order=TRUE)
  indices<-split(seq_len(nrow(raw)),group,drop=TRUE)
  by_cell<-list()
  k<-0L
  for(idx in indices) {
    ww<-w[idx]
    if(max(ww)-min(ww)>weight_tolerance*max(1,mean(ww)))
      stop("EFKm2 varies within a Subregion-GEZ-Nstr cell; inspect weights")
    n<-length(idx)
    # n_h * expansion factor equals the population area represented by this cell
    total_area<-n*mean(ww)
    for(v in variables) {
      x<-raw[[v]][idx]
      if(!is.numeric(x)||any(!is.na(x)&(!is.finite(x)|x<0|x>1)))
        stop(paste("Invalid response:",v))
      mu<-mean(x,na.rm=TRUE)  # mirrors Oliver's NA removal for means
      # Oliver uses var(x)/n without na.rm; preserves NA variance on missing x.
      varprop<-if(n>1) stats::var(x)/n else 0
      k<-k+1L
      by_cell[[k]]<-data.frame(Subregion=as.character(raw[[subregion]][idx[1]]),
        GEZ=as.character(raw[[gez]][idx[1]]),
        Nstr=as.character(raw[[stratum]][idx[1]]),
        variable=v,nh=n,total_area_km2=total_area,proportion=mu,
        proportion_variance=varprop,area_km2=mu*total_area,
        area_variance_km4=varprop*total_area^2)
    }
  }
  cells<-do.call(rbind,by_cell)
  # Oliver aggregate_area adds area and its variance, then square roots.
  global<-do.call(rbind,lapply(split(cells,cells$variable),function(d){
    A<-sum(d$area_km2)
    V<-sum(d$area_variance_km4)
    data.frame(variable=d$variable[1],area_Mha=A/1e4,
      variance_Mha2=V/1e8,se_Mha=sqrt(V)/1e4,
      rel_plus_minus_percent=if(A<=1e-10)NA_real_ else 100*1.96*sqrt(V)/A,
      cells=nrow(d),singleton_cells=sum(d$nh==1))
  }))
  rownames(global)<-NULL
  list(by_cell=cells,global=global,method="Oliver Hexagon Calculations; no FPC")
}
