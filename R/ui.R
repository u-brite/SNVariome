library(shiny)
library(mygene)
library(DT)
library(shinyjs)
library(shinythemes)


shinyUI(
  navbarPage(inverse = TRUE,
             title = "SNVariome",
             theme = shinytheme("journal"),
             tabPanel("MyGene Tool",
                      tags$footer(verbatimTextOutput("citemygene"),
                      sidebarLayout(
                        sidebarPanel(textInput("accession", "Input Gene or Variant", value="NM_000680.3"),
                                     width = 4),
                        mainPanel(dataTableOutput('mygene_table'),
                                  width = 13)
                      )
             )),
             navbarMenu("About",
                        tabPanel("Links"),
                        tabPanel("Team",
                                 fluidRow(includeMarkdown("about.md")
                                   ),))
             ))
