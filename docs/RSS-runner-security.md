# FRA RSS R runner — security and reproducibility

This repository is public. The workflow installs R and checks the runner syntax using **no FAO data**. It does not access Google Drive, fetch institutional files, or upload results.

The command-line runner accepts an input XLSX, an original Oliver Rmd, and an output directory. It stages them in a temporary local workspace, checks the input workbook has RawData and weights worksheets, renders the Rmd without changing its equations, and checks that an Excel output exists.

**Not production-ready:** The original Rmd may include additional relative paths, depend on other input files, expect a different R version, or include external data and packages. The current wrapper requires its exact XLSX filename to appear in the original Rmd. The runner must be tested in a controlled, authorized environment against an independently verified reference output. Never interpret smoke-test success as estimator validation.

Before running FAO data on GitHub-hosted workers, obtain institutional authorization for transfer, processing, logs and artifact retention; use a private controlled environment and locked-down credentials. Do not put institutional data, sensitive outputs, the original Rmd, or secrets into this public repository, Git history, issue comments, or CI logs. If external processing is not approved, run locally or on approved FAO infrastructure.

Once approved, version R/package dependencies (renv), verify file hashes, save a processing manifest, and add numerical regression tests covering hexagon estimates, centroid calibration, drivers, variances and confidence intervals. Outputs remain experimental until validated.
