# ################## #
# Data Processing    #
#                    #
# Author: Yi Zhang   #
# Date: AUG/27/2014  #
# ################## #
library(reshape2)
library(plyr)

# ################# #
# Environment       #
# ################# #
repo                  <- list()
repo$root             <- paste(getwd(), "/", sep = "")
repo$data             <- paste(repo$root, "/data/", sep = "")
repo$results          <- paste(repo$root, "/results/", sep = "")
config                <- list()
config$data_util_rate <- c("dev" = .01, "prod" = 1)
# Rscript: excution type "dev":development or "prod": production
RRUN_TYPE   <- commandArgs(trailingOnly=TRUE)
RDEP_LENGTH <- 120
# ######################### #
# Functions Definition ----
# ######################### #
getDataPath <- function(filename, dir = NA){
  if(is.na(dir)) dir <- repo$root
  res <- paste(dir, filename, sep="")
  return(res)
}

getDiff <- function(x){
  # x(t+1) - x(t)
  res <- x[ 2:length(x) ] - x[ 1:length(x)-1 ]
  return(res)
}

ts2mtx <- function(ts, dep_length =10, col_name_prefix = "ts", progress.bar = FALSE){ 
  # ############################### #
  # Trabsform time series to matrix #
  # ############################### #
  res <- matrix(data=0, nrow = length(ts) - dep_length, ncol = dep_length)
  colnames(res) <- paste(col_name_prefix, 
                         rev(seq(from=1, by=1, length.out=dep_length)), 
                         sep="_")
  for(i in 1:nrow(res)){
    window   <- seq(from=i, by=1, length.out = dep_length)
    window   <- rev(window)
    res[i, ] <- ts[window] 
  }
  return(res)
}

# ##################### #
# Load data -----------
# ##################### #
print(paste("**START_TIME: ", Sys.time(), "\n",sep=""))
print("**Loading data...\n")
X <- read.csv(file=paste(repo$data, "x.txt", sep=""), header=F, sep=" ")
Y <- read.csv(file=paste(repo$data, "y.txt", sep=""), header=F, sep=" ")
if(nrow(X) > 0) print("X had been load successfully...")
if(nrow(Y) > 0) print("Y had been load successfully...")
#单笔trade大小 bid_price ask_price bid_size ask_size
colnames(X) <- c("trade_size", "bid_price", "ask_price", "bid_size", "ask_size")
colnames(Y) <- c("trade_price")

# ##################### #
# Data Processing ------ 
# ##################### #
# Data Transformation:
# 1. eliminate the time dependency by retraining difference (t_n+1 - t_n)
# 2. assume influential variables, y_n+1 = f(x(1)_n,...x(1)_n-k+1, ...)
# 3. trade_price is encode as 1 for increase, 0 for non-increase

temp           <- list()
temp$obs_idx   <- seq(from=1, to=floor(nrow(X) * config$data_util_rate[RRUN_TYPE]) )
temp$save_nobs <- 1:length(temp$obs_idx)
# trade_price
print("** Processing trade_price as Y ... \n")
temp$y              <- getDiff(x=Y$trade_price[temp$obs_idx])
temp$y[temp$y >  0] <- 1
temp$y[temp$y <= 0] <- 0
temp$data <- ts2mtx(ts = temp$y, 
                    dep_length=RDEP_LENGTH + 1, 
                    col_name_prefix="trade_price_y")
write.table(x=temp$data[, 1], 
            file=getDataPath("TRADE_PRICE_Y_MTX.csv", dir=repo$data), 
            col.names = TRUE, row.names = FALSE, sep = ",")
print("TRADE_PRICE_Y_MTX.csv had been saved as result of success transformation!\n")
temp$data_size <- c()
temp$save_nobs <- 1:nrow(temp$data)

print("** Processing trade_price as X ... \n")
temp$y    <- getDiff(x=Y$trade_price[temp$obs_idx])
temp$data <- ts2mtx(ts = temp$y, 
                    dep_length=RDEP_LENGTH, 
                    col_name_prefix="trade_price")
write.table(x=temp$data[temp$save_nobs, ], 
            file=getDataPath("TRADE_PRICE_X_MTX.csv", dir=repo$data), 
            col.names = TRUE, row.names = FALSE, sep = ",")
print("TRADE_PRICE_X_MTX.csv had been saved as result of success transformation!\n")
temp$data_size <- c()

# trade_size
print("** Processing trade_size in X ... \n")
temp$data <- ts2mtx(ts = getDiff(x=X$trade_size[temp$obs_idx]), 
                    dep_length=RDEP_LENGTH, 
                    col_name_prefix="trade_size")
write.table(x=temp$data[temp$save_nobs, ], 
            file=getDataPath("TRADE_SIZE_MTX.csv", repo$data), 
            col.names = TRUE, row.names = FALSE, sep = ",")
print("TRADE_SIZE_MTX.csv had been saved as result of success transformation!\n")
temp$data_size <- c()

# bid_price
print("** Processing trade_size in X ... \n")
temp$data <- ts2mtx(ts = getDiff(x=X$bid_price[temp$obs_idx]), 
                    dep_length=RDEP_LENGTH, 
                    col_name_prefix="bid_price")
write.table(x=temp$data[temp$save_nobs, ], 
            file=getDataPath("BID_PRICE_MTX.csv", dir=repo$data), 
            col.names = TRUE, row.names = FALSE, sep = ",")
print("BID_PRICE_MTX.csv had been saved as result of success transformation!\n")
temp$data_size <- c()

# ask_price
print("** Processing trade_size in X ... \n")
temp$data <- ts2mtx(ts = getDiff(x=X$ask_price[temp$obs_idx]), 
                    dep_length=RDEP_LENGTH, 
                    col_name_prefix="ask_price")
write.table(x=temp$data[temp$save_nobs, ], 
            file=getDataPath("ASK_PRICE_MTX.csv", dir=repo$data), 
            col.names = TRUE, row.names = FALSE, sep = ",")
print("ASK_PRICE_MTX.csv had been saved as result of success transformation!\n")
temp$data_size <- c()

# bid_size
print("** Processing trade_size in X ... \n")
temp$data <- ts2mtx(ts = getDiff(x=X$bid_size[temp$obs_idx]), 
                    dep_length=RDEP_LENGTH, 
                    col_name_prefix="bid_size")
write.table(x=temp$data[temp$save_nobs, ], 
            file=getDataPath("BID_SIZE_MTX.csv", dir=repo$data), 
            col.names = TRUE, row.names = FALSE, sep = ",")
print("BID_SIZE_MTX.csv had been saved as result of success transformation!\n")
temp$data_size <- c()

# ask_size
print("** Processing trade_size in X ... \n")
temp$data <- ts2mtx(ts = getDiff(x=X$ask_size[temp$obs_idx]), 
                    dep_length=RDEP_LENGTH, 
                    col_name_prefix="ask_size")
write.table(x=temp$data[temp$save_nobs, ], 
            file=getDataPath("ASK_SIZE_MTX.csv", repo$data), 
            col.names = TRUE, row.names = FALSE, sep = ",")
print("ASK_SIZE_MTX.csv had been saved as result of success transformation!\n")
temp$data_size <- c()
print(paste("**END_TIME: ", Sys.time(), "\n",sep=""))
