require('move')
library('lubridate')

rFunction = function(startTimestamp, endTimestamp, data) {
    if(is.na(interval(paste0(startTimestamp, "/", endTimestamp)))) {
      start <- strptime(startTimestamp, "%Y-%m-%dT%H:%M:%S")
      end <- strptime(endTimestamp, "%Y-%m-%dT%H:%M:%S")
      if(!is.na(start)) {
        print(paste0("Dropping coordinates before ", startTimestamp))
        filteredData(data, function(timestamp) {
          timestamp >= start
        })
      } else if(!is.na(end)) {
        print(paste0("Dropping coordinates after ", endTimestamp))
        filteredData(data, function(timestamp) {
          timestamp <= end
        })
      } else {
        print("no timestamp -> Return data")
        data
      }
    } else {
      timestampInterval = interval(paste0(startTimestamp, "/", endTimestamp))
      print(paste0("start filtering within interval: ", timestampInterval))

      filteredData(data, function(timestamp) {
        timestamp %within% timestampInterval
      })
    }
}

filteredData <- function(data, filterFunction) {
  filteredTimestamps = vector()
  filteredLatitudes = vector()
  filteredLongitudes = vector()

  timestamps = as.POSIXct(data$timestamp, format="%Y-%m-%dT%H:%M:%S", tz="GMT")
  for (i in 1:length(timestamps)) {
    timestamp = timestamps[i]
    if(filterFunction(timestamp)) {
      filteredTimestamps[length(filteredTimestamps)+1] <- timestamp
      filteredLatitudes[length(filteredLatitudes)+1] <- data$location_lat[i]
      filteredLongitudes[length(filteredLongitudes)+1] <- data$location_long[i]
    }
  }

  print(paste0("finished filtering and found ", length(filteredTimestamps), " coordinates"))
  if(length(filteredTimestamps) == 0) {
    filteredTimestamps[1] <- 0
    filteredLatitudes[1] <- 0
    filteredLongitudes[1] <- 0
  }

  move(x=filteredLongitudes, y=filteredLatitudes, time=as.POSIXct(x = filteredTimestamps, "1970-01-01", tz = "GMT"), proj=CRS("+proj=longlat +ellps=WGS84"))
}

