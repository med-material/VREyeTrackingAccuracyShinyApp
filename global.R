##### Methods called by main program (server and ui) #####

# Libraries called
library(shiny)
library(RMySQL)

# Method test to return text
textInit = function() {
  return(
    "This is a test."
  )
}