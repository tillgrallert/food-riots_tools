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
setwd("/BachCloud/BTSync/FormerDropbox/FoodRiots/food-riots_data") #Volumes/Dessau HD/

# 1. read price data from csv, note that the first row is a date
vFoodRiots <- read.csv("csv/events_food-riots.csv", header=TRUE, sep = ",", quote = "")
v.Prices <- read.csv("csv/prices.csv", header=TRUE, sep = ",", quote = "")

# fix date types
## convert date to Date class, note that dates supplied as years only will be turned into NA
vFoodRiots$date <- as.Date(vFoodRiots$date)
v.Prices$date <- as.Date(v.Prices$date)
## numeric
#v.Prices$quantity.2 <- as.numeric(v.Prices$quantity.2)
#v.Prices$quantity.3 <- as.numeric(v.Prices$quantity.3)

# aggregate periods
## use cut() to generate summary stats for time periods
## create variables of the year, quarter week and month of each observation:
v.Prices$year <- as.Date(cut(v.Prices$date, breaks = "year"))
v.Prices$quarter <- as.Date(cut(v.Prices$date,breaks = "quarter"))
v.Prices$month <- as.Date(cut(v.Prices$date,breaks = "month"))
v.Prices$week <- as.Date(cut(v.Prices$date,breaks = "week",
                                 start.on.monday = TRUE)) # allows to change weekly break point to Sunday
## add a column that sets all month/day combinations to the same year
v.Prices$date.common <- as.Date(paste0("2000-",format(v.Prices$date, "%j")), "%Y-%j")
v.Prices$month.common <- as.Date(cut(v.Prices$date.common,breaks = "month"))

# create a subset of rows based on conditions
v.Prices.Wheat <- subset(v.Prices,commodity.1=="wheat" & unit.1=="kile" & commodity.2=="currency" & unit.2=="ops")
v.Prices.Barley <- subset(v.Prices,commodity.1=="barley" & unit.1=="kile" & commodity.2=="currency" & unit.2=="ops")
v.Prices.Bread <- subset(v.Prices,commodity.1=="bread" & unit.1=="kg" & commodity.2=="currency" & unit.2=="ops")
v.Prices.Newspapers <- subset(v.Prices,commodity.1=="newspaper" & commodity.2=="currency" & unit.2=="ops")

# select rows
## select the first row (containing dates), and the rows containing prices in ops
#vWheatKileSimple <- vWheatKile[,c("date","quantity.2","quantity.3")]

# specify period
v.Date.Start <- as.Date("1870-01-01")
v.Date.Stop <- as.Date("1916-12-31")
v.Prices.Wheat.Period <- funcPeriod(v.Prices.Wheat,v.Date.Start,v.Date.Stop) 
v.Prices.Barley.Period <- funcPeriod(v.Prices.Barley,v.Date.Start,v.Date.Stop) 
v.Prices.Bread.Period <- funcPeriod(v.Prices.Bread,v.Date.Start,v.Date.Stop) 
vFoodRiotsPeriod <- funcPeriod(vFoodRiots,v.Date.Start,v.Date.Stop)

# the list of wheat prices includes two very high data points for regions outside Bilād al-Shām, they should be filtered out
v.Prices.Wheat.Period <- subset(v.Prices.Wheat.Period, quantity.2 < 200)

# calculate means for periods
## annual means
v.Prices.Wheat.Mean.Annual <- aggregate((quantity.2 + quantity.3)/2 ~ year, data=v.Prices.Wheat.Period, mean)
#vWheatKilePeriodAnnualMinPrice <- aggregate(quantity.2 ~ year, data=vWheatKilePeriod, mean)
#vWheatKilePeriodAnnualMaxPrice <- aggregate(quantity.3 ~ year, data=vWheatKilePeriod, mean)
## quarterly means
v.Prices.Wheat.Min.Quarterly <- aggregate(quantity.2 ~ quarter, data=v.Prices.Wheat.Period, mean)
v.Prices.Wheat.Max.Quarterly <- aggregate(quantity.3 ~ quarter, data=v.Prices.Wheat.Period, mean)
## merge the two data frames into one
v.Prices.Wheat.Mean.Quarterly <- merge(v.Prices.Wheat.Min.Quarterly, v.Prices.Wheat.Max.Quarterly, by=c("quarter"), all=T)
## monthly means
v.Prices.Wheat.Min.Monthly <- aggregate(quantity.2 ~ month, data=v.Prices.Wheat.Period, mean)
v.Prices.Wheat.Max.Monthly <- aggregate(quantity.3 ~ month, data=v.Prices.Wheat.Period, mean)
## merge the two data frames into one
v.Prices.Wheat.Mean.Monthly <- merge(v.Prices.Wheat.Min.Monthly, v.Prices.Wheat.Max.Monthly, by=c("month"), all=T)


# plot
## base plot
v.Plot.Base <- ggplot() +
  # add labels
  labs(x="Date") +
  # layer: vertical lines for bread riots
  geom_segment(data = vFoodRiotsPeriod, aes(x = date, xend = date, y = 10, yend = 24, colour = "food riot"),
               size = 1, show.legend = F, na.rm = T, linetype=1)+ # linetypes: 1=solid, 2=dashed
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+
               #limits=as.Date(c(v.Date.Start, v.Date.Stop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw()+ # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
