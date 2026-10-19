# Read-only BA_NC85 hexagon expansion. No internal data on public GitHub.
# Rscript scripts/run_hexagon_nc85.R INPUT.xlsx PRIVATE_OUTPUT_DIR
args <- commandArgs(trailingOnly=TRUE)
if(length(args)!=2L)stop("Usage: Rscript scripts/run_hexagon_nc85.R NC85.xlsx OUTPUT_DIR")
if(!requireNamespace("readxl",quietly=TRUE))stop("Install readxl locally")
input<-normalizePath(args[1],mustWork=TRUE)
output<-args[2]
if(!dir.exists(output))dir.create(output,recursive=TRUE)
sheets<-readxl::excel_sheets(input)
if(length(sheets)!=1L)stop("Expected definitive BA_NC85 single sheet; inspect input")
fields<-c("FOREST%24","OWL%24","OL%24","WATER%24")
periods<-c("2000-2010","2010-2018","2018-2024")
terms<-c("%FORLOSS ","%FORGAIN ","%STABFOR ","%StabNFor ")
vars<-c(fields,unlist(lapply(periods,function(p)paste0(terms,p)),use.names=FALSE))
required<-c("PL_PLOTID","SubRegGEZNstr","GEZ","Nstr0024","EFKm2",vars)
raw<-as.data.frame(readxl::read_excel(input,sheet=sheets[1],col_types="guess"))
if(!all(required%in%names(raw)))stop(paste("Missing:",paste(setdiff(required,names(raw)),collapse=", ")))
if(anyDuplicated(raw$PL_PLOTID))stop("Duplicate hexagons")
w<-raw$EFKm2
if(!is.numeric(w)||anyNA(w)||any(!is.finite(w)|w<=0))
  stop("Invalid EFKm2 weights")
out<-lapply(vars,function(v){
 y<-raw[[v]]
 if(!is.numeric(y)||any(!is.na(y)&(!is.finite(y)|y<0|y>1)))
   stop(paste("Invalid fractions",v))
 valid<-!is.na(y)
 data.frame(variable=v,estimate_Mha=sum(w[valid]*y[valid])/10000,
   valid_n=sum(valid),missing_n=sum(!valid),
   missing_expansion_km2=sum(w[!valid]))
})
out<-do.call(rbind,out)
write.csv(out,file.path(output,"hexagon_estimates_Mha.csv"),row.names=FALSE)
# Descriptive raw trajectory QA. Do not filter or edit flagged hexagons.
qa<-lapply(periods,function(p){
 x<-rowSums(raw[,paste0(terms,p),drop=FALSE])
 data.frame(period=p,closure_fail=sum(abs(x-1)>1e-6,na.rm=TRUE))
})
write.csv(do.call(rbind,qa),file.path(output,"transition_QA.csv"),row.names=FALSE)
message("PRIVATE NC85 point totals complete. SE/variance require design verification.")
