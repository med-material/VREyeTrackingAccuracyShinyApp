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

# Disconnect db
onStop(function() {
  dbDisconnect(connection)
})