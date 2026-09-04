box::use(
  DT[DTOutput, datatable, renderDT],
  bslib[card, card_body, card_header, layout_columns],
  shiny,
)

#' @export
ui <- function(id) {
  ns <- shiny$NS(id)
  shiny$div(
    class = "content-shell",
    shiny$tags$div(
      class = "workspace-heading",
      shiny$tags$p(class = "eyebrow", "Measured allele-specific evidence"),
      shiny$tags$h1("Interaction records"),
      shiny$tags$p(
        "Search, sort, or select a row. The inspector preserves assay,",
        "model, uncertainty, and source context."
      )
    ),
    layout_columns(
      col_widths = c(8, 4),
      card(
        class = "workspace-card",
        card_header("Mutant versus wild-type interactions"),
        card_body(DTOutput(ns("interactions")))
      ),
      card(
        class = "workspace-card inspector-card",
        card_header("Selected interaction"),
        card_body(shiny$uiOutput(ns("details")))
      )
    )
  )
}

#' @export
server <- function(id, selected_variant) {
  if (!shiny$is.reactive(selected_variant)) {
    stop("`selected_variant` must be a reactive expression.", call. = FALSE)
  }

  shiny$moduleServer(id, function(input, output, session) {
    output$interactions <- renderDT({
      interactions <- selected_variant()$interactions
      rows <- do.call(rbind, lapply(interactions, interaction_row))

      datatable(
        rows,
        rownames = FALSE,
        filter = "top",
        selection = "single",
        options = list(
          pageLength = 8,
          scrollX = TRUE,
          columnDefs = list(list(visible = FALSE, targets = 0))
        )
      )
    })

    output$details <- shiny$renderUI({
      selected_row <- input$interactions_rows_selected
      interactions <- selected_variant()$interactions

      if (length(selected_row) != 1L || selected_row > length(interactions)) {
        return(shiny$div(
          class = "empty-inspector",
          shiny$tags$strong("Select an interaction"),
          shiny$tags$p("Choose a table row to inspect its evidence context.")
        ))
      }

      interaction_details(interactions[[selected_row]])
    })
  })
}

interaction_row <- function(interaction) {
  data.frame(
    ID = interaction$interaction_id,
    Partner = interaction$partner,
    State = interaction$state,
    Measurement = interaction$measurement_status,
    `Mutant versus WT` = interaction$mutant_measurement,
    Evidence = interaction$evidence_class,
    Assay = interaction$assay,
    Model = interaction$model,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

interaction_details <- function(interaction) {
  shiny$div(
    class = "interaction-detail",
    shiny$tags$div(
      class = paste(
        "interaction-state",
        tolower(gsub("[^A-Za-z]+", "-", interaction$state))
      ),
      interaction$state
    ),
    shiny$tags$h2(interaction$partner),
    shiny$tags$p(class = "muted", interaction$mutant_measurement),
    shiny$tags$dl(
      class = "compact-definition inspector-definition",
      shiny$tags$dt("Measurement"),
      shiny$tags$dd(interaction$measurement_status),
      shiny$tags$dt("Evidence class"),
      shiny$tags$dd(interaction$evidence_class),
      shiny$tags$dt("Assay"),
      shiny$tags$dd(interaction$assay),
      shiny$tags$dt("Model"),
      shiny$tags$dd(interaction$model),
      shiny$tags$dt("Effect size"),
      shiny$tags$dd(value_or_missing(interaction$effect_size)),
      shiny$tags$dt("Uncertainty"),
      shiny$tags$dd(interaction$uncertainty),
      shiny$tags$dt("Source location"),
      shiny$tags$dd(interaction$source_location),
      shiny$tags$dt("Source ID"),
      shiny$tags$dd(paste(interaction$source_ids, collapse = ", "))
    )
  )
}

value_or_missing <- function(value) {
  if (is.null(value)) "Not available" else as.character(value)
}
