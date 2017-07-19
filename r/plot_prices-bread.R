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
v_pricesBread <- read.csv("csv/prices_bread-kg.csv", header=TRUE, sep = ",", quote = "")

# convert date to Date class
v_pricesBread$date <- as.Date(v_pricesBread$date)

# create a subset of rows based on conditions
v_breadKg <- subset(v_pricesBread,commodity.1=="bread" & unit.1=="kg" & commodity.2=="currency" & unit.2=="ops")

# select rows
## select the first row (containing dates), and the rows containing prices in ops
v_breadKgSimple <- v_breadKg[,c(1,8,11)]


# 2. plot with ggplot
## plot_breadKg <- ggplot(v_breadKgSimple, aes(date,quantity.2, quantity.3)) + ggtitle("Bread prices in Bilad al-Sham") + xlab("Date") + ylab("Prices (piaster)") + geom_point(na.rm=TRUE, color="purple", size=3, pch=1)

## plot only for period
## specify period
v_dateStart <- as.Date("1875-01-01")
v_dateStop <- as.Date("1916-12-31")
v_breadKgPeriod <- func_period(v_breadKgSimple,v_dateStart,v_dateStop)  

## plot
plot_breadKgPeriod <- ggplot(v_breadKgPeriod, aes(date,quantity.2, quantity.3)) +
  ggtitle("Bread prices in Bilad al-Sham") +
  xlab("Date") + ylab("Prices (piaster/kg)") +
  geom_point(na.rm=TRUE, color="purple", size=1, pch=3) +
  scale_x_date(breaks=date_breaks("5 years"), labels=date_format("%Y")) +
  stat_smooth(colour="green", method="loess") +
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  
plot_breadKgPeriod1 <- ggplot(v_breadKgPeriod, aes(x=date, y=value)) +
  ggtitle("Wheat prices in Bilad al-Sham") +
  xlab("Date") + ylab("Prices (piaster/kg)") +
  geom_point(aes(y=quantity.2, col='min price'), na.rm=TRUE, size=2, pch=1, color="black")  +
  geom_point(aes(y=quantity.3, col='max price'), na.rm=TRUE, size=2, pch=3, color="red") +
  scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) + # add interval to x-axis
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)

## final plot
plot_breadKgPeriod
