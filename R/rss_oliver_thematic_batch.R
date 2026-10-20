# Run driver and pastoral calculations within the single-read private batch.
# All tables are diagnostic until matched to authoritative Oliver outputs.
rss_oliver_run_thematic <- function(raw,hex,save_csv,status) {
 key<-c("Subreg","GEZ","Nstr0024","EFKm2")
 cover<-c("FOREST%24","OWL%24","OL%24","WATER%24")
 periods<-c("2000-2010","2010-2018","2018-2024")
 drivers<-c("Driver0010","Driver1018","Driver1824")
 changes<-c("CHANGE0010","CHANGE1018","CHANGE1824")
 if(!all(c(key,drivers,changes)%in%names(raw))){
  status("drivers","BLOCKED",paste("Missing",paste(setdiff(c(drivers,changes),names(raw)),collapse=", ")))
 } else {
  dp<-rss_oliver_multicategory(raw,drivers,"Not applicable (driver)","DRV")
  prep<-raw[,key,drop=FALSE]
  dict<-list()
  references<-raw[,key,drop=FALSE]
  for(i in seq_along(periods)) {
    part<-dp$parts[[i]]
    prep<-cbind(prep,part$indicators)
    dictionary<-part$dictionary
    dictionary$period<-periods[i]
    dictionary$parent<-rss_oliver_driver_mapping(dictionary,rep(periods[i],nrow(dictionary)))$parent
    dict[[i]]<-dictionary
    x<-as.character(raw[[changes[i]]])
    references[[paste0("%FORLOSS ",periods[i])]]<-as.numeric(x=="Forest Loss")
    references[[paste0("%FORGAIN ",periods[i])]]<-as.numeric(x%in%c("Forest gain","Forest Gain"))
    references[[paste0("%StabNFor ",periods[i])]]<-as.numeric(x=="Stable Non Forest")
  }
  dic<-do.call(rbind,dict)
  save_csv(dic,"drivers_dictionary.csv")
  unknown<-unique(unlist(lapply(seq_along(periods),function(i) {
    x<-as.character(raw[[changes[i]]])
    unique(x[!is.na(x)&!x%in%c("Forest Loss","Forest gain","Forest Gain",
      "Stable Non Forest","Stable Forest")])
  })))
  if(length(unknown)){
   status("drivers","REVIEW",paste("Unexpected CHANGE labels",paste(unknown,collapse="; ")))
  }else{
   vals<-unique(dic$variable)
   base<-unique(dic$parent)
   derived<-rss_oliver_hexagon(prep,vals)$by_cell
   refc<-rss_oliver_hexagon(references,base)$by_cell
   target<-hex$by_cell[hex$by_cell$variable%in%base,,drop=FALSE]
   if(anyNA(target$area_km2)|anyNA(target$area_variance_km4)){
    status("drivers","REVIEW","Target hexagon change variables have NA; no calibration")
   } else {
    cal<-rss_oliver_calibrate(derived,target,
      dic[,c("variable","parent")],centroid_reference_cells=refc)
    save_csv(cal,"drivers_calibrated_by_stratum.csv")
    # Not-applicable categories have arbitrary parents; exclude from public/report outputs.
    cal<-cal[!grepl("^Not applicable",dic$label[match(cal$variable,dic$variable)]),,drop=FALSE]
    if(anyNA(cal$area_km2)|anyNA(cal$area_variance_km4)){
      status("drivers","REVIEW","Missing calibrated values or variances")
    } else {
      domains<-rss_oliver_domains(cal,rss_oliver_region_mapping())
      for(n in names(domains))save_csv(domains[[n]],paste0("drivers_",n,".csv"))
      status("drivers","READY_FOR_REVIEW","Oliver style indicators and stratum calibration; driver closure not assumed")
    }
   }
  }
 }
 if(!"Ranch_Pastoralism"%in%names(raw)){
   status("pastoralism","BLOCKED","Missing Ranch_Pastoralism")
 } else if(!"LU24CEN"%in%names(raw)){
   status("pastoralism","BLOCKED","Missing LU24CEN reference")
 } else {
   p<-rss_oliver_onehot(raw,"Ranch_Pastoralism","PAST__",
                        "Not applicable (ranch and pastoralism)")
   dict<-p$dictionary
   dict$parent<-rss_oliver_pastoral_parent(dict$label)
   save_csv(dict,"pastoralism_dictionary.csv")
   d<-cbind(raw[,key,drop=FALSE],p$indicators)
   reference<-raw[,key,drop=FALSE]
   luc<-as.character(raw$LU24CEN)
   lut<-c("Forest","Other Wooded Land","Other Land","Water")
   for(i in seq_along(cover))reference[[cover[i]]]<-as.numeric(luc==lut[i])
   unknown<-unique(luc[!is.na(luc)&!luc%in%lut])
   target<-hex$by_cell[hex$by_cell$variable%in%cover,,drop=FALSE]
   if(length(unknown)){
     status("pastoralism","REVIEW",paste("Unknown LU24CEN categories",paste(unknown,collapse="; ")))
   } else if(anyNA(target$area_km2)|anyNA(target$area_variance_km4)){
     status("pastoralism","REVIEW","2024 coverage variance undefined; retain pastoral category audit only")
   } else {
     cells<-rss_oliver_hexagon(d,dict$variable)$by_cell
     refs<-rss_oliver_hexagon(reference,cover)$by_cell
     cal<-rss_oliver_calibrate(cells,target,dict[,c("variable","parent")],
       centroid_reference_cells=refs)
     save_csv(cal,"pastoralism_calibrated_by_stratum.csv")
     cal<-cal[!grepl("^Not applicable",dict$label[match(cal$variable,dict$variable)]),,drop=FALSE]
     domains<-rss_oliver_domains(cal,rss_oliver_region_mapping())
     for(n in names(domains))save_csv(domains[[n]],paste0("pastoralism_",n,".csv"))
     status("pastoralism","READY_FOR_REVIEW","Calibrated 2024 category areas; pastoral subset interpretation requires review")
   }
 }
}
