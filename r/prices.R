# Remember it is good coding technique to add additional packages to the top of
# your script 
library(tidyverse) # load the tidyverse, which includes dplyr, tidyr and ggplot2
library(lubridate) # for working with dates
library(anytime) # for parsing incomplete dates
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
library(plotly) # interactive plots based on ggplot
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# set a working directory
setwd("/BachCloud/BTSync/FormerDropbox/FoodRiots/food-riots_data") #Volumes/Dessau HD/

# 1. read price data from csv, note that the first row is a date
#data.Events.FoodRiots <- read.csv("csv/events_food-riots.csv", header=TRUE, sep = ";", quote = "\"")
data.Events <- read.csv("csv/events.csv", header=TRUE, sep = ";", quote = "\"")
data.Prices <- read.csv("csv/prices-2018-03-27.csv", header=TRUE, sep = ",", quote = "\"")
data.Prices.Trends <- read.csv("csv/qualitative-prices.csv", header=TRUE, sep = ",", quote = "\"")

# add daily data based on the 'duration' column

# fix date types
## convert date to Date class, note that dates supplied as years only will be turned into NA if one uses as.date()
## anydate() converts dates from Y0001 to Y0001-M01-D01
data.Events$date <- anydate(data.Events$date)
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
                date.common = as.Date(paste0("2000-",format(data.Prices$date, "%j")), "%Y-%j")) # add a column that sets all month/day combinations to the same year
data.Prices <- data.Prices %>%  
  dplyr::mutate(month.common = as.Date(cut(data.Prices$date.common,breaks = "month"))) # add a column that sets all month/day combinations to first day of the month

data.Prices.Trends <- data.Prices.Trends %>%
  dplyr::mutate(year = as.Date(cut(data.Prices.Trends$date, breaks = "year")), # first day of the year
                quarter = as.Date(cut(data.Prices.Trends$date,breaks = "quarter")), # first day of the quarter
                month = as.Date(cut(data.Prices.Trends$date,breaks = "month")), # first day of the month
                week = as.Date(cut(data.Prices.Trends$date,breaks = "week", start.on.monday = TRUE)), # first day of the week; allows to change weekly break point to Sunday
                date.common = as.Date(paste0("2000-",format(data.Prices.Trends$date, "%j")), "%Y-%j")) # add a column that sets all month/day combinations to the same year
data.Prices.Trends <- data.Prices.Trends %>%  
  dplyr::mutate(month.common = as.Date(cut(data.Prices.Trends$date.common,breaks = "month"))) # add a column that sets all month/day combinations to first day of the month

data.Events <- data.Events %>%
  dplyr::mutate(date.common = as.Date(paste0("2000-",format(data.Events$date, "%j")), "%Y-%j")) %>% # add a column that sets all month/day combinations to the same year
  # separate lat and long for publication place
  tidyr::separate(location.coordinates, c("lat", "long"),sep = ", ", extra = "drop") %>%
  # change data type for coordinates to numeric
  dplyr::mutate(lat = as.numeric(lat), 
         long = as.numeric(long))

# filter data and rename columns
## events: food riots
data.Events.FoodRiots <- data.Events %>%
  dplyr::filter(type=="food riot")
## write result to file
write.table(data.Events.FoodRiots, "csv/summary/events_food-riots.csv" , row.names = F, quote = T , sep = ";")

## exchange rates
data.Exchange <- data.Prices %>%
  dplyr::filter(commodity.1=="currency" & commodity.2=="currency") %>% # filter for rows containing exchange rates
  dplyr::select(-commodity.1, -commodity.2, -commodity.3) # delete redundant rows

## other prices
data.Prices <- data.Prices %>%
  dplyr::filter(commodity.2=="currency" & unit.2=="ops") %>% # filter for rows containing prices in Ottoman Piasters only
  dplyr::rename(commodity = commodity.1,
                quantity = quantity.1,
                unit = unit.1,
                price.min = quantity.2,
                price.max = quantity.3) %>% # rename the columns relevant to later operations
  dplyr::select(-commodity.2, -commodity.3, -unit.2, -unit.3) %>% # omit columns not needed
  dplyr::mutate(price.avg = case_when(price.max!='' ~ (price.min + price.max)/2, TRUE ~ price.min)) # add average between minimum and maximum prices

# create a subset of rows based on conditions; this can also be achieved with the filter() function from dplyr
data.Prices.Wheat <- subset(data.Prices,commodity=="wheat" & unit=="kile")
  ## descriptive stats
  # the computed arithmetic mean [mean(data.Prices.Wheat$price.min, na.rm=T, trim = 0.1)] based on the observed values
  #is much too high, compared to the prices reported as "normal" in our sources. Thus, I use a fixed parameter value
