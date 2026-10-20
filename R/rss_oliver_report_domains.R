# Oliver RSS Analysis 2025 hexagon calculations: report-domain aggregation.
# No confidential data or derived official results belong in the public repository.
rss_oliver_domains <- function(by_cell, mappings=NULL) {
 required<-c("Subregion","GEZ","Nstr","variable","area_km2","area_variance_km4")
 if(!is.data.frame(by_cell)||!all(required%in%names(by_cell)))
   stop("Missing by-cell columns")
 if(anyNA(by_cell[,c("area_km2","area_variance_km4")]))
   stop("Undefined area or variance in at least one cell: resolve missingness")
 if(anyDuplicated(by_cell[,c("Subregion","GEZ","Nstr","variable")]))
   stop("Duplicate cell/variable")
 d<-by_cell
 if(!is.null(mappings)){
   if(!all(c("Subregion","Region")%in%names(mappings)))
     stop("Mappings must contain Subregion and Region")
   if(anyDuplicated(mappings$Subregion))stop("Duplicate Subregion mappings")
   d$Region<-mappings$Region[match(d$Subregion,mappings$Subregion)]
   if(anyNA(d$Region))stop("Unmapped Subregion")
 }
 domains<-list(Global=character(),GEZ="GEZ",Subregion="Subregion")
 if("Region"%in%names(d))domains$Region<-"Region"
 domains[["Subregion_GE Z"]]<-c("Subregion","GEZ")
 names(domains)[length(domains)]<-"Subregion_GEZ"
 results<-lapply(names(domains),function(lev){
   g<-domains[[lev]]
   grouping<-if(length(g))interaction(d[,g,drop=FALSE],drop=TRUE,lex.order=TRUE)
     else factor(rep("Global",nrow(d)))
   ids<-split(seq_len(nrow(d)),interaction(grouping,d$variable,drop=TRUE),drop=TRUE)
   do.call(rbind,lapply(ids,function(ix){
     x<-d[ix,,drop=FALSE]
     A<-sum(x$area_km2); V<-sum(x$area_variance_km4)
     ans<-data.frame(level=lev,variable=x$variable[1],
       area_Mha=A/1e4,se_Mha=sqrt(V)/1e4,variance_Mha2=V/1e8,
       ci95_low_Mha=(A-1.96*sqrt(V))/1e4,
       ci95_high_Mha=(A+1.96*sqrt(V))/1e4)
     if(length(g))for(v in g)ans[[v]]<-as.character(x[[v]][1])
     ans
   }))
 })
 names(results)<-names(domains)
 results
}
rss_oliver_annual_change <- function(global_results) {
 if(!all(c("variable","area_Mha","se_Mha")%in%names(global_results)))
   stop("Invalid global result schema")
 periods<-c("2000-2010"=10,"2010-2018"=8,"2018-2024"=6)
 do.call(rbind,lapply(names(periods),function(p){
   take<-function(pre)global_results[global_results$variable==paste0(pre,p),,drop=FALSE]
   loss<-take("%FORLOSS ");gain<-take("%FORGAIN ")
   if(nrow(loss)!=1||nrow(gain)!=1)stop(paste("Missing change component",p))
   # Reference notebook does not produce the covariance of net gain-loss.
   # Do NOT add individual variances and label the result as net SE.
   data.frame(period=p,years=unname(periods[[p]]),
      loss_Mha=loss$area_Mha,gain_Mha=gain$area_Mha,
      net_Mha=gain$area_Mha-loss$area_Mha,
      annual_loss_Mha=loss$area_Mha/periods[[p]],
      annual_gain_Mha=gain$area_Mha/periods[[p]],
      annual_net_Mha=(gain$area_Mha-loss$area_Mha)/periods[[p]],
      se_loss_Mha=loss$se_Mha,se_gain_Mha=gain$se_Mha)
 }))
}
