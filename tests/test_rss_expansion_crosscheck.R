source("R/rss_expansion_crosscheck.R")
d<-data.frame(SubRegGEZNstr=c("A","A","B","B"),EFKm2=c(5,5,10,10),
              loss=c(.1,.3,.2,.4))
z<-rss_expansion_crosscheck(d,"loss")
stopifnot(nrow(z)==1L,z$pass[1],abs(z$direct_Mha[1]-.0008)<1e-12)
cat("Expansion crosscheck synthetic test: PASS\n")
