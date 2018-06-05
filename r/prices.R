# Remember it is good coding technique to add additional packages to the top of
# your script 
library(tidyverse) # load the tidyverse, which includes dplyr and ggplot2
#library(dplyr) # data manipulation
library(lubridate) # for working with dates
library(anytime) # for parsing incomplete dates
#library(ggplot2)  # for creating graphs
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
library(plotly) # interactive plots based on ggplot
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# set a working directory
setwd("/BachCloud/BTSync/FormerDropbox/FoodRiots/food-riots_data") #Volumes/Dessau HD/

# 1. read price data from csv, note that the first row is a date
data.Events.FoodRiots <- read.csv("csv/events_food-riots.csv", header=TRUE, sep = ",", quote = "\"")
data.Prices <- read.csv("csv/prices-2018-03-27.csv", header=TRUE, sep = ",", quote = "\"")
data.Prices.Trends <- read.csv("csv/qualitative-prices.csv", header=TRUE, sep = ",", quote = "\"")

# add daily data based on the 'duration' column

# fix date types
## convert date to Date class, note that dates supplied as years only will be turned into NA if one uses as.date()
## anydate() converts dates from Y0001 to Y0001-M01-D01
data.Events.FoodRiots$date <- anydate(data.Events.FoodRiots$date)
data.Prices$date <- anydate(data.Prices$date)
data.Prices.Trends$date <- anydate(data.Prices.Trends$date)
## numeric
#data.Prices$quantity.2 <- as.numeric(data.Prices$quantity.2)
#data.Prices$quantity.3 <- as.numeric(data.Prices$quantity.3)

# aggregate periods
## use cut() to generate summary stats for time periods
## create variables of the year, quarter week and month of each observation:
data.Prices <- data.Prices %>%
  dplyr::mutate(year = as.Date(cut(data.Prices$date, breaks = "year")), # first day of the year
                quarter = as.Date(cut(data.Prices$date,breaks = "quarter")), # first day of the quarter
                month = as.Date(cut(data.Prices$date,breaks = "month")), # first day of the month
                week = as.Date(cut(data.Prices$date,breaks = "week", start.on.monday = TRUE)), # first day of the week; allows to change weekly break point to Sunday
                date.common = as.Date(paste0("2000-",format(data.Prices$date, "%j")), "%Y-%j")) %>% # add a column that sets all month/day combinations to the same year
  dplyr::mutate(month.common = as.Date(cut(data.Prices$date.common,breaks = "month"))) # add a column that sets all month/day combinations to first day of the month

# filter data and rename columns
data.Prices <- data.Prices %>%
  dplyr::filter(commodity.2=="currency" & unit.2=="ops") %>% # filter for rows containing prices in Ottoman Piasters only
  dplyr::rename(commodity = commodity.1,
                quantity = quantity.1,
                unit = unit.1,
                price.min = quantity.2,
                price.max = quantity.3) %>% # rename the columns relevant to later operations
  dplyr::select(-commodity.2, -commodity.3, -unit.2, -unit.3) # omit columns not needed

# create a subset of rows based on conditions; this can also be achieved with the filter() function from dplyr
data.Prices.Wheat <- subset(data.Prices,commodity=="wheat" & unit=="kile")
  ## descriptive stats
  # the computed arithmetic mean [mean(data.Prices.Wheat$price.min, na.rm=T, trim = 0.1)] based on the observed values
  #is much too high, compared to the prices reported as "normal" in our sources. Thus, I use a fixed parameter value
data.Prices.Wheat.Mean <- 25
data.Prices.Wheat <- data.Prices.Wheat %>%
  ## deviation from the mean
  dplyr::mutate(dm.2 = (data.Prices.Wheat$price.min - data.Prices.Wheat.Mean),
                dm.3 = (data.Prices.Wheat$price.max - data.Prices.Wheat.Mean)) %>%
  ## the same as percentages of mean
  dplyr::mutate(dmp.2 = 100 * data.Prices.Wheat$dm.2 / data.Prices.Wheat.Mean,
                dmp.3 = 100 * data.Prices.Wheat$dm.3 / data.Prices.Wheat.Mean)
  ## write result to file
  write.table(data.Prices.Wheat, "csv/summary/prices_wheat-kile.csv" , row.names = F, quote = T , sep = ",")