v.Plot.Base  
  
  
  
## plot all values
v.Plot.Wheat.Scatter <- v.Plot.Base+
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
      subtitle="based on announcements in newspapers", 
       #x="Date", 
       y="Prices (piaster/kile)") +
  # first layer: min prices
  geom_point(data = v.Prices.Wheat.Period, 
             aes(x = date, # select period: date, year, quarter, month
                 y = quantity.2),
             na.rm=TRUE, color="green", size=2, pch=3)+
  # second layer: max prices
  geom_point(data = v.Prices.Wheat.Period, 
             aes(x=date, y=quantity.3),
             na.rm=TRUE, size=2, pch=3, color="red")
v.Plot.Wheat.Scatter

## quarterly averages
v.Plot.Wheat.Quarterly.Mean.Scatter <- v.Plot.Base+
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       subtitle="Quarterly averages of minimum and maximum prices based on announcements in newspapers", 
       y="Prices (piaster/kile)") +
  # first layer: min prices
  geom_point(data = v.Prices.Wheat.Mean.Quarterly, 
             aes(x = quarter, # select period: date, year, quarter, month
                 y = quantity.2),
             na.rm=TRUE, size=2, pch=3)+
  scale_color_gradient(low="darkkhaki", high="darkgreen")+
  #geom_text(data = v.Prices.Wheat.Mean.Quarterly,aes(x = quarter, quantity.2, label=round(quantity.2)), size=3)+
  # second layer: max prices
  geom_point(data = v.Prices.Wheat.Mean.Quarterly, 
             aes(x=quarter, y=quantity.3),
             na.rm=TRUE, size=2, pch=3, color="black")+
  # layer with connecting lines between min and max prices
  geom_segment(data = v.Prices.Wheat.Mean.Quarterly, 
               aes(x = quarter, xend = quarter, 
                   y = quantity.2, yend = quantity.3),
               size = 0.3, show.legend = F, na.rm = T, linetype=1) # linetypes: 1=solid, 2=dashed,
  
v.Plot.Wheat.Quarterly.Mean.Scatter
  

## Jitter plot
v.Plot.Wheat.Jitter <- v.Plot.Base+
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       subtitle="based on announcements in newspapers", 
       #x="Date", 
       y="Prices (piaster/kile)") +
  # first layer: min prices
  geom_jitter(data = v.Prices.Wheat.Period, 
              aes(x = date, # select period: date, year, quarter, month
                  y = quantity.2),
              na.rm=TRUE,width = 100, # width controls the jitter around the original position. High values are required for my data
              size=1) +
  # second layer: max prices
  geom_jitter(data = v.Prices.Wheat.Period, 
              aes(x = date, # select period: date, year, quarter, month
                  y = quantity.3),
              na.rm=TRUE,width = 100, # width controls the jitter around the original position. High values are required for my data
              size=1) +
  # second layer: fitted line
  stat_smooth(data = v.Prices.Wheat.Period, aes(x = date, # select period: date, year, quarter, month
                                                y = quantity.2),
              colour="green",na.rm = TRUE,
              method="loess", # methods are "lm", "loess" ...
              se=F) # removes the range around the fitting
v.Plot.Wheat.Jitter
  
## box plot
v.Plot.Wheat.Box <- v.Plot.Base+
  # add labels
  labs(title="Wheat prices and food riots in Bilad al-Sham", 
       subtitle="minimum prices aggregated by year", 
       y="Price (piaster/kile)") + # provides title, subtitle, x, y, caption
  # layer: box plot prices, average of min and max prices
  #geom_boxplot(data = vWheatKilePeriod,aes(x=year,group=year,y=(quantity.2 + quantity.3) / 2), na.rm = T)+
  # layer: box plot min prices
  geom_boxplot(data = v.Prices.Wheat.Period,aes(x=year,group=year,y=quantity.2), na.rm = T)+
  ## add error bars
  stat_boxplot(geom ='errorbar')+
  # layer: box plot max prices
  geom_boxplot(data = v.Prices.Wheat.Period,aes(x=year, group=year,y=quantity.3), na.rm = T, color="blue", width=100)
  # layer: jitter plot
  #geom_jitter(data = vWheatKilePeriod,aes(date, quantity.2,colour = "price points"), size=1, na.rm=TRUE,width = 50)+ # width depends on the width of the entire plot
  # layer: line with all values
  #geom_line(aes(date, quantity.2), na.rm=TRUE,color="red") +
  # layer: fitted line
  #stat_smooth(aes(date, quantity.2), na.rm = T,method="lm", se=T,color="blue")
v.Plot.Wheat.Box

