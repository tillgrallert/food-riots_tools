# Remember it is good coding technique to add additional packages to the top of
# your script 
library(lubridate) # for working with dates
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
v.FoodRiots <- read.csv("csv/events_food-riots.csv", header=TRUE, sep = ",", quote = "\"")
v.Prices <- read.csv("csv/prices.csv", header=TRUE, sep = ",", quote = "\"")

# fix date types
## convert date to Date class, note that dates supplied as years only will be turned into NA
v.FoodRiots$date <- as.Date(v.FoodRiots$date)
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

# create a subset of rows based on conditions; this can also be achieved with the filter() function from dplyr
v.Prices.Wheat <- subset(v.Prices,commodity.1=="wheat" & unit.1=="kile" & commodity.2=="currency" & unit.2=="ops")
  ## descriptive stats
  # the computed arithmetic mean [mean(v.Prices.Wheat$quantity.2, na.rm=T, trim = 0.1)] based on the observed values
  #is much too high, compared to the prices reported as "normal" in our sources. Thus, I use a fixed parameter value
  v.Prices.Wheat.Mean <- 25
  ## deviation from the mean
  v.Prices.Wheat$dm.2 <- (v.Prices.Wheat$quantity.2 - v.Prices.Wheat.Mean)
  v.Prices.Wheat$dm.3 <- (v.Prices.Wheat$quantity.3 - v.Prices.Wheat.Mean)
  ## the same as percentages of mean
  v.Prices.Wheat$dmp.2 <- (100 * v.Prices.Wheat$dm.2 / v.Prices.Wheat.Mean)
  v.Prices.Wheat$dmp.3 <- (100 * v.Prices.Wheat$dm.3 / v.Prices.Wheat.Mean)
  ## write result to file
  write.table(v.Prices.Wheat, "csv/summary/prices_wheat-kile.csv" , row.names = F, quote = T , sep = ",")
v.Prices.Barley <- subset(v.Prices,commodity.1=="barley" & unit.1=="kile" & commodity.2=="currency" & unit.2=="ops")
  ## deviation from the mean
  v.Prices.Barley$dm.2 <- (v.Prices.Barley$quantity.2 - mean(v.Prices.Barley$quantity.2, na.rm=T, trim = 0.1))
  v.Prices.Barley$dm.3 <- (v.Prices.Barley$quantity.3 - mean(v.Prices.Barley$quantity.3, na.rm=T, trim = 0.1))
  ## the same as percentages of mean
  v.Prices.Barley$dmp.2 <- (100 * v.Prices.Barley$dm.2 / mean(v.Prices.Barley$quantity.2, na.rm=T, trim = 0.1))
  v.Prices.Barley$dmp.3 <- (100 * v.Prices.Barley$dm.3 / mean(v.Prices.Barley$quantity.3, na.rm=T, trim = 0.1))
  # write result to file
  write.table(v.Prices.Barley, "csv/summary/prices_barley-kile.csv" , row.names = F, quote = T , sep = ",")
v.Prices.Bread <- subset(v.Prices,commodity.1=="bread" & unit.1=="kg" & commodity.2=="currency" & unit.2=="ops")
  ## deviation from the mean
  v.Prices.Bread$dm.2 <- (v.Prices.Bread$quantity.2 - mean(v.Prices.Bread$quantity.2, na.rm=T, trim = 0.1))
  v.Prices.Bread$dm.3 <- (v.Prices.Bread$quantity.3 - mean(v.Prices.Bread$quantity.3, na.rm=T, trim = 0.1))
  ## the same as percentages of mean
  v.Prices.Bread$dmp.2 <- (100 * v.Prices.Bread$dm.2 / mean(v.Prices.Bread$quantity.2, na.rm=T, trim = 0.1))
  v.Prices.Bread$dmp.3 <- (100 * v.Prices.Bread$dm.3 / mean(v.Prices.Bread$quantity.3, na.rm=T, trim = 0.1))
  # write result to file
  write.table(v.Prices.Bread, "csv/summary/prices_bread-kg.csv" , row.names = F, quote = T , sep = ",")
