# Private thematic QA: check label families and reference closure without modifying RAW.
rss_thematic_qa <- function(raw, periods=c("0010","1018","1824")) {
 out<-list()
 for(p in periods){
  d<-as.character(raw[[paste0("Driver",p)]])
  change<-as.character(raw[[paste0("CHANGE",p)]])
  applicable<-!is.na(d)&!d%in%c("NA","","Not applicable (driver)")
  mismatch<-applicable&!is.na(change)&!(
    (grepl("^Loss_",d)&change=="Forest Loss")|
    (grepl("^Gain_",d)&change%in%c("Forest gain","Forest Gain")))
  out[[p]]<-data.frame(period=p,n=nrow(raw),
    applicable=sum(applicable),unknown_prefix=sum(applicable&!grepl("^(Gain_|Loss_)",d)),
    mismatch=sum(mismatch),missing_change=sum(is.na(change)),
    status=if(sum(mismatch)>0||sum(is.na(change))>0)"REVIEW" else "PASS")
 }
 do.call(rbind,out)
}
rss_thematic_subset_qa <- function(raw,field,non_applicable) {
 x<-as.character(raw[[field]])
 applicable<-!is.na(x)&!x%in%c("NA","",non_applicable)
 data.frame(field=field,n=nrow(raw),n_applicable=sum(applicable),
   n_not_applicable=sum(!applicable),
   n_unique_categories=length(unique(x[applicable])))
}
