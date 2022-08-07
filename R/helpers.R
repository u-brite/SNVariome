# This was used to create an igraph for our data
library(wppi)
omnipath_data <- wppi_omnipath_data(datasets = 'omnipath')
db <- wppi_data(datasets = c('omnipath', 'kinaseextra'))
