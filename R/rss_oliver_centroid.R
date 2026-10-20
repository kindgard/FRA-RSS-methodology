# Oliver RSS Analysis 2025 centroid indicator preparation and estimators.
# Public synthetic-only implementation; centroid totals are UNCALIBRATED.
# Original notebook creates indicators from L2/L3, drivers and subcategory changes,
# then takes means and var(x)/n by Subregion x GEZ x Nstr.
rss_oliver_centroid_indicators <- function(raw, categorical, levels_map=NULL,
                                            missing_label=NULL) {
  if(!is.data.frame(raw)||!all(categorical%in%names(raw)))
    stop("Missing categorical centroid fields")
  d<-raw
  created<-character()
  for(v in categorical){
    x<-as.character(raw[[v]])
    if(!is.null(missing_label))x[is.na(x)|x=="NA"]<-missing_label
    classes<-if(!is.null(levels_map)&&!is.null(levels_map[[v]]))
      as.character(levels_map[[v]]) else sort(unique(x[!is.na(x)]))
    if(anyDuplicated(classes))stop("Duplicate categorical levels")
    if(any(!is.na(x)&!x%in%classes))stop(paste("Unmapped categories",v))
    for(j in seq_along(classes)){
      name<-paste0(v,"__",sprintf("%03d",j))
      if(name%in%names(d))stop("Indicator collision")
      d[[name]]<-as.numeric(!is.na(x)&x==classes[j])
      # Leave genuine missing values missing unless explicit missing category.
      if(is.null(missing_label))d[[name]][is.na(x)]<-NA_real_
      created<-c(created,name)
    }
  }
  list(data=d,variables=created,levels=levels_map)
}
rss_oliver_centroid_estimates <- function(raw, indicator_variables) {
  if(!exists("rss_oliver_hexagon",mode="function"))
    stop("Source R/rss_oliver_hexagon.R first")
  out<-rss_oliver_hexagon(raw,indicator_variables)
  out$method<-"Oliver 2025 centroid indicators (unadjusted, not hexagon-calibrated)"
  out
}