v.Prices.Newspapers <- subset(v.Prices,commodity.1=="newspaper" & commodity.2=="currency")
  # write result to file
  write.table(v.Prices.Newspapers, "csv/summary/prices_newspapers.csv" , row.names = F, quote = T , sep = ",")

# select rows
## select the first row (containing dates), and the rows containing prices in ops
#vWheatKileSimple <- vWheatKile[,c("date","quantity.2","quantity.3")]

# calculate means for periods
## annual means
#v.Prices.Wheat.Mean.Annual <- aggregate((quantity.2 + quantity.3)/2 ~ year, data=v.Prices.Wheat.Period, mean)
## data frame with annual mean for min and max prices
v.Prices.Wheat.Mean.Annual <- merge(
  aggregate(quantity.2 ~ year, data=v.Prices.Wheat.Period, FUN = mean),
  aggregate(quantity.3 ~ year, data=v.Prices.Wheat.Period, FUN = mean), 
  by=c("year"), all=T)
## use the more powerful dplyr package
v.Prices.Wheat.Summary.Annual <- v.Prices.Wheat %>%
  group_by(year) %>%
  summarise(count=n(), 
            mean.2=mean(quantity.2, na.rm = TRUE),
            mean.3=mean(quantity.3, na.rm = TRUE),
            median.2=median(quantity.2, na.rm = TRUE),
            median.3=median(quantity.3, na.rm = TRUE),
            sd.2=sd(quantity.2, na.rm = TRUE),
            sd.3=sd(quantity.3, na.rm = TRUE)
  )
  # write result to file
  write.table(v.Prices.Wheat.Summary.Annual, "csv/summary/prices_wheat-summary-annual.csv" , row.names = F, quote = T , sep = ",")

## data frame with quarterly mean for min and max prices
v.Prices.Wheat.Mean.Quarterly <- merge(
  aggregate(quantity.2 ~ quarter, data=v.Prices.Wheat.Period, FUN = mean),
  aggregate(quantity.3 ~ quarter, data=v.Prices.Wheat.Period, FUN = mean),  
  by=c("quarter"), all=T)
v.Prices.Wheat.Summary.Quarterly <- v.Prices.Wheat %>%
  group_by(quarter) %>%
  summarise(count=n(), 
            mean.2=mean(quantity.2, na.rm = TRUE),
            mean.3=mean(quantity.3, na.rm = TRUE),
            median.2=median(quantity.2, na.rm = TRUE),
            median.3=median(quantity.3, na.rm = TRUE),
            sd.2=sd(quantity.2, na.rm = TRUE),
            sd.3=sd(quantity.3, na.rm = TRUE)
  )
  # write result to file
  write.table(v.Prices.Wheat.Summary.Quarterly, "csv/summary/prices_wheat-summary-quarterly.csv" , row.names = F, quote = T , sep = ",")

## data frame with monthly mean for min and max prices
v.Prices.Wheat.Summary.Monthly <- v.Prices.Wheat %>%
  group_by(month) %>%
  summarise(count=n(), 
            mean.2=mean(quantity.2, na.rm = TRUE),
            mean.3=mean(quantity.3, na.rm = TRUE),
            median.2=median(quantity.2, na.rm = TRUE),
            median.3=median(quantity.3, na.rm = TRUE),
            sd.2=sd(quantity.2, na.rm = TRUE),
            sd.3=sd(quantity.3, na.rm = TRUE)
            )
  # write result to file
  write.table(v.Prices.Wheat.Summary.Monthly, "csv/summary/prices_wheat-summary-monthly.csv" , row.names = F, quote = T , sep = ",")

