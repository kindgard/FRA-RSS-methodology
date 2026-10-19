# Synthetic-only policy gate. Does not implement BNC85 imputation/projection.
# Inputs are deliberately explicit decisions from a separately validated private
# classification pipeline; never infer eligibility from an absent flag.
bnc85_gate <- function(records, min_quality=0.85) {
  cols <- c("record_id","manual_resolved","remaining_inconsistency",
            "quality","change_first_period","change_second_period")
  if (!is.data.frame(records) || !all(cols %in% names(records))) stop("Missing BNC85 policy columns")
  if (anyNA(records[,cols]) || anyDuplicated(records$record_id)) stop("Missing or duplicate BNC85 records")
  if (!is.numeric(records$quality) || any(!is.finite(records$quality)) ||
      any(records$quality < 0 | records$quality > 1)) stop("Invalid quality")
  if (!is.numeric(min_quality) || length(min_quality)!=1 ||
      !is.finite(min_quality) || min_quality < 0 || min_quality > 1)
    stop("Invalid threshold")
  flags <- c("manual_resolved","remaining_inconsistency","change_first_period","change_second_period")
  if (!all(vapply(records[flags],is.logical,logical(1)))) stop("Flags must be logical")
  eligible <- !records$manual_resolved & records$remaining_inconsistency &
    records$quality >= min_quality &
    !records$change_first_period & !records$change_second_period
  reason <- ifelse(records$manual_resolved,"already_manual_resolved",
            ifelse(!records$remaining_inconsistency,"not_inconsistent",
            ifelse(records$quality < min_quality,"quality_below_threshold",
            ifelse(records$change_first_period | records$change_second_period,
                   "change_involved","eligible_for_review"))))
  data.frame(record_id=records$record_id,eligible=eligible,
             reason=reason,stringsAsFactors=FALSE)
}