data.Price.Wheat.Mean <- 25
data.Prices.Wheat <- data.Prices.Wheat %>%
  ## deviation from the mean
  dplyr::mutate(dm.min = (price.min - mean(price.min, na.rm=T, trim = 0.1)),
                dm.max = (price.max - mean(price.max, na.rm=T, trim = 0.1)),
                dm.avg = (price.avg - mean(price.avg, na.rm=T, trim = 0.1))) %>%
  ## the same as percentages of mean
  dplyr::mutate(dmp.min = 100 * dm.min / mean(price.min, na.rm=T, trim = 0.1),
                dmp.max = 100 * dm.max / mean(price.max, na.rm=T, trim = 0.1),
                dmp.avg = 100 * dm.avg / mean(price.avg, na.rm=T, trim = 0.1))
  ## write result to file
  write.table(data.Prices.Wheat, "csv/summary/prices_wheat-kile.csv" , row.names = F, quote = T , sep = ",")
data.Prices.Barley <- subset(data.Prices,commodity=="barley" & unit=="kile")%>%
  ## deviation from the mean
  dplyr::mutate(dm.min = (price.min - mean(price.min, na.rm=T, trim = 0.1)),
                dm.max = (price.max - mean(price.max, na.rm=T, trim = 0.1)),
                dm.avg = (price.avg - mean(price.avg, na.rm=T, trim = 0.1))) %>%
  ## the same as percentages of mean
  dplyr::mutate(dmp.min = 100 * dm.min / mean(price.min, na.rm=T, trim = 0.1),
                dmp.max = 100 * dm.max / mean(price.max, na.rm=T, trim = 0.1),
                dmp.avg = 100 * dm.avg / mean(price.avg, na.rm=T, trim = 0.1))
  # write result to file
  write.table(data.Prices.Barley, "csv/summary/prices_barley-kile.csv" , row.names = F, quote = T , sep = ",")
data.Prices.Bread <- subset(data.Prices,commodity=="bread" & unit=="kg")%>%
  ## deviation from the mean
  dplyr::mutate(dm.min = (price.min - mean(price.min, na.rm=T, trim = 0.1)),
                dm.max = (price.max - mean(price.max, na.rm=T, trim = 0.1)),
                dm.avg = (price.avg - mean(price.avg, na.rm=T, trim = 0.1))) %>%
  ## the same as percentages of mean
  dplyr::mutate(dmp.min = 100 * dm.min / mean(price.min, na.rm=T, trim = 0.1),
                dmp.max = 100 * dm.max / mean(price.max, na.rm=T, trim = 0.1),
                dmp.avg = 100 * dm.avg / mean(price.avg, na.rm=T, trim = 0.1))
  # write result to file
  write.table(data.Prices.Bread, "csv/summary/prices_bread-kg.csv" , row.names = F, quote = T , sep = ",")
# there is a customary threshold price for the ratl of bread at about Ps 3 per raṭl
data.Price.Bread.Threshold <- 1.169 
data.Prices.Newspapers <- subset(data.Prices,commodity=="newspaper")
  # write result to file
  write.table(data.Prices.Newspapers, "csv/summary/prices_newspapers.csv" , row.names = F, quote = T , sep = ",")

# calculate means for periods
## annual means: not used
## data frame with annual mean for min and max prices
data.Prices.Wheat.Mean.Annual <- merge(
  aggregate(price.min ~ year, data=data.Prices.Wheat.Period, FUN = mean),
  aggregate(price.max ~ year, data=data.Prices.Wheat.Period, FUN = mean), 
  by=c("year"), all=T)
## use the more powerful dplyr package
data.Prices.Wheat.Summary.Annual <- data.Prices.Wheat %>%
  group_by(year) %>%
  summarise(count=n(), 
            mean.price.min = mean(price.min, na.rm = TRUE),
            mean.price.max = mean(price.max, na.rm = TRUE),
            median.min = median(price.min, na.rm = TRUE),
            median.max = median(price.max, na.rm = TRUE),
            sd.min = sd(price.min, na.rm = TRUE),
            sd.max = sd(price.max, na.rm = TRUE)
  )
  # write result to file
  write.table(data.Prices.Wheat.Summary.Annual, "csv/summary/prices_wheat-summary-annual.csv" , row.names = F, quote = T , sep = ",")

