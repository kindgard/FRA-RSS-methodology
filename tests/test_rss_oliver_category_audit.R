source("R/rss_oliver_category_mapping.R")
source("R/rss_oliver_category_audit.R")
d<-data.frame(IPCC24=c("13forest planted stocked","15Mangroves",
 "21Cropland no trees","Unknown",NA_character_))
z<-rss_oliver_category_audit(d)
stopifnot(z$missing==1L,z$unknown_n==1L,z$status=="REVIEW_UNMAPPED",
 any(z$categories$spelling_normalized))
d$IPCC24[4]<-"11Forest nat stocked"
stopifnot(rss_oliver_category_audit(d)$status=="MAPPED")
q<-data.frame(a=c(1,0,1),b=c(0,1,0))
stopifnot(rss_oliver_indicator_closure(q,c("a","b"))$status=="PARTITION")
q$b[1]<-1
stopifnot(rss_oliver_indicator_closure(q,c("a","b"))$n_not_one==1)
cat("Oliver category and partition audit synthetic: PASS\n")
