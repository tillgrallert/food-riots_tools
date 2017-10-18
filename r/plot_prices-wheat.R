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
vWheatKile <- subset(vPricesWheat,commodity.1=="wheat" & unit.1=="kile" & commodity.2=="currency" & unit.2=="ops")

# select rows
## select the first row (containing dates), and the rows containing prices in ops
## vwheatKileSimple <- vwheatKile[,c(1,8,11)]
vWheatKileSimple <- vwheatKile[,c("date","quantity.2","quantity.3")]

# specify period
vDateStart <- as.Date("1875-01-01")
vDateStop <- as.Date("1916-12-31")
vWheatKilePeriod <- funcPeriod(vWheatKile,vDateStart,vDateStop)  

# calculate means for periods
## annual means
vWheatKilePeriodAnnualMinPrice <- aggregate(quantity.2 ~ year, data=vWheatKilePeriod, mean)
vWheatKilePeriodAnnualMaxPrice <- aggregate(quantity.3 ~ year, data=vWheatKilePeriod, mean)
## quarterly means
vWheatKilePeriodQuarterlyMinPrice <- aggregate(quantity.2 ~ quarter, data=vWheatKilePeriod, mean)
vWheatKilePeriodQuarterlyMaxPrice <- aggregate(quantity.3 ~ quarter, data=vWheatKilePeriod, mean)

# plot
## plot all values
plotScatterAll <- ggplot(vWheatKilePeriod, aes(date, # select period: date, year, quarter, month
                                   quantity.2, quantity.3)) +
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       # subtitle="based on announcements in newspapers", 
       x="Date", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  # first layer: all prices
  geom_point(na.rm=TRUE, color="purple", size=1, pch=3) +
  # second layer: fitted line
  stat_smooth(colour="green",na.rm = TRUE,
              method="loess", # methods are "lm", "loess" ...
              se=F) + # removes the range around the fitting
  scale_x_date(breaks=date_breaks("5 years"), 
               labels=date_format("%Y"),
               limits=as.Date(c(vDateStart, vDateStop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotScatterAll

## Jitter plot
plotJitterAll <- ggplot(vWheatKilePeriod, aes(date, # select period: date, year, quarter, month
                                               quantity.2, quantity.3)) +
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       # subtitle="based on announcements in newspapers", 
       x="Date", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  # first layer: all prices
  # geom_point(na.rm=TRUE, color="purple", size=1, pch=3) +
  geom_jitter(na.rm=TRUE,width = 100, # width controls the jitter around the original position. High values are required for my data
              size=1) +
  # second layer: fitted line
  stat_smooth(colour="green",na.rm = TRUE,
              method="loess", # methods are "lm", "loess" ...
              se=F) + # removes the range around the fitting
  scale_x_date(breaks=date_breaks("5 years"), 
               labels=date_format("%Y"),
               limits=as.Date(c(vDateStart, vDateStop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotJitterAll

## Counts chart
plotCountsAll <- ggplot(vWheatKilePeriod, aes(date, # select period: date, year, quarter, month
                                              quantity.2, quantity.3)) +
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       # subtitle="based on announcements in newspapers", 
       x="Date", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  # first layer: all prices
  # geom_point(na.rm=TRUE, color="purple", size=1, pch=3) +
  geom_count(na.rm=T, show.legend = F) +
  # second layer: fitted line
  stat_smooth(colour="green",na.rm = T,
              method="loess", # methods are "lm", "loess" ...
              se=F) + # removes the range around the fitting
  scale_x_date(breaks=date_breaks("5 years"), 
               labels=date_format("%Y"),
               limits=as.Date(c(vDateStart, vDateStop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotCountsAll

## plot averages per period
plotLineAvgQuarterlyMin <- ggplot(vWheatKilePeriodQuarterlyMinPrice, 
                               aes(quarter, # select period: date, year, quarter, month
                                   quantity.2)) +
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
      subtitle="quarterly average minimum prices", 
       x="Date", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  # first layer: all prices
  # geom_point(na.rm=TRUE, color="purple", size=1, pch=3) +
  geom_line(aes(y=quantity.2)) +
  # second layer: fitted line
  #stat_smooth(colour="green",na.rm = TRUE,method="loess", se=F) +
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"),
               limits=as.Date(c(vDateStart, vDateStop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotLineAvgQuarterlyMin

## box plot
plotBox <- ggplot(vWheatKilePeriod,
                  aes(x=year,
                      group=year,
                      y=quantity.2)) +
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       #subtitle="quarterly average minimum prices", 
       x="Date", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  # layer: box plot
  geom_boxplot(na.rm = T)+
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"),
               limits=as.Date(c(vDateStart, vDateStop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotBox
  
## plot with two time series
plotWheatKilePeriod2 <- ggplot(vWheatKilePeriod, aes(x=year, y=value)) +
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       # subtitle="based on announcements in newspapers", 
       x="Date", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  # first layer: min prices
  geom_point(aes(y=quantity.2),
             na.rm=TRUE,
             size=2, pch=1, color="black")  +
  # second layer: max prices
  geom_point(aes(y=quantity.3),
             na.rm=TRUE, 
             size=2, pch=3, color="black") +
  scale_x_date(breaks=date_breaks("5 years"), 
               labels=date_format("%Y"),
               limits=as.Date(c(vDateStart, vDateStop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw() # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
plotWheatKilePeriod2
