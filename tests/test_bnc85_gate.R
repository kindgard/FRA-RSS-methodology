source("R/bnc85_gate.R")
d <- data.frame(record_id=paste0("S",1:6),
 manual_resolved=c(FALSE,FALSE,FALSE,FALSE,TRUE,FALSE),
 remaining_inconsistency=c(TRUE,TRUE,TRUE,TRUE,TRUE,FALSE),
 quality=c(.9,.8,.9,.9,.9,.99),
 change_first_period=c(FALSE,FALSE,TRUE,FALSE,FALSE,FALSE),
 change_second_period=c(FALSE,FALSE,FALSE,TRUE,FALSE,FALSE))
a <- bnc85_gate(d)
stopifnot(identical(a$eligible,c(TRUE,FALSE,FALSE,FALSE,FALSE,FALSE)),
          a$reason[3]=="change_involved",a$reason[4]=="change_involved")
bad <- d; bad$change_first_period[1] <- NA
stopifnot(inherits(try(bnc85_gate(bad),silent=TRUE),"try-error"))
cat("BNC85 eligibility gate synthetic tests: PASS\n")
