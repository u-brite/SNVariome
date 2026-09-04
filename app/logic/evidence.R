box::use(
  jsonlite[fromJSON, write_json],
  jsonvalidate[json_validate],
)

#' Load and validate the versioned evidence bundle.
#'
#' Validation occurs before simplification so missing and null values retain
#' their distinct meanings in the application.
#' @export
load_bundle <- function(bundle_path, schema_path) {
  validation_errors <- json_validate(
    bundle_path,
    schema_path,
    verbose = TRUE,
    greedy = TRUE
  )

  if (!isTRUE(validation_errors)) {
    details <- attr(validation_errors, "errors")
    stop(
      paste("Evidence bundle failed schema validation:", details, collapse = "\n"),
      call. = FALSE
    )
  }

  bundle <- fromJSON(bundle_path, simplifyVector = FALSE)
  validate_references(bundle)
  bundle
}

#' Return one variant from an evidence bundle.
#' @export
get_variant <- function(bundle, variant_id) {
  matches <- vapply(
    bundle$variants,
    function(variant) identical(variant$variant_id, variant_id),
    logical(1)
  )

  if (sum(matches) != 1L) {
    stop(sprintf("Expected one variant for '%s'.", variant_id), call. = FALSE)
  }

  bundle$variants[[which(matches)]]
}

#' Return the sources referenced by a variant.
#' @export
get_variant_sources <- function(bundle, variant) {
  source_ids <- unique(c(
    variant$identity$source_ids,
    variant$clinical$source_ids,
    variant$structure$source_ids,
    unlist(lapply(variant$mechanisms, `[[`, "source_ids")),
    unlist(lapply(variant$interactions, `[[`, "source_ids")),
    unlist(lapply(variant$phenotypes, `[[`, "source_ids")),
    unlist(lapply(variant$hypotheses, `[[`, "source_ids"))
  ))

  Filter(
    function(source) source$source_id %in% source_ids,
    bundle$sources
  )
}

#' Summarize the evidence available for one variant.
#'
#' The counts are descriptive navigation aids. They are deliberately not
#' combined into a pathogenicity or confidence score.
#' @export
summarize_variant <- function(bundle, variant) {
  assertions <- c(
    variant$mechanisms,
    variant$interactions,
    variant$phenotypes,
    variant$hypotheses
  )
  direct_evidence_count <- sum(vapply(
    assertions,
    function(assertion) {
      identical(assertion$evidence_class, "Direct experimental")
    },
    logical(1)
  ))
  missing_section_count <- sum(c(
    !identical(variant$clinical$availability, "available"),
    length(variant$phenotypes) == 0L,
    length(variant$hypotheses) == 0L
  ))

  list(
    interaction_count = length(variant$interactions),
    direct_evidence_count = direct_evidence_count,
    source_count = length(get_variant_sources(bundle, variant)),
    missing_section_count = missing_section_count
  )
}

#' Build a self-contained export for one selected variant.
#'
#' Keeping export assembly in the evidence layer ensures that the UI download
#' and automated validation use the same evidence and provenance records.
#' @export
make_variant_export <- function(bundle, variant) {
  list(
    schema_version = bundle$schema_version,
    generated_at = bundle$generated_at,
    variants = list(variant),
    sources = get_variant_sources(bundle, variant)
  )
}

#' Write a selected variant and its sources as schema-valid JSON.
#' @export
write_variant_export <- function(bundle, variant, output_path) {
  write_json(
    make_variant_export(bundle, variant),
    output_path,
    auto_unbox = TRUE,
    pretty = TRUE,
    null = "null"
  )

  invisible(output_path)
}

validate_references <- function(bundle) {
  variant_ids <- vapply(bundle$variants, `[[`, character(1), "variant_id")
  if (anyDuplicated(variant_ids)) {
    stop("Variant identifiers must be unique.", call. = FALSE)
  }

  source_ids <- vapply(bundle$sources, `[[`, character(1), "source_id")
  if (anyDuplicated(source_ids)) {
    stop("Source identifiers must be unique.", call. = FALSE)
  }

  interaction_ids <- unlist(lapply(
    bundle$variants,
    function(variant) {
      vapply(
        variant$interactions,
        `[[`,
        character(1),
        "interaction_id"
      )
    }
  ))
  if (anyDuplicated(interaction_ids)) {
    stop("Interaction identifiers must be unique.", call. = FALSE)
  }

  referenced_sources <- unique(unlist(lapply(
    bundle$variants,
    function(variant) {
      c(
        variant$identity$source_ids,
        variant$clinical$source_ids,
        variant$structure$source_ids,
        unlist(lapply(variant$mechanisms, `[[`, "source_ids")),
        unlist(lapply(variant$interactions, `[[`, "source_ids")),
        unlist(lapply(variant$phenotypes, `[[`, "source_ids")),
        unlist(lapply(variant$hypotheses, `[[`, "source_ids"))
      )
    }
  )))
  unknown_sources <- setdiff(referenced_sources, source_ids)

  if (length(unknown_sources) > 0L) {
    stop(
      sprintf("Unknown source identifiers: %s", paste(unknown_sources, collapse = ", ")),
      call. = FALSE
    )
  }

  invisible(TRUE)
}