## data frame with daily mean for min and max prices
v.Prices.Wheat.Summary.Daily <- v.Prices.Wheat %>%
	group_by(date) %>%
	summarise(count=n(), 
	          mean.2=mean(quantity.2, na.rm = TRUE),
	          mean.3=mean(quantity.3, na.rm = TRUE),
	          median.2=median(quantity.2, na.rm = TRUE),
	          median.3=median(quantity.3, na.rm = TRUE),
	          sd.2=sd(quantity.2, na.rm = TRUE),
	          sd.3=sd(quantity.3, na.rm = TRUE)
	)
  ## difference from mean in per cent
  v.Prices.Wheat.Summary.Daily$dmp.2 <- (100 * (v.Prices.Wheat.Summary.Daily$mean.2 - v.Prices.Wheat.Mean) / v.Prices.Wheat.Mean)
  v.Prices.Wheat.Summary.Daily$dmp.3 <- (100 * (v.Prices.Wheat.Summary.Daily$mean.3 - v.Prices.Wheat.Mean) / v.Prices.Wheat.Mean)
  # write result to file
  write.table(v.Prices.Wheat.Summary.Daily, "csv/summary/prices_wheat-summary-daily.csv" , row.names = F, quote = T , sep = ",")

## annual means: Barley
v.Prices.Barley.Summary.Annual <- v.Prices.Barley %>%
  group_by(year) %>%
  summarise(count=n(), 
            mean.2=mean(quantity.2, na.rm = TRUE),
            mean.3=mean(quantity.3, na.rm = TRUE),
            median.2=median(quantity.2, na.rm = TRUE),
            median.3=median(quantity.3, na.rm = TRUE),
            sd.2=sd(quantity.2, na.rm = TRUE),
            sd.3=sd(quantity.3, na.rm = TRUE)
  )
  # write result to file
  write.table(v.Prices.Barley.Summary.Annual, "csv/summary/prices_barley-summary-annual.csv" , row.names = F, quote = T , sep = ",")

## data frame with quarterly mean for min and max prices
v.Prices.Barley.Summary.Quarterly <- v.Prices.Barley %>%
  group_by(quarter) %>%
  summarise(count=n(), 
            mean.2=mean(quantity.2, na.rm = TRUE),
            mean.3=mean(quantity.3, na.rm = TRUE),
            median.2=median(quantity.2, na.rm = TRUE),
            median.3=median(quantity.3, na.rm = TRUE),
            sd.2=sd(quantity.2, na.rm = TRUE),
            sd.3=sd(quantity.3, na.rm = TRUE)
  )
  # write result to file
  write.table(v.Prices.Barley.Summary.Quarterly, "csv/summary/prices_barley-summary-quarterly.csv" , row.names = F, quote = T , sep = ",")

## data frame with monthly mean for min and max prices
v.Prices.Barley.Summary.Monthly <- v.Prices.Barley %>%
  group_by(month) %>%
  summarise(count=n(), 
            mean.2=mean(quantity.2, na.rm = TRUE),
            mean.3=mean(quantity.3, na.rm = TRUE),
            median.2=median(quantity.2, na.rm = TRUE),
            median.3=median(quantity.3, na.rm = TRUE),
            sd.2=sd(quantity.2, na.rm = TRUE),
            sd.3=sd(quantity.3, na.rm = TRUE)
  )
  # write result to file
  write.table(v.Prices.Barley.Summary.Monthly, "csv/summary/prices_barley-summary-monthly.csv" , row.names = F, quote = T , sep = ",")
  
# specify period
v.Date.Start <- as.Date("1870-01-01")
v.Date.Stop <- as.Date("1916-12-31")
v.Prices.Wheat.Period <- funcPeriod(v.Prices.Wheat,v.Date.Start,v.Date.Stop)
v.Prices.Wheat.Daily.Period <- funcPeriod(v.Prices.Wheat.Summary.Daily,v.Date.Start,v.Date.Stop)
v.Prices.Barley.Period <- funcPeriod(v.Prices.Barley,v.Date.Start,v.Date.Stop) 
v.Prices.Bread.Period <- funcPeriod(v.Prices.Bread,v.Date.Start,v.Date.Stop) 
v.FoodRiots.Period <- funcPeriod(v.FoodRiots,v.Date.Start,v.Date.Stop)

