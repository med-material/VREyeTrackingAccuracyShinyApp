##### Execute methods from global.R to render in ui.R #####

# Libraries called
library(shiny)
library(RMySQL)

# Server method
server = function(input, output) {
  # Render active query
  render = reactive({
    # Nothing selected
    if (input$target == "All Targets" && input$participant == "All Participants") {
      queryBuilder(query_number = 4)
    }
    # Only participant selected
    else if (input$target == "All Targets") {
      queryBuilder(query_number = 3, participant = input$participant)
    }
    # Only target selected
    else if (input$participant == "All Participants") {
      queryBuilder(query_number = 1, target = input$target)
    }
    # Target and participant selected
    else {
      queryBuilder(query_number = 2, target = input$target, participant = input$participant)
    }
  })
  # Render a circle
  renderCircle = reactive({
    if (input$target != "All Targets" && input$participant != "All Participants") {
      cell = drawCell(target = input$target, participant = input$participant)
      htmlRenderTarget(cell)
    }
  })
  # Output query
  output$ui_query = renderUI({
    render()
  })
  # Output circle
  output$ui_circles = renderUI({
    renderCircle()
  })
}

# Initialize server
shinyServer(server)