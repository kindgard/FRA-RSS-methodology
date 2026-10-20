# Forest 2024 — reconstructed stratified estimator (synthetic validation)
This module reconstructs the equations recorded in the historical internal calculation summary, which cites FRA 2020 RSS Methodology section 9, table 5. This is a **method reconstruction**, not yet an exact verification of the October 17 institutional final input/output.

Data protection: No original institutional inputs, summaries, or outputs are in this repository; code and examples are synthetic only.

Let W_h = N_h / sum_h N_h. For a fraction of forest cover y in [0,1], estimate P = sum(W_h mean_h), V = sum(W_h^2 s_h^2/n_h (1-n_h/N_h)), SE = sqrt(V), CI95 = P +/- 1.96*SE.
Use unbiased sample variance (n-1 denominator). n_h must correspond to valid observations for this variable. Unlike a simple 0/1 prototype, observations can be continuous proportions.

Limitations:
- No claims about the institutional workbook's exact field mapping, missingness, spatial domain aggregation, or cluster/hexagon unit until code and input/output are cross-checked.
- Multiplying P by real geographic area needs an authoritative land/stratum area frame, not the number of hexagons alone.
- Geographic domain estimators and covariance between indicators remain separate work.
- Normal intervals are not automatically bounded to [0,1].
- This code must never silently discard unmatched strata or missing responses.

Next gate: compare locally (not GitHub CI) with the official R implementation and historical input/output, then compare to the October 17, 2026 workbook.
