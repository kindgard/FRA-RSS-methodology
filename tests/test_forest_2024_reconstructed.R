source("R/forest_2024_reconstructed.R")
# All observations and population counts are invented.
obs <- data.frame(stratum=rep(c("A","B"),each=4),
                  forest_fraction=c(1,0.5,0.5,0, 0,0.25,0.5,0.25))
frame <- data.frame(stratum=c("A","B"),Nh=c(100,200))
r <- forest2024_from_samples(obs,frame)
# h=A mean=0.5, s2=1/6; h=B mean=0.25, s2=1/24
expected_p <- (100/300)*0.5 + (200/300)*0.25
expected_v <- (1/3)^2*(1/6)/4*(1-4/100) +
              (2/3)^2*(1/24)/4*(1-4/200)
stopifnot(isTRUE(all.equal(r$proportion,expected_p,tolerance=1e-12)),
          isTRUE(all.equal(r$variance,expected_v,tolerance=1e-12)),
          isTRUE(all.equal(sum(r$by_stratum$variance_contribution),r$variance)))
s <- r$by_stratum[,c("stratum","Nh","nh","mean","s2")]
r2 <- forest2024_from_strata(s)
stopifnot(isTRUE(all.equal(r$proportion,r2$proportion)),
          isTRUE(all.equal(r$se,r2$se)))
invalid <- obs; invalid$forest_fraction[1] <- 1.2
fails <- function(expr) inherits(try(suppressWarnings(expr),silent=TRUE),"try-error")
stopifnot(fails(forest2024_from_samples(invalid,frame)),
          fails(forest2024_from_samples(obs[obs$stratum=="A",],frame)))
cat("Reconstructed Forest 2024 synthetic tests: PASS\n")
