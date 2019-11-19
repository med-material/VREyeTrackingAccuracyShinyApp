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
           selectInput(
             inputId = "target",
             label = "Targets",
             choices = c("All Targets", getTargets()),
             selected = "All Targets"
           ),
           selectInput(
             inputId = "participant",
             label = "Participant",
             choices = c("All Participants", getParticipants()),
             selected = "All Participants"
           )
    ),
    # Active query
    column(width = 9,
      uiOutput("ui_query"),
      uiOutput("ui_circles")
    )
  )
)

# Instantiate UI
shinyUI(ui)