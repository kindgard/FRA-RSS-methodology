# Check that calibrated L2/L3 subclasses close against hexagon parent totals.
# Diagnostic only: never alter, discard or reassign original observations.
rss_oliver_calibration_closure <- function(calibrated,reference,parent_map,
                                          tolerance_km2=1e-6) {
 keys<-c("Subregion","GEZ","Nstr")
 required<-c(keys,"variable","area_km2")
 if(!all(required%in%names(calibrated))||!all(required%in%names(reference)))
   stop("Missing required calibration columns")
 if(anyDuplicated(parent_map$variable))stop("Duplicate subclass mapping")
 z<-calibrated
 if(!("parent"%in%names(z)))z$parent<-parent_map$parent[match(z$variable,parent_map$variable)]
 if(anyNA(z$parent))stop("Missing parent mapping")
 groups<-split(seq_len(nrow(z)),interaction(z[,c(keys,"parent")],drop=TRUE))
 out<-do.call(rbind,lapply(groups,function(i){
   d<-z[i,,drop=FALSE]
   ix<-which(reference$Subregion==d$Subregion[1]&
       as.character(reference$GEZ)==as.character(d$GEZ[1])&
       as.character(reference$Nstr)==as.character(d$Nstr[1])&
       reference$variable==d$parent[1])
   if(length(ix)!=1)stop("Reference cell missing or duplicated")
   value<-sum(d$area_km2)
   target<-reference$area_km2[ix]
   data.frame(Subregion=d$Subregion[1],GEZ=d$GEZ[1],Nstr=d$Nstr[1],
     parent=d$parent[1],calibrated_km2=value,reference_km2=target,
     difference_km2=value-target,
     pass=is.finite(value)&is.finite(target)&abs(value-target)<=tolerance_km2)
 }))
 rownames(out)<-NULL
 out
}
