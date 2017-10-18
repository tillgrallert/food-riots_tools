# Remember it is good coding technique to add additional packages to the top of
# your script 
library(lubridate) # for working with dates
library(ggplot2)  # for creating graphs
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
library(plotly) # interactive plots based on ggplot

# function to create subsets for periods
funcPeriod <- function(f,x,y){f[f$date >= x & f$date <= y,]}

# use a working directory
setwd("/Volumes/Dessau HD/BachCloud/BTSync/FormerDropbox/FoodRiots/food-riots_data")

# 1. read price data from csv, note that the first row is a date
vPricesWheat <- read.csv("csv/prices_wheat-kile.csv", header=TRUE, sep = ",", quote = "")

# convert date to Date class
vPricesWheat$date <- as.Date(vPricesWheat$date)

# aggregate periods
## use cut() to generate summary stats for time periods
## create variables of the year, quarter week and month of each observation:
vPricesWheat$year <- as.Date(cut(vPricesWheat$date,
                                breaks = "year"))
vPricesWheat$quarter <- as.Date(cut(vPricesWheat$date,
                                   breaks = "quarter"))
vPricesWheat$month <- as.Date(cut(vPricesWheat$date,
                                 breaks = "month"))
vPricesWheat$week <- as.Date(cut(vPricesWheat$date,
                                breaks = "week",
                                start.on.monday = TRUE)) # allows to change weekly break point to Sunday

# create a subset of rows based on conditions
vWheatKile <- subset(vpricesWheat,commodity.1=="wheat" & unit.1=="kile" & commodity.2=="currency" & unit.2=="ops")

# select rows
## select the first row (containing dates), and the rows containing prices in ops
## vwheatKileSimple <- vwheatKile[,c(1,8,11)]
vWheatKileSimple <- vwheatKile[,c("date","quantity.2","quantity.3")]


# 2. plot with ggplot
## plot_wheatKile <- ggplot(vwheatKileSimple, aes(date,quantity.2, quantity.3)) + ggtitle("Wheat prices in Bilad al-Sham") + xlab("Date") + ylab("Prices (piaster)") + geom_point(na.rm=TRUE, color="purple", size=3, pch=1)

## plot only for period
## specify period
vDateStart <- as.Date("1909-07-01")
vDateStop <- as.Date("1910-12-31")
vWheatKilePeriod <- funcPeriod(vWheatKile,vdateStart,vdateStop)  

## plot
plotWheatKilePeriod1 <- ggplot(vWheatKilePeriod, aes(date,quantity.2, quantity.3)) +
  ggtitle("Wheat prices in Bilad al-Sham") +
  xlab("Date") + ylab("Prices (piaster/kile)") +
  geom_point(na.rm=TRUE, color="purple", size=1, pch=3) +
  scale_x_date(breaks=date_breaks("1 years"), labels=date_format("%Y")) +
  stat_smooth(colour="green", method="loess") +
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  
## plot with two time series
plotWheatKilePeriod2 <- ggplot(vWheatKilePeriod, aes(x=date, y=value)) +
  ggtitle("Wheat prices in Bilad al-Sham") +
  xlab("Date") + ylab("Prices (piaster/kile)") +
  geom_point(aes(y=quantity.2, col='min price'), na.rm=TRUE, size=2, pch=1, color="black")  +
  geom_point(aes(y=quantity.3, col='max price'), na.rm=TRUE, size=2, pch=3, color="black") +
  scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) + # add interval to x-axis
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
## final plot
plotWheatKilePeriod1
plotWheatKilePeriod2
