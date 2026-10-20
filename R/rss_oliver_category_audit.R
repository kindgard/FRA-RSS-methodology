# Diagnostic QA for categorical centroid inputs. No private values in this code.
# Completeness checks run on UNMODIFIED source columns.
rss_oliver_category_audit <- function(raw, field="IPCC24") {
 if(!is.data.frame(raw)||!(field%in%names(raw)))stop("Missing categorical field")
 mapping<-rss_oliver_subclass_mapping()
 original<-as.character(raw[[field]])
 normalized<-rss_oliver_normalize_ipcc(original)
 v<-unique(normalized)
 v<-v[!is.na(v)]
 result<-do.call(rbind,lapply(v,function(value) {
  ix<-which(!is.na(normalized)&normalized==value)
  data.frame(field=field,value=value,n=length(ix),
   known=value%in%mapping$level_3_subclass,
   spelling_normalized=any(original[ix]!=normalized[ix]))
 }))
 if(is.null(result))result<-data.frame(field=character(),value=character(),
   n=integer(),known=logical(),spelling_normalized=logical())
 result<-result[order(!result$known,-result$n,result$value),,drop=FALSE]
 rownames(result)<-NULL
 list(categories=result,missing=sum(is.na(original)),
      unknown_n=sum(result$n[!result$known]),
      status=if(any(!result$known))"REVIEW_UNMAPPED" else "MAPPED")
}
rss_oliver_indicator_closure <- function(indicator_data,variables,
                                         tolerance=1e-10) {
 if(!all(variables%in%names(indicator_data)))stop("Missing indicators")
 values<-indicator_data[,variables,drop=FALSE]
 if(!all(vapply(values,is.numeric,logical(1))))stop("Indicators must be numeric")
 sums<-rowSums(values)
 data.frame(n=nrow(indicator_data),n_missing=sum(!stats::complete.cases(values)),
    n_not_one=sum(stats::complete.cases(values)&abs(sums-1)>tolerance),
    status=if(all(stats::complete.cases(values)&abs(sums-1)<=tolerance))
      "PARTITION" else "REVIEW")
}
