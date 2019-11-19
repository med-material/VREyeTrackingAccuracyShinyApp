##### Methods called by main program (server and ui) #####

# Libraries called
library(shiny)
library(RMySQL)

# DB informations
user = 'yohann'
password = 'neraud'
host = '192.38.56.104'
dbname = 'vr_rehab'

# DB connection
connection = DBI::dbConnect(
  MySQL(),
  user = user,
  password = password,
  host = host,
  dbname = dbname)

# Get data from a query
data = function(query = NULL) {
  tmp_data = dbGetQuery(connection, query)
  return(tmp_data)
}

# Get target names availible in db 
getTargets = function() {
  tmp_targets = data('SELECT CircleName FROM eye_tracking GROUP BY CircleName ORDER BY CircleName ASC')
  tmp_targets = tmp_targets[[1]]
  return(tmp_targets)
}

# Get participant number availible in db
getParticipants = function() {
  tmp_participants = data('SELECT ParticipantNumber FROM eye_tracking GROUP BY ParticipantNumber ORDER BY ParticipantNumber ASC')
  tmp_participants = tmp_participants[[1]]
  return(tmp_participants)
}

# Query builder, to do all circle queries
queryBuilder = function(query_number = NULL, target = NULL, participant = NULL) {
  # Basic query
  tmp_query = paste('SELECT AVG(EyeTrackAccuracy) FROM eye_tracking', sep = ' ')
  # Build queries
  switch(query_number,
         # Target and no participant , '"BottomCenter"'
         return(paste(tmp_query, ' WHERE CircleName = "', target, '"', sep = '')),
         # Target and participant
         return(paste(tmp_query, ' WHERE CircleName = "', target, '" AND ParticipantNumber = ', participant, sep = '')),
         # No Target and participant
         return(paste(tmp_query, ' WHERE ParticipantNumber = ', participant, sep = '')),
         # Default query
         return(tmp_query)
  )
  # Return value
  return(tmp_query)
}

# Get average from a query
average = function(query = NULL) {
  tmp_average = dbGetQuery(connection, query)
  return(tmp_average[["AVG(EyeTrackAccuracy)"]])
}

# Draw grid target selected
htmlRenderTarget = function(cell) {
  return(
    tags$table(
      class = "table_setting",
      tags$tr(
        cell
      )
    )
  )
}

# Draw grid no target selected
htmlRenderTargets = function(cell_upper_l, cell_upper_c, cell_upper_r, cell_middle_l, cell_middle_c, cell_middle_r, cell_bottom_l, cell_bottom_c, cell_bottom_r) {
  return(
    tags$table(
      class = "table_setting",
      tags$tr(
        cell_upper_l,
        cell_upper_c,
        cell_upper_r
      ),
      tags$tr(
        cell_middle_l,
        cell_middle_c,
        cell_middle_r
      ),
      tags$tr(
        cell_bottom_l,
        cell_bottom_c,
        cell_bottom_r
      )
    )
  )
}

# Draw cell from the grid
drawCell = function(target = "UpperLeft", participant = "All Participants") {
  if (participant == "All Participants") {
    circle_size = average(queryBuilder(query_number = 1, target = target))
  } else {
    circle_size = average(queryBuilder(query_number = 2, target = target, participant = participant))
  }
  circle_size = circle_size * 200
  circle_max_size = 200
  red_coef = 0.47
  red_max = 254
  red_color = as.integer(red_coef*(circle_size-circle_max_size)+red_max)
  green_coef = -1.025
  green_max = 50
  green_color = as.integer(green_coef*(circle_size-circle_max_size)+green_max)
  blue_coef = 0.245
  blue_max = 49
  blue_color = as.integer(blue_coef*(circle_size-circle_max_size)+blue_max)
  color = paste(red_color, ', ', green_color, ', ', blue_color, sep = '')
  tmp_style = paste('border-color: rgb(', color, '); background-color: rgba(', color, ', 0.2);', sep = '')
  return(
    tags$td(
      class = "outer_circle",
      style = tmp_style,
      drawCircle(width = circle_size, color = color)
    )
  )
}

# Draw circle from a cell
drawCircle = function(width = 1, color = "black") {
  tmp_style = paste("background-color: rgb(", color, "); height: ", width, "px; width: ", width, "px;", sep = '')
  return(
    tags$div(
      class = "inner_circle",
      style = tmp_style
    )
  )
}

# Disconnect db
onStop(function() {
  dbDisconnect(connection)
})