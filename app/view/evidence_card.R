box::use(
  bslib[accordion, accordion_panel, card, card_body, card_header, layout_columns],
  shiny,
)

#' @export
ui <- function(id) {
  ns <- shiny$NS(id)
  shiny$div(
    class = "content-shell",
    shiny$uiOutput(ns("header")),
    layout_columns(
      col_widths = c(8, 4),
      shiny$div(
        class = "evidence-main-column",
        card(
          class = "workspace-card",
          card_header("Molecular mechanism"),
          card_body(shiny$uiOutput(ns("mechanisms")))
        ),
        card(
          class = "workspace-card",
          card_header("Additional evidence layers"),
          card_body(shiny$uiOutput(ns("additional_evidence")))
        )
      ),
      shiny$div(
        class = "evidence-inspector",
        card(
          class = "workspace-card",
          card_header("Variant identity"),
          card_body(shiny$uiOutput(ns("identity")))
        ),
        card(
          class = "workspace-card",
          card_header("Clinical evidence"),
          card_body(shiny$uiOutput(ns("clinical")))
        ),
        card(
          class = "workspace-card",
          card_header("Structural context"),
          card_body(shiny$uiOutput(ns("structure")))
        )
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
    output$header <- shiny$renderUI({
      variant <- selected_variant()
      shiny$div(
        class = "record-header",
        shiny$div(
          shiny$tags$p(class = "eyebrow", "Variant evidence record"),
          shiny$tags$h1(
            paste(variant$identity$gene, variant$identity$protein_hgvs)
          ),
          shiny$tags$p(
            class = "record-subtitle",
            paste(variant$identity$transcript, variant$identity$genomic_hgvs)
          )
        ),
        evidence_badge("Curated mapping")
      )
    })

    output$mechanisms <- shiny$renderUI({
      assertion_list(selected_variant()$mechanisms)
    })

    output$additional_evidence <- shiny$renderUI({
      variant <- selected_variant()
      accordion(
        accordion_panel(
          "Phenotype and pathway context",
          assertion_list(variant$phenotypes)
        ),
        accordion_panel(
          "Perturbational hypotheses",
          assertion_list(variant$hypotheses)
        ),
        open = FALSE
      )
    })

    output$identity <- shiny$renderUI({
      identity <- selected_variant()$identity
      shiny$tags$dl(
        class = "compact-definition",
        shiny$tags$dt("Gene"), shiny$tags$dd(identity$gene),
        shiny$tags$dt("HGNC"), shiny$tags$dd(identity$hgnc_id),
        shiny$tags$dt("Assembly"), shiny$tags$dd(identity$assembly),
        shiny$tags$dt("Transcript"), shiny$tags$dd(identity$transcript),
        shiny$tags$dt("Protein"), shiny$tags$dd(identity$protein),
        shiny$tags$dt("Genomic HGVS"), shiny$tags$dd(identity$genomic_hgvs),
        shiny$tags$dt("Protein HGVS"), shiny$tags$dd(identity$protein_hgvs)
      )
    })

    output$clinical <- shiny$renderUI({
      clinical <- selected_variant()$clinical
      shiny$tagList(
        evidence_badge(
          if (identical(clinical$availability, "available")) {
            "Curated clinical"
          } else {
            "Missing"
          }
        ),
        shiny$tags$p(
          if (identical(clinical$availability, "available")) {
            clinical$classification
          } else {
            "ClinVar evidence has not yet been cached for this fixture."
          }
        ),
        shiny$tags$p(
          class = "muted small-copy",
          "Unavailable evidence is not interpreted as a negative finding."
        )
      )
    })

    output$structure <- shiny$renderUI({
      structure <- selected_variant()$structure
      shiny$tagList(
        evidence_badge("Contextual association"),
        shiny$tags$dl(
          class = "compact-definition",
          shiny$tags$dt("Domain"),
          shiny$tags$dd(value_or_missing(structure$domain)),
          shiny$tags$dt("Experimental coverage"),
          shiny$tags$dd(structure$experimental_coverage),
          shiny$tags$dt("Predicted coverage"),
          shiny$tags$dd(structure$predicted_coverage),
          shiny$tags$dt("EDC"),
          shiny$tags$dd(value_or_missing(structure$edc))
        )
      )
    })
  })
}

assertion_list <- function(assertions) {
  if (length(assertions) == 0L) {
    return(shiny$div(
      class = "missing-state",
      "No evidence is available in this bundle."
    ))
  }

  shiny$tagList(lapply(assertions, function(assertion) {
    shiny$div(
      class = "assertion",
      evidence_badge(assertion$evidence_class),
      shiny$tags$strong(assertion$term),
      shiny$tags$p(assertion$statement),
      shiny$tags$p(
        class = "assertion-source",
        paste("Source:", paste(assertion$source_ids, collapse = ", "))
      )
    )
  }))
}

evidence_badge <- function(evidence_class) {
  class_name <- tolower(gsub("[^A-Za-z]+", "-", evidence_class))
  shiny$span(class = paste("evidence-badge", class_name), evidence_class)
}

value_or_missing <- function(value) {
  if (is.null(value)) "Not available" else as.character(value)
}