## data frame with quarterly mean for min and max prices: not used
data.Prices.Wheat.Summary.Quarterly <- data.Prices.Wheat %>%
  group_by(quarter) %>%
  summarise(count=n(), 
            mean.price.min=mean(price.min, na.rm = TRUE),
            mean.price.max=mean(price.max, na.rm = TRUE),
            median.min=median(price.min, na.rm = TRUE),
            median.max=median(price.max, na.rm = TRUE),
            sd.min=sd(price.min, na.rm = TRUE),
            sd.max=sd(price.max, na.rm = TRUE)
  )
  # write result to file
  write.table(data.Prices.Wheat.Summary.Quarterly, "csv/summary/prices_wheat-summary-quarterly.csv" , row.names = F, quote = T , sep = ",")

## data frame with monthly mean for min and max prices: not used
data.Prices.Wheat.Summary.Monthly <- data.Prices.Wheat %>%
  group_by(month) %>%
  summarise(count=n(), 
            mean.price.min=mean(price.min, na.rm = TRUE),
            mean.price.max=mean(price.max, na.rm = TRUE),
            median.min=median(price.min, na.rm = TRUE),
            median.max=median(price.max, na.rm = TRUE),
            sd.min=sd(price.min, na.rm = TRUE),
            sd.max=sd(price.max, na.rm = TRUE)
            )
  # write result to file
  write.table(data.Prices.Wheat.Summary.Monthly, "csv/summary/prices_wheat-summary-monthly.csv" , row.names = F, quote = T , sep = ",")

## data frame with daily mean for min and max prices
data.Prices.Wheat.Summary.Daily <- data.Prices.Wheat %>%
	group_by(date) %>%
	summarise(count=n(), 
	          mean.price.min=mean(price.min, na.rm = TRUE),
	          mean.price.max=mean(price.max, na.rm = TRUE),
	          mean.price.avg=mean(price.avg, na.rm = TRUE),
	          median.min = median(price.min, na.rm = TRUE),
	          median.max = median(price.max, na.rm = TRUE),
	          median.avg = median(price.avg, na.rm = TRUE),
	          sd.min = sd(price.min, na.rm = TRUE),
	          sd.max = sd(price.max, na.rm = TRUE),
	          sd.avg = sd(price.avg, na.rm = TRUE)
	) %>%
  ## difference from mean in per cent
  dplyr::mutate(dmp.min = 100 * (mean.price.min - mean(mean.price.min, na.rm=T, trim = 0.1)) / mean(mean.price.min, na.rm=T, trim = 0.1),
                dmp.max = 100 * (mean.price.max - mean(mean.price.max, na.rm=T, trim = 0.1)) / mean(mean.price.max, na.rm=T, trim = 0.1),
                dmp.avg = 100 * (mean.price.avg - mean(mean.price.avg, na.rm=T, trim = 0.1)) / mean(mean.price.avg, na.rm=T, trim = 0.1))
  #data.Prices.Wheat.Summary.Daily$dmp.2 <- (100 * (data.Prices.Wheat.Summary.Daily$mean.price.min - data.Price.Wheat.Mean) / data.Price.Wheat.Mean)
  #data.Prices.Wheat.Summary.Daily$dmp.3 <- (100 * (data.Prices.Wheat.Summary.Daily$mean.price.max - data.Price.Wheat.Mean) / data.Price.Wheat.Mean)
  # write result to file
  write.table(data.Prices.Wheat.Summary.Daily, "csv/summary/prices_wheat-summary-daily.csv" , row.names = F, quote = T , sep = ",")

## annual means: Barley: not used
data.Prices.Barley.Summary.Annual <- data.Prices.Barley %>%
  group_by(year) %>%
  summarise(count=n(), 
            mean.price.min=mean(price.min, na.rm = TRUE),
            mean.price.max=mean(price.max, na.rm = TRUE),
            median.min=median(price.min, na.rm = TRUE),
            median.max=median(price.max, na.rm = TRUE),
            sd.min=sd(price.min, na.rm = TRUE),
            sd.max=sd(price.max, na.rm = TRUE)
  )
  # write result to file
  write.table(data.Prices.Barley.Summary.Annual, "csv/summary/prices_barley-summary-annual.csv" , row.names = F, quote = T , sep = ",")

## data frame with quarterly mean for min and max prices
data.Prices.Barley.Summary.Quarterly <- data.Prices.Barley %>%
  group_by(quarter) %>%
  summarise(count=n(), 
            mean.price.min=mean(price.min, na.rm = TRUE),
            mean.price.max=mean(price.max, na.rm = TRUE),
            median.min=median(price.min, na.rm = TRUE),
            median.max=median(price.max, na.rm = TRUE),
            sd.min=sd(price.min, na.rm = TRUE),
            sd.max=sd(price.max, na.rm = TRUE)
  )
  # write result to file
  write.table(data.Prices.Barley.Summary.Quarterly, "csv/summary/prices_barley-summary-quarterly.csv" , row.names = F, quote = T , sep = ",")

