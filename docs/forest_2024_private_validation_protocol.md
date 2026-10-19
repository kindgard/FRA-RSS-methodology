# Private Forest 2024 validation protocol — definitive BNC85 input

The public repository is restricted to generic code and synthetic data. Do NOT upload the institutional workbook, its observations, historical result workbook, or output summaries to this repo or public Actions artifacts.

## Fixed authoritative input
`merged_v24_DBfinal_v14_delGLUE__corrected_BA_NC85_2026-10-17.xlsx`

The dataset has already undergone v24 improvements, manual correction, and BNC85 handling. Approximately 3,600 hexagons still have trajectory inconsistencies (unverified); keep them in the input. Never apply an additional BNC85 filter or rewrite classifications.

## Order of private verification
1. Record SHA-256 checksum, sheet names, exact row/column counts and headers of the definitive XLSX. Verify uniqueness of the original hexagon/sample identifiers. Do not assume a one-row-per-hexagon schema without inspection.
2. Map the explicit forest-2024 column and stratification key to generic `stratum` and `forest_fraction`, confirming value scales (0–1 versus 0–100) and units. Do not silently divide by 100.
3. Load the authoritative `Nh` population frame with its documented source and verify 20 GEZ × 5 stratum coverage (or document deviations).
4. Independently tabulate records and missing forest values by stratum; do not discard flags of trajectory inconsistencies. Distinguish missing values from diagnosed trajectory inconsistencies.
5. Establish missing-value policy from original R estimator. Apply no complete-case policy to a final institutional estimate until confirmed.
6. Compute the global weighted proportion, FPC variance, standard error and 95% interval using `forest2024_from_samples` only after policy confirmation.
7. Compare the per-stratum means, sample SDs, n_h, Nh, weights, estimated contributions and variance contributions to the official R output. Record numerical tolerances and differences.
8. Capture private machine-readable QA log: input checksum, R version, code commit, mapping, counts, warnings, differences and verdict; keep the log in approved private storage.

## Important
`forest2024_candidate_complete_case()` is explicitly a **candidate** convenience wrapper, not verified official missingness handling. The public synthetic CI does not certify the final institutional workbook.
