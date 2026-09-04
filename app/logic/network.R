state_colors <- c(
  "Gained" = "#00876C",
  "Lost" = "#B91C1C",
  "Strengthened" = "#3A7D44",
  "Weakened" = "#D97706",
  "Unchanged" = "#64748B",
  "Predicted disruption" = "#7C3AED",
  "Unmeasured" = "#94A3B8"
)

state_dashes <- c(
  "Direct experimental" = FALSE,
  "Curated clinical" = FALSE,
  "Computational prediction" = TRUE,
  "Contextual association" = TRUE,
  "Conflicting" = TRUE,
  "Missing" = TRUE
)

#' Convert one variant's interaction records into visNetwork tables.
#' @export
build_network_data <- function(variant) {
  interactions <- variant$interactions
  variant_node <- data.frame(
    id = variant$variant_id,
    label = paste(variant$identity$gene, variant$identity$protein_hgvs),
    group = "variant",
    title = "Selected variant",
    stringsAsFactors = FALSE
  )

  if (length(interactions) == 0L) {
    return(list(nodes = variant_node, edges = empty_edges()))
  }

  partner_nodes <- do.call(rbind, lapply(interactions, function(interaction) {
    data.frame(
      id = interaction$partner,
      label = interaction$partner,
      group = "partner",
      title = interaction$partner_uniprot %||% "UniProt accession unavailable",
      stringsAsFactors = FALSE
    )
  }))
  partner_nodes <- partner_nodes[!duplicated(partner_nodes$id), , drop = FALSE]

  edges <- do.call(rbind, lapply(interactions, function(interaction) {
    data.frame(
      id = interaction$interaction_id,
      from = variant$variant_id,
      to = interaction$partner,
      label = interaction$state,
      color = unname(state_colors[[interaction$state]]),
      dashes = unname(state_dashes[[interaction$evidence_class]]),
      title = paste(interaction$assay, interaction$source_location, sep = " | "),
      stringsAsFactors = FALSE
    )
  }))

  list(nodes = rbind(variant_node, partner_nodes), edges = edges)
}

#' Return a single interaction record by its stable identifier.
#' @export
get_interaction <- function(variant, interaction_id) {
  matches <- Filter(
    function(interaction) identical(interaction$interaction_id, interaction_id),
    variant$interactions
  )
  if (length(matches) == 0L) NULL else matches[[1]]
}

empty_edges <- function() {
  data.frame(
    id = character(),
    from = character(),
    to = character(),
    label = character(),
    color = character(),
    dashes = logical(),
    title = character(),
    stringsAsFactors = FALSE
  )
}

`%||%` <- function(value, fallback) {
  if (is.null(value) || identical(value, "")) fallback else value
}
