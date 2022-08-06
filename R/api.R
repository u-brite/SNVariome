library(httr)
library(jsonlite)
library(xml2)

# API End point from Sigcom LINCS
server <- "https://maayanlab.cloud/sigcom-lincs/metadata-api/resources/count"
  
r <- GET(paste(server), content_type("application/json"))

stop_for_status(r)

head(data.frame(t(sapply(content(r),c))))
head(fromJSON(toJSON(content(r))))