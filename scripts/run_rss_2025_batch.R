#!/usr/bin/env Rscript
# FRA RSS read-only private batch: all calculations run from one in-memory RAW.
# Never run this script in public CI with institutional data.
args <- commandArgs(trailingOnly=TRUE)
if(length(args)!=2L)stop("Usage: Rscript scripts/run_rss_2025_batch.R RAW.xlsx PRIVATE_OUTPUT_DIRECTORY")
input<-normalizePath(args[1],mustWork=TRUE)
out<-normalizePath(args[2],mustWork=FALSE)
if(normalizePath(dirname(input),mustWork=TRUE)==normalizePath(out,mustWork=FALSE))
  stop("Output cannot be the input's containing directory")
if(!requireNamespace("readxl",quietly=TRUE))stop("Install readxl in private R runtime")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
if(length(list.files(out,all.files=TRUE,no..=TRUE)))stop("Output directory must be EMPTY")
source("R/rss_oliver_hexagon.R")
source("R/rss_oliver_report_domains.R")
source("R/rss_oliver_regions.R")
source("R/rss_oliver_centroid.R")
source("R/rss_oliver_category_mapping.R")
source("R/rss_oliver_category_audit.R")
source("R/rss_oliver_calibration.R")
source("R/rss_oliver_calibration_closure.R")
source("R/rss_oliver_drivers_pastoral.R")
source("R/rss_thematic_qa.R")
source("R/rss_oliver_thematic_batch.R")
save_csv<-function(x,name)utils::write.csv(x,file.path(out,name),row.names=FALSE,na="")
statuses<-data.frame(module=character(),status=character(),reason=character())
status<-function(module,state,reason=""){
 statuses<<-rbind(statuses,data.frame(module=module,status=state,reason=reason))
}
finish<-function(){save_csv(statuses,"module_status.csv")}
on.exit(finish(),add=TRUE)
sheets<-readxl::excel_sheets(input)
if(length(sheets)!=1L)stop("Expected single-sheet NC85-style RAW; no implicit v23 weight-sheet substitution")
raw<-as.data.frame(readxl::read_excel(input,sheet=sheets[[1]],.name_repair="minimal"))
if(anyDuplicated(names(raw)))stop("Duplicate input column names")
required<-c("PL_PLOTID","Subreg","GEZ","Nstr0024","EFKm2")
periods<-c("2000-2010","2010-2018","2018-2024")
cover<-c("FOREST%24","OWL%24","OL%24","WATER%24")
change<-unlist(lapply(periods,function(p)paste0(c("%FORGAIN ","%FORLOSS ","%STABFOR ","%StabNFor "),p)),use.names=FALSE)
required<-c(required,cover,change)
if(!all(required%in%names(raw)))stop(paste("Missing RAW columns:",paste(setdiff(required,names(raw)),collapse=", ")))
if(anyDuplicated(raw$PL_PLOTID))stop("Duplicate plot IDs")
if(anyNA(raw[,c("Subreg","GEZ","Nstr0024","EFKm2")]))stop("Missing stratum identifiers or weights")
if(!is.numeric(raw$EFKm2)||any(!is.finite(raw$EFKm2)|raw$EFKm2<=0))stop("Invalid EFKm2")
manifest<-data.frame(input_filename=basename(input),sha256=unname(tools::md5sum(input)),
  records=nrow(raw),columns=ncol(raw),sheet=sheets[[1]],
  r_version=as.character(getRversion()),stringsAsFactors=FALSE)
names(manifest)[2]<-"md5"
save_csv(manifest,"input_manifest.csv")
missing<-data.frame(variable=c(cover,change),
 n_missing=vapply(c(cover,change),function(v)sum(is.na(raw[[v]])),integer(1)))
