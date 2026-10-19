# Oliver Stoner country RSS estimator — reconstruction scope

Primary source inspected privately: `RSS Country Estimator.R`, author Oliver Stoner, FAO. The public repository carries **newly written generic compatibility code**, not the institutional script or dataset.

## Original v23 workbook
`GLUE2024_template_FRARSS_v1_RawData_v23_Drivers_09052026_recalculated.xlsx`

- Sheet `RawData`: one row per sampled hexagon; original script renames `Subreg` -> `Subregion`, `Country_n` -> `Country`, `Nstr0024` -> `Nstr`.
- Sheet `weights`: subregional population/sample weights in `G2:I623` and country cells in `A1:E3102`, as read by original script. Do not silently assume those fixed Excel ranges suit a later workbook.
- Expansion weights `Nh/nh` by Subregion × GEZ × Nstr; implied hexagon area in original script `0.3962 km2`.
- Sixteen primary variables: four 2024 areas (`FOREST%24`, `OWL%24`, `OL%24`, `WATER%24`), and four transitions per period for 2000–2010, 2010–2018 and 2018–2024.

## Original estimator methods
`rss_estimator_hexagons()` reports proportions by country × GEZ × Nstr and by country. Country-cell point estimates: direct sample mean (`country_perc`), `perc_1` fallback to subregional then stratum mean, `perc_2` fallback to beta-binomial prediction, `perc_3` weighted blend of direct mean and prediction with `Nsamp/(Nsamp+10)`, `perc_4` prediction only. `correct_area` changes denominator handling for missing country cells. Beta-binomial model via `glmmTMB` using grouped `response=sum(round(10 * coverage))`, `n=10*sample count` and random effects of GEZ:Nstr, Subregion:GEZ:Nstr, and Country.

`rss_estimator_hexagons_bootstrap()` resamples with replacement *within Subregion × GEZ × Nstr*, recomputes country and country-cell estimates and reports bootstrap variance and quantile intervals. Original prototype uses 10 replicates; this is not by itself enough to treat Monte Carlo variance as a production-standard confidence interval.

Separate sections implement missing-country-cell imputation experiments. These are **estimation of geographic empty cells** and unrelated to prior upstream BA_NC85 editing or trajectory inconsistency decisions.

## Current verified state
The public repository now has a 16-variable schema contract and a separate Forest 2024 global design-based estimator. It does **not yet contain a port of Oliver's beta-binomial modeling, fallback point estimates, bootstrap, or experiments**. These require careful implementation and synthetic numerical regression tests.

## BA_NC85 definitive source
`merged_v24_DBfinal_v14_delGLUE__corrected_BA_NC85_2026-10-17.xlsx` is the immutable definitive input. The earlier v23 workbook is a schema/methodological reference, **not** an authoritative estimate for this new database. An identical *intended* RAW schema is not proof that all values, types and weight tabs match. Exact column-by-column match and weight provenance still require accessing the definitive workbook. Approximately 3600 trajectory-inconsistent hexagons remain in it; do not filter, select, or correct them in the estimator.
