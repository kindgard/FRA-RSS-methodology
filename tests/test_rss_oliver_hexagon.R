source("R/rss_oliver_hexagon.R")
d<-data.frame(Subreg=c("SAM","SAM","SAM","SAM","WAF"),
 GEZ=c(11,11,11,11,12),Nstr0024=c(1,1,2,2,1),
 EFKm2=c(10,10,20,20,30),check.names=FALSE)
d[["FOREST%24"]]<-c(.2,.6,.1,.3,.4)
d[["%FORLOSS 2000-2010"]]<-c(.1,.3,.2,.4,.1)
r<-rss_oliver_hexagon(d,c("FOREST%24","%FORLOSS 2000-2010"))
forest<-r$global[r$global$variable=="FOREST%24",]
stopifnot(abs(forest$area_Mha-(8+8+12)/1e4)<1e-12,
  forest$cells==3,forest$singleton_cells==1)
v<-(stats::var(c(.2,.6))/2)*20^2+(stats::var(c(.1,.3))/2)*40^2
stopifnot(abs(forest$variance_Mha2-v/1e8)<1e-12)
bad<-d;bad$EFKm2[1]<-11
stopifnot(inherits(try(rss_oliver_hexagon(bad,"FOREST%24"),silent=TRUE),"try-error"))
cat("Oliver 2025 hexagon synthetic equivalence: PASS\n")
