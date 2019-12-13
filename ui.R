##### Control the layout and appearance #####

# Libraries called
library(shiny)
library(RMySQL)

# UI method
ui = fluidPage(
  # Include CSS file
  includeCSS("custom.css"),
  fluidRow(
    # Title
    column(width = 12,
           titlePanel(title = "Eye Tracking Accuracy Test")
    ),
    # Dropdowns
    column(width = 3,
           uiOutput("dropdown_targets"),
           uiOutput("dropdown_participants")
    ),
    # Table for circle
    column(width = 9,
           uiOutput("ui_circles")
    )
  )
)

# Instantiate UI
shinyUI(ui)