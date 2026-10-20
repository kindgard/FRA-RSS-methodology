source("R/rss_oliver_calibration.R")
source("R/rss_oliver_category_mapping.R")
m<-rss_oliver_subclass_mapping()
stopifnot(nrow(m)==18L,length(unique(m$level_3_subclass))==18L,
 sum(m$level_1_subclass=="FOREST%24")==5L,
 all(m$level_1_subclass %in% c("FOREST%24","OWL%24","OL%24","WATER%24")))
x<-rss_oliver_map_ipcc(c("13forest planted stocked","15Mangroves","44Shifting cultivations"))
stopifnot(identical(as.character(x$level_1_subclass),c("FOREST%24","FOREST%24","OL%24")))
p<-rss_oliver_centroid_parent_map(m$level_3_subclass,"l3")
stopifnot(identical(p$parent,m$level_1_subclass))
stopifnot(rss_oliver_centroid_parent_map("23Grassland no trees","l3")$parent=="OL%24")
stopifnot(rss_oliver_centroid_parent_map("Loss_21Croplandnotrees_0010","driver")$parent=="%FORLOSS 2000-2010")
stopifnot(inherits(try(rss_oliver_map_ipcc("unknown"),silent=TRUE),"try-error"))
cat("Oliver IPCC and calibration parent mapping synthetic: PASS\n")
