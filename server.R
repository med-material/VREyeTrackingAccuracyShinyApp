##### Execute methods from global.R to render in ui.R #####

# Libraries called
library(shiny)
library(RMySQL)

# Server method
server = function(input, output) {
  # Render a circle
  renderCircle = reactive({
    # 
    if (is.null(input$target) || is.null(input$participant)) {
      return("No value availible inside dropdowns.")
    }
    # Nothing selected
    else if (input$target == "All Targets" && input$participant == "All Participants") {
      cell_upper_l = drawCell(target = "UpperLeft")
      cell_upper_c = drawCell(target = "UpperCenter")
      cell_upper_r = drawCell(target = "UpperRight")
      cell_middle_l = drawCell(target = "MiddleLeft")
      cell_middle_c = drawCell(target = "MiddleCenter")
      cell_middle_r = drawCell(target = "MiddleRight")
      cell_bottom_l = drawCell(target = "BottomLeft")
      cell_bottom_c = drawCell(target = "BottomCenter")
      cell_bottom_r = drawCell(target = "BottomRight")
      return(htmlRenderTargets(cell_upper_l, cell_upper_c, cell_upper_r, cell_middle_l, cell_middle_c, cell_middle_r, cell_bottom_l, cell_bottom_c, cell_bottom_r))
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
      return(htmlRenderTargets(cell_upper_l, cell_upper_c, cell_upper_r, cell_middle_l, cell_middle_c, cell_middle_r, cell_bottom_l, cell_bottom_c, cell_bottom_r))
    }
    # Only target selected
    else if (input$participant == "All Participants") {
      cell = drawCell(target = input$target)
      return(htmlRenderTarget(cell))
    }
    # Target and participant selected
    else {
      cell = drawCell(target = input$target, participant = input$participant)
      return(htmlRenderTarget(cell))
    }
  })
  
  # Output circle
  output$ui_circles = renderUI({
    renderCircle()
  })
  
  # Render for Targets dropdown
  renderTargets = reactive({
    selectInput(
      inputId = "target",
      label = "Targets",
      choices = c("All Targets", getTargets()),
      selected = "All Targets"
    )
  })
  
  # Output target dropdown
  output$dropdown_targets = renderUI({
    renderTargets()
  })
  
  # Render for Participants dropdown
  renderParticipants = reactive({
    selectInput(
      inputId = "participant",
      label = "Participant",
      choices = c("All Participants", getParticipants()),
      selected = "All Participants"
    )
  })
  
  # Output participant dropdown
  output$dropdown_participants = renderUI({
    renderParticipants()
  })
  
  # Render a Condition dropdown
  renderConditions = reactive({
    if (input$participant == "All Participants" || is.null(input$participant)) {
      tmp_participant = NULL
    }
    else {
      tmp_participant = input$participant
    }
    return(
      checkboxGroupInput(
        inputId = "condition",
        label = "Condition",
        choices = c(getConditions(participant = tmp_participant))
      )
    )
  })
  
  # Output condition dropdown
  output$checkbox_conditions = renderUI({
    renderConditions()
  })
}


# Initialize server
shinyServer(server)