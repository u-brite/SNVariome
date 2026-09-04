box::use(
  bslib[bs_theme, nav_panel, navbar_options, page_navbar, sidebar],
  config,
  shiny,
)

box::use(
  app/logic/evidence,
  app/view/evidence_card,
  app/view/interactions,
  app/view/provenance,
  app/view/rewiring_network,
  app/view/search,
)

# The evidence fixture is immutable for a running process, so validate it once
# rather than repeating file I/O for every user session.
settings <- config$get()
evidence_bundle <- evidence$load_bundle(
  settings$evidence_bundle,
  settings$evidence_schema
)

#' @export
ui <- function(id) {
  ns <- shiny$NS(id)
  page_navbar(
    title = "SNVariome",
    id = ns("workspace"),
    selected = "Overview",
    fillable = FALSE,
    navbar_options = navbar_options(
      bg = "#FFFFFF",
      theme = "light",
      underline = TRUE
    ),
    sidebar = sidebar(
      search$sidebar_ui(ns("search")),
      width = 300,
      bg = "#F4F6F5",
      resizable = TRUE
    ),
    theme = bs_theme(
      version = 5,
      bg = "#F6F7F7",
      fg = "#202522",
      primary = "#1E6B52",
      secondary = "#88C408"
    ),
    header = shiny$tagList(
      shiny$tags$head(
        shiny$tags$link(rel = "stylesheet", href = "static/main.css")
      ),
      shiny$uiOutput(ns("variant_context"))
    ),
    nav_panel("Overview", search$ui(ns("search"))),
    nav_panel("Evidence", evidence_card$ui(ns("evidence_card"))),
    nav_panel("Interactions", interactions$ui(ns("interactions"))),
    nav_panel("Network", rewiring_network$ui(ns("rewiring_network"))),
    nav_panel("Sources", provenance$ui(ns("provenance")))
  )
}

#' @export
server <- function(id) {
  shiny$moduleServer(id, function(input, output, session) {
    search_state <- search$server("search", evidence_bundle)
    selected_variant <- shiny$reactive({
      evidence$get_variant(evidence_bundle, search_state$selected_id())
    })

    output$variant_context <- shiny$renderUI({
      variant <- selected_variant()
      summary <- evidence$summarize_variant(evidence_bundle, variant)
      resolution <- search_state$resolution()

      shiny$div(
        class = "variant-context",
        shiny$div(
          class = "variant-context-identity",
          shiny$tags$small("Selected allele"),
          shiny$tags$strong(
            paste(variant$identity$gene, variant$identity$protein_hgvs)
          ),
          shiny$span(
            class = paste("status-pill", resolution$status),
            resolution_label(resolution$status)
          )
        ),
        context_metric("Interactions", summary$interaction_count),
        context_metric("Direct evidence", summary$direct_evidence_count),
        context_metric("Sources", summary$source_count),
        context_metric("Missing sections", summary$missing_section_count)
      )
    })

    evidence_card$server("evidence_card", selected_variant)
    interactions$server("interactions", selected_variant)
    rewiring_network$server("rewiring_network", selected_variant)
    provenance$server("provenance", evidence_bundle, selected_variant)
  })
}

context_metric <- function(label, value) {
  shiny$div(
    class = "context-metric",
    shiny$tags$small(label),
    shiny$tags$strong(as.character(value))
  )
}

resolution_label <- function(status) {
  if (identical(status, "resolved")) {
    "Matched curated record"
  } else {
    "No new match"
  }
}
