if (file.exists("renv")) {
  source("renv/activate.R")
} else {
  # rsconnect skips the renv directory during deployment.
  message("No 'renv' directory found; renv will not be activated.")
}

# Resolve box modules from the project root.
options(box.path = getwd())
