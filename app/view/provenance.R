box::use(
  DT[DTOutput, datatable, renderDT],
  bslib[card, card_body, card_header],
  shiny[
    NS,
    div,
    downloadButton,
    downloadHandler,
    is.reactive,
    moduleServer,
    tags,
  ],
)

box::use(
  app/logic/evidence,
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  div(
    class = "content-shell",
    tags$div(
      class = "section-heading",
      tags$p(class = "eyebrow", "Assertion-level traceability"),
      tags$h1("Provenance")
    ),
    card(
      card_header("Sources used by the selected variant"),
      card_body(DTOutput(ns("sources")))
    ),
    downloadButton(
      ns("download_bundle"),
      "Download structured evidence record",
      class = "btn-primary"
    )
  )
}

#' @export
server <- function(id, bundle, selected_variant) {
  if (!is.reactive(selected_variant)) {
    stop("`selected_variant` must be a reactive expression.", call. = FALSE)
  }

  moduleServer(id, function(input, output, session) {
    output$sources <- renderDT({
      sources <- evidence$get_variant_sources(bundle, selected_variant())
      rows <- do.call(rbind, lapply(sources, function(source) {
        data.frame(
          Title = source$title,
          Type = source$source_type,
          Identifier = source$identifier,
          Version = source$version %||% "Not specified",
          Retrieved = source$retrieved_at,
          Redistribution = source$redistribution,
          URL = sprintf(
            "<a href='%s' target='_blank' rel='noopener noreferrer'>Open source</a>",
            source$url
          ),
          check.names = FALSE,
          stringsAsFactors = FALSE
        )
      }))

      datatable(
        rows,
        rownames = FALSE,
        escape = which(names(rows) != "URL"),
        options = list(pageLength = 10, scrollX = TRUE)
      )
    })

    output$download_bundle <- downloadHandler(
      filename = function() {
        paste0(selected_variant()$variant_id, "-evidence.json")
      },
      content = function(file) {
        evidence$write_variant_export(bundle, selected_variant(), file)
      }
    )
  })
}

`%||%` <- function(value, fallback) {
  if (is.null(value) || identical(value, "")) fallback else value
}
