#' Resolve a submitted notation against the curated allele set.
#'
#' This intentionally does not guess mappings absent from the local dataset. External
#' normalization belongs after the curated path is validated.
#' @export
normalize_variant <- function(submitted_notation, bundle) {
  normalized_input <- normalize_alias(submitted_notation)
  alias_index <- build_alias_index(bundle)
  variant_ids <- unique(alias_index[[normalized_input]])

  if (is.null(variant_ids) || length(variant_ids) == 0L) {
    return(list(
      status = "not_in_dataset",
      submitted_notation = submitted_notation,
      variant_id = NULL,
      message = paste(
        "No matching record is in the current dataset.",
        "Try PIK3CA p.Glu545Lys, p.Met1043Val, or p.His1047Arg.",
        "The last selected variant remains visible."
      )
    ))
  }

  if (length(variant_ids) > 1L) {
    return(list(
      status = "ambiguous",
      submitted_notation = submitted_notation,
      variant_id = NULL,
      message = "The submitted notation maps to more than one curated allele."
    ))
  }

  list(
    status = "resolved",
    submitted_notation = submitted_notation,
    variant_id = variant_ids[[1]],
    message = "Resolved to one curated PIK3CA allele."
  )
}

build_alias_index <- function(bundle) {
  index <- list()

  for (variant in bundle$variants) {
    aliases <- unique(c(
      variant$variant_id,
      variant$identity$aliases,
      variant$identity$genomic_hgvs,
      variant$identity$protein_hgvs
    ))

    for (alias in aliases) {
      key <- normalize_alias(alias)
      index[[key]] <- c(index[[key]], variant$variant_id)
    }
  }

  index
}

normalize_alias <- function(value) {
  value <- trimws(value)
  value <- sub("^PIK3CA[:[:space:]]*", "", value, ignore.case = TRUE)
  value <- gsub("\\s+", "", value)
  tolower(value)
}
