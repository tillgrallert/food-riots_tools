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
v_pricesBarley <- read.csv("csv/prices_barley-kile.csv", header=TRUE, sep = ",", quote = "")

# convert date to Date class
v_pricesBarley$date <- as.Date(v_pricesBarley$date)

# create a subset of rows based on conditions
v_barleyKile <- subset(v_pricesBarley,commodity.1=="barley" & unit.1=="kile" & commodity.2=="currency" & unit.2=="ops")

# select rows
## select the first row (containing dates), and the rows containing prices in ops
## v_barleyKileSimple <- v_barleyKile[,c(1,8,11)]
v_barleyKileSimple <- v_barleyKile[,c("date","quantity.2","quantity.3")]


# 2. plot with ggplot
## plot_barleyKile <- ggplot(v_barleyKileSimple, aes(date,quantity.2, quantity.3)) + ggtitle("Barley prices in Bilad al-Sham") + xlab("Date") + ylab("Prices (piaster)") + geom_point(na.rm=TRUE, color="purple", size=3, pch=1)

## plot only for period
## specify period
v_dateStart <- as.Date("1875-01-01")
v_dateStop <- as.Date("1916-12-31")
v_barleyKilePeriod <- func_period(v_barleyKileSimple,v_dateStart,v_dateStop)  

## plot
plot_barleyKilePeriod <- ggplot(v_barleyKilePeriod, aes(date,quantity.2, quantity.3)) +
  ggtitle("Barley prices in Bilad al-Sham") +
  xlab("Date") + ylab("Prices (piaster/kile)") +
  geom_point(na.rm=TRUE, color="purple", size=1, pch=3) +
  scale_x_date(breaks=date_breaks("5 years"), labels=date_format("%Y")) +
  stat_smooth(colour="green", method="loess") +
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  
## plot with two time series
plot_barleyKilePeriod1 <- ggplot(v_barleyKilePeriod, aes(x=date, y=value)) +
  ggtitle("Barley prices in Bilad al-Sham") +
  xlab("Date") + ylab("Prices (piaster/kile)") +
  geom_point(aes(y=quantity.2, col='min price'), na.rm=TRUE, size=2, pch=1, color="black")  +
  geom_point(aes(y=quantity.3, col='max price'), na.rm=TRUE, size=2, pch=3, color="black") +
  scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) + # add interval to x-axis
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
## final plot
plot_barleyKilePeriod
