source("R/rss_oliver_calibration.R")
source("R/rss_oliver_calibration_closure.R")
key<-data.frame(Subregion="SAM",GEZ="11",Nstr="1")
h<-data.frame(key,variable="FOREST%24",area_km2=100,area_variance_km4=25)
c<-rbind(data.frame(key,variable="FOREST%24",area_km2=80,area_variance_km4=16),
 data.frame(key,variable="Natural",area_km2=60,area_variance_km4=9),
 data.frame(key,variable="Planted",area_km2=20,area_variance_km4=4))
p<-data.frame(variable=c("Natural","Planted"),parent="FOREST%24")
cal<-rss_oliver_calibrate(c[2:3,],h,p,centroid_reference_cells=c[1,,drop=FALSE])
z<-rss_oliver_calibration_closure(cal,h,p)
stopifnot(nrow(z)==1,z$pass,abs(z$difference_km2)<1e-10)
bad<-cal;bad$area_km2[1]<-bad$area_km2[1]-1
stopifnot(!rss_oliver_calibration_closure(bad,h,p)$pass)
cat("Oliver calibration closure: PASS\n")
