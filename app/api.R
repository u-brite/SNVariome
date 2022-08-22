library(httr)
library(jsonlite)
library(xml2)

# API End point from Sigcom LINCS
server2 <- "https://maayanlab.cloud/sigcom-lincs/metadata-api/signatures/{HTR1A}"
server <- "https://ldp3.cloud/metadata-api/libraries/find"

payload <- '{"filter": {
  "where": {
    "meta": {
        "fullTextSearch": "proteomics"}},
    "limit": 2}}'
  
r <- POST(paste(server), body = payload, encode = "json", content_type("application/json"))

stop_for_status(r)

#head(data.frame(t(sapply(content(r),c))))
head(fromJSON(toJSON(content(r))))