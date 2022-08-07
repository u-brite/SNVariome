# This was used to create an igraph for our data
library(wppi)
omnipath_data <- wppi_omnipath_data(datasets = 'omnipath')
db <- wppi_data(datasets = c('omnipath', 'kinaseextra'))


library(visNetwork)
library(geomnet)
library(igraph)

graph <- graph_from_data_frame(edges, directed = FALSE)
#Louvain Comunity Detection
cluster <- cluster_louvain(graph)
