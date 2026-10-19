# Data lineage contract: v23-compatible raw / v24 / manual review / BNC85

This documentation is a *working interpretation* of the user's provenance description, not a reproduction of confidential classification rules.

1. Input raw tables were intended to maintain the `glue2024_v23` column structure while using improved v24 records.
2. Roughly 2,800 inconsistencies were manually corrected (approximate count, not a verified table count).
3. Remaining inconsistencies may be *considered* for projection by interpreter quality only if no change is involved in either interpreter's applicable observation windows.
4. Forest 2024 follows these transformations, and must retain enough provenance for an independent audit.

## Security and semantics
This public code does not read real records or perform projection. It implements a conservative *eligibility gate* for synthetic flags only. `min_quality=0.85` is a provisional interpretation of the label BNC85, not a confirmed official threshold. Neither the meaning of interpreter quality, tie handling, nor how projected labels are calculated is established.

The chronological phrase supplied for the first interpreter included `2000-2010-2028`. Confirm whether this denotes 2018 before encoding year-specific checks. The second interpreter's interval is described as 2018–2024. Until this is clarified, checks accept explicit change flags from a validated upstream source, not year-specific formulas.

## Planned private adapter
Compare v23 and v24 field lists, datatype, scales, order, and missing-value conventions; verify key uniqueness; count manual corrections; document eligible/rejected unresolved cases and original vs resolved values; never transmit row-level data or derived institutional outputs to public GitHub CI.
