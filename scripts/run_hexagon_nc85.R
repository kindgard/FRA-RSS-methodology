# Private-runtime runner, code is public; never upload workbook or results to GitHub.
# Usage: Rscript scripts/run_hexagon_nc85.R /private/NC85.xlsx /private/output
args <- commandArgs(trailingOnly=TRUE)
if(length(args)!=2L)stop("Usage: Rscript scripts/run_hexagon_nc85.R INPUT_XLSX OUTPUT_DIR")
if(!requireNamespace("readxl",quietly=TRUE))
  stop("Install R package readxl in your PRIVATE runtime")
input <- normalizePath(args[1],mustWork=TRUE)
out <- args[2]
if(!dir.exists(out))dir.create(out,recursive=TRUE)
source("R/rss_multivariable.R")
source("R/rss_joint_change.R")
source("R/rss_hexagon_area_transitions.R")
sheets <- readxl::excel_sheets(input)
if(!all(c("RawData","weights") %in% sheets))
  stop("Expected Oliver RawData and weights sheets; inspect format first")
# READ ONLY. The original Oliver weight tables are fixed-range; verify headers
# because BA_NC85 may not have the same sheet layout.
raw <- as.data.frame(readxl::read_excel(input,sheet="RawData"))
w <- as.data.frame(readxl::read_excel(input,sheet="weights",range="G2:I623"))
required <- c("SubRegGEZNstr","Nh","nh")
if(!all(required %in% names(w)))stop("Subregional weights header mismatch")
if(!all(c("GEZ","Nstr0024","Subreg") %in% names(raw)))
  stop("RawData stratum fields mismatch")
if(anyNA(raw[,c("GEZ","Nstr0024","Subreg")]))stop("Missing RAW keys")
if(anyDuplicated(w$SubRegGEZNstr))stop("Duplicated population-weight keys")
if(anyNA(w[,required]))stop("Missing weight fields")
raw$stratum <- paste0(raw$Subreg,sprintf("%02d",as.integer(raw$GEZ)),
                     as.integer(raw$Nstr0024))
frame <- data.frame(stratum=as.character(w$SubRegGEZNstr),Nh=as.numeric(w$Nh))
if(!setequal(unique(raw$stratum),frame$stratum))
  stop("RAW strata do not match weight frame; refuse silent reweighting")
if(any(table(raw$stratum)>frame$Nh[match(names(table(raw$stratum)),frame$stratum)]))
  stop("Sample count exceeds population")
result <- rss_hexagon_area_transitions(raw,frame)
for(name in c("cover_2024","transitions","net","closure","continuity")) {
  write.csv(result[[name]],file.path(out,paste0(name,".csv")),row.names=FALSE)
}
cat("Finished read-only hexagon estimation; outputs saved PRIVATELY at:",out,"\n")
