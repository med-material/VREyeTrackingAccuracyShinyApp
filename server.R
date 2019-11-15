##### Execute methods from global.R to render in ui.R #####

# Libraries called
library(shiny)
library(RMySQL)

# Server method
server = function(input, output) {
  output$text = renderText({
    textInit()
  })
}

# Initialize server
shinyServer(server)