##### Control the layout and appearance #####

# Libraries called
library(shiny)
library(RMySQL)

# UI method
ui = fluidPage(
  fluidRow(
    column(width = 12,
           titlePanel(title = "Eye Tracking Accuracy Test")
    ),
    column(width = 12,
           uiOutput("text")
    )
  )
)

# Instantiate UI
shinyUI(ui)