## data frame with monthly mean for min and max prices
data.Prices.Barley.Summary.Monthly <- data.Prices.Barley %>%
  group_by(month) %>%
  summarise(count=n(), 
            mean.price.min=mean(price.min, na.rm = TRUE),
            mean.price.max=mean(price.max, na.rm = TRUE),
            median.min=median(price.min, na.rm = TRUE),
            median.max=median(price.max, na.rm = TRUE),
            sd.min=sd(price.min, na.rm = TRUE),
            sd.max=sd(price.max, na.rm = TRUE)
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
mean(data.Prices.Wheat.Period$price.avg, na.rm=T, trim = 0.1)
mean(data.Prices.Barley.Period$price.avg, na.rm=T, trim = 0.1)
median(data.Prices.Wheat.Period$price.avg, na.rm=T)
quantile(data.Prices.Wheat.Period$price.avg, na.rm=T)
sd(data.Prices.Wheat.Period$price.avg, na.rm=T)

# the list of wheat prices includes two very high data points for regions outside Bilād al-Shām, they should be filtered out
data.Prices.Wheat.Period <- data.Prices.Wheat.Period %>% 
  filter(price.avg < 200,
         price.avg > 2) # filter out some very unlikely minimum prices, which are most likely taxes and not prices
data.Prices.Wheat.Daily.Period <- data.Prices.Wheat.Daily.Period %>%
  filter(mean.price.avg < 200,
         mean.price.avg > 2)

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
## base plot for annual cycles
plot.Base.Annual <- ggplot() +
  labs(x = "",
       caption = "Till Grallert, CC BY-SA 4.0") +
  scale_x_date(breaks=date_breaks("1 month"), 
               labels=date_format("%B")) + # %B full month names; $b abbreviated month
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, vjust=0.5,hjust = 0.5, size = 8))  # rotate x axis text

# layers
labels.Wheat <- c(labs(title="Wheat prices in Bilad al-Sham",
                             y="Prices (piaster/kile)"))
## vertical lines for bread riots
layer.Events.FoodRiots <- c(geom_segment(data = data.Events.FoodRiots.Period, 
  aes(x = date, xend = date, y = 0, yend = 24, colour = type),
  size = 1, show.legend = T, na.rm = T, linetype=1)) # linetypes: 1=solid, 2=dashed)
layer.Events.FoodRiots.Small <- c(geom_segment(data = data.Events.FoodRiots.Period, 
  aes(x = date, xend = date, y = 0, yend = 1, colour = type),
  size = 1, show.legend = T, na.rm = T, linetype=1)) # linetypes: 1=solid, 2=dashed)
# Wheat prices
## scater plot of minimum prices
layer.Wheat.Price.Min.Scatter <- c(geom_point(data = data.Prices.Wheat.Period, 
  aes(x = date, # select period: date, year, quarter, month
      y = price.min, colour="price.min"),
  na.rm=TRUE, size=2, pch=3))
## scatter plot of maximum prices
layer.Wheat.Price.Max.Scatter <- c(geom_point(data = data.Prices.Wheat.Period, 
  aes(x=date, y=price.max, colour = "price.max"),
  na.rm=TRUE, size=2, pch=3))
## scatter plot of maximum prices
layer.Wheat.Price.Avg.Scatter <- c(geom_point(data = data.Prices.Wheat.Period, 
  aes(x=date, y=price.avg, colour = "price.avg"),
  na.rm=TRUE, size=2, pch=3))
## scatter plot of daily average minimum prices
layer.Wheat.Price.Min.Daily.Scatter <- c(geom_point(data = data.Prices.Wheat.Daily.Period, 
  aes(x = date, y = mean.price.min, colour = "price.min"),
  na.rm=TRUE, size=2, pch=3))
## line plot of daily average minimum prices
layer.Wheat.Price.Min.Daily.Line <- c(geom_line(data = data.Prices.Wheat.Daily.Period, 
  aes(x = date, y = mean.price.min, colour = "price.min"),
  na.rm=TRUE))
## scatter plot of daily average maximum prices
layer.Wheat.Price.Max.Daily.Scatter <- c(geom_point(data = data.Prices.Wheat.Daily.Period, 
  aes(x = date, y = mean.price.max, colour = "price.max"),
  na.rm=TRUE, size=2, pch=3))
