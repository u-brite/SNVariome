box::use(
  shiny[reactive, testServer],
  testthat[expect_equal, expect_match, expect_s3_class, test_that],
)

box::use(
  app/logic/evidence,
  app/view/evidence_card,
  app/view/interactions,
  app/view/provenance,
  app/view/rewiring_network,
)

project_root <- normalizePath(file.path("..", ".."))
bundle <- evidence$load_bundle(
  file.path(project_root, "app", "data", "pik3ca", "evidence-bundle.json"),
  file.path(project_root, "schema", "evidence-bundle.schema.json")
)
selected_variant <- reactive(bundle$variants[[1]])

rendered_text <- function(output_value) {
  paste(as.character(output_value), collapse = "")
}

test_that("dashboard view functions return Shiny tags", {
  expect_s3_class(evidence_card$ui("evidence"), "shiny.tag")
  expect_s3_class(interactions$ui("interactions"), "shiny.tag")
  expect_s3_class(provenance$ui("provenance"), "shiny.tag")
  expect_s3_class(rewiring_network$ui("network"), "shiny.tag")
})

test_that("the evidence card renders the selected variant", {
  testServer(
    evidence_card$server,
    args = list(selected_variant = selected_variant),
    {
      expect_match(rendered_text(output$header), "Glu545Lys")
      expect_match(rendered_text(output$mechanisms), "Gain of function")
      expect_match(rendered_text(output$clinical), "Missing")
      expect_match(rendered_text(output$structure), "Contextual association")
    }
  )
})

test_that("the interaction inspector follows the selected table row", {
  testServer(
    interactions$server,
    args = list(selected_variant = selected_variant),
    {
      expect_match(rendered_text(output$details), "Select an interaction")

      session$setInputs(interactions_rows_selected = 1)

      interaction <- selected_variant()$interactions[[1]]
      expect_match(rendered_text(output$details), interaction$partner)
      expect_match(rendered_text(output$details), interaction$assay)
      expect_match(rendered_text(output$details), interaction$source_ids[[1]])
    }
  )
})

test_that("the network inspector uses the selected evidence record", {
  testServer(
    rewiring_network$server,
    args = list(selected_variant = selected_variant),
    {
      interaction <- selected_variant()$interactions[[1]]
      session$setInputs(selected_edge = interaction$interaction_id)

      expect_match(rendered_text(output$edge_details), interaction$partner)
      expect_match(rendered_text(output$edge_details), interaction$assay)
      expect_match(rendered_text(output$edge_details), interaction$source_location)
    }
  )
})

test_that("the sources module initializes selected-variant provenance", {
  testServer(
    provenance$server,
    args = list(bundle = bundle, selected_variant = selected_variant),
    {
      rendered_sources <- rendered_text(output$sources)
      sources <- evidence$get_variant_sources(bundle, selected_variant())

      expect_match(rendered_sources, "Identifier")
      expect_match(rendered_sources, "Retrieved")
      expect_equal(length(sources), 2L)
      expect_equal(sources[[1]]$title, "A protein interaction landscape of breast cancer")
    }
  )
})
