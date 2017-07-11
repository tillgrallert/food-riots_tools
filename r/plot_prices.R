# Remember it is good coding technique to add additional packages to the top of
# your script 
library(lubridate) # for working with dates
library(ggplot2)  # for creating graphs
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots

# use a working directory
setwd("/Volumes/Dessau HD/BachCloud/BTSync/FormerDropbox/PostDoc Food Riots/food-riots_data")

# read price data from csv, note that the first row is a date
## colClasses can specify the data type: , colClasses=c("date"="date") this however currently throws an error
## sometimes row.names="id" throws an error
v_prices <- read.csv("csv/prices.csv", header=TRUE, sep = ",") # this file is currently not the best choice
v_pricesWheat <- read.csv("csv/prices_wheat-kile.csv", header=TRUE, sep = ",")

# covert date to Date class
v_prices$date <- as.Date(v_prices$date)
v_pricesWheat$date <- as.Date(v_pricesWheat$date)

# create a subset of rows based on conditions
v_wheatKile <- subset(v_pricesWheat,commodity.1=="wheat" & unit.1=="kile" & commodity.2=="currency" & unit.2=="ops")
v_barleyKile <- subset(v_prices,commodity.1=="barley" & unit.1=="kile")

# select rows
## select the first row (containing dates), and the rows containing prices in ops
v_wheatKileSimple <- v_wheatKile[,c(1,8,11)]

# change data types, especially dates
## with line 16 above this is not necessary anymore
## v_pricesDates <- as.Date(v_prices[,c(1)], format = "%Y-%m-%d") # works but only returns the first column (of course)
## v_pricesDates[,c(1)] <- as.Date(v_prices[,c(1)], format = "%Y-%m-%d") # doesn't work
## v_wheatKilePrices[,c(1)] <- as.Date(v_wheatKilePrices[,c(1)], format = "%Y-%m-%d") # this works


# try to plot stuff
## 1. simple plot of prices with qplot
qplot(x=date, y=quantity.2,
      data=v_wheatKileSimple, na.rm=TRUE,
      main="Wheat prices",
      xlab="Date", 
      ylab="Price (piasters)")
