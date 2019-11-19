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

# Disconnect db
onStop(function() {
  dbDisconnect(connection)
})