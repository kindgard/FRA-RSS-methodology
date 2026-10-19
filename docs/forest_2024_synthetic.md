# Forest 2024 — synthetic prototype (not official FRA RSS output)

## Scope and confidentiality
Only hand-crafted synthetic observations are used here. Never commit the selected institutional workbook, row-level records, credentials, or institutional output to this public repository. Repository CI is for public synthetic fixtures only.

## Mathematical definition
For stratum h with known area A_h, n_h independent SRS observations y_hi in {0,1}, and optional finite population size N_h:

- Estimated forest area: sum_h A_h * mean(y_h)
- Estimated variance: sum_h A_h^2 * (1 - n_h/N_h) * s_h^2/n_h
- If N_h is not supplied, the finite population correction is set to one.
- Normal 95% interval: estimate +/- 1.959964 * SE (unbounded diagnostic interval).

## Important limitations
The real RSS design may use hexagon/plot aggregation, explicit strata and weights, finite population factors, geographic domains, clustered observations, and specific variance estimators. This function does NOT claim to implement those yet. Binary forest definitions and the exact source columns are not inferred from the institutional workbook. Do not use these outputs for institutional reporting.

## Validation gates
1. Synthetic examples reproduce hand-calculated area and variance.
2. Row-level classifications are limited to 0/1; missing strata and insufficient observations stop execution.
3. A census in each synthetic stratum produces zero sampling variance.
4. Official method, unit of observation, weighting, domain handling, and forest classification must be approved before adapting to actual data.
5. Private execution and audit logs must not be uploaded as public GitHub Actions artifacts.
