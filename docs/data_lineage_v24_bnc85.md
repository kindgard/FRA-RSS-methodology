# FRA RSS final input lineage — BNC85 (frozen input)

## Authoritative user decision (19 October 2026)
The workbook `merged_v24_DBfinal_v14_delGLUE__corrected_BA_NC85_2026-10-17.xlsx` is the **definitive selected analytical dataset**. BNC85 was already applied upstream. Do not rerun the BNC85 selection, reinterpret interpreter quality, or alter any unresolved classifications.

## Data history
- RAW files were intended to preserve the schema of `glue2024_v23`, rebuilt using improved v24.
- Approximately 2,800 trajectory inconsistencies were corrected manually upstream (approximate, not re-counted).
- Remaining cases were processed using the existing BNC85 decision upstream.
- Approximately 3,600 hexagon samples apparently still exhibit trajectory inconsistencies, and remain part of the definitive dataset. This count is an estimate pending read-only confirmation.

## Estimation and audit protocol
1. Read definitive data *read-only*, in an authorized private runtime.
2. Verify exact field names, units, sample identifiers and strata, and file checksums; never assume the old v23 column semantics solely from schema compatibility.
3. Independently flag any remaining trajectory inconsistencies **for diagnostic reporting**, without removing or modifying them.
4. Reproduce the official historical R aggregation and estimators on the definitive rows, matching its treatment of missing data.
5. Show the number of flagged hexagons globally and by stratum, and distinguish a trajectory issue from a missing/invalid value for the Forest 2024 indicator.
6. Any optional comparison excluding flagged records is a clearly labeled sensitivity analysis only. **Never** silently exclude cases from the main estimates.
7. Emit reproducibility metadata, reference comparisons, and audit warnings; do not publish institutional records or outputs to GitHub.

## Outstanding validation
The definitive workbook has not yet been read and its approximate inconsistency count is not independently verified. The historical R input/output and exact 2024 forest fraction mapping still need confirmation before declaring official equivalence.
