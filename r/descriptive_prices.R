# Remember it is good coding technique to add additional packages to the top of
# your script 
library(lubridate) # for working with dates
library(ggplot2)  # for creating graphs
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
library(plotly) # interactive plots based on ggplot

# function to create subsets for periods
func_period <- function(f,x,y){f[f$date >= x & f$date <= y,]}

# use a working directory
setwd("/Volumes/Dessau HD/BachCloud/BTSync/FormerDropbox/PostDoc Food Riots/food-riots_data")

# read price data from csv, note that the first row is a date
## colClasses can specify the data type: , colClasses=c("date"="date") this however currently throws an error
## sometimes row.names="id" throws an error
v_prices <- read.csv("csv/prices.csv", header=TRUE, sep = ",") # this file is currently not the best choice
v_pricesWheat <- read.csv("csv/prices_wheat-kile.csv", header=TRUE, sep = ",")
v_pricesBread <- read.csv("csv/prices_bread-kg.csv", header=TRUE, sep = ",") # this file throws an error

# convert date to Date class
# v_prices$date <- as.Date(v_prices$date)
v_pricesWheat$date <- as.Date(v_pricesWheat$date)

# create a subset of rows based on conditions
v_wheatKile <- subset(v_pricesWheat,commodity.1=="wheat" & unit.1=="kile" & commodity.2=="currency" & unit.2=="ops")
v_barleyKile <- subset(v_prices,commodity.1=="barley" & unit.1=="kile")

## specify period
v_dateStart <- as.Date("1875-01-01")
v_dateStop <- as.Date("1916-12-31")
v_wheatKilePeriod <- func_period(v_wheatKile,v_dateStart,v_dateStop) 

# select rows
## select the first row (containing dates), and the rows containing prices in ops
v_wheatKileSimple <- v_wheatKilePeriod[,c(1,8,11)]

# descriptive stats
## quick summary
summary(v_wheatKileSimple)
