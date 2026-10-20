# Oliver RSS 2025 calibration mappings and area scaling, synthetic-only.
rss_oliver_driver_parent <- function(variable) {
 p<-ifelse(grepl("_0010$",variable),"2000-2010",
    ifelse(grepl("_1018$",variable),"2010-2018",
    ifelse(grepl("_1824$",variable),"2018-2024",NA_character_)))
 base<-ifelse(grepl("^Loss_",variable),"%FORLOSS ",
    ifelse(grepl("^Gain_",variable),"%FORGAIN ",
    ifelse(grepl("Not applicable",variable,fixed=TRUE),"%StabNFor ",NA_character_)))
 if(anyNA(p)|anyNA(base))stop("Unknown driver classification/suffix")
 paste0(base,p)
}
rss_oliver_calibrate <- function(centroid_cells,hexagon_cells,parent_map,
                                 variance_method=c("original_unscaled","scaled_fixed_ratio"),
                                 zero_policy=c("oliver_zero","error")) {
 variance_method<-match.arg(variance_method)
 zero_policy<-match.arg(zero_policy)
 keys<-c("Subregion","GEZ","Nstr")
 required<-c(keys,"variable","area_km2","area_variance_km4")
 if(!all(required%in%names(centroid_cells))||
    !all(required%in%names(hexagon_cells)))stop("Missing cell columns")
 if(!is.data.frame(parent_map)||!all(c("variable","parent")%in%names(parent_map))||
    anyDuplicated(parent_map$variable))stop("Invalid parent mapping")
 c<-centroid_cells
 c$parent<-parent_map$parent[match(c$variable,parent_map$variable)]
 if(anyNA(c$parent))stop("Unmapped centroid variables")
 factor_frame<-merge(
  hexagon_cells[,c(keys,"variable","area_km2")],
  centroid_cells[,c(keys,"variable","area_km2")],
  by=c(keys,"variable"),suffixes=c("_hex","_cen"))
 factor_frame$scale<-ifelse(factor_frame$area_km2_cen>0,
    factor_frame$area_km2_hex/factor_frame$area_km2_cen,0)
 if(zero_policy=="error"&&any(factor_frame$area_km2_cen<=0))
   stop("Zero centroid reference area")
 names(factor_frame)[names(factor_frame)=="variable"]<-"parent"
 ix<-match(do.call(paste,c[,c(keys,"parent")]),do.call(paste,factor_frame[,c(keys,"parent")]))
 if(anyNA(ix))stop("Missing cell-level calibration ratios")
 c$scaling_factor<-factor_frame$scale[ix]
 c$uncalibrated_area_km2<-c$area_km2
 c$area_km2<-c$area_km2*c$scaling_factor
 if(variance_method=="scaled_fixed_ratio")
   c$area_variance_km4<-c$area_variance_km4*c$scaling_factor^2
 c$variance_method<-variance_method
 c
}
