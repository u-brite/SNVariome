library(shiny)
library(mygene)
library(DT)
library(shinyjs)
library(shinythemes)
library(bslib)

uab_theme <- bs_theme(
  bg = "white", fg = "#144B39", primary = "#1E6B52", secondary = "#88C408",
  base_font = font_google("Poppins")
)


shinyUI(
  navbarPage(
    inverse = FALSE,
    title = "SNVariome",
    theme = uab_theme,
    tabPanel(
      "Data table",
      sidebarLayout(
        sidebarPanel(textInput("accession", "Input Gene or Variant", value = "NM_000680.3"),
          width = 2
        ),
        mainPanel(dataTableOutput("mygene_table"),
          width = 8
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
