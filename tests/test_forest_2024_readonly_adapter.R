source("R/forest_2024_reconstructed.R")
source("R/forest_2024_readonly_adapter.R")
d <- data.frame(S=c("A","A","A","B","B","B"),
                Y=c(0.2,0.5,0.8,0.1,NA,0.9),
                trajectory_warning=c(FALSE,TRUE,FALSE,TRUE,TRUE,FALSE))
fr <- data.frame(stratum=c("A","B"),Nh=c(20,30))
original <- d
x <- forest2024_readonly_adapter(d,list(stratum="S",forest_fraction="Y"),fr,
                                 expected_rows=6)
stopifnot(identical(d,original),x$full_n==6L,x$missing_n==1L,
          x$integrity$n_records[2]==3L,x$integrity$n_valid[2]==2L,
          x$integrity$n_missing[2]==1L,
          identical(x$observations$forest_fraction,d$Y))
r <- forest2024_candidate_complete_case(x,fr)
stopifnot(isTRUE(all.equal(r$proportion,0.5)))
# Trajectory warning is intentionally ignored: no silent filtering.
d2 <- d; d2$Y[1] <- 75
stopifnot(inherits(try(forest2024_readonly_adapter(d2,
 list(stratum="S",forest_fraction="Y"),fr),silent=TRUE),"try-error"))
cat("Readonly definitive-dataset adapter tests: PASS\n")
