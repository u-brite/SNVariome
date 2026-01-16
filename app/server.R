library(shiny)
library(DT)
library(shinyjs)
library(shinythemes)
library(myvariant)

shinyServer(function(input, output) {
  
  myvar_results <- reactive({
    queryVariants(input$variant, scopes=c("clinvar.gene.symbol", "clinvar.rcv.accession", "clinvar.rsid", "dbnsfp.clinvar.hgvs"), fields="clinvar.gene.symbol, clinvar.rsid, clinvar.type, dbnsfp.clinvar.trait, dbnsfp.clinvar.review")
  })
  
  # mygene_results <- reactive({
  #   queryMany(input$accession, scopes="accession", fields=c("entrezgene", "symbol", "name", "summary"), species="human")
  # })
  
  output$citeus <- renderText({ invisible("Shaurita Hutchins, Bernhard Hane, Oladosu Tosin Ayodeji, Bharat Mishara, Hailey Jori Levi, Pooja Singaravelu (2022).") })
  
  
  output$myvar_table <- renderDataTable({as.data.frame(myvar_results())})
})