v.Plot.Barley.Box <- v.Plot.Base+
  # add labels
  labs(title="Wheat prices and food riots in Bilad al-Sham", 
       subtitle="minimum prices aggregated by year", 
       y="Price (piaster/kile)") + # provides title, subtitle, x, y, caption
  # layer: box plot prices, average of min and max prices
  #geom_boxplot(data = vWheatKilePeriod,aes(x=year,group=year,y=(quantity.2 + quantity.3) / 2), na.rm = T)+
  # layer: box plot min prices
  geom_boxplot(data = v.Prices.Barley.Period,aes(x=year,group=year,y=quantity.2), na.rm = T)+
  # layer: box plot max prices
  geom_boxplot(data = v.Prices.Barley.Period,aes(x=year, group=year,y=quantity.3), na.rm = T, color="blue", width=100)
v.Plot.Barley.Box
  
  
## plot with two time series
plotWheatKilePeriod2 <- ggplot(vWheatKilePeriod) +
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       # subtitle="based on announcements in newspapers", 
       x="Date", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  # layer: vertical lines for bread riots
  geom_segment(data = vFoodRiotsPeriod, aes(x = date, xend = date, y = 10, yend = 24, colour = "food riot"),
               size = 1, show.legend = F, na.rm = T, linetype=1)+ # linetypes: 1=solid, 2=dashed,
  # first layer: min prices
  geom_point(aes(x=date, y=quantity.2),
             na.rm=TRUE,
             size=2, pch=1, color="black")  +
  # second layer: max prices
  geom_point(aes(x=date, y=quantity.3),
             na.rm=TRUE, 
             size=2, pch=3, color="black") +
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"),
               limits=as.Date(c(vDateStart, vDateStop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw()+ # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
plotWheatKilePeriod2

vDateStart <- as.Date("1908-01-01")
vDateStop <- as.Date("1916-12-31")
vWheatKilePeriod <- funcPeriod(vWheatKile,vDateStart,vDateStop) 
vFoodRiotsPeriod <- funcPeriod(vFoodRiots,vDateStart,vDateStop) 

plotWheatKilePeriod3 <- ggplot(vWheatKilePeriod) +
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       # subtitle="based on announcements in newspapers", 
       x="Date", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  # layer: vertical lines for bread riots
  geom_segment(data = vFoodRiotsPeriod, aes(x = date, xend = date, y = 10, yend = 24, colour = "food riot"),
               size = 1, show.legend = F, na.rm = T, linetype=1)+ # linetypes: 1=solid, 2=dashed, 
  # first layer: min prices
  geom_point(aes(x=date, y=quantity.2),
             na.rm=TRUE,
             size=2, pch=3, color="black")  +
  # second layer: max prices
  geom_point(aes(x=date, y=quantity.3),
             na.rm=TRUE, 
             size=2, pch=3, color="black") +
  # layer with connecting lines between min and max prices
  geom_segment(aes(x = date, xend = date, y = quantity.2, yend = quantity.3), show.legend = F, na.rm = T, linetype=1, color = "black")+ # linetypes: 1=solid, 2=dashed, 
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"),
               limits=as.Date(c(vDateStart, vDateStop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw()+ # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
plotWheatKilePeriod3


# plot day of the year / explore seasonality

v.Plot.Wheat.Annual.Cycle.Scatter <- ggplot()+
  geom_point(data = v.Prices.Wheat.Period, 
             aes(x = date.common, y = quantity.2),
             na.rm=TRUE, size=2, pch=3, color="black")+
  geom_point(data = v.Prices.Wheat.Period, 
             aes(x = date.common, y = quantity.3),
             na.rm=TRUE, size=2, pch=3, color="black")+
  scale_x_date(breaks=date_breaks("1 month"), 
               labels=date_format("%d-%b")) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
v.Plot.Wheat.Annual.Cycle.Scatter

v.Plot.Wheat.Annual.Cycle.Box <- ggplot()+
  # it would be important to know how many values are represented in each box
  geom_boxplot(data = v.Prices.Wheat.Period, 
             aes(x = month.common, group = month.common, y = quantity.2),
             na.rm=TRUE, color="black")+
  geom_boxplot(data = v.Prices.Wheat.Period, 
               aes(x = month.common, group = month.common, y = quantity.3),
               na.rm=TRUE, width = 10,  color="blue")+
  stat_boxplot(geom ="errorbar")+
  scale_x_date(breaks=date_breaks("1 month"), 
               labels=date_format("%B")) + # %B full month names; $b abbreviated month
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
v.Plot.Wheat.Annual.Cycle.Box

v.Plot.Bread.Annual.Cycle.Box <- ggplot()+
  # it would be important to know how many values are represented in each box
  geom_boxplot(data = v.Prices.Bread.Period, 
               aes(x = month.common, group = month.common, y = quantity.2),
               na.rm=TRUE, color="black")+
  geom_boxplot(data = v.Prices.Bread.Period, 
               aes(x = month.common, group = month.common, y = quantity.3),
               na.rm=TRUE, width = 10,  color="blue")+
  stat_boxplot(geom ="errorbar")+
  scale_x_date(breaks=date_breaks("1 month"), 
               labels=date_format("%B")) + # %B full month names; $b abbreviated month
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
v.Plot.Bread.Annual.Cycle.Box
