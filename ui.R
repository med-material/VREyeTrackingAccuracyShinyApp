##### Control the layout and appearance #####

# Libraries called
library(shiny)
library(RMySQL)

# UI method
ui = fluidPage(
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
             choices = c("All Targets", "Other Target"),
             selected = "All Targets"
           ),
           selectInput(
             inputId = "participant",
             label = "Participant",
             choices = c("All Participants", "Other Participant"),
             selected = "All Participants"
           )
    )
  )
)

# Instantiate UI
shinyUI(ui)