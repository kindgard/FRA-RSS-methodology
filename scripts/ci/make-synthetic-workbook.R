# Synthetic end-to-end test fixture. NO FRA data, no FAO methodology.
dir.create("test-fixtures/synthetic", recursive=TRUE, showWarnings=FALSE)
path <- "test-fixtures/synthetic/demo.xlsx"
openxlsx::write.xlsx(list(RawData=data.frame(id=1:4, sample=c(1,0,1,1)), weights=data.frame(group="test",N=100)),path,overwrite=TRUE)
cat("Created synthetic workbook:",path,"\n")
