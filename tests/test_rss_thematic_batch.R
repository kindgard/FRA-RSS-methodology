source("R/rss_oliver_hexagon.R")
source("R/rss_oliver_report_domains.R")
source("R/rss_oliver_regions.R")
source("R/rss_oliver_calibration.R")
source("R/rss_oliver_drivers_pastoral.R")
source("R/rss_oliver_thematic_batch.R")
d<-data.frame(Subreg=rep("SAM",4),GEZ=rep(11,4),Nstr0024=rep(1,4),EFKm2=rep(10,4))
for(p in c("0010","1018","1824")){
 d[[paste0("Driver",p)]]<-c("Loss_21Croplandnotrees","Loss_21Croplandnotrees",
    "Gain_13Forestplantedstocked","NA")
 d[[paste0("CHANGE",p)]]<-c("Forest Loss","Forest Loss","Forest Gain","Stable Non Forest")
}
d$Ranch_Pastoralism<-c("11_p_Forest_nat_stocked_Pastoralism",
 "11_np_Forest_nat_stocked_NO_Pastoralism","23_p_Grassland_no_trees_Non_manage_Pastoralism",
 "Not applicable (ranch and pastoralism)")
d$LU24CEN<-c("Forest","Forest","Other Land","Other Land")
d$TempOrPerenn<-c("NA","NA","Maize_NoT_Smallscale","NA")
for(v in c("FOREST%24","OWL%24","OL%24","WATER%24"))d[[v]]<-as.numeric(d$LU24CEN==switch(v,
 "FOREST%24"="Forest","OWL%24"="Other Wooded Land",
 "OL%24"="Other Land","WATER%24"="Water"))
for(i in seq_along(c("2000-2010","2010-2018","2018-2024"))){
 p<-c("2000-2010","2010-2018","2018-2024")[i]
 for(term in c("%FORLOSS ","%FORGAIN ","%StabNFor "))d[[paste0(term,p)]]<-as.numeric(d[[paste0("CHANGE",c("0010","1018","1824")[i])]]==
 switch(term,"%FORLOSS "="Forest Loss","%FORGAIN "="Forest Gain","%StabNFor "="Stable Non Forest"))
}
x<-rss_oliver_hexagon(d,c("FOREST%24","OWL%24","OL%24","WATER%24",
 unlist(lapply(c("2000-2010","2010-2018","2018-2024"),function(p)
 paste0(c("%FORLOSS ","%FORGAIN ","%StabNFor "),p))))) 
dir<-tempfile();dir.create(dir)
saved<-character(); states<-data.frame(module=character(),status=character())
save_csv<-function(x,n){write.csv(x,file.path(dir,n),row.names=FALSE);saved<<-c(saved,n)}
status<-function(m,s,r){states<<-rbind(states,data.frame(module=m,status=s))}
rss_oliver_run_thematic(d,x,save_csv,status)
stopifnot(any(states$module=="drivers"),any(states$module=="pastoralism"),any(states$module=="crops"),
 "drivers_dictionary.csv"%in%saved,"pastoralism_dictionary.csv"%in%saved,"crops_dictionary.csv"%in%saved,
 all(states$status=="READY_FOR_REVIEW"))
unlink(dir,recursive=TRUE)
cat("Thematic drivers and pastoralism synthetic: PASS\n")