save_csv(missing,"input_missingness.csv")
status("input","PASS","Single-read, immutable RAW validated")
# Original Oliver formula: mean(...,na.rm=TRUE); var(...)/n, no FPC.
hex<-rss_oliver_hexagon(raw,c(cover,change))
save_csv(hex$by_cell,"hexagon_by_stratum.csv")
save_csv(hex$global,"hexagon_global_unfiltered.csv")
# Keep point areas for variables with missing variances, but refuse to publish SE as zero.
if(anyNA(hex$by_cell$area_variance_km4)){
 status("hexagon_uncertainty","REVIEW","Undefined variance in cells with missing fractions; do not zero-fill")
 valid_variables<-setdiff(unique(hex$by_cell$variable),
   unique(hex$by_cell$variable[is.na(hex$by_cell$area_variance_km4)|is.na(hex$by_cell$area_km2)]))
} else {
 status("hexagon_uncertainty","PASS","Original Oliver variance / n and singleton zero")
 valid_variables<-unique(hex$by_cell$variable)
}
domain<-rss_oliver_domains(hex$by_cell[hex$by_cell$variable%in%valid_variables,,drop=FALSE],rss_oliver_region_mapping())
for(n in names(domain))save_csv(domain[[n]],paste0("hexagon_",n,".csv"))
status("hexagon_domains","PASS","Output excludes variables with undefined variance")
if(all(c(paste0("%FORLOSS ",periods),paste0("%FORGAIN ",periods))%in%domain$Global$variable)){
 annual<-rss_oliver_annual_change(domain$Global)
 save_csv(annual,"forest_change_annual.csv")
 status("change_annual","PASS","Gain/loss rates; net SE is not inferred")
}else status("change_annual","REVIEW","Missing/undefined change components")
# IPCC24 level 2 / 3 calibrated areas; requires full closure audit.
if(!"IPCC24"%in%names(raw)){
 status("ipcc_subclasses","BLOCKED","IPCC24 absent")
}else{
 audit<-rss_oliver_category_audit(raw,"IPCC24")
 save_csv(audit$categories,"ipcc_category_audit.csv")
 if(audit$unknown_n>0||audit$missing>0) {
  status("ipcc_subclasses","REVIEW",paste("Unknown",audit$unknown_n,"missing",audit$missing,"— no silent imputation"))
 } else if(!all(cover%in%valid_variables)){
  status("ipcc_subclasses","BLOCKED","Coverage-2024 reference variances undefined; calibration deferred")
 } else {
  # Reference centroid indicators and subclass indicators share the SAME sampled hexagons.
  map<-rss_oliver_subclass_mapping()
  classes<-rss_oliver_map_ipcc(raw$IPCC24)
  prepared<-raw[,c("Subreg","GEZ","Nstr0024","EFKm2"),drop=FALSE]
  for(v in cover)prepared[[v]]<-as.numeric(classes$level_1_subclass==v)
  for(i in seq_len(nrow(map)))prepared[[paste0("L3__",i)]]<-as.numeric(classes$level_3_subclass==map$level_3_subclass[i])
  refs<-rss_oliver_hexagon(prepared,cover)$by_cell
  l3vars<-paste0("L3__",seq_len(nrow(map)))
  cent<-rss_oliver_hexagon(prepared,l3vars)$by_cell
  pm<-data.frame(variable=l3vars,parent=map$level_1_subclass)
  cal<-rss_oliver_calibrate(cent,hex$by_cell[hex$by_cell$variable%in%cover,],
    pm,centroid_reference_cells=refs,variance_method="original_unscaled")
  closure<-rss_oliver_calibration_closure(cal,hex$by_cell[hex$by_cell$variable%in%cover,],pm)
  save_csv(closure,"calibration_l3_closure.csv")
  save_csv(cal,"calibration_l3_by_stratum.csv")
  save_csv(data.frame(variable=l3vars,label=map$level_3_subclass,
     parent=map$level_1_subclass),"calibration_l3_dictionary.csv")
  if(all(closure$pass)) {
    cal_domains<-rss_oliver_domains(cal,rss_oliver_region_mapping())
    for(n in names(cal_domains))save_csv(cal_domains[[n]],paste0("calibrated_l3_",n,".csv"))
    status("ipcc_subclasses","PASS","L3 area calibration and closure; Oliver unscaled variances")
  }else status("ipcc_subclasses","REVIEW","Nonclosing strata retained in diagnostics, not promoted")
 }
}
rss_oliver_run_thematic(raw,hex,save_csv,status)
status("full_notebook_equivalence","BLOCKED","No complete original-notebook equivalence test yet")
finish()
cat("Batch finished. Private outputs:",out,"\n")
