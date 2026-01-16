# Load the httr, jsonlite, and xml2 packages
library(httr)
library(jsonlite)
library(xml2)

# Define the function
find_libraries <- function(full_text_search, limit) {
  # API End point from Sigcom LINCS
  server <- "https://ldp3.cloud/metadata-api/libraries/find"
  
  # Create the payload for the API request
  payload <- list(
    filter = list(
      where = list(
        meta = list(
          fullTextSearch = full_text_search
        )
      ),
      limit = limit
    )
  )
  
  # Send the API request
  r <- POST(paste(server), body = payload, encode = "json", content_type("application/json"))
  
  # Check the status of the API request
  stop_for_status(r)
  
  # Return the response from the API request
  fromJSON(toJSON(content(r)))
}

# Call the function to search for libraries with "proteomics" in their metadata
libraries <- find_libraries("proteomics", 2)

# View the first six rows of the response from the API
head(libraries)