## line plot of daily average maximum prices
layer.Wheat.Price.Max.Daily.Line <- c(geom_line(data = data.Prices.Wheat.Daily.Period, 
  aes(x = date, y = mean.price.max, colour = "price.max"),
  na.rm=TRUE))
# scatter plot of daily average prices
layer.Wheat.Price.Avg.Daily.Scatter <- c(geom_point(data = data.Prices.Wheat.Daily.Period, 
  aes(x = date, y = mean.price.avg, colour = "price.avg"),
  na.rm=TRUE, size=2, pch=3))
## line plot of daily average prices
layer.Wheat.Price.Avg.Daily.Line <- c(geom_line(data = data.Prices.Wheat.Daily.Period, 
  aes(x = date, y = mean.price.avg, colour = "price.avg"),
  na.rm=TRUE))
## box plot of minimum prices, aggregated by year.
layer.Wheat.Price.Min.Box <- c(geom_boxplot(data = data.Prices.Wheat.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
    group = year,y = price.min, colour = "price.min"), na.rm = T))
## box plot of maximum prices, aggregated by year
layer.Wheat.Price.Max.Box <- c(geom_boxplot(data = data.Prices.Wheat.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
    group = year,y = price.max, colour = "price.max"), na.rm = T, width=100))
## box plot of average prices, aggregated by year
layer.Wheat.Price.Avg.Box <- c(geom_boxplot(data = data.Prices.Wheat.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
  group = year,y = price.avg, colour = "price.avg"), na.rm = T))

# Barley prices
## box plot of minimum prices, aggregated by year.
layer.Barley.Price.Min.Box <- c(geom_boxplot(data = data.Prices.Barley.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
    group = year,y = price.min, colour = "price.min"), na.rm = T))
## box plot of maximum prices, aggregated by year
layer.Barley.Price.Max.Box <- c(geom_boxplot(data = data.Prices.Barley.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
    group = year,y = price.max, colour = "price.max"), na.rm = T, width=100))
## box plot of average prices, aggregated by year
layer.Barley.Price.Avg.Box <- c(geom_boxplot(data = data.Prices.Barley.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
  group = year,y = price.avg, colour = "price.avg"), na.rm = T))

# Bread prices
## box plot of minimum prices, aggregated by year.
layer.Bread.Price.Min.Box <- c(geom_boxplot(data = data.Prices.Bread.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
    group = year,y = price.min, colour = "price.min"), na.rm = T))
## scatter plot of daily average minimum prices
layer.Bread.Price.Min.Scatter <- c(geom_point(data = data.Prices.Bread.Period, 
  aes(x = date, y = price.min),  na.rm=TRUE, size=2, pch=3, color="black"))
## box plot of maximum prices, aggregated by year
layer.Bread.Price.Max.Box <- c(geom_boxplot(data = data.Prices.Bread.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
    group = year,y = price.max, colour = "price.max"), na.rm = T, width=100))
## box plot of average prices, aggregated by year
layer.Bread.Price.Avg.Box <- c(geom_boxplot(data = data.Prices.Bread.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
  group = year,y = price.avg, colour = "price.avg"), na.rm = T))
## layer for line of just price
layer.Bread.Price.Threshold <- c(geom_segment(data = data.Prices.Bread.Period, 
  aes(x = date.Start, xend = date.Stop, 
    y = data.Price.Bread.Threshold, yend = data.Price.Bread.Threshold,
    colour = "price.just"), 
  linetype = 3))


# qualitative data: prices
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
## annual cycle
layer.Trend.High.Cycle <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: high"),
  aes(x = date.common, group = date.common, y = size.Dot / 5 * 8, fill = tag),
  #fill = "#871020",
  shape=21, size=size.Dot/2, alpha = alpha.Dot))
layer.Trend.Rising.Cycle <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: rising"),
  aes(x = date.common, group = date.common, y = size.Dot / 5 * 6, fill = tag), 
  #fill = "#F7240C",
  shape=21, size=size.Dot/2, alpha = alpha.Dot))
layer.Trend.Normal.Cycle <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: normal"),
  aes(x = date.common, group = date.common, y = size.Dot / 5 * 4, fill = tag),
  shape=21, size=size.Dot/2, alpha = alpha.Dot))
layer.Trend.Falling.Cycle <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: falling"),
  aes(x = date.common, group = date.common, y = size.Dot / 5 * 2, fill = tag),
  #fill = "#91F200",
  shape=21, size=size.Dot/2, alpha = alpha.Dot))
