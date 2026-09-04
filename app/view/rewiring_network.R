box::use(
  bslib[card, card_body, card_header, layout_columns],
  shiny[NS, div, is.reactive, moduleServer, renderUI, tags, uiOutput],
  visNetwork[
    renderVisNetwork,
    visEdges,
    visEvents,
    visGroups,
    visNetwork,
    visNetworkOutput,
    visOptions,
    visPhysics,
  ],
)

box::use(
  app/logic/network,
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  div(
    class = "content-shell",
    tags$div(
      class = "section-heading",
      tags$p(class = "eyebrow", "Allele-specific interaction evidence"),
      tags$h1("Focused rewiring network")
    ),
    layout_columns(
      col_widths = c(8, 4),
      card(
        card_header("PIK3CA interaction partners"),
        card_body(visNetworkOutput(ns("network"), height = "620px"))
      ),
      card(
        card_header("Selected edge"),
        card_body(uiOutput(ns("edge_details")))
      )
    )
  )
}

#' @export
server <- function(id, selected_variant) {
  if (!is.reactive(selected_variant)) {
    stop("`selected_variant` must be a reactive expression.", call. = FALSE)
  }

  moduleServer(id, function(input, output, session) {
    output$network <- renderVisNetwork({
      network_data <- network$build_network_data(selected_variant())
      graph <- visNetwork(network_data$nodes, network_data$edges, width = "100%")
      graph <- visGroups(
        graph,
        groupname = "variant",
        color = "#1E6B52",
        shape = "diamond",
        font = list(color = "#FFFFFF")
      )
      graph <- visGroups(
        graph,
        groupname = "partner",
        color = "#E7F2ED",
        shape = "dot",
        font = list(color = "#15372C")
      )
      graph <- visEdges(graph, width = 3, arrows = "to", smooth = FALSE)
      graph <- visOptions(graph, highlightNearest = TRUE)
      graph <- visPhysics(graph, solver = "barnesHut", stabilization = TRUE)
      visEvents(
        graph,
        selectEdge = sprintf(
          paste0(
            "function(properties) {",
            "Shiny.setInputValue('%s', properties.edges[0], {priority: 'event'});",
            "}"
          ),
          session$ns("selected_edge")
        )
      )
    })

    output$edge_details <- renderUI({
      edge_id <- input$selected_edge
      if (is.null(edge_id)) {
        return(div(
          class = "missing-state",
          "Select an edge to inspect its assay and provenance."
        ))
      }

      interaction <- network$get_interaction(selected_variant(), edge_id)
      if (is.null(interaction)) {
        return(div(class = "missing-state", "No matching interaction record."))
      }

      tags$dl(
        class = "compact-definition",
        tags$dt("Partner"), tags$dd(interaction$partner),
        tags$dt("State"), tags$dd(interaction$state),
        tags$dt("Evidence"), tags$dd(interaction$evidence_class),
        tags$dt("Assay"), tags$dd(interaction$assay),
        tags$dt("Model"), tags$dd(interaction$model),
        tags$dt("Source"), tags$dd(interaction$source_location)
      )
    })
  })
}
