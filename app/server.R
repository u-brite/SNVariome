library(shiny)
library(mygene)
library(DT)
library(shinyjs)
library(shinythemes)

shinyServer(function(input, output) {
  
  mygene_results <- reactive({
    queryMany(input$accession, scopes="accession", fields=c("entrezgene", "symbol", "name", "summary"), species="human")
  })
  
  output$citeus <- renderText({ invisible("Shaurita Hutchins, Bernhard Hane, Oladosu Tosin Ayodeji, Bharat Mishara, Hailey Jori Levi, Pooja Singaravelu (2022).") })
  
  
  output$mygene_table <- renderDataTable({as.data.frame(mygene_results())})
})