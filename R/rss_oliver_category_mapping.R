# Exact subclass categories transcribed from Oliver's RSS Analysis 2025 mapping.
rss_oliver_subclass_mapping <- function() {
 l3<-c("11Forest nat stocked","12Forest nat temp unstocked",
 "13Forest planted stocked","14Forest planted temp unstocked","15Mangroves",
 "19Other wooded","21Cropland no trees","22Cropland trees",
 "23Grassland no trees","24Grassland trees","25Oil palm",
 "35Settlement no trees","36Settlement trees","31Bare soil",
 "44Shifting cultivations","41Inland water","42Sea water","43Permanent ice")
 l2<-c(rep("Naturally regenerating forest",2),rep("Planted forest",2),
 "Mangroves","Other wooded",rep("Cropland",2),rep("Grassland",2),
 "Oil palm",rep("Settlement",2),"Bare soil","Shifting cultivations",
 "Inland water","Sea water","Permanent ice")
 l1<-c(rep("FOREST%24",5),"OWL%24",rep("OL%24",9),rep("WATER%24",3))
 data.frame(level_3_subclass=l3,level_2_subclass=l2,
            level_1_subclass=l1,stringsAsFactors=FALSE)
}
rss_oliver_normalize_ipcc <- function(x) {
 r<-as.character(x)
 from<-c("13forest planted stocked","14forest planted temp unstocked",
         "21cropland no trees","22cropland trees",
         "35Settlement  no trees","36Settlement  trees")
 to<-c("13Forest planted stocked","14Forest planted temp unstocked",
       "21Cropland no trees","22Cropland trees",
       "35Settlement no trees","36Settlement trees")
 for(i in seq_along(from))r[!is.na(r)&r==from[i]]<-to[i]
 r
}
rss_oliver_map_ipcc <- function(x,strict=TRUE) {
 m<-rss_oliver_subclass_mapping()
 normalized<-rss_oliver_normalize_ipcc(x)
 i<-match(normalized,m$level_3_subclass)
 if(strict&&any(!is.na(normalized)&is.na(i)))
   stop(paste("Unmapped IPCC24 categories:",paste(unique(normalized[!is.na(normalized)&is.na(i)]),collapse="; ")))
 data.frame(level_3_subclass=normalized,
  level_2_subclass=m$level_2_subclass[i],
  level_1_subclass=m$level_1_subclass[i])
}
rss_oliver_centroid_parent_map <- function(variables,kind=c("l3","l2","driver","subcategory","crop","pastoral")) {
 kind<-match.arg(kind);m<-rss_oliver_subclass_mapping()
 if(kind=="l3")parent<-m$level_1_subclass[match(variables,m$level_3_subclass)]
 if(kind=="l2"){
  parent<-vapply(variables,function(v){
   q<-unique(m$level_1_subclass[m$level_2_subclass==v])
   if(length(q)!=1)NA_character_ else q
  },character(1))
 }
 if(kind=="driver")parent<-rss_oliver_driver_parent(variables)
 if(kind=="subcategory")parent<-rep("FOREST%24",length(variables))
 if(kind=="crop")parent<-rep("OL%24",length(variables))
 if(kind=="pastoral"){
  parent<-ifelse(grepl("Forest_",variables)|grepl("Mangroves",variables),"FOREST%24",
   ifelse(grepl("Other_wooded_",variables),"OWL%24",
    ifelse(grepl("water|ice",variables,ignore.case=TRUE),"WATER%24","OL%24")))
 }
 if(anyNA(parent))stop("Unmapped calibration categories")
 data.frame(variable=variables,parent=parent,stringsAsFactors=FALSE)
}
