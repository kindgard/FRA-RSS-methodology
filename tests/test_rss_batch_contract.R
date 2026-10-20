# Synthetic static contract tests: never use a real RAW on GitHub Actions.
files<-c("scripts/run_rss_2025_batch.R","R/rss_oliver_regions.R")
for(f in files)stopifnot(length(parse(f))>0L)
source("R/rss_oliver_regions.R")
source("R/rss_oliver_report_domains.R")
m<-rss_oliver_region_mapping()
stopifnot(nrow(m)==12L,!anyDuplicated(m$Subregion),
 m$Region[m$Subregion=="SAM"]=="South America",
 m$Region[m$Subregion=="WAF"]=="Africa")
stopifnot(grepl('status("drivers","BLOCKED"',paste(readLines(files[1]),collapse=""),fixed=TRUE))
cat("RSS batch CLI and region mapping static synthetic: PASS\n")
