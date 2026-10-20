# Oliver Stoner RSS Country Estimator.R compatibility contract.
# Public metadata and synthetic-only tests; no institutional records.
oliver_hexagon_variables <- function() c(
  "FOREST%24","OWL%24","OL%24","WATER%24",
  unlist(lapply(c("2000-2010","2010-2018","2018-2024"),function(p)
    paste0(c("%FORGAIN ","%FORLOSS ","%STABFOR ","%StabNFor "),p)),
    use.names=FALSE)
)
oliver_required_raw_columns <- function() c(
  "Subreg","Country_n","GEZ","Nstr0024",oliver_hexagon_variables()
)
# weights: Oliver reads G2:I623 for SubRegGEZNstr, Nh, nh and A1:E3102
# for CountryGEZNstr, SubRegGEZNstr, Nh, nh and accompanying metadata.
oliver_validate_raw_schema <- function(columns,strict=TRUE) {
  missing <- setdiff(oliver_required_raw_columns(),columns)
  list(status=if(length(missing)==0L) "PASS" else "FAIL",
       required=oliver_required_raw_columns(),missing=missing,
       extra=setdiff(columns,oliver_required_raw_columns()),
       strict=strict)
}
oliver_validate_raw_data <- function(raw) {
  if(!is.data.frame(raw)) stop("raw must be a data.frame")
  schema <- oliver_validate_raw_schema(names(raw))
  if(schema$status!="PASS") stop(paste("Missing Oliver fields:",paste(schema$missing,collapse=", ")))
  vars <- oliver_hexagon_variables()
  errors <- vapply(vars,function(v) {
    x <- raw[[v]]
    if(!is.numeric(x)) return(paste("nonnumeric",v))
    if(any(!is.na(x) & (!is.finite(x)|x<0|x>1)))
      return(paste("out of [0,1]",v))
    ""
  },character(1))
  errors <- errors[nzchar(errors)]
  list(status=if(length(errors)) "FAIL" else "PASS",
       records=nrow(raw),variable_count=length(vars),
       variable_missing=vapply(raw[vars],function(x)sum(is.na(x)),integer(1)),
       errors=unname(errors))
}
oliver_validate_weights <- function(subregion_weights,country_weights) {
  a <- c("SubRegGEZNstr","Nh","nh")
  b <- c("CountryGEZNstr","SubRegGEZNstr","Nh","nh")
  if(!is.data.frame(subregion_weights)||!is.data.frame(country_weights)||
     !all(a %in% names(subregion_weights))||!all(b %in% names(country_weights)))
     stop("Required weights columns absent")
  if(anyDuplicated(subregion_weights$SubRegGEZNstr)||
     anyDuplicated(country_weights$CountryGEZNstr))
     stop("Duplicate weight keys")
  for(d in list(subregion_weights,country_weights)) {
    if(anyNA(d[,c("Nh","nh")])||any(d$Nh<0|d$nh<0|d$nh>d$Nh))
       stop("Invalid weight counts")
  }
  list(status="PASS",subregion_cells=nrow(subregion_weights),
       country_cells=nrow(country_weights))
}
