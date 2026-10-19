# Hexagon area and forest transition report, synthetic/public engine.
# Source data are immutable. Four transition fractions per period; no subclasse calibration.
rss_hexagon_area_transitions <- function(raw, frame, area_km2=0.3962,
                                         tol=1e-8) {
  if (!exists("rss_multivariable",mode="function") ||
      !exists("rss_joint_change",mode="function"))
    stop("Source rss_multivariable.R and rss_joint_change.R")
  periods <- c("2000-2010","2010-2018","2018-2024")
  cover <- c("FOREST%24","OWL%24","OL%24","WATER%24")
  suffix <- c("%FORGAIN ","%FORLOSS ","%STABFOR ","%StabNFor ")
  change <- unlist(lapply(periods,function(p)paste0(suffix,p)))
  fields <- c(cover,change)
  if (!all(fields %in% names(raw))) stop("Required hexagon indicators missing")
  # Never silently convert 0..100 or discard inconsistent hexagons.
  cover_est <- rss_multivariable(raw,frame,cover,area_km2=area_km2)
  change_est <- rss_multivariable(raw,frame,change,area_km2=area_km2)
  checks <- list()
  net <- lapply(periods,function(p) {
    g <- paste0("%FORGAIN ",p); l <- paste0("%FORLOSS ",p)
    r <- rss_joint_change(raw,frame,g,l,hexagon_area_km2=area_km2)
    total_km2 <- sum(frame$Nh)*area_km2
    years <- switch(p,"2000-2010"=10,"2010-2018"=8,"2018-2024"=6)
    data.frame(period=p,years=years,loss_Mha=-r$area_km2["loss"]/1e4,
       gain_Mha=r$area_km2["gain"]/1e4,net_Mha=r$area_km2["net"]/1e4,
       se_net_Mha=r$se_area_km2["net"]/1e4,
       annual_net_Mha=(r$area_km2["net"]/1e4)/years,
       annual_loss_Mha=r$area_km2["loss"]/1e4/years,
       annual_gain_Mha=r$area_km2["gain"]/1e4/years,
       covariance_proportion=r$covariance_gain_loss)
  })
  # For each period: gain + loss + stable forest + stable nonforest == 1?
  # Not mandatory; quantify deviations, retain all rows.
  closure <- lapply(periods,function(p){
    names4 <- paste0(suffix,p)
    x <- rowSums(raw[,names4,drop=FALSE])
    data.frame(period=p,n=nrow(raw),
       n_outside_tolerance=sum(abs(x-1)>tol),
       max_abs_deviation=max(abs(x-1)),
       mean_sum=mean(x))
  })
  # End/start forest fraction implied by the transition variables.
  endpoint <- lapply(periods,function(p){
    g <- raw[[paste0("%FORGAIN ",p)]]
    l <- raw[[paste0("%FORLOSS ",p)]]
    stable <- raw[[paste0("%STABFOR ",p)]]
    list(start=stable+l,end=stable+g)
  })
  continuity <- data.frame(
    interface=c("2010","2018","2024"),
    n_outside_tolerance=integer(3),max_abs_deviation=numeric(3))
  for(i in seq_len(3)){
    earlier <- if(i<3) endpoint[[i]]$end else endpoint[[3]]$end
    later <- if(i<3) endpoint[[i+1]]$start else raw[["FOREST%24"]]
    delta <- earlier-later
    continuity$n_outside_tolerance[i] <- sum(abs(delta)>tol)
    continuity$max_abs_deviation[i] <- max(abs(delta))
  }
  # All diagnostics are descriptive; do not filter these cases.
  list(cover_2024=cover_est,transitions=change_est,
       net=do.call(rbind,net),closure=do.call(rbind,closure),
       continuity=continuity,
       status="SYNTHETIC_ENGINE_NOT_FINAL_BA_NC85")
}
