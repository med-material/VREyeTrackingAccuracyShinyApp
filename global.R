##### Methods called by main program (server and ui) #####

# Libraries called
library(shiny)
library(RMySQL)

# Get DB informations
db_informations = read.csv(
  "db_informations.csv", header=TRUE, sep=",", colClasses=c("character", "character", "character", "character")
)

# DB connection
connection = DBI::dbConnect(
  MySQL(),
  user = db_informations[1, "user"],
  password = db_informations[1, "password"],
  host = db_informations[1, "host"],
  dbname = db_informations[1, "dbname"])

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
  # Get sizes of different circles
  width = circle_size * 200
  circle_max_size = 200
  # Operations to define circles color
  red_coef = 0.47
  red_max = 254
  red_color = as.integer(red_coef*(width-circle_max_size)+red_max)
  green_coef = -1.025
  green_max = 50
  green_color = as.integer(green_coef*(width-circle_max_size)+green_max)
  blue_coef = 0.245
  blue_max = 49
  blue_color = as.integer(blue_coef*(width-circle_max_size)+blue_max)
  color = paste(red_color, ', ', green_color, ', ', blue_color, sep = '')
  tmp_style = paste('border-color: rgb(', color, '); background-color: rgba(', color, ', 0.2);', sep = '')
  return(
    tags$div(
      tags$td(
        class = "outer_circle",
        style = tmp_style,
        showAverage(average = circle_size, margin = width),
        drawCircle(width = width, color = color)
      )
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

# Print values of circles
showAverage = function(average = 1, margin = 0) {
  margin = 60 + margin / 2
  tmp_style = paste('margin-top: ', margin, 'px;', sep = '')
  return(
    tags$div(
      class = "average_txt",
      style = tmp_style,
      round(average, digits = 2)
    )
  )
}

# Disconnect db
onStop(function() {
  dbDisconnect(connection)
})
