# FRA 2025 RSS — editorial outputs and validation gates (public specification)
Source: draft dated 19 Oct 2026, sections 4.1–4.3. This is a **production specification**, not official results. Input is private BA_NC85 or later RAW. Never upload source data or output tables to public CI.

| ID | Draft | Deliverable | Geography | Inputs / output file | Unit | Gate |
|---|---|---|---|---|---|---|
| T01 | 4.1.1 | 2024 Forest / OWL / OL / Water | Global, Region, Subregion, GEZ | 4 `%24` hexagon indicators; `hexagon_*.csv` | Mha, SE, ±95% | REVIEW: missing 2024 fractions |
| F01 | 4.1.1 | 2024 land-use share (stacked bar) | Global | T01 and total land area | % | REVIEW |
| T02 | 4.1.2 | Natural forest / planted forest / mangroves | Global, Region | IPCC24 -> L2/L3 -> calibrated cells; `calibrated_l3_*.csv` | Mha, SE | BLOCKED pending complete category/closure audit |
| F02 | 4.1.2 | Forest characteristics (bars) | Global | T02, check mangrove overlap before adding | Mha | BLOCKED |
| T03 | 4.1.3 | Temporarily unstocked forest by type | Global, Region | L3 codes 12,14; additional drivers require explicit rule | Mha | BLOCKED |
| T04 | 4.1.4–4.1.5 | Other land with tree cover / tree status | Global, Region | L3 22,24,36, other tree definitions | Mha, % | BLOCKED |
| T05 | 4.1.6–4.1.7 | Shifting cultivation and pastoralism | Global, Region | IPCC24 44 and Ranch_Pastoralism | Mha | BLOCKED |
| T06 | 4.2.1 | Gross loss / gain and net 2000–10,10–18,18–24 | Global | `%FORLOSS`, `%FORGAIN`; `forest_change_annual.csv` | Mha, Mha/yr | AVAILABLE for point totals; net SE needs covariance |
| F03 | 4.2.1 | Annual loss / gain / net by period | Global | T06 | Mha/yr | AVAILABLE for point totals |
| T07 | 4.2.2 | Gross loss by region, subregion, GEZ | Region, Subregion, GEZ | `hexagon_Region.csv`, `hexagon_Subregion.csv`, `hexagon_GEZ.csv` | Mha, Mha/yr, SE | AVAILABLE after private run |
| F04 | 4.2.2 | Regional deforestation by period | Region | T07 | Mha/yr | AVAILABLE after private run |
| T08 | 4.2.3 | Gross expansion by region, subregion, GEZ | Region, Subregion, GEZ | same domain outputs | Mha, Mha/yr, SE | AVAILABLE after private run |
| F05 | 4.2.3 | Regional expansion by period | Region | T08 | Mha/yr | AVAILABLE after private run |
| T09 | 4.2.4 | Net forest change by geography | Global and regions | joint gain/loss covariance by cell, unimplemented in unified batch | Mha/yr, SE | BLOCKED for SE |
| T10 | 4.3.1–4.3.4 | Proximate loss drivers, destination and scale | Global and regions | Driver0010/1018/1824; Loss_ categories calibrated against corresponding period loss | Mha, %, SE | BLOCKED: driver classification not integrated |
| F06 | 4.3 | Drivers by region/period | Region | T10 | Mha/yr or % | BLOCKED |
| A01 | Annex | Full geography × indicator × period | Region, Subregion, GEZ, climatic domain | calibrated and hexagon outputs | Mha, SE, 95% interval, CoV | PARTIAL |

## Consistency rules
1. **No national estimates** in the public report.
2. `Mha = km² / 10000`; annualized amount divides by 10, 8, or 6 years respectively.
3. Show separately **gross forest loss**, **gross expansion**, and **net**; net variance must account for within-hexagon covariance.
4. For **coverage 2024** missing values must not silently become zero or be ignored in variance. Do not release 2024 ±95% until resolved.
5. Calibrated L3/L2 areas are produced only after the IPCC mapping and closure pass; mangroves are a category inside forest in Oliver's mapping, not a separate addition to already-totalled forest.
6. Singleton strata: Oliver's reference defines variance contribution as zero; identify them and flag assumptions in methodology.
7. An editor should only copy a number to the manuscript if its source file checksum, run ID, estimator version, and QA gate have been recorded.
8. Tables/figures prepared under BLOCKED or REVIEW may use schematic placeholders, never preliminary estimates labelled definitive.
