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

# Get participant number availible in db
getConditions = function(participant = NULL) {
  if (is.null(participant)) {
    tmp_query = 'SELECT CustomCondition FROM eye_tracking GROUP BY CustomCondition ORDER BY CustomCondition ASC'
  } else {
    tmp_query = paste('SELECT CustomCondition FROM eye_tracking WHERE ParticipantNumber =', participant, 'GROUP BY CustomCondition ORDER BY CustomCondition ASC', sep = ' ')
  }
  tmp_conditions = data(tmp_query)
  tmp_conditions = tmp_conditions[[1]]
  return(tmp_conditions)
}

# Check input target value
checkTarget = function(target = NULL) {
  tmp_target = if (is.null(target) || target == "All Targets") NULL else target
  return(tmp_target)
}

# Check input participant value
checkParticipant = function(participant = NULL) {
  tmp_participant = if (is.null(participant) || participant == "All Participants") NULL else participant
  return(tmp_participant)
}

# Check input condition value
checkCondition = function(condition = NULL) {
  tmp_condition = if (is.null(condition) || condition == "All Conditions") NULL else condition
  return(tmp_condition)
}

# Build string part of query for conditions
buildStringCondition = function(condition = NULL) {
  str_condition = NULL
  # Set query with conditions
  if (!is.null(condition)) {
    if (length(condition) == 1) {
      str_condition = condition[1]
    } else {
      str_condition = condition[1]
      for (i in 2:length(condition)) {
        str_condition = paste(str_condition, '" OR CustomCondition = "', condition[i], sep = '')
      }
    }
  }
  return(str_condition)
}
# Query builder for any average
queryBuilder = function(query_arg = 1, target = NULL, participant = NULL, condition = NULL) {
  # Basic query
  tmp_query = paste('SELECT AVG(EyeTrackAccuracy) FROM eye_tracking', sep = '')
  # Build queries
  switch(query_arg,
         # 1 -> no participant, no condition
         return(paste(tmp_query, ' WHERE CircleName = "', target, '"', sep = '')),
         # 2 -> no participant, condition
         return(paste(tmp_query, ' WHERE CircleName = "', target, '" AND (CustomCondition = "', condition, '")', sep = '')),
         # 3 -> participant, no condition
         return(paste(tmp_query, ' WHERE CircleName = "', target, '" AND Participantnumber = ', participant, sep = '')),
         # 4 -> participant, condition
         return(paste(tmp_query, ' WHERE CircleName = "', target, '" AND Participantnumber = ', participant, ' AND (CustomCondition = "', condition, '")', sep = '')),
         # Default
         return(tmp_query)
  )
}

# Get average from a query
average = function(query = NULL) {
  tmp_average = dbGetQuery(connection, query)
  return(tmp_average[["AVG(EyeTrackAccuracy)"]])
}

# Return all averages values needed to build table in UI
getAverages = function(target = NULL, participant = NULL, condition = NULL) {
  averages = NULL
  # No target
  if (is.null(target)) {
    target_list = c("UpperLeft", "UpperCenter", "UpperRight", "MiddleLeft", "MiddleCenter", "MiddleRight", "BottomLeft", "BottomCenter", "BottomRight")
    # No participant, no condition
    if (is.null(participant) && is.null(condition)) {
      # Get average of each circle in UI
      for(i in 1:9) {
        averages[i] = average(query = queryBuilder(query_arg = 1, target = target_list[i]))
      }
    }
    # No participant, condition
    else if (is.null(participant) && !is.null(condition)) {
      # Get average of each circle in UI
      for(i in 1:9) {
        averages[i] = average(query = queryBuilder(query_arg = 2, target = target_list[i], condition = condition))
      }
    }
    # Participant, no condition
    else if (!is.null(participant) && is.null(condition)) {
      # Get average of each circle in UI
      for(i in 1:9) {
        averages[i] = average(query = queryBuilder(query_arg = 3, target = target_list[i], participant = participant))
      }
    }
    # Participant, condition
    else {
      # Get average of each circle in UI
      for(i in 1:9) {
        averages[i] = average(query = queryBuilder(query_arg = 4, target = target_list[i], participant = participant, condition = condition))
      }
    }
  }
  # Target
  else {
    # No participant, no condition
    if (is.null(participant) && is.null(condition)) {
      # Get average of circle in UI
      averages[1] = average(query = queryBuilder(query_arg = 1, target = target))
    }
    # No participant, condition
    else if (is.null(participant) && !is.null(condition)) {
      # Get average of each circle in UI
      averages[1] = average(query = queryBuilder(query_arg = 2, target = target, condition = condition))
    }
    # Participant, no condition
    else if (!is.null(participant) && is.null(condition)) {
      # Get average of each circle in UI
      averages[1] = average(query = queryBuilder(query_arg = 3, target = target, participant = participant))
    }
    # Participant, condition
    else {
      # Get average of each circle in UI
      averages[1] = average(query = queryBuilder(query_arg = 4, target = target, participant = participant, condition = condition))
    }
  }
  return(averages)
}

# Builder for a table in HTML page
tableBuilder = function(averages = NULL) {
  return(
    tags$table(
      class = "table_setting",
      rowBuilder(averages = averages)
    )
  )
}

# Builder for rows in table in HTML page
rowBuilder = function(averages = NULL) {
  # Check if only target is selected
  if (length(averages) == 1) {
    return(
      tags$div(
        tags$tr(
          cellBuilder(average = averages[1])
        )
      )
    )
  }
  # Then all targets are selected
  else {
    return(
      tags$div(
        tags$tr(
          cellBuilder(average = averages[1]),
          cellBuilder(average = averages[2]),
          cellBuilder(average = averages[3])
        ),
        tags$tr(
          cellBuilder(average = averages[4]),
          cellBuilder(average = averages[5]),
          cellBuilder(average = averages[6])
        ),
        tags$tr(
          cellBuilder(average = averages[7]),
          cellBuilder(average = averages[8]),
          cellBuilder(average = averages[9])
        )
      )
    )
  }
}

# Builder for cell of table rows in HTML page
cellBuilder = function(average = NULL) {
  # Get sizes of different circles
  width = average * 200
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
    tags$td(
      class = "outer_circle",
      style = tmp_style,
      showAverage(average = average, margin = width),
      drawCircle(width = width, color = color)
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
