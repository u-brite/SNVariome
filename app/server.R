library(shiny)
library(DT)
library(shinyjs)
library(shinythemes)
library(myvariant)

shinyServer(function(input, output) {
  
  myvar_results <- reactive({
    queryVariants(input$variant, scopes=c("clinvar.gene.symbol", "clinvar.rcv.accession", "clinvar.rsid", "dbnsfp.clinvar.hgvs"), fields="clinvar.gene.symbol, clinvar.rsid, clinvar.type, dbnsfp.clinvar.trait, dbnsfp.clinvar.review")
  })
  
  output$citeus <- renderText({ invisible("Shaurita Hutchins, Bernhard Hane, Oladosu Tosin Ayodeji, Bharat Mishara, Hailey Jori Levi, Pooja Singaravelu (2022).") })
  
  
  output$myvar_table <- renderDataTable({subset(as.data.frame(myvar_results()), select = -c(2,3,4,8))}, width = "100%", height = "auto")
})
