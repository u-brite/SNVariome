box::use(
  jsonvalidate[json_validate],
  testthat[
    expect_equal,
    expect_false,
    expect_null,
    expect_true,
    test_that,
  ],
  app/logic/evidence,
  app/logic/network,
  app/logic/normalization,
)

project_root <- normalizePath(file.path("..", ".."))
bundle_path <- file.path(
  project_root,
  "app",
  "data",
  "pik3ca",
  "evidence-bundle.json"
)
schema_path <- file.path(project_root, "schema", "evidence-bundle.schema.json")
bundle <- evidence$load_bundle(bundle_path, schema_path)

test_that("the curated evidence bundle validates", {
  expect_equal(bundle$schema_version, "0.1.0")
  expect_equal(length(bundle$variants), 3L)
  expect_true(all(vapply(
    bundle$variants,
    function(variant) length(variant$interactions) > 0L,
    logical(1)
  )))
})

test_that("equivalent notations resolve to the same allele", {
  alias_sets <- list(
    c("PIK3CA E545K", "p.Glu545Lys", "p.E545K", "NM_006218.4:c.1633G>A"),
    c("PIK3CA M1043V", "p.Met1043Val", "p.M1043V", "NM_006218.4:c.3127A>G"),
    c("PIK3CA H1047R", "p.His1047Arg", "p.H1047R", "NM_006218.4:c.3140A>G")
  )

  for (aliases in alias_sets) {
    results <- lapply(aliases, normalization$normalize_variant, bundle = bundle)
    variant_ids <- vapply(results, `[[`, character(1), "variant_id")

    expect_equal(length(unique(variant_ids)), 1L)
    expect_true(all(vapply(
      results,
      function(result) identical(result$status, "resolved"),
      logical(1)
    )))
  }
})

test_that("inputs absent from the dataset are not guessed", {
  result <- normalization$normalize_variant("BRCA1 p.Cys61Gly", bundle)

  expect_equal(result$status, "not_in_dataset")
  expect_null(result$variant_id)
})

test_that("missing clinical data remains distinct from negative evidence", {
  clinical_records <- lapply(bundle$variants, `[[`, "clinical")

  expect_true(all(vapply(
    clinical_records,
    function(record) identical(record$availability, "unavailable"),
    logical(1)
  )))
  expect_true(all(vapply(
    clinical_records,
    function(record) is.null(record$classification),
    logical(1)
  )))
})

test_that("network edges are derived from the same interaction records", {
  for (variant in bundle$variants) {
    network_data <- network$build_network_data(variant)

    expect_equal(nrow(network_data$edges), length(variant$interactions))
    expect_equal(
      sort(network_data$edges$id),
      sort(vapply(variant$interactions, `[[`, character(1), "interaction_id"))
    )
    expect_false(anyDuplicated(network_data$edges$id) > 0L)
  }
})

test_that("duplicate partners produce one node without dropping evidence", {
  variant <- bundle$variants[[1]]
  duplicate_interaction <- variant$interactions[[1]]
  duplicate_interaction$interaction_id <- paste0(
    duplicate_interaction$interaction_id,
    "-replicate"
  )
  variant$interactions <- c(variant$interactions, list(duplicate_interaction))

  network_data <- network$build_network_data(variant)

  expect_equal(nrow(network_data$edges), length(variant$interactions))
  expect_equal(
    sum(network_data$nodes$id == duplicate_interaction$partner),
    1L
  )
})

test_that("summary counts describe evidence without creating a score", {
  variant <- bundle$variants[[1]]
  summary <- evidence$summarize_variant(bundle, variant)

  expect_equal(summary$interaction_count, length(variant$interactions))
  expect_true(summary$direct_evidence_count > 0L)
  expect_true(summary$source_count > 0L)
  expect_equal(summary$missing_section_count, 3L)
})

test_that("a selected-variant export remains schema-valid", {
  variant <- bundle$variants[[2]]
  output_path <- tempfile(fileext = ".json")

  evidence$write_variant_export(bundle, variant, output_path)

  expect_true(json_validate(output_path, schema_path))
  expect_equal(
    length(evidence$get_variant_sources(bundle, variant)),
    length(evidence$make_variant_export(bundle, variant)$sources)
  )
})
