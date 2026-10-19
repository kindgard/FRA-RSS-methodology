source("R/rss_multivariable.R")
source("R/rss_joint_change.R")
source("R/rss_hexagon_area_transitions.R")
d <- data.frame(stratum=rep(c("A","B"),each=4),check.names=FALSE)
periods <- c("2000-2010","2010-2018","2018-2024")
for (p in periods) {
 d[[paste0("%FORGAIN ",p)]] <- c(.1,.2,0,.1,.1,.2,0,.1)
 d[[paste0("%FORLOSS ",p)]] <- c(.1,.2,0,.1,.1,.2,0,.1)
 d[[paste0("%STABFOR ",p)]] <- c(.4,.3,.5,.4,.4,.3,.5,.4)
 d[[paste0("%StabNFor ",p)]] <- c(.4,.3,.5,.4,.4,.3,.5,.4)
}
d[["FOREST%24"]] <- d[["%STABFOR 2018-2024"]]+d[["%FORGAIN 2018-2024"]]
d[["OWL%24"]] <- rep(.15,8)
d[["OL%24"]] <- rep(.20,8)
d[["WATER%24"]] <- rep(.05,8)
f <- data.frame(stratum=c("A","B"),Nh=c(100,200))
r <- rss_hexagon_area_transitions(d,f)
stopifnot(nrow(r$cover_2024)==4,nrow(r$transitions)==12,
 nrow(r$net)==3,
 all(r$closure$n_outside_tolerance==0),
 all(r$continuity$n_outside_tolerance==0),
 all(abs(r$net$net_Mha)<1e-10))
# Mutated timeline remains in full input and is flagged.
d[["FOREST%24"]][1] <- d[["FOREST%24"]][1]-.1
bad <- rss_hexagon_area_transitions(d,f)
stopifnot(bad$continuity$n_outside_tolerance[3]==1,
 nrow(d)==8)
cat("Hexagon 2024 and transitions synthetic tests: PASS\n")
