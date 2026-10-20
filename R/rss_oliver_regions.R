rss_oliver_region_mapping <- function() {
 data.frame(Subregion=c("NAM","CAM","CAB","SAM","EUR","NAF","WAF",
  "EAF","WAS","EAS","SSA","OCE"),
 Region=c(rep("North and Central America",3),"South America",
  "Europe (including Russia)",rep("Africa",3),rep("Asia",3),"Oceania"),
 stringsAsFactors=FALSE)
}
