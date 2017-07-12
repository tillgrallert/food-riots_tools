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

# 1. read price data from csv, note that the first row is a date
v_pricesWheat <- read.csv("csv/prices_wheat-kile.csv", header=TRUE, sep = ",")

# convert date to Date class
v_pricesWheat$date <- as.Date(v_pricesWheat$date)

# create a subset of rows based on conditions
v_wheatKile <- subset(v_pricesWheat,commodity.1=="wheat" & unit.1=="kile" & commodity.2=="currency" & unit.2=="ops")

# select rows
## select the first row (containing dates), and the rows containing prices in ops
v_wheatKileSimple <- v_wheatKile[,c(1,8,11)]


# 2. plot with ggplot
plot_wheatKile <- ggplot(v_wheatKileSimple, aes(date,quantity.2, quantity.3)) +
  ggtitle("Wheat prices in Bilad al-Sham") +
  xlab("Date") + ylab("Prices (piaster)") + 
  geom_point(na.rm=TRUE, color="purple", size=3, pch=1)

## plot only for period
## specify period
v_dateStart <- as.Date("1875-01-01")
v_dateStop <- as.Date("1916-12-31")
v_wheatKilePeriod <- func_period(v_wheatKileSimple,v_dateStart,v_dateStop)  

## plot
plot_wheatKilePeriod <- ggplot(v_wheatKilePeriod, aes(date,quantity.2, quantity.3)) +
  ggtitle("Wheat prices in Bilad al-Sham") +
  xlab("Date") + ylab("Prices (piaster)") +
  geom_point(na.rm=TRUE, color="purple", size=1, pch=3) +
  scale_x_date(breaks=date_breaks("1 years"), labels=date_format("%Y")) +
  stat_smooth(colour="green", method="loess")
  
## final plot
plot_wheatKilePeriod