# descriptive statistics
mean(v.Prices.Wheat.Period$quantity.2, na.rm=T, trim = 0.1)
mean(v.Prices.Barley.Period$quantity.2, na.rm=T, trim = 0.1)
median(v.Prices.Wheat.Period$quantity.2, na.rm=T)
quantile(v.Prices.Wheat.Period$quantity.2, na.rm=T)
sd(v.Prices.Wheat.Period$quantity.2, na.rm=T)

# the list of wheat prices includes two very high data points for regions outside Bilād al-Shām, they should be filtered out
v.Prices.Wheat.Period <- subset(v.Prices.Wheat.Period, quantity.2 < 200)
v.Prices.Wheat.Daily.Period <- subset(v.Prices.Wheat.Daily.Period, mean.2 < 200)

# plot
## base plot
v.Plot.Base <- ggplot() +
  # add labels
  labs(x="Date") +
  # layer: vertical lines for bread riots
  geom_segment(data = v.FoodRiots.Period, aes(x = date, xend = date, y = 10, yend = 24, colour = "food riot"),
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
  geom_point(data = v.Prices.Wheat.Summary.Quarterly, 
             aes(x = quarter, y = mean.2),
             na.rm=TRUE, size=2, pch=3)+
  #scale_color_gradient(low="darkkhaki", high="darkgreen")+
  #geom_text(data = v.Prices.Wheat.Mean.Quarterly,aes(x = quarter, quantity.2, label=round(quantity.2)), size=3)+
  # second layer: max prices
  geom_point(data = v.Prices.Wheat.Summary.Quarterly, 
             aes(x = quarter, y = mean.3),
             na.rm=TRUE, size=2, pch=3, color="black")+
  # layer with connecting lines between min and max prices
  geom_segment(data = v.Prices.Wheat.Summary.Quarterly, 
               aes(x = quarter, xend = quarter, y = mean.2, yend = mean.3),size = 0.3, show.legend = F, na.rm = T, linetype=1) # linetypes: 1=solid, 2=dashed,
v.Plot.Wheat.Quarterly.Mean.Scatter

## monthly averages
v.Plot.Wheat.Monthly.Mean.Scatter <- v.Plot.Base+
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       subtitle="Quarterly averages of minimum and maximum prices based on announcements in newspapers", 
       y="Prices (piaster/kile)") +
  # first layer: min prices
  geom_point(data = v.Prices.Wheat.Summary.Monthly, 
             aes(x = month, y = mean.2),
             na.rm=TRUE, size=2, pch=3)+
  geom_line(data = v.Prices.Wheat.Summary.Monthly, 
            aes(x = month, y = mean.2),
             na.rm=TRUE, color="green")+
  #geom_text(data = v.Prices.Wheat.Mean.Monthly,aes(x = month, quantity.2, label=round(quantity.2)), size=3)+
  # second layer: max prices
  geom_point(data = v.Prices.Wheat.Summary.Monthly, 
             aes(x = month, y = mean.3),
             na.rm=TRUE, size=2, pch=3, color="black")+
  geom_line(data = v.Prices.Wheat.Summary.Monthly, 
            aes(x = month, y = mean.3),
          na.rm=TRUE, color="red")+
# layer with connecting lines between min and max prices
geom_segment(data = v.Prices.Wheat.Summary.Monthly, 
             aes(x = month, xend = month, y = mean.2, yend = mean.3),
             size = 0.3, show.legend = F, na.rm = T, linetype=1) # linetypes: 1=solid, 2=dashed,
v.Plot.Wheat.Monthly.Mean.Scatter

