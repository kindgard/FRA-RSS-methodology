source("R/rss_oliver_calibration.R")
k<-data.frame(Subregion="SAM",GEZ="11",Nstr="1")
hex<-data.frame(k,variable="FOREST%24",area_km2=100,area_variance_km4=25)
centroid<-rbind(data.frame(k,variable="FOREST%24",area_km2=80,area_variance_km4=16),
 data.frame(k,variable="Natural",area_km2=60,area_variance_km4=9),
 data.frame(k,variable="Planted",area_km2=20,area_variance_km4=4))
pm<-data.frame(variable=c("Natural","Planted"),parent="FOREST%24")
z<-rss_oliver_calibrate(centroid,hex,pm)
stopifnot(all(abs(z$area_km2-c(75,25))<1e-10),
 all(z$area_variance_km4==c(9,4)),all(z$scaling_factor==1.25))
s<-rss_oliver_calibrate(centroid,hex,pm,variance_method="scaled_fixed_ratio")
stopifnot(abs(s$area_variance_km4[1]-9*1.25^2)<1e-10)
stopifnot(rss_oliver_driver_parent("Loss_21Croplandnotrees_0010")=="%FORLOSS 2000-2010")
stopifnot(rss_oliver_driver_parent("Gain_13Forestplantedstocked_1824")=="%FORGAIN 2018-2024")
cat("Oliver calibration synthetic test: PASS\n")
