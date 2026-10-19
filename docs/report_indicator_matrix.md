# FRA 2025 RSS draft -> estimator matrix (working, no institutional result data)

Source: Draft_FRA2025RSS_19October 2026.docx, accessed in connected private Drive. Methodological cross-reference: FRA 2020 RSS Methodology, section 9, tables 5-6.

| Report section | Output | Candidate raw variables | Estimator status |
|---|---|---|---|
| 4.1.1 | Global forest/OWL/other land and uses 2024 | FOREST%24, OWL%24, OL%24, WATER%24; other subclasses require mapping | generic stratified proportions; finer categories pending |
| 4.1.2 | Regenerating/planted forest and mangroves | classification subclass mapping pending | pending |
| 4.1.3 | Temporarily unstocked forest and drivers | thematic variables and cross-class definitions pending | pending |
| 4.2.1 | Annual deforestation, expansion and net change for 2000-10, 2010-18, 2018-24 | %FORLOSS and %FORGAIN by period | candidate; variance of net difference requires within-unit covariance |
| 4.2.2 | Loss by regions, subregions and GEZ | %FORLOSS by period plus geographic domains | domain inference pending |
| 4.2.3 | Expansion by regions, subregions and GEZ | %FORGAIN by period plus geographic domains | domain inference pending |
| Results drivers | forest loss by destination and proximate drivers | transition/driver columns must be inspected | pending |
| Annex | regional, subregional and GEZ detail | domain crosswalk and population frame | pending |

Core formula for direct global stratum estimator: sum_h (Nh/N)*mean(y_h). Variance: sum_h ((Nh/N)^2)*(s_h^2/nh)*(1-nh/Nh). Hexagon area used by Oliver: 0.3962 km2; scaling to report land area must follow the authoritative domain/population frame.

**Critical distinction:** The draft contains language about domain-specific weights and random domain samples. That language must be reconciled with the global stratified design and the authoritative per-domain population counts; do not silently treat subregion as independently stratified sampling.

**Confidentiality:** No figures or institutional outputs in this public file. Draft v24 numbers are not verified BA_NC85 estimates.
