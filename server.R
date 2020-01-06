##### Execute methods from global.R to render in ui.R #####

# Libraries called
library(shiny)
library(RMySQL)

# Server method
server = function(input, output) {
  # Render circle
  renderCircle = reactive({
    # Define paramaters for queries
    tmp_target = checkTarget(target = input$target)
    tmp_participant = checkParticipant(participant = input$participant)
    tmp_condition = checkCondition(condition = input$condition)
    str_condition = buildStringCondition(condition = tmp_condition)
    # Get all averages needed to build table in UI
    averages = getAverages(target = tmp_target, participant = tmp_participant, condition = str_condition)
    # Build table in UI
    return(tableBuilder(averages = averages))
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