# Remember it is good coding technique to add additional packages to the top of
# your script 
library(lubridate) # for working with dates
library(ggplot2)  # for creating graphs
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
library(plotly) # interactive plots based on ggplot

# use a working directory
setwd("/Volumes/Dessau HD/BachCloud/BTSync/FormerDropbox/PostDoc Food Riots/food-riots_data")

# read price data from csv, note that the first row is a date
## colClasses can specify the data type: , colClasses=c("date"="date") this however currently throws an error
## sometimes row.names="id" throws an error
v_prices <- read.csv("csv/prices.csv", header=TRUE, sep = ",", quote="") # this file is currently not the best choice
v_pricesWheat <- read.csv("csv/prices_wheat-kile.csv", header=TRUE, sep = ",")
v_pricesBread <- read.csv("csv/prices_bread-kg.csv", header=TRUE, sep = ",", quote = "") # this file throws an error

# convert date to Date class
v_prices$date <- as.Date(v_prices$date)
v_pricesWheat$date <- as.Date(v_pricesWheat$date)


# create a subset of rows based on conditions
v_wheatKile <- subset(v_prices,commodity.1=="wheat" & unit.1=="kile" & commodity.2=="currency" & unit.2=="ops")
v_barleyKile <- subset(v_prices,commodity.1=="barley" & unit.1=="kile")

## create subsets for periods
func_period <- function(f,x,y){f[f$date >= x & f$date <= y,]}


# select rows
## select the first row (containing dates), and the rows containing prices in ops
v_wheatKileSimple <- v_wheatKile[,c("date","quantity.2","quantity.3")]
v_wheatKileSimple$quantity.2 <- as.numeric(v_wheatKileSimple$quantity.2) #attempt to translate the second column to numeric values, but somehow this does not work as expected

# change data types, especially dates
## with line 16 above this is not necessary anymore
## v_pricesDates <- as.Date(v_prices[,c(1)], format = "%Y-%m-%d") # works but only returns the first column (of course)
## v_pricesDates[,c(1)] <- as.Date(v_prices[,c(1)], format = "%Y-%m-%d") # doesn't work
## v_wheatKilePrices[,c(1)] <- as.Date(v_wheatKilePrices[,c(1)], format = "%Y-%m-%d") # this works


# try to plot stuff
## 1. simple plot of prices with qplot
plot_wheatKile1 <- qplot(x=date, y=quantity.2,
      data=v_wheatKileSimple, na.rm=TRUE,
      main="Wheat prices",
      xlab="Date", 
      ylab="Price (piasters)")

## 2. plot with ggplot
### aes for aesthetics
### geom_XXXX for geometry
plot_wheatKile2 <- ggplot(v_wheatKileSimple, aes(date,quantity.2, quantity.3)) +
  ggtitle("Wheat prices in Bilad al-Sham") +
  xlab("Date") + ylab("Prices (piaster)")
  # scale_x_date(breaks=date_breaks("5 years"), labels=date_format("%Y"))

### additional features can be added to the variable
plot_wheatKile2 <- plot_wheatKile2 + geom_point(na.rm=TRUE, color="purple", size=3, pch=1)

### plot only for period
### start and end dates can be defined for the plot without subsetting the original data source, BUT: this will keep the scales adjusted to the original maximum values
v_dateStart <- as.Date("1875-01-01")
v_dateStop <- as.Date("1916-12-31")

### create a start and end time R object
v_period <- c(v_dateStart,v_dateStop)

### limit the plot to the period and write everything to a new variable
plot_wheatKilePeriod1 <- plot_wheatKile2 + 
  scale_x_date(limits=v_period, breaks=date_breaks("5 years"), labels=date_format("%Y"))


### plot for subset of prices (this completely removes values for dates outside the specified period)
#### specify period
v_dateStart <- as.Date("1875-01-01")
v_dateStop <- as.Date("1916-12-31")
v_wheatKilePeriod <- func_period(v_wheatKileSimple,v_dateStart,v_dateStop)  

#### plot
plot_wheatKilePeriod2 <- ggplot(v_wheatKilePeriod, aes(date,quantity.2, quantity.3)) +
  ggtitle("Wheat prices in Bilad al-Sham") +
  xlab("Date") + ylab("Prices (piaster)") +
  geom_point(na.rm=TRUE, color="purple", size=1, pch=3) +
  scale_x_date(breaks=date_breaks("1 years"), labels=date_format("%Y")) +
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  
plot_wheatKilePeriod2 + stat_smooth(colour="green", method="loess")

### trend lines
### stat_smooth() provides a number of methods that need to be understood:
### method="lm": linear
### method="loess"
plot_wheatKileTrend <- plot_wheatKile2 +
  stat_smooth(colour="green", method="loess") +
  scale_x_date(breaks=date_breaks("5 years"), labels=date_format("%Y"))

### plot with two time series
plot_wheatKilePeriod3 <- ggplot(v_wheatKilePeriod, aes(x=date, y=value)) +
  ggtitle("Wheat prices in Bilad al-Sham") +
  xlab("Date") + ylab("Prices (piaster/kile)") +
  geom_point(aes(y=quantity.2, col='min price'), na.rm=TRUE, size=2, pch=1, color="black")  +
  geom_point(aes(y=quantity.3, col='max price'), na.rm=TRUE, size=2, pch=2, color="black") +
  scale_x_date(breaks=date_breaks("2 years"), labels=date_format("%Y")) + # add interval to x-axis
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)

plot_wheatKilePeriod3

### plotly
ggplotly(plot_wheatKilePeriod3)

