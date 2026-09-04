box::use(
  shiny[testServer],
  testthat[expect_equal, test_that],
  app/logic/evidence,
  app/view/search,
)

project_root <- normalizePath(file.path("..", ".."))
bundle <- evidence$load_bundle(
  file.path(project_root, "app", "data", "pik3ca", "evidence-bundle.json"),
  file.path(project_root, "schema", "evidence-bundle.schema.json")
)

test_that("the search module resolves a supported allele", {
  testServer(search$server, args = list(bundle = bundle), {
    session$setInputs(variant = "PIK3CA p.Glu545Lys", resolve = 1)

    expect_equal(resolution()$status, "resolved")
    expect_equal(
      selected_id(),
      "PIK3CA-NM_006218.4-c.1633G>A"
    )
  })
})

test_that("an unmatched input preserves the last resolved allele", {
  testServer(search$server, args = list(bundle = bundle), {
    session$setInputs(variant = "p.M1043V", resolve = 1)
    resolved_id <- selected_id()

    session$setInputs(variant = "BRCA1 p.Cys61Gly", resolve = 2)

    expect_equal(resolution()$status, "not_in_dataset")
    expect_equal(selected_id(), resolved_id)
  })
})