layer.Trend.Low.Cycle <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: low"),
  aes(x = date.common, group = date.common, y = size.Dot / 5 * 0, fill = tag),
  #fill = "#1B8500",
  shape=21, size=size.Dot/2, alpha = alpha.Dot))

# scales and colour schemes
scale.Colours <- c(scale_colour_manual(name="Colours",
  breaks=c("price.avg", "price.just", "price.min", "price.max", 
           "prices: falling", "prices: high", "prices: low", "prices: normal", "prices: rising",
           "food riot"),
  values=c("food riot" = "#E11F05",
           "price.avg" = "black",
           "price.just" = "#E11F05",
           "price.min" = "#6E42F7",
           "price.max" = "#001368",
           "prices: high" = "#E72100",
           "prices: rising" = "#FF8840",
           "prices: normal" = "#49BCF3",
           "prices: falling" = "#88C816",
           "prices: low" = "#1B8500")))

# variables for saving the plots
period.String <- paste(year(date.Start),"-",year(date.Stop),sep = "")
width.Plot <- 600
height.Plot <- 200
dpi.Plot <- 300
units.Plot <- "mm"


# combine layers into plots
## plot all values
plot.Wheat.Scatter <- plot.Base + 
  #labels.Wheat +
  layer.Events.FoodRiots +
  #layer.Wheat.Price.Avg.Scatter +
  layer.Wheat.Price.Min.Scatter +
  layer.Wheat.Price.Max.Scatter +
  labs(title = paste("Wheat prices in Bilād al-Shām","between",year(date.Start), "and", year(date.Stop)),
       subtitle = "Showing minimum and maximum prices",
       y="Prices (piaster/kile)") +
  scale.Colours
plot.Wheat.Scatter

ggsave(filename = paste("plots/rplot_prices-wheat-", period.String ,"_scatter.png", sep = ""), 
       plot = plot.Wheat.Scatter,
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)

## daily averages
plot.Wheat.Daily.Mean.Scatter <- plot.Base +
  #labels.Wheat +
  layer.Events.FoodRiots +
  # first layer: min prices
  #layer.Wheat.Price.Min.Daily.Line +
  #layer.Wheat.Price.Min.Daily.Scatter +
  #geom_text(data = data.Prices.Wheat.Summary.Daily,aes(x = month, price.min, label=round(price.min)), size=3)+
  # second layer: max prices
  #layer.Wheat.Price.Max.Daily.Line +
  #layer.Wheat.Price.Max.Daily.Scatter +
  # layer: average prices
  #layer.Wheat.Price.Avg.Daily.Line +
  layer.Wheat.Price.Avg.Daily.Scatter +
# layer with connecting lines between min and max prices
#geom_segment(data = data.Prices.Wheat.Daily.Period, 
#             aes(x = date, xend = date, y = mean.price.min, yend = mean.price.max),
#             size = 0.3, show.legend = F, na.rm = T, linetype=1) # linetypes: 1=solid, 2=dashed,
  # add labels
  labs(title = paste("Wheat prices in Bilād al-Shām","between",year(date.Start), "and", year(date.Stop)), 
       subtitle= "Daily averages of minimum and maximum prices", 
       y = "Prices (piaster/kile)") +
  scale.Colours
plot.Wheat.Daily.Mean.Scatter

ggsave(filename = paste("plots/rplot_prices-wheat-", period.String ,"_daily-avg-scatter.png", sep = ""), 
       plot = plot.Wheat.Daily.Mean.Scatter,
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)

plot.Wheat.Daily.Mean.Line <- plot.Base +
  layer.Events.FoodRiots +
  # layer: average prices
  layer.Wheat.Price.Avg.Daily.Line +
  #layer.Wheat.Price.Avg.Daily.Scatter +
  # add labels
  labs(title = paste("Wheat prices in Bilād al-Shām","between",year(date.Start), "and", year(date.Stop)), 
       subtitle= "Daily averages of minimum and maximum prices", 
       y = "Prices (piaster/kile)") +
  scale.Colours
plot.Wheat.Daily.Mean.Line

ggsave(filename = paste("plots/rplot_prices-wheat-", period.String ,"_daily-avg-line.png", sep = ""), 
       plot = plot.Wheat.Daily.Mean.Scatter,
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)

## box plot
plot.Wheat.Box <- plot.Base +
  # add labels
  labs(title = paste("Wheat prices in Bilād al-Shām","between", year(date.Start), "and", year(date.Stop)),
       subtitle="Average prices aggregated by year", 
       y="Price (piaster/kile)") + # provides title, subtitle, x, y, caption
  layer.Events.FoodRiots +
  # layer: box plot prices, average of min and max prices
  layer.Wheat.Price.Avg.Box +
  #layer.Wheat.Price.Min.Box +
  ## add error bars
  #stat_boxplot(geom ='errorbar')+
  #layer.Wheat.Price.Max.Box +
  # change legend and colours
  scale.Colours +
  theme(legend.position="right", legend.box = "vertical")
plot.Wheat.Box

ggsave(filename = paste("plots/rplot_prices-wheat-", period.String ,"_box-plot.png", sep = ""), 
       plot = plot.Wheat.Box,
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)

plot.Barley.Box <- plot.Base +
  # add labels
  labs(title = paste("Barley prices in Bilād al-Shām","between", year(date.Start), "and", year(date.Stop)),
       subtitle="Average prices aggregated by year", 
       y="Price (piaster/kile)") +
  layer.Events.FoodRiots +
  layer.Barley.Price.Avg.Box +
  #layer.Barley.Price.Min.Box +
  #layer.Barley.Price.Max.Box +
  # change legend and colours
  scale.Colours +
  theme(legend.position="right", legend.box = "vertical")
plot.Barley.Box

ggsave(filename = paste("plots/rplot_prices-barley-", period.String ,"_box-plot.png", sep = ""), 
       plot = plot.Barley.Box,
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)

plot.Bread.Box <- plot.Base +
  # add labels
  labs(title = paste("Bread prices in Bilād al-Shām","between", year(date.Start), "and", year(date.Stop)),
       subtitle="Average prices aggregated by year", 
       y="Price (piaster/kg)") + # provides title, subtitle, x, y, caption
  layer.Events.FoodRiots.Small +
  layer.Bread.Price.Threshold +
  layer.Bread.Price.Avg.Box +
  #layer.Bread.Price.Min.Box +
  #layer.Bread.Price.Max.Box +
  #layer.Bread.Price.Min.Scatter +
  # change legend and colours
  scale.Colours + 
  theme(legend.position="right", legend.box = "vertical")
plot.Bread.Box

ggsave(filename = paste("plots/rplot_prices-bread-", period.String ,"_box-plot.png", sep = ""), 
       plot = plot.Bread.Box,
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)

# explore annual cycles
plot.Wheat.Annual.Cycle.Box <- plot.Base.Annual +
  geom_segment(data = data.Events.FoodRiots.Period, 
               aes(x = date.common, xend = date.common, y = 0, yend = 24, colour = type),
               size = 1, show.legend = T, na.rm = T, linetype=1)+
  # it would be important to know how many values are represented in each box
  #geom_boxplot(data = data.Prices.Wheat.Period, 
   #            aes(x = month.common %m+% days(15), group = month.common, y = price.min, colour = "price.min"),
    #           na.rm=TRUE) +
  #geom_boxplot(data = data.Prices.Wheat.Period, 
   #            aes(x = month.common %m+% days(15), group = month.common, y = price.max, colour = "price.max"),
    #           na.rm=TRUE, width = 10) +
  geom_boxplot(data = data.Prices.Wheat.Period, 
               aes(x = month.common %m+% days(15), group = month.common, y = price.avg, colour = "price.avg"),
               na.rm=TRUE) +
  #stat_boxplot(geom ="errorbar") +
  labs(title = paste("Wheat prices in Bilād al-Shām","between", year(date.Start), "and", year(date.Stop)),
       subtitle = "Annual cycle of average prices aggregated by month",
       y ="Price (piaster/kile)") +
  # change legend and colours
  scale.Colours + 
  theme(legend.position="right", legend.box = "vertical")
plot.Wheat.Annual.Cycle.Box

ggsave(filename = paste("plots/rplot_prices-wheat-", period.String ,"_annual-cycle-box.png", sep = ""), 
       plot = plot.Wheat.Annual.Cycle.Box,
       units = units.Plot , height = height.Plot, width = height.Plot, dpi = dpi.Plot)

## annual cycle with trends
plot.Wheat.Annual.Cycle.Box.Trends <- plot.Wheat.Annual.Cycle.Box +
  layer.Trend.High.Cycle +
  layer.Trend.Rising.Cycle +
  layer.Trend.Falling.Cycle +
  layer.Trend.Low.Cycle

ggsave(filename = paste("plots/rplot_prices-wheat-", period.String ,"_annual-cycle-box-trends.png", sep = ""), 
       plot = plot.Wheat.Annual.Cycle.Box.Trends,
       units = units.Plot , height = height.Plot, width = height.Plot, dpi = dpi.Plot)

plot.Bread.Annual.Cycle.Box <- plot.Base.Annual +
  geom_segment(data = data.Events.FoodRiots.Period, 
               aes(x = date.common, xend = date.common, y = 0, yend = 1, colour = type),
               size = 1, show.legend = T, na.rm = T, linetype=1)+
  # it would be important to know how many values are represented in each box
  #geom_boxplot(data = data.Prices.Bread.Period, 
   #            aes(x = month.common %m+% days(15), group = month.common, y = price.min, colour = "price.min"),
    #           na.rm=TRUE)+
  #geom_boxplot(data = data.Prices.Bread.Period, 
   #            aes(x = month.common %m+% days(15), group = month.common, y = price.max, colour = "price.max"),
    #           na.rm=TRUE, width = 10)+
  geom_boxplot(data = data.Prices.Bread.Period, 
               aes(x = month.common %m+% days(15), group = month.common, y = price.avg, colour = "price.avg"),
               na.rm=TRUE)+
  #stat_boxplot(geom ="errorbar") +
  labs(title = paste("Bread prices in Bilād al-Shām","between", year(date.Start), "and", year(date.Stop)),
       subtitle = "Annual cycle aggregated by month",
       y ="Price (piaster/kg)") +
  # change legend and colours
  scale.Colours + 
  theme(legend.position="right", legend.box = "vertical")
plot.Bread.Annual.Cycle.Box

ggsave(filename = paste("plots/rplot_prices-bread-", period.String ,"_annual-cycle-box.png", sep = ""), 
       plot = plot.Bread.Annual.Cycle.Box,
       units = units.Plot , height = height.Plot, width = height.Plot, dpi = dpi.Plot)

## plot of qualitative trend data
plot.Trends <- plot.Base + 
  layer.Events.FoodRiots +
  layer.Trend.High + 
  layer.Trend.Rising +
  layer.Trend.Normal +
  layer.Trend.Falling +
  layer.Trend.Low +
  #layer.Wheat.Price.Min.Daily.Line +
  #layer.Wheat.Price.Min.Daily.Scatter +
  labs(title = paste("Food prices in Bilād al-Shām","between", year(date.Start), "and", year(date.Stop)),
       subtitle = "Showing qualitative price information") +
  scale.Colours
plot.Trends

ggsave(filename = paste("plots/rplot_prices-food-", period.String ,"_trends.png", sep = ""), 
       plot = plot.Trends,
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)

## box plot plus trend data
plot.Wheat.Box.Trends <- plot.Wheat.Box +
  #layer.Wheat.Price.Avg.Daily.Line +
  layer.Trend.High + 
  layer.Trend.Rising +
  layer.Trend.Normal +
  layer.Trend.Falling +
  layer.Trend.Low
plot.Wheat.Box.Trends

ggsave(filename = paste("plots/rplot_prices-wheat-", period.String ,"_box-plot-trends.png", sep = ""), 
       plot = plot.Wheat.Box.Trends,
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)

# percentage of difference from the mean
plot.Food.Deviance <- plot.Base +
  geom_segment(data = data.Events.FoodRiots.Period, 
               aes(x = date, xend = date, y = -100, yend = -50, colour = type),
               size = 1, show.legend = T, na.rm = T, linetype=1)+
  # first layer: min prices of wheat
  geom_line(data = data.Prices.Wheat.Daily.Period, 
            aes(x = date,y = dmp.avg, linetype = "wheat"),
            na.rm=TRUE, color="black") +
  # second layer: min prices of barley
  geom_line(data = data.Prices.Barley.Period, 
            aes(x = date,y = dmp.avg, linetype = "barley"),
            na.rm=TRUE, color="black") +
  # second layer: min prices of bread
  geom_line(data = data.Prices.Bread.Period, 
            aes(x = date,y = dmp.avg, linetype = "bread"),
            na.rm=TRUE, color="black") +
  labs(title=paste("Food prices in Bilād al-Shām","between", year(date.Start), "and", year(date.Stop)),
       subtitle="Wheat, barley and bread prices", 
       y="Deviation from mean in per cent") +
  scale_linetype_manual("Commodity",values=c("wheat"=1,"barley"=2, "bread" = 3)) +
  scale.Colours
plot.Food.Deviance

ggsave(filename = paste("plots/rplot_prices-food-", period.String ,"_deviation-from-mean.png", sep = ""), 
       plot = plot.Food.Deviance,
       units = units.Plot , height = height.Plot, width = width.Plot, dpi = dpi.Plot)


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
