BASE_URI = 'http://api.indeed.com/ads/apisearch'
API_KEY = '6564792173922206'
END_OF_URI = '&sort=&radius=&limit=100&latlong=1&v=2&format=json'
RELEVANT_KEYS = ["jobtitle", "company", "formattedLocation", "date", "source", "snippet", "url", "formattedRelativeTime", "latitude", "longitude"]
LOCS_LIMIT = 9 # 10 locations is the max, so 9 is the max array index
NO_RESULTS_ERROR_MSG = "Your search did not match any jobs."
ERROR_MSGS = ["Please type one or more locations, separated by commas.", "too many locations", "invalid query", "loc list nil"]


BASE_URI2 = 'http://api2.walkscore.com/api/v1/traveltime/json?wsapikey'
API_KEY2 = '94db5d1a5e559d9e830fea3894f9d6e0'
END_OF_URI2 = 'mode=walk&origin=34.013579, -118.495999&destination=47.646757,-122.361152&
destination=47.6517,-122.3545'
RELEVANT_KEYS2 = ["status", "error", "mode", "origin", "destination", "wsapikey", "travel_times", "seconds", "unroutable"]
LOCS_LIMIT2 = 9
NO_RESULT_ERROR_MSG2 = "Your search did not match any jobs"
ERROR_MSGS2 = ["Please type one or more locations, seperated by commas." "too many locations", "invalid query", "loc list nil"]



# mode => string
# origin => integer (coordinate)
# destination => integer (coordinate)
# travel_times => integer (seconds)

