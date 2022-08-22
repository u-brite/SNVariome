library(shiny)
library(DT)
library(shinyjs)
library(shinythemes)
library(bslib)
library(myvariant)

uab_theme <- bs_theme(
  bg = "#144B39", fg = "white", primary = "#1E6B52", secondary = "#88C408",
  base_font = font_google("Roboto Mono")
)


shinyUI(
  navbarPage(
    inverse = FALSE,
    title = "SNVariome",
    theme = uab_theme,
    tabPanel(
      "Data table",
      sidebarLayout(
        sidebarPanel(textInput("variant", "Input RSID or Gene Symbol", value = "rs756206533, BRCA1"),
          width = 3
        ),
        mainPanel(dataTableOutput("myvar_table"),
          width = 9
        )
      )
    ),
  navbarMenu(
    "About",
    tabPanel("Team",
             includeMarkdown("team.md")),
    tabPanel("FAQS",
             includeMarkdown("about.md"))
  )
)
)
