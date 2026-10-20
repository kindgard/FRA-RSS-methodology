source("R/rss_oliver_hexagon.R")
source("R/rss_oliver_report_domains.R")
d<-data.frame(Subreg=c("SAM","SAM","WAF","WAF"),
 GEZ=c(11,11,12,12),Nstr0024=c(1,1,1,1),EFKm2=c(10,10,20,20),
 check.names=FALSE)
d[["%FORLOSS 2000-2010"]]<-c(.1,.3,.2,.4)
d[["%FORGAIN 2000-2010"]]<-c(.2,.4,.1,.1)
d[["FOREST%24"]]<-c(.5,.5,.8,.6)
for(p in c("2010-2018","2018-2024")) {
 d[[paste0("%FORLOSS ",p)]]<-d[["%FORLOSS 2000-2010"]]
 d[[paste0("%FORGAIN ",p)]]<-d[["%FORGAIN 2000-2010"]]
}
vars<-c("FOREST%24",unlist(lapply(c("2000-2010","2010-2018","2018-2024"),function(p)paste0(c("%FORLOSS ","%FORGAIN "),p))))
z<-rss_oliver_hexagon(d,vars)
r<-rss_oliver_domains(z$by_cell,data.frame(Subregion=c("SAM","WAF"),Region=c("South America","Africa")))
stopifnot(all(c("Global","Region","Subregion","GEZ","Subregion_GEZ")%in%names(r)))
loss<-r$Global[r$Global$variable=="%FORLOSS 2000-2010",]
stopifnot(abs(loss$area_Mha-16/1e4)<1e-12,
  abs(loss$se_Mha-sqrt((.02/2)*20^2+(.02/2)*40^2)/1e4)<1e-12)
annual<-rss_oliver_annual_change(r$Global[r$Global$variable!="FOREST%24",])
stopifnot(nrow(annual)==3,abs(annual$loss_Mha-loss$area_Mha)<1e-12,
  abs(annual$annual_loss_Mha[annual$period=="2000-2010"]-loss$area_Mha/10)<1e-12)
cat("Oliver multi-domain and annual change synthetic: PASS\n")
