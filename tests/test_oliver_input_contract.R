source("R/oliver_input_contract.R")
vars <- oliver_hexagon_variables()
stopifnot(length(vars)==16L,
          vars[1]=="FOREST%24",
          vars[16]=="%StabNFor 2018-2024")
d <- data.frame(Subreg=c("SAM","SAM"),Country_n=c("ARG","ARG"),
                GEZ=c(11,11),Nstr0024=c(1,1),check.names=FALSE)
for (v in vars) d[[v]] <- c(0,0.5)
stopifnot(oliver_validate_raw_data(d)$status=="PASS")
bad <- d;bad[[vars[1]]][1] <- 50
stopifnot(oliver_validate_raw_data(bad)$status=="FAIL")
no_col <- d;no_col[[vars[1]]] <- NULL
stopifnot(oliver_validate_raw_schema(names(no_col))$status=="FAIL")
sw <- data.frame(SubRegGEZNstr="SAM111",Nh=100,nh=2)
cw <- data.frame(CountryGEZNstr="ARG111",SubRegGEZNstr="SAM111",Nh=20,nh=2)
stopifnot(oliver_validate_weights(sw,cw)$status=="PASS")
cat("Oliver input contract synthetic tests: PASS\n")
