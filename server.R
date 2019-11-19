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
    # Nothing selected
    if (input$target == "All Targets" && input$participant == "All Participants") {
      cell_upper_l = drawCell(target = "UpperLeft")
      cell_upper_c = drawCell(target = "UpperCenter")
      cell_upper_r = drawCell(target = "UpperRight")
      cell_middle_l = drawCell(target = "MiddleLeft")
      cell_middle_c = drawCell(target = "MiddleCenter")
      cell_middle_r = drawCell(target = "MiddleRight")
      cell_bottom_l = drawCell(target = "BottomLeft")
      cell_bottom_c = drawCell(target = "BottomCenter")
      cell_bottom_r = drawCell(target = "BottomRight")
      htmlRenderTargets(cell_upper_l, cell_upper_c, cell_upper_r, cell_middle_l, cell_middle_c, cell_middle_r, cell_bottom_l, cell_bottom_c, cell_bottom_r)
    }
    # Only participant selected
    else if (input$target == "All Targets") {
      cell_upper_l = drawCell(target = "UpperLeft", participant = input$participant)
      cell_upper_c = drawCell(target = "UpperCenter", participant = input$participant)
      cell_upper_r = drawCell(target = "UpperRight", participant = input$participant)
      cell_middle_l = drawCell(target = "MiddleLeft", participant = input$participant)
      cell_middle_c = drawCell(target = "MiddleCenter", participant = input$participant)
      cell_middle_r = drawCell(target = "MiddleRight", participant = input$participant)
      cell_bottom_l = drawCell(target = "BottomLeft", participant = input$participant)
      cell_bottom_c = drawCell(target = "BottomCenter", participant = input$participant)
      cell_bottom_r = drawCell(target = "BottomRight", participant = input$participant)
      htmlRenderTargets(cell_upper_l, cell_upper_c, cell_upper_r, cell_middle_l, cell_middle_c, cell_middle_r, cell_bottom_l, cell_bottom_c, cell_bottom_r)
    }
    # Only target selected
    else if (input$participant == "All Participants") {
      cell = drawCell(target = input$target)
      htmlRenderTarget(cell)
    }
    # Target and participant selected
    else {
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