data.Prices.Barley <- subset(data.Prices,commodity=="barley" & unit=="kile")
  ## deviation from the mean
  data.Prices.Barley$dm.2 <- (data.Prices.Barley$price.min - mean(data.Prices.Barley$price.min, na.rm=T, trim = 0.1))
  data.Prices.Barley$dm.3 <- (data.Prices.Barley$price.max - mean(data.Prices.Barley$price.max, na.rm=T, trim = 0.1))
  ## the same as percentages of mean
  data.Prices.Barley$dmp.2 <- (100 * data.Prices.Barley$dm.2 / mean(data.Prices.Barley$price.min, na.rm=T, trim = 0.1))
  data.Prices.Barley$dmp.3 <- (100 * data.Prices.Barley$dm.3 / mean(data.Prices.Barley$price.max, na.rm=T, trim = 0.1))
  # write result to file
  write.table(data.Prices.Barley, "csv/summary/prices_barley-kile.csv" , row.names = F, quote = T , sep = ",")
data.Prices.Bread <- subset(data.Prices,commodity=="bread" & unit=="kg")
  ## deviation from the mean
  data.Prices.Bread$dm.2 <- (data.Prices.Bread$price.min - mean(data.Prices.Bread$price.min, na.rm=T, trim = 0.1))
  data.Prices.Bread$dm.3 <- (data.Prices.Bread$price.max - mean(data.Prices.Bread$price.max, na.rm=T, trim = 0.1))
  ## the same as percentages of mean
  data.Prices.Bread$dmp.2 <- (100 * data.Prices.Bread$dm.2 / mean(data.Prices.Bread$price.min, na.rm=T, trim = 0.1))
  data.Prices.Bread$dmp.3 <- (100 * data.Prices.Bread$dm.3 / mean(data.Prices.Bread$price.max, na.rm=T, trim = 0.1))
  # write result to file
  write.table(data.Prices.Bread, "csv/summary/prices_bread-kg.csv" , row.names = F, quote = T , sep = ",")
data.Prices.Newspapers <- subset(data.Prices,commodity=="newspaper")
  # write result to file
  write.table(data.Prices.Newspapers, "csv/summary/prices_newspapers.csv" , row.names = F, quote = T , sep = ",")

# calculate means for periods
## annual means
#data.Prices.Wheat.Mean.Annual <- aggregate((price.min + price.max)/2 ~ year, data=data.Prices.Wheat.Period, mean)
## data frame with annual mean for min and max prices
data.Prices.Wheat.Mean.Annual <- merge(
  aggregate(price.min ~ year, data=data.Prices.Wheat.Period, FUN = mean),
  aggregate(price.max ~ year, data=data.Prices.Wheat.Period, FUN = mean), 
  by=c("year"), all=T)
## use the more powerful dplyr package
data.Prices.Wheat.Summary.Annual <- data.Prices.Wheat %>%
  group_by(year) %>%
  summarise(count=n(), 
            mean.price.min=mean(price.min, na.rm = TRUE),
            mean.price.max=mean(price.max, na.rm = TRUE),
            median.2=median(price.min, na.rm = TRUE),
            median.3=median(price.max, na.rm = TRUE),
            sd.2=sd(price.min, na.rm = TRUE),
            sd.3=sd(price.max, na.rm = TRUE)
  )
  # write result to file
  write.table(data.Prices.Wheat.Summary.Annual, "csv/summary/prices_wheat-summary-annual.csv" , row.names = F, quote = T , sep = ",")

## data frame with quarterly mean for min and max prices
data.Prices.Wheat.Summary.Quarterly <- data.Prices.Wheat %>%
  group_by(quarter) %>%
  summarise(count=n(), 
            mean.price.min=mean(price.min, na.rm = TRUE),
            mean.price.max=mean(price.max, na.rm = TRUE),
            median.2=median(price.min, na.rm = TRUE),
            median.3=median(price.max, na.rm = TRUE),
            sd.2=sd(price.min, na.rm = TRUE),
            sd.3=sd(price.max, na.rm = TRUE)
  )
  # write result to file
  write.table(data.Prices.Wheat.Summary.Quarterly, "csv/summary/prices_wheat-summary-quarterly.csv" , row.names = F, quote = T , sep = ",")

## data frame with monthly mean for min and max prices
data.Prices.Wheat.Summary.Monthly <- data.Prices.Wheat %>%
  group_by(month) %>%
  summarise(count=n(), 
            mean.price.min=mean(price.min, na.rm = TRUE),
            mean.price.max=mean(price.max, na.rm = TRUE),
            median.2=median(price.min, na.rm = TRUE),
            median.3=median(price.max, na.rm = TRUE),
            sd.2=sd(price.min, na.rm = TRUE),
            sd.3=sd(price.max, na.rm = TRUE)
            )
  # write result to file
  write.table(data.Prices.Wheat.Summary.Monthly, "csv/summary/prices_wheat-summary-monthly.csv" , row.names = F, quote = T , sep = ",")

## data frame with daily mean for min and max prices
data.Prices.Wheat.Summary.Daily <- data.Prices.Wheat %>%
	group_by(date) %>%
	summarise(count=n(), 
	          mean.price.min=mean(price.min, na.rm = TRUE),
	          mean.price.max=mean(price.max, na.rm = TRUE),
	          median.2=median(price.min, na.rm = TRUE),
	          median.3=median(price.max, na.rm = TRUE),
	          sd.2=sd(price.min, na.rm = TRUE),
	          sd.3=sd(price.max, na.rm = TRUE)
	)
  ## difference from mean in per cent
  data.Prices.Wheat.Summary.Daily$dmp.2 <- (100 * (data.Prices.Wheat.Summary.Daily$mean.price.min - data.Prices.Wheat.Mean) / data.Prices.Wheat.Mean)
  data.Prices.Wheat.Summary.Daily$dmp.3 <- (100 * (data.Prices.Wheat.Summary.Daily$mean.price.max - data.Prices.Wheat.Mean) / data.Prices.Wheat.Mean)
  # write result to file
  write.table(data.Prices.Wheat.Summary.Daily, "csv/summary/prices_wheat-summary-daily.csv" , row.names = F, quote = T , sep = ",")

## annual means: Barley
data.Prices.Barley.Summary.Annual <- data.Prices.Barley %>%
  group_by(year) %>%
  summarise(count=n(), 
            mean.price.min=mean(price.min, na.rm = TRUE),
            mean.price.max=mean(price.max, na.rm = TRUE),
            median.2=median(price.min, na.rm = TRUE),
            median.3=median(price.max, na.rm = TRUE),
            sd.2=sd(price.min, na.rm = TRUE),
            sd.3=sd(price.max, na.rm = TRUE)
  )
  # write result to file
  write.table(data.Prices.Barley.Summary.Annual, "csv/summary/prices_barley-summary-annual.csv" , row.names = F, quote = T , sep = ",")

## data frame with quarterly mean for min and max prices
data.Prices.Barley.Summary.Quarterly <- data.Prices.Barley %>%
  group_by(quarter) %>%
  summarise(count=n(), 
            mean.price.min=mean(price.min, na.rm = TRUE),
            mean.price.max=mean(price.max, na.rm = TRUE),
            median.2=median(price.min, na.rm = TRUE),
            median.3=median(price.max, na.rm = TRUE),
            sd.2=sd(price.min, na.rm = TRUE),
            sd.3=sd(price.max, na.rm = TRUE)
  )
  # write result to file
  write.table(data.Prices.Barley.Summary.Quarterly, "csv/summary/prices_barley-summary-quarterly.csv" , row.names = F, quote = T , sep = ",")

## data frame with monthly mean for min and max prices
data.Prices.Barley.Summary.Monthly <- data.Prices.Barley %>%
  group_by(month) %>%
  summarise(count=n(), 
            mean.price.min=mean(price.min, na.rm = TRUE),
            mean.price.max=mean(price.max, na.rm = TRUE),
            median.2=median(price.min, na.rm = TRUE),
            median.3=median(price.max, na.rm = TRUE),
            sd.2=sd(price.min, na.rm = TRUE),
            sd.3=sd(price.max, na.rm = TRUE)
  )
  # write result to file
  write.table(data.Prices.Barley.Summary.Monthly, "csv/summary/prices_barley-summary-monthly.csv" , row.names = F, quote = T , sep = ",")
  
# specify period
## function to create subsets for periods
func.Period.Date <- function(f,x,y){f[f$date >= x & f$date <= y,]}
func.Period.Year <- function(f,x,y){f[f$year >= x & f$year <= y,]}
date.Start <- anydate("1874-01-01")
date.Stop <- anydate("1916-12-31")
data.Prices.Wheat.Period <- func.Period.Date(data.Prices.Wheat,date.Start,date.Stop)
data.Prices.Wheat.Daily.Period <- func.Period.Date(data.Prices.Wheat.Summary.Daily,date.Start,date.Stop)
data.Prices.Barley.Period <- func.Period.Date(data.Prices.Barley,date.Start,date.Stop) 
data.Prices.Bread.Period <- func.Period.Date(data.Prices.Bread,date.Start,date.Stop) 
data.Prices.Trends.Period <- func.Period.Date(data.Prices.Trends,date.Start,date.Stop)
data.Events.FoodRiots.Period <- func.Period.Date(data.Events.FoodRiots,date.Start,date.Stop)

# descriptive statistics
mean(data.Prices.Wheat.Period$price.min, na.rm=T, trim = 0.1)
mean(data.Prices.Barley.Period$price.min, na.rm=T, trim = 0.1)
median(data.Prices.Wheat.Period$price.min, na.rm=T)
quantile(data.Prices.Wheat.Period$price.min, na.rm=T)
sd(data.Prices.Wheat.Period$price.min, na.rm=T)

# the list of wheat prices includes two very high data points for regions outside Bilād al-Shām, they should be filtered out
data.Prices.Wheat.Period <- data.Prices.Wheat.Period %>% 
  filter(price.min < 200,
         price.min > 2) # filter out some very unlikely minimum prices, which are most likely taxes and not prices
data.Prices.Wheat.Daily.Period <- data.Prices.Wheat.Daily.Period %>%
  filter(mean.price.min < 200,
         mean.price.min > 2)

# plot
## base plot
plot.Base <- ggplot() +
  # add labels
  labs(x="Date",
       caption = "Till Grallert, CC BY-SA 4.0") +
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"))+
               #limits=as.Date(c(v.Date.Start, v.Date.Stop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw()+ # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text

# layers
labels.Wheat <- c(labs(title="Wheat prices in Bilad al-Sham",
                             y="Prices (piaster/kile)"))
## vertical lines for bread riots
layer.Events.FoodRiots <- c(geom_segment(data = data.Events.FoodRiots.Period, 
  aes(x = date, xend = date, y = 0, yend = 24, colour = type),
  size = 1, show.legend = T, na.rm = T, linetype=1)) # linetypes: 1=solid, 2=dashed)
## scater plot of minimum prices
layer.Wheat.Price.Min.Scatter <- c(geom_point(data = data.Prices.Wheat.Period, 
  aes(x = date, # select period: date, year, quarter, month
      y = price.min),
  na.rm=TRUE, color="green", size=2, pch=3))
## scatter plot of maximum prices
layer.Wheat.Price.Max.Scatter <- c(geom_point(data = data.Prices.Wheat.Period, 
  aes(x=date, y=price.max),
  na.rm=TRUE, size=2, pch=3, color="red"))

## scatter plot of daily average minimum prices
layer.Wheat.Price.Min.Daily.Scatter <- c(geom_point(data = data.Prices.Wheat.Daily.Period, 
  aes(x = date, y = mean.price.min),
  na.rm=TRUE, size=2, pch=3, color="black"))
## line plot of daily average minimum prices
layer.Wheat.Price.Min.Daily.Line <- c(geom_line(data = data.Prices.Wheat.Daily.Period, 
  aes(x = date, y = mean.price.min),
  na.rm=TRUE, color="green"))
## scatter plot of daily average maximum prices
layer.Wheat.Price.Max.Daily.Scatter <- c(geom_point(data = data.Prices.Wheat.Daily.Period, 
  aes(x = date, y = mean.price.max),
  na.rm=TRUE, size=2, pch=3, color="black"))
## line plot of daily average maximum prices
layer.Wheat.Price.Max.Daily.Line <- c(geom_line(data = data.Prices.Wheat.Daily.Period, 
  aes(x = date, y = mean.price.max),
  na.rm=TRUE, color="red"))
## box plot of minimum prices, aggregated by year.
layer.Wheat.Price.Min.Box <- c(geom_boxplot(data = data.Prices.Wheat.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
    group=year,y=price.min), na.rm = T))
## box plot of maximum prices, aggregated by year
layer.Wheat.Price.Max.Box <- c(geom_boxplot(data = data.Prices.Wheat.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
    group=year,y=price.max), na.rm = T, color="blue", width=100))
## qualitative data prices
size.Dot <- 10
alpha.Dot <- 0.3
layer.Trend.High <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: high"),
  aes(x = date, y = size.Dot / 5 * 8, fill = tag),
  #fill = "#871020",
  shape=21, size=size.Dot, alpha = alpha.Dot))
layer.Trend.Rising <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: rising"),
  aes(x = date, y = size.Dot / 5 * 6, fill = tag), 
  #fill = "#F7240C",
  shape=21, size=size.Dot, alpha = alpha.Dot))
layer.Trend.Normal <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: normal"),
  aes(x = date, y = size.Dot / 5 * 4, fill = tag),
  shape=21, size=size.Dot, alpha = alpha.Dot))
layer.Trend.Falling <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: falling"),
  aes(x = date, y = size.Dot / 5 * 2, fill = tag),
  #fill = "#91F200",
  shape=21, size=size.Dot, alpha = alpha.Dot))
layer.Trend.Low <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: low"),
  aes(x = date, y = size.Dot / 5 * 0, fill = tag),
  #fill = "#1B8500",
  shape=21, size=size.Dot, alpha = alpha.Dot))


# combine layers into plots
## plot all values
plot.Wheat.Scatter <- plot.Base + 
  #labels.Wheat +
  layer.Events.FoodRiots +
  layer.Wheat.Price.Min.Scatter +
  layer.Wheat.Price.Max.Scatter +
  labs(title = paste("Wheat prices in Bilād al-Shām","between",date.Start, "and", date.Stop),
       subtitle = "Showing minimum and maximum prices",
       y="Prices (piaster/kile)")
plot.Wheat.Scatter


## daily averages
plot.Wheat.Daily.Mean.Scatter <- plot.Base +
  #labels.Wheat +
  layer.Events.FoodRiots +
  # first layer: min prices
  layer.Wheat.Price.Min.Daily.Line +
  layer.Wheat.Price.Min.Daily.Scatter +
  #geom_text(data = data.Prices.Wheat.Summary.Daily,aes(x = month, price.min, label=round(price.min)), size=3)+
  # second layer: max prices
  layer.Wheat.Price.Max.Daily.Line +
  layer.Wheat.Price.Max.Daily.Scatter +
# layer with connecting lines between min and max prices
#geom_segment(data = data.Prices.Wheat.Daily.Period, 
#             aes(x = date, xend = date, y = mean.price.min, yend = mean.price.max),
#             size = 0.3, show.legend = F, na.rm = T, linetype=1) # linetypes: 1=solid, 2=dashed,
  # add labels
  labs(title = paste("Wheat prices in Bilād al-Shām","between",date.Start, "and", date.Stop), 
       subtitle= "Daily averages of minimum and maximum prices", 
       y = "Prices (piaster/kile)") +
plot.Wheat.Daily.Mean.Scatter

## box plot
plot.Wheat.Box <- plot.Base +
  # add labels
  labs(title = paste("Wheat prices in Bilād al-Shām","between",date.Start, "and", date.Stop),
       subtitle="Minimum and maximum prices aggregated by year", 
       y="Price (piaster/kile)") + # provides title, subtitle, x, y, caption
  # layer: box plot prices, average of min and max prices
  #geom_boxplot(data = vWheatKilePeriod,aes(x=year,group=year,y=(price.min + price.max) / 2), na.rm = T)+
  layer.Wheat.Price.Min.Box +
  ## add error bars
  stat_boxplot(geom ='errorbar')+
  layer.Wheat.Price.Max.Box +
  layer.Events.FoodRiots
# layer: jitter plot
#geom_jitter(data = vWheatKilePeriod,aes(date, price.min,colour = "price points"), size=1, na.rm=TRUE,width = 50)+ # width depends on the width of the entire plot
# layer: line with all values
#geom_line(aes(date, price.min), na.rm=TRUE,color="red") +
# layer: fitted line
#stat_smooth(aes(date, price.min), na.rm = T,method="lm", se=T,color="blue")
plot.Wheat.Box

## plot of trend data
plot.Trends <- plot.Base + 
  layer.Events.FoodRiots +
  layer.Trend.High + 
  layer.Trend.Rising +
  layer.Trend.Normal +
  layer.Trend.Falling +
  layer.Trend.Low +
  #layer.Wheat.Price.Min.Daily.Line +
  #layer.Wheat.Price.Min.Daily.Scatter +
  labs(title = paste("Wheat prices in Bilād al-Shām","between",date.Start, "and", date.Stop),
       subtitle = "Showing qualitative price information")
plot.Trends

## box plot plus trend data
plot.Wheat.Box.Trends <- plot.Wheat.Box +
  layer.Trend.High + 
  layer.Trend.Rising +
  layer.Trend.Normal +
  layer.Trend.Falling +
  layer.Trend.Low
plot.Wheat.Box.Trends



# unused plots
## quarterly averages
plot.Wheat.Quarterly.Mean.Scatter <- plot.Base +
  layer.Events.FoodRiots +
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       subtitle="Quarterly averages of minimum and maximum prices based on announcements in newspapers", 
       y="Prices (piaster/kile)") +
  # first layer: min prices
  geom_point(data = data.Prices.Wheat.Summary.Quarterly, 
             aes(x = quarter, y = mean.price.min),
             na.rm=TRUE, size=2, pch=3)+
  #scale_color_gradient(low="darkkhaki", high="darkgreen")+
  #geom_text(data = data.Prices.Wheat.Mean.Quarterly,aes(x = quarter, price.min, label=round(price.min)), size=3)+
  # second layer: max prices
  geom_point(data = data.Prices.Wheat.Summary.Quarterly, 
             aes(x = quarter, y = mean.price.max),
             na.rm=TRUE, size=2, pch=3, color="black")+
  # layer with connecting lines between min and max prices
  geom_segment(data = data.Prices.Wheat.Summary.Quarterly, 
               aes(x = quarter, xend = quarter, y = mean.price.min, yend = mean.price.max),size = 0.3, show.legend = F, na.rm = T, linetype=1) # linetypes: 1=solid, 2=dashed,
plot.Wheat.Quarterly.Mean.Scatter

## monthly averages
plot.Wheat.Monthly.Mean.Scatter <- plot.Base+
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       subtitle="Quarterly averages of minimum and maximum prices based on announcements in newspapers", 
       y="Prices (piaster/kile)") +
  # first layer: min prices
  geom_point(data = data.Prices.Wheat.Summary.Monthly, 
             aes(x = month, y = mean.price.min),
             na.rm=TRUE, size=2, pch=3)+
  geom_line(data = data.Prices.Wheat.Summary.Monthly, 
            aes(x = month, y = mean.price.min),
             na.rm=TRUE, color="green")+
  #geom_text(data = data.Prices.Wheat.Mean.Monthly,aes(x = month, price.min, label=round(price.min)), size=3)+
  # second layer: max prices
  geom_point(data = data.Prices.Wheat.Summary.Monthly, 
             aes(x = month, y = mean.price.max),
             na.rm=TRUE, size=2, pch=3, color="black")+
  geom_line(data = data.Prices.Wheat.Summary.Monthly, 
            aes(x = month, y = mean.price.max),
          na.rm=TRUE, color="red")+
# layer with connecting lines between min and max prices
geom_segment(data = data.Prices.Wheat.Summary.Monthly, 
             aes(x = month, xend = month, y = mean.price.min, yend = mean.price.max),
             size = 0.3, show.legend = F, na.rm = T, linetype=1) # linetypes: 1=solid, 2=dashed,
plot.Wheat.Monthly.Mean.Scatter


  

## Jitter plot
plot.Wheat.Jitter <- plot.Base+
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       subtitle="based on announcements in newspapers", 
       #x="Date", 
       y="Prices (piaster/kile)") +
  # first layer: min prices
  geom_jitter(data = data.Prices.Wheat.Period, 
              aes(x = date, # select period: date, year, quarter, month
                  y = price.min),
              na.rm=TRUE,width = 100, # width controls the jitter around the original position. High values are required for my data
              size=1) +
  # second layer: max prices
  geom_jitter(data = data.Prices.Wheat.Period, 
              aes(x = date, # select period: date, year, quarter, month
                  y = price.max),
              na.rm=TRUE,width = 100, # width controls the jitter around the original position. High values are required for my data
              size=1) +
  # second layer: fitted line
  stat_smooth(data = data.Prices.Wheat.Period, aes(x = date, # select period: date, year, quarter, month
                                                y = price.min),
              colour="green",na.rm = TRUE,
              method="loess", # methods are "lm", "loess" ...
              se=F) # removes the range around the fitting
plot.Wheat.Jitter
  

## box plot plus price trends, reset the period
# specify period
v.Date.Start <- as.Date("1900-01-01")
v.Date.Stop <- as.Date("1916-12-31")
data.Prices.Wheat.Period <- funcPeriod(data.Prices.Wheat,v.Date.Start,v.Date.Stop)
data.Prices.Wheat.Daily.Period <- funcPeriod(data.Prices.Wheat.Summary.Daily,v.Date.Start,v.Date.Stop)
data.Prices.Trends.Period <- funcPeriod(data.Prices.Trends,v.Date.Start,v.Date.Stop)
data.Events.FoodRiots.Period <- funcPeriod(data.Events.FoodRiots,v.Date.Start,v.Date.Stop)

plot.Wheat.Box.Price.Trends <- plot.Base +
  # add labels
  labs(title="Wheat prices and food riots in Bilad al-Sham", 
       subtitle="minimum prices aggregated by year", 
       y="Price (piaster/kile)") + # provides title, subtitle, x, y, caption
  # layer: box plot prices, average of min and max prices
  #geom_boxplot(data = vWheatKilePeriod,aes(x=year,group=year,y=(price.min + price.max) / 2), na.rm = T)+
  # layer: box plot min prices
  geom_boxplot(data = data.Prices.Wheat.Period,aes(x=year,group=year,y=price.min), na.rm = T)+
  ## add error bars
  stat_boxplot(geom ='errorbar')+
  # layer: box plot max prices
  geom_boxplot(data = data.Prices.Wheat.Period,aes(x=year, group=year,y=price.max), na.rm = T, color="blue", width=100)+
  # despite some visiual overlap, count charts are not the best solution to the data set 
  # because only very few reports fall on the same day (and thus formally) overlap
  # layer: falling prices
  geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: high"),
             aes(x = date, y = 9, colour = tag),
             fill = "#871020",
             shape=21, size=4, alpha = 0.3)+
  # layer: falling prices
  geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: rising"),
             aes(x = date, y = 7, colour = tag), 
             fill = "#F7240C",
             shape=21, size=4, alpha = 0.3)+
  # layer: falling prices
  geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: normal"),
             aes(x = date, y = 5, colour = tag),
             shape=21, size=4, alpha = 0.3)+
  # layer: falling prices
  geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: falling"),
             aes(x = date, y = 3, colour = tag),
             fill = "#91F200",
             shape=21, size=4, alpha = 0.3)+
  # layer: falling prices
  geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: low"),
             aes(x = date, y = 1, colour = tag),
             fill = "#1B8500",
             shape=21, size=4, alpha = 0.3)
plot.Wheat.Box.Price.Trends

plot.Barley.Box <- plot.Base+
  # add labels
  labs(title="Barley prices and food riots in Bilad al-Sham", 
       subtitle="minimum prices aggregated by year", 
       y="Price (piaster/kile)") + # provides title, subtitle, x, y, caption
  # layer: box plot min prices
  geom_boxplot(data = data.Prices.Barley.Period,aes(x=year,group=year,y=price.min), na.rm = T)+
  # layer: box plot max prices
  geom_boxplot(data = data.Prices.Barley.Period,aes(x=year, group=year,y=price.max), na.rm = T, color="blue", width=100)
plot.Barley.Box
  
  
## plot with two time series
plotWheatKilePeriod2 <- ggplot(vWheatKilePeriod) +
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       # subtitle="based on announcements in newspapers", 
       x="Date", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  # layer: vertical lines for bread riots
  geom_segment(data = data.Events.FoodRiots.Period, aes(x = date, xend = date, y = 10, yend = 24, colour = "food riot"),
               size = 1, show.legend = F, na.rm = T, linetype=1)+ # linetypes: 1=solid, 2=dashed,
  # first layer: min prices
  geom_point(aes(x=date, y=price.min),
             na.rm=TRUE,
             size=2, shape=21, color="black")  +
  # second layer: max prices
  geom_point(aes(x=date, y=price.max),
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
data.Events.FoodRiots.Period <- funcPeriod(data.Events.FoodRiots,vDateStart,vDateStop) 

plotWheatKilePeriod3 <- ggplot(vWheatKilePeriod) +
  # add labels
  labs(title="Wheat prices in Bilad al-Sham", 
       # subtitle="based on announcements in newspapers", 
       x="Date", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  # layer: vertical lines for bread riots
  geom_segment(data = data.Events.FoodRiots.Period, aes(x = date, xend = date, y = 10, yend = 24, colour = "food riot"),
               size = 1, show.legend = F, na.rm = T, linetype=1)+ # linetypes: 1=solid, 2=dashed, 
  # first layer: min prices
  geom_point(aes(x=date, y=price.min),
             na.rm=TRUE,
             size=2, pch=3, color="black")  +
  # second layer: max prices
  geom_point(aes(x=date, y=price.max),
             na.rm=TRUE, 
             size=2, pch=3, color="black") +
  # layer with connecting lines between min and max prices
  geom_segment(aes(x = date, xend = date, y = price.min, yend = price.max), show.legend = F, na.rm = T, linetype=1, color = "black")+ # linetypes: 1=solid, 2=dashed, 
  scale_x_date(breaks=date_breaks("2 years"), 
               labels=date_format("%Y"),
               limits=as.Date(c(vDateStart, vDateStop))) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw()+ # make the themeblack-and-white rather than grey (do this before font changes, or it overridesthem)
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
plotWheatKilePeriod3


# plot day of the year / explore seasonality

plot.Wheat.Annual.Cycle.Scatter <- ggplot()+
  geom_point(data = data.Prices.Wheat.Period, 
             aes(x = date.common, y = price.min),
             na.rm=TRUE, size=2, pch=3, color="black")+
  geom_point(data = data.Prices.Wheat.Period, 
             aes(x = date.common, y = price.max),
             na.rm=TRUE, size=2, pch=3, color="black")+
  scale_x_date(breaks=date_breaks("1 month"), 
               labels=date_format("%d-%b")) + # if plotting more than one graph, it is helpful to provide the same limits for each
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
plot.Wheat.Annual.Cycle.Scatter

plot.Wheat.Annual.Cycle.Line <- ggplot(data = data.Prices.Wheat.Period) + 
  #geom_line(aes(x = date.common, y = price.min, group=factor(year(date)), colour=factor(year(date)))) + #the group function provides ways of generating plot per group and superimpose them onto each other
  # one could also use the yday() function from the lubridate library
  geom_line(aes(x = as.Date(yday(date), "1870-01-01"), y=price.min, colour=factor(year(date))))+
  # add labels
  labs(title="Wheat prices in Bilād al-Shām", 
       # subtitle="based on announcements in newspapers", 
       x="Month", 
       y="Prices (piaster/kile)") + # provides title, subtitle, x, y, caption
  scale_x_date(breaks=date_breaks("1 month"), 
               labels=date_format("%b")) + # %B full month names; $b abbreviated month
  theme_classic()+
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
plot.Wheat.Annual.Cycle.Line

plot.Wheat.Annual.Cycle.Box <- ggplot()+
  # it would be important to know how many values are represented in each box
  geom_boxplot(data = data.Prices.Wheat.Period, 
             aes(x = month.common, group = month.common, y = price.min),
             na.rm=TRUE, color="black")+
  geom_boxplot(data = data.Prices.Wheat.Period, 
               aes(x = month.common, group = month.common, y = price.max),
               na.rm=TRUE, width = 10,  color="blue")+
  stat_boxplot(geom ="errorbar")+
  scale_x_date(breaks=date_breaks("1 month"), 
               labels=date_format("%B")) + # %B full month names; $b abbreviated month
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
plot.Wheat.Annual.Cycle.Box

plot.Bread.Annual.Cycle.Box <- ggplot()+
  # it would be important to know how many values are represented in each box
  geom_boxplot(data = data.Prices.Bread.Period, 
               aes(x = month.common, group = month.common, y = price.min),
               na.rm=TRUE, color="black")+
  geom_boxplot(data = data.Prices.Bread.Period, 
               aes(x = month.common, group = month.common, y = price.max),
               na.rm=TRUE, width = 10,  color="blue")+
  stat_boxplot(geom ="errorbar")+
  scale_x_date(breaks=date_breaks("1 month"), 
               labels=date_format("%B")) + # %B full month names; $b abbreviated month
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text
plot.Bread.Annual.Cycle.Box

v.Date.Start <- as.Date("1904-01-01")
v.Date.Stop <- as.Date("1916-12-31")
data.Prices.Wheat.Period <- funcPeriod(data.Prices.Wheat,v.Date.Start,v.Date.Stop) 
data.Prices.Barley.Period <- funcPeriod(data.Prices.Barley,v.Date.Start,v.Date.Stop) 
data.Prices.Bread.Period <- funcPeriod(data.Prices.Bread,v.Date.Start,v.Date.Stop) 
data.Events.FoodRiots.Period <- funcPeriod(data.Events.FoodRiots,v.Date.Start,v.Date.Stop) 

# percentage of difference from the mean
plot.Base +
  # first layer: min prices of wheat
  geom_line(data = data.Prices.Wheat.Daily.Period, 
            aes(x = date,y = dmp.2),
            na.rm=TRUE, color="black", linetype = 1)+
  # second layer: min prices of barley
  geom_line(data = data.Prices.Barley.Period, 
            aes(x = date,y = dmp.2),
            na.rm=TRUE, color="black", linetype = 2)+
  # second layer: min prices of bread
  geom_line(data = data.Prices.Bread.Period, 
            aes(x = date,y = dmp.2),
            na.rm=TRUE, color="black", linetype = 3)

