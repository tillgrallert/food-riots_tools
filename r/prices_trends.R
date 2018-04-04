# Remember it is good coding technique to add additional packages to the top of
# your script 
library(lubridate) # for working with dates
library(anytime) # for parsing incomplete dates
library(ggplot2)  # for creating graphs
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
library(plotly) # interactive plots based on ggplot
library(dplyr) # data manipulation


# function to create subsets for periods
funcPeriod <- function(f,x,y){f[f$date >= x & f$date <= y,]}

# use a working directory
setwd("/BachCloud/BTSync/FormerDropbox/FoodRiots/food-riots_data") #Volumes/Dessau HD/

# 1. read price data from csv, note that the first row is a date
v.FoodRiots <- read.csv("csv/events_food-riots.csv", header=TRUE, sep = ",", quote = "")
v.Prices.Trends <- read.csv("csv/qualitative-prices.csv", header=TRUE, sep = ",", quote = "\"")


# fix date types
## convert date to Date class, note that dates supplied as years only will be turned into NA
v.FoodRiots$date <- as.Date(v.FoodRiots$date)
v.Prices.Trends$date <- anydate(v.Prices.Trends$date)

# specify period
v.Date.Start <- as.Date("1870-01-01")
v.Date.Stop <- as.Date("1916-12-31")
v.FoodRiots.Period <- funcPeriod(v.FoodRiots,v.Date.Start,v.Date.Stop)
v.Prices.Trends.Period <- funcPeriod(v.Prices.Trends,v.Date.Start,v.Date.Stop)

# plot
## base plot
v.Plot.Base <- ggplot() +
  # add labels
  labs(x="Date") +
  # layer: vertical lines for bread riots
  geom_segment(data = v.FoodRiots.Period, aes(x = date, xend = date, y = 0, yend = 24, colour = "food riot"),
               size = 1, show.legend = F, na.rm = T, linetype=1)+ # linetypes: 1=solid, 2=dashed
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+
  #limits=as.Date(c(v.Date.Start, v.Date.Stop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw()+ # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
v.Plot.Base 

v.Plot.Price.Trends <- v.Plot.Base +
  # despite some visiual overlap, count charts are not the best solution to the data set 
  # because only very few reports fall on the same day (and thus formally) overlap
  # layer: falling prices
  geom_point(data = filter(v.Prices.Trends.Period, tag=="prices: high"),
             aes(x = date, y = 5, colour = tag))+
  # layer: falling prices
  geom_point(data = filter(v.Prices.Trends.Period, tag=="prices: rising"),
             aes(x = date, y = 4, colour = tag))+
  # layer: falling prices
  geom_point(data = filter(v.Prices.Trends.Period, tag=="prices: normal"),
             aes(x = date, y = 3, colour = tag))+
  # layer: falling prices
  geom_point(data = filter(v.Prices.Trends.Period, tag=="prices: falling"),
             aes(x = date, y = 2, colour = tag))+
  # layer: falling prices
  geom_point(data = filter(v.Prices.Trends.Period, tag=="prices: low"),
             aes(x = date, y = 1, colour = tag))
v.Plot.Price.Trends
