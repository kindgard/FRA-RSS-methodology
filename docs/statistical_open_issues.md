# FRA RSS statistical open issues — decision register

STATUS: working register; no official BA_NC85 results calculated. Data remain immutable.

## N1 — Gain/loss/net covariance (implemented as synthetic module)
For measurements g (gain) and l (loss) on the same sampled hexagon, net z=g-l.
Within each stratum, var(z)=var(g)+var(l)-2cov(g,l).
With weight Wh=Nh/N and finite population correction (1-nh/Nh), sum Wh^2/n_h times each respective within-stratum variance/covariance.
Use paired observations, not independent marginal variances. Public module: R/rss_joint_change.R.

## N2 — Hexagon changes without centroid changes
Hexagon proportions and centroid categorical interpretations use different observation supports. A transition observed within a hexagon need not cross its centroid. Such discordance is not automatically an error; it may be a spatial-support effect. Record joint cross-tabulation before attributing discordance to poor quality. Do not edit or discard such definitive BA_NC85 records.

## N3 — Calibration between centroid subclasses and hexagon totals
FRA 2020 section 9 describes a proportional reconciliation for centroid/IPCC subclass totals to hexagon-based total classes. A candidate formulation is calibrated subclass = original subclass estimate * (hexagon parent total / centroid parent total). Verify exact target level (global/domain, land use class, period), denominators and special cases against the official publication and R implementation.

## N4 — Variance of calibrated estimator
Calibration factor is estimated from the SAME probability sample. Treating the adjustment as fixed, or ignoring covariances among hexagon total, centroid subclass and centroid parent, will generally misstate precision. Options to investigate: full linearization (delta method with 3x3 design covariance), or design-consistent stratified resampling of paired hexagon-centroid observations with recalibration on EACH replication. No official calibration SE can be reported until formula and design are reconciled.

## N5 — Regional/subregional/GEZ domain inference
Reconcile draft domain sampling language with the global GEZ x stratum probability design and population frame. Verify fixed frame sizes and variance expression for domains; avoid substituting n_domain/N_domain as the initial global inclusion probability without justification.

## N6 — Temporal trajectories
About 3,600 apparently inconsistent hexagon trajectories remain in definitive BA_NC85 data. Audit separately from N2 spatial-support mismatch. Do not assume these two sets coincide. No classification changes or automatic exclusions.

## N7 — Net change and interval units
Separate area in km2/Mha, fractional proportions and annualized changes (period lengths 10, 8 and 6 years). For uncertainty of net change, do not add marginal confidence interval widths.

## N8 — Missing, degeneracy and zero denominators
Confirm missingness policy of reference script, n_h>=2 for variance, and ratio-calibration when centroid parent is zero. Do not replace NA by 0 without explicit method approval.

## Next validation
Add independent synthetic calibration covariance and stratified bootstrap tests. Private dataset and draft v24 reference outputs must never be uploaded to public CI.
