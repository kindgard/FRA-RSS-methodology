source("R/rss_oliver_hexagon.R")
source("R/rss_oliver_centroid.R")
d<-data.frame(Subreg=c("SAM","SAM","SAM","SAM"),GEZ=c(11,11,11,11),
 Nstr0024=c(1,1,1,1),EFKm2=rep(10,4),L2=c("Forest","Other","Forest","Forest"),
 Driver=c("Agriculture","Urban","Agriculture","Urban"))
p<-rss_oliver_centroid_indicators(d,c("L2","Driver"),
 levels_map=list(L2=c("Forest","Other"),Driver=c("Agriculture","Urban")))
stopifnot(length(p$variables)==4,all(rowSums(p$data[,p$variables[1:2]])==1))
z<-rss_oliver_centroid_estimates(p$data,p$variables)
f<-z$global[z$global$variable=="L2__001",]
stopifnot(abs(f$area_Mha-30/1e4)<1e-12,abs(f$se_Mha-sqrt(stats::var(c(1,0,1,1))/4)*40/1e4)<1e-12)
d$Driver[1]<-NA
q<-rss_oliver_centroid_indicators(d,"Driver")
stopifnot(is.na(q$data[["Driver__001"]][1]))
cat("Oliver centroid indicator synthetic test: PASS\n")