## daily averages
v.Plot.Wheat.Daily.Mean.Scatter <- v.Plot.Base+
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       subtitle="Quarterly averages of minimum and maximum prices based on announcements in newspapers", 
       y="Prices (piaster/kile)") +
  # first layer: min prices
  geom_point(data = v.Prices.Wheat.Daily.Period, 
             aes(x = date, y = mean.2),
             na.rm=TRUE, size=2, pch=3)+
  geom_line(data = v.Prices.Wheat.Daily.Period, 
            aes(x = date, y = mean.2),
            na.rm=TRUE, color="green")+
  #geom_text(data = v.Prices.Wheat.Summary.Daily,aes(x = month, quantity.2, label=round(quantity.2)), size=3)+
  # second layer: max prices
  geom_point(data = v.Prices.Wheat.Daily.Period, 
             aes(x = date, y = mean.3),
             na.rm=TRUE, size=2, pch=3, color="black")+
  geom_line(data = v.Prices.Wheat.Daily.Period, 
            aes(x = date, y = mean.3),
            na.rm=TRUE, color="red")+
  # layer with connecting lines between min and max prices
  geom_segment(data = v.Prices.Wheat.Daily.Period, 
               aes(x = date, xend = date, y = mean.2, yend = mean.3),
               size = 0.3, show.legend = F, na.rm = T, linetype=1) # linetypes: 1=solid, 2=dashed,
v.Plot.Wheat.Daily.Mean.Scatter
  

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
  labs(title="Barley prices and food riots in Bilad al-Sham", 
       subtitle="minimum prices aggregated by year", 
       y="Price (piaster/kile)") + # provides title, subtitle, x, y, caption
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
  geom_segment(data = v.FoodRiots.Period, aes(x = date, xend = date, y = 10, yend = 24, colour = "food riot"),
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
v.FoodRiots.Period <- funcPeriod(v.FoodRiots,vDateStart,vDateStop) 

plotWheatKilePeriod3 <- ggplot(vWheatKilePeriod) +
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       # subtitle="based on announcements in newspapers", 
       x="Date", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  # layer: vertical lines for bread riots
  geom_segment(data = v.FoodRiots.Period, aes(x = date, xend = date, y = 10, yend = 24, colour = "food riot"),
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

v.Plot.Wheat.Annual.Cycle.Line <- ggplot(data = v.Prices.Wheat.Period) + 
  #geom_line(aes(x = date.common, y = quantity.2, group=factor(year(date)), colour=factor(year(date)))) + #the group function provides ways of generating plot per group and superimpose them onto each other
  # one could also use the yday() function from the lubridate library
  geom_line(aes(x = as.Date(yday(date), "1870-01-01"), y=quantity.2, colour=factor(year(date))))+
  # add labels
  labs(title="Wheat prices in Bilād al-Shām", 
       # subtitle="based on announcements in newspapers", 
       x="Month", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  scale_x_date(breaks=date_breaks("1 month"), 
               labels=date_format("%b")) + # %B full month names; $b abbreviated month
  theme_classic()+
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
v.Plot.Wheat.Annual.Cycle.Line

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

v.Date.Start <- as.Date("1904-01-01")
v.Date.Stop <- as.Date("1916-12-31")
v.Prices.Wheat.Period <- funcPeriod(v.Prices.Wheat,v.Date.Start,v.Date.Stop) 
v.Prices.Barley.Period <- funcPeriod(v.Prices.Barley,v.Date.Start,v.Date.Stop) 
v.Prices.Bread.Period <- funcPeriod(v.Prices.Bread,v.Date.Start,v.Date.Stop) 
v.FoodRiots.Period <- funcPeriod(v.FoodRiots,v.Date.Start,v.Date.Stop) 

# percentage of difference from the mean
v.Plot.Base +
  # first layer: min prices of wheat
  geom_line(data = v.Prices.Wheat.Daily.Period, 
            aes(x = date,y = dmp.2),
            na.rm=TRUE, color="black", linetype = 1)+
  # second layer: min prices of barley
  geom_line(data = v.Prices.Barley.Period, 
            aes(x = date,y = dmp.2),
            na.rm=TRUE, color="black", linetype = 2)+
  # second layer: min prices of bread
  geom_line(data = v.Prices.Bread.Period, 
            aes(x = date,y = dmp.2),
            na.rm=TRUE, color="black", linetype = 3)

