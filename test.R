print("Hello, World")
print(paste("Root: ", getwd(), sep = ""))

repo                  <- list()
repo$root             <- paste(getwd(), "/", sep = "")
repo$data             <- paste(repo$root, "/data/", sep = "")
repo$results          <- paste(repo$root, "/results/", sep = "")
config                <- list()
config$data_util_rate <- c("dev" = .01, "prod" = 1)

print(paste("RRUN_TYPE: ", RRUN_TYPE, "\n"))
print(paste("data_util_rate: ", config$data_util_rate[RRUN_TYPE]))