box::use(
  DT[DTOutput, datatable, renderDT],
  bslib[card, card_body, card_header, layout_columns],
  shiny,
)

box::use(
  app/logic/evidence,
  app/logic/normalization,
)

#' @export
sidebar_ui <- function(id) {
  ns <- shiny$NS(id)
  shiny$div(
    class = "variant-search",
    shiny$tags$p(class = "sidebar-label", "Find a variant"),
    shiny$textInput(
      ns("variant"),
      "Genomic, transcript, or protein notation",
      value = "PIK3CA p.Glu545Lys",
      width = "100%"
    ),
    shiny$actionButton(
      ns("resolve"),
      "Resolve variant",
      class = "btn-primary w-100"
    ),
    shiny$uiOutput(ns("status")),
    shiny$tags$hr(),
    shiny$tags$p(class = "sidebar-label", "Current scope"),
    shiny$tags$p(
      class = "sidebar-copy",
      "Search the three PIK3CA records included in this demonstration dataset."
    ),
    shiny$helpText(
      "Accepted examples: PIK3CA p.Glu545Lys, p.M1043V, or ",
      "NM_006218.4:c.3140A>G."
    )
  )
}

#' @export
ui <- function(id) {
  ns <- shiny$NS(id)
  shiny$div(
    class = "content-shell",
    shiny$tags$div(
      class = "workspace-heading",
      shiny$tags$p(class = "eyebrow", "Curated demonstration"),
      shiny$tags$h1("PIK3CA variant workspace"),
      shiny$tags$p(
        "Choose a supported allele to inspect its identity, mechanism,",
        "interaction evidence, network, and provenance."
      )
    ),
    shiny$uiOutput(ns("collection_summary")),
    layout_columns(
      col_widths = c(8, 4),
      card(
        class = "workspace-card",
        card_header(
          shiny$tags$div(
            shiny$tags$strong("Supported variants"),
            shiny$tags$small("Select a row to update the entire workspace")
          )
        ),
        card_body(DTOutput(ns("variants")))
      ),
      card(
        class = "workspace-card guidance-card",
        card_header("How to use this workspace"),
        card_body(
          workflow_step("1", "Resolve", "Enter an equivalent variant notation."),
          workflow_step("2", "Review", "Separate measured evidence from missing data."),
          workflow_step("3", "Inspect", "Select an interaction edge or table row."),
          workflow_step("4", "Trace", "Open the source record or export the JSON bundle.")
        )
      )
    )
  )
}

#' @export
server <- function(id, bundle) {
  if (!is.list(bundle) || length(bundle$variants) == 0L) {
    stop("`bundle` must contain at least one curated variant.", call. = FALSE)
  }

  shiny$moduleServer(id, function(input, output, session) {
    selected_id <- shiny$reactiveVal(bundle$variants[[1]]$variant_id)
    resolution <- shiny$reactiveVal(list(
      status = "resolved",
      message = "Showing the default curated PIK3CA allele.",
      variant_id = bundle$variants[[1]]$variant_id
    ))

    shiny$observeEvent(input$resolve, {
      result <- normalization$normalize_variant(input$variant, bundle)
      resolution(result)
      if (identical(result$status, "resolved")) {
        selected_id(result$variant_id)
      }
    })

    shiny$observeEvent(input$variants_rows_selected, {
      selected_row <- input$variants_rows_selected
      if (length(selected_row) != 1L) {
        return()
      }

      variant <- bundle$variants[[selected_row]]
      selected_id(variant$variant_id)
      resolution(list(
        status = "resolved",
        message = "Selected from the curated variant table.",
        variant_id = variant$variant_id
      ))
    })

    output$status <- shiny$renderUI({
      result <- resolution()
      status_label <- if (identical(result$status, "resolved")) {
        "Matched curated record"
      } else {
        "Not in current dataset"
      }

      shiny$div(
        class = paste(
          "normalization-result",
          if (identical(result$status, "resolved")) "resolved" else "warning"
        ),
        shiny$span(
          class = "normalization-icon",
          if (identical(result$status, "resolved")) "✓" else "!"
        ),
        shiny$div(
          shiny$tags$strong(status_label),
          shiny$tags$p(result$message)
        )
      )
    })

    output$collection_summary <- shiny$renderUI({
      variants <- bundle$variants
      interaction_count <- sum(vapply(
        variants,
        function(variant) length(variant$interactions),
        integer(1)
      ))
      direct_count <- sum(vapply(
        variants,
        function(variant) {
          evidence$summarize_variant(bundle, variant)$direct_evidence_count
        },
        integer(1)
      ))

      shiny$div(
        class = "summary-card-grid",
        summary_card("Curated alleles", length(variants), "PIK3CA"),
        summary_card("Interaction records", interaction_count, "Focused AP-MS set"),
        summary_card("Direct assertions", direct_count, "Allele-specific"),
        summary_card("Source records", length(bundle$sources), "Traceable provenance")
      )
    })

    output$variants <- renderDT({
      rows <- do.call(rbind, lapply(bundle$variants, function(variant) {
        summary <- evidence$summarize_variant(bundle, variant)
        data.frame(
          Gene = variant$identity$gene,
          Protein = variant$identity$protein_hgvs,
          Transcript = variant$identity$transcript,
          Genomic = variant$identity$genomic_hgvs,
          Interactions = summary$interaction_count,
          `Direct evidence` = summary$direct_evidence_count,
          check.names = FALSE,
          stringsAsFactors = FALSE
        )
      }))

      datatable(
        rows,
        rownames = FALSE,
        selection = "single",
        options = list(
          dom = "t",
          ordering = FALSE,
          pageLength = nrow(rows),
          scrollX = TRUE
        )
      )
    })

    list(
      selected_id = selected_id,
      resolution = resolution
    )
  })
}

summary_card <- function(label, value, detail) {
  shiny$div(
    class = "summary-card",
    shiny$tags$small(label),
    shiny$tags$strong(as.character(value)),
    shiny$tags$span(detail)
  )
}

workflow_step <- function(number, title, description) {
  shiny$div(
    class = "workflow-step",
    shiny$span(class = "workflow-number", number),
    shiny$div(shiny$tags$strong(title), shiny$tags$p(description))
  )
}
