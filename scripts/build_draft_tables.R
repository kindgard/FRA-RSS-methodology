#!/usr/bin/env Rscript
# PRIVATE-ONLY manuscript-ready data tables. No charts are certified without QA.
args<-commandArgs(trailingOnly=TRUE)
if(length(args)!=2L)stop("Usage: Rscript scripts/build_draft_tables.R PRIVATE_BATCH_DIR PRIVATE_REPORT_DIR")
root<-normalizePath(args[1],mustWork=TRUE)
dest<-args[2]
if(!file.exists(file.path(root,"module_status.csv")))stop("Missing private batch manifest")
if(!file.exists(file.path(root,"input_manifest.csv")))stop("Missing RAW identity manifest")
if(!dir.exists(dest))dir.create(dest,recursive=TRUE)
if(length(list.files(dest,all.files=TRUE,no..=TRUE)))stop("Report directory must be empty")
status<-read.csv(file.path(root,"module_status.csv"),stringsAsFactors=FALSE)
flag<-function(module) {
 ix<-match(module,status$module)
 if(is.na(ix))return("BLOCKED")
 status$status[ix]
}
emit<-function(dat,path)write.csv(dat,file.path(dest,path),row.names=FALSE,na="")
src<-read.csv(file.path(root,"input_manifest.csv"),stringsAsFactors=FALSE)
emit(src,"provenance.csv")
cfile<-file.path(root,"forest_change_annual.csv")
if(flag("change_annual")=="PASS"&&file.exists(cfile)){
 ch<-read.csv(cfile,check.names=FALSE)
 cols<-c("period","years","loss_Mha","gain_Mha","net_Mha",
         "annual_loss_Mha","annual_gain_Mha","annual_net_Mha")
 if(!all(cols%in%names(ch)))stop("Annual change contract changed")
 emit(ch[,cols,drop=FALSE],"T06_global_forest_change.csv")
 emit(ch[,c("period","annual_loss_Mha","annual_gain_Mha","annual_net_Mha")],
      "F03_annual_change_plot_data.csv")
}
# Geographic loss and expansion: same standard schema at each scale.
periods<-c("2000-2010"=10,"2010-2018"=8,"2018-2024"=6)
for(domain in c("Region","Subregion","GEZ")){
 f<-file.path(root,paste0("hexagon_",domain,".csv"))
 if(!file.exists(f))next
 d<-read.csv(f,check.names=FALSE,stringsAsFactors=FALSE)
 key<-domain
 if(!all(c(key,"variable","area_Mha","se_Mha")%in%names(d)))
   stop(paste("Domain output contract changed",domain))
 take<-subset(d,variable%in%unlist(lapply(names(periods),function(p)
   paste0(c("%FORLOSS ","%FORGAIN "),p))))
 if(!nrow(take))next
 take$period<-sub("^%FOR(LOSS|GAIN) ","",take$variable)
 take$change_type<-ifelse(grepl("^%FORLOSS",take$variable),"loss","gain")
 take$years<-unname(periods[take$period])
 take$annual_Mha<-take$area_Mha/take$years
 take$annual_se_Mha<-take$se_Mha/take$years
 take<-take[,c(key,"period","change_type","area_Mha","se_Mha","annual_Mha","annual_se_Mha")]
 emit(take,paste0("T07_T08_",domain,"_forest_change.csv"))
}
# Coverage 2024 can be released only after its statistical gate passes.
g<-file.path(root,"hexagon_Global.csv")
if(file.exists(g)&&flag("hexagon_uncertainty")=="PASS"){
 d<-read.csv(g,check.names=FALSE,stringsAsFactors=FALSE)
 coverage<-subset(d,variable%in%c("FOREST%24","OWL%24","OL%24","WATER%24"))
 if(nrow(coverage)==4)emit(coverage,"T01_global_land_use_2024.csv")
}
state<-data.frame(deliverable=c("T01","T02","T03","T04","T05","T06","T07","T08","T09","T10"),
 status=c(if(flag("hexagon_uncertainty")=="PASS")"CONDITIONAL" else "REVIEW",
   rep("BLOCKED",4),
   if(file.exists(file.path(dest,"T06_global_forest_change.csv")))"READY_FOR_REVIEW" else "BLOCKED",
   if(file.exists(file.path(dest,"T07_T08_Region_forest_change.csv")))"READY_FOR_REVIEW" else "BLOCKED",
   if(file.exists(file.path(dest,"T07_T08_Region_forest_change.csv")))"READY_FOR_REVIEW" else "BLOCKED",
   "BLOCKED","BLOCKED"),
 stringsAsFactors=FALSE)
emit(state,"editorial_status.csv")
cat("Created draft source tables privately in",dest,"\n")
