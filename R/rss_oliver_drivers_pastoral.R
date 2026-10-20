# Exact Oliver-style expansion of multicategory variables on a single RAW.
# Never alter RAW; all category substitutions are confined to indicator matrix.
rss_oliver_onehot <- function(raw,field,prefix,missing_label,levels=NULL) {
 if(!field%in%names(raw))stop(paste("Missing",field))
 x<-as.character(raw[[field]])
 x[is.na(x)|x==""|x=="NA"]<-missing_label
 if(is.null(levels))levels<-sort(unique(x))
 unknown<-setdiff(unique(x),levels)
 if(length(unknown))stop(paste("Unknown",field,paste(unknown,collapse="; ")))
 z<-matrix(as.numeric(rep(0,length(x)*length(levels))),nrow=length(x))
 for(i in seq_along(levels))z[,i]<-as.numeric(x==levels[i])
 colnames(z)<-paste0(prefix,seq_along(levels))
 list(indicators=as.data.frame(z),dictionary=data.frame(variable=colnames(z),
   label=levels,source=field,stringsAsFactors=FALSE))
}
rss_oliver_multicategory <- function(raw,fields,missing_label,prefix,
                                    level_set=NULL) {
 if(!all(fields%in%names(raw)))stop("Missing categorical RAW columns")
 all_levels<-if(is.null(level_set))sort(unique(unlist(lapply(fields,function(f) {
  x<-as.character(raw[[f]])
  x[is.na(x)|x==""|x=="NA"]<-missing_label
  x
 })))) else level_set
 res<-lapply(seq_along(fields),function(i){
  rss_oliver_onehot(raw,fields[i],paste0(prefix,i,"__"),
                    missing_label,all_levels)
 })
 list(parts=res,levels=all_levels)
}
rss_oliver_driver_mapping <- function(dictionary,periods) {
 if(nrow(dictionary)!=length(periods))stop("Driver dictionary period mismatch")
 variable<-dictionary$variable
 original<-dictionary$label
 parent<-ifelse(grepl("^Loss_",original),"%FORLOSS ",
   ifelse(grepl("^Gain_",original),"%FORGAIN ",
   ifelse(original=="Not applicable (driver)","%StabNFor ",NA_character_)))
 if(anyNA(parent))stop("Driver category lacks Loss_/Gain_ prefix; review RAW")
 data.frame(variable=variable,label=original,
   period=periods,parent=paste0(parent,periods),stringsAsFactors=FALSE)
}
rss_oliver_pastoral_parent <- function(labels) {
 v<-paste0("ranch_pasto_",labels)
 # Mapping matches Oliver's ranch_pasto_mapping, including NA as arbitrary forest parent.
 ifelse(grepl("Forest_",v)|grepl("Mangroves",v),"FOREST%24",
  ifelse(grepl("Other_wooded_",v),"OWL%24",
   ifelse(grepl("water|ice",v,ignore.case=TRUE),"WATER%24",
    ifelse(grepl("Not applicable",v),"FOREST%24","OL%24"))))
}
