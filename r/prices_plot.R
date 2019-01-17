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

# load functions from external R script
source("/BachCloud/BTSync/FormerDropbox/FoodRiots/food-riots_tools/r/food-riots_functions.R")

# load data output from `prices_process-data.R` and `events_process-data.R`
## event data
load("rda/events_food-riots.rda") # data.Events.FoodRiots
## price data
load("rda/prices.rda") # data.Prices
load("rda/prices_ops.rda") # data.Prices.Ops
load("rda/prices_gbp.rda") # data.Prices.Gbp
load("rda/prices_wheat-kile.rda") # data.Prices.Wheat
load("rda/prices_wheat-kg-gbp.rda") # data.Prices.Wheat.Gbp
load("rda/prices_barley-kile.rda") # data.Prices.Barley
load("rda/prices_bread-kg.rda") # data.Prices.Bread
load("rda/prices_wheat-summary-annual.rda") # data.Prices.Wheat.Summary.Annual
load("rda/prices_wheat-summary-quarterly.rda") # data.Prices.Wheat.Summary.Quarterly
load("rda/prices_wheat-summary-monthly.rda") # data.Prices.Wheat.Summary.Monthly
load("rda/prices_wheat-summary-daily.rda") # data.Prices.Wheat.Summary.Daily
load("rda/prices_trends.rda") # data.Prices.Trends

# specify a geographic region
## Bilād al-Shām
location.Levant <- c('Acre','Aleppo','Baʿbdā','Beirut','Bayrūt','Damascus','Haifa','Hama','Hebron','Homs','Jaffa','Jerusalem','Nablus','Latakia','Tripoli', 'Ottoman Empire','Syria')
location.Beirut <- c('Beirut', 'Bayrūt')
location.Damascus <- c('Damascus', 'Syria')

## Egypt
location.Egypt <- c('Alexandria', 'Cairo', 'Egypt', 'Port Said')
location.Maghrib <- c('ALgiers', 'Tunis')
location.OEm <- c('Constantinople','Istanbul','Ottoman Empire')
## Yemen, Iraq, Iran, India still missing

# specify period
## function to create subsets for periods
date.Start <- anydate("1875-01-01")
date.Stop <- anydate("1882-12-31")
data.Prices.Wheat.Period <- f.date.period(data.Prices.Wheat,date.Start,date.Stop)
data.Prices.Wheat.Daily.Period <- f.date.period(data.Prices.Wheat.Summary.Daily,date.Start,date.Stop)
data.Prices.Barley.Period <- f.date.period(data.Prices.Barley,date.Start,date.Stop) 
data.Prices.Bread.Period <- f.date.period(data.Prices.Bread,date.Start,date.Stop) 
data.Prices.Trends.Period <- f.date.period(data.Prices.Trends,date.Start,date.Stop)
data.Events.FoodRiots.Period <- f.date.period(data.Events.FoodRiots,date.Start,date.Stop)

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
  aes(x = schema.date, xend = schema.date, y = 0, yend = 24, colour = type),
  size = 1, show.legend = T, na.rm = T, linetype=1)) # linetypes: 1=solid, 2=dashed)
layer.Events.FoodRiots.Small <- c(geom_segment(data = data.Events.FoodRiots.Period, 
  aes(x = schema.date, xend = schema.date, y = 0, yend = 1, colour = type),
  size = 1, show.legend = T, na.rm = T, linetype=1)) # linetypes: 1=solid, 2=dashed)
# Wheat prices
## scater plot of minimum prices
layer.Wheat.Price.Min.Scatter <- c(geom_point(data = data.Prices.Wheat.Period, 
  aes(x = schema.date, # select period: date, year, quarter, month
      y = price.min, colour="price.min"),
  na.rm=TRUE, size=2, pch=3))
## scatter plot of maximum prices
layer.Wheat.Price.Max.Scatter <- c(geom_point(data = data.Prices.Wheat.Period, 
  aes(x = schema.date, y=price.max, colour = "price.max"),
  na.rm=TRUE, size=2, pch=3))
## scatter plot of average prices
layer.Wheat.Price.Avg.Scatter <- c(geom_point(data = data.Prices.Wheat.Period, 
  aes(x = schema.date, y=price.avg, colour = "price.avg"),
  na.rm=TRUE, size=2, pch=3))
## scatter plot of daily average prices
layer.Wheat.Price.Avg.Daily.Scatter <- c(geom_point(data = data.Prices.Wheat.Daily.Period, 
  aes(x = schema.date, y = mean.price.avg, colour = "price.avg"),
  na.rm=TRUE, size=2, pch=3))
## line plot of daily average prices
layer.Wheat.Price.Avg.Daily.Line <- c(geom_line(data = data.Prices.Wheat.Daily.Period, 
  aes(x = schema.date, y = mean.price.avg, colour = "price.avg"),
  na.rm=TRUE))
## box plot of average prices, aggregated by year
layer.Wheat.Price.Avg.Box <- c(geom_boxplot(data = data.Prices.Wheat.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
  group = year,y = price.avg, colour = "price.avg"), na.rm = T))


# Barley prices
## box plot of average prices, aggregated by year
layer.Barley.Price.Avg.Box <- c(geom_boxplot(data = data.Prices.Barley.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
  group = year,y = price.avg, colour = "price.avg"), na.rm = T))

# Bread prices
## box plot of average prices, aggregated by year
layer.Bread.Price.Avg.Box <- c(geom_boxplot(data = data.Prices.Bread.Period,
  aes(x = year %m+% months(6), # add six months to move box to center of the year
  group = year,y = price.avg, colour = "price.avg"), na.rm = T))
## scatter plot of average prices
layer.Bread.Price.Avg.Scatter <- c(geom_point(data = data.Prices.Bread.Period, 
  aes(x = schema.date, y=price.avg, colour = "price.avg"),
  na.rm=TRUE, size=2, pch=3))
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
  aes(x = schema.date, y = size.Dot / 5 * 8, fill = tag),
  #fill = "#871020",
  shape=21, size=size.Dot, alpha = alpha.Dot))
layer.Trend.Rising <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: rising"),
  aes(x = schema.date, y = size.Dot / 5 * 6, fill = tag), 
  #fill = "#F7240C",
  shape=21, size=size.Dot, alpha = alpha.Dot))
layer.Trend.Normal <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: normal"),
  aes(x = schema.date, y = size.Dot / 5 * 4, fill = tag),
  shape=21, size=size.Dot, alpha = alpha.Dot))
layer.Trend.Falling <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: falling"),
  aes(x = schema.date, y = size.Dot / 5 * 2, fill = tag),
  #fill = "#91F200",
  shape=21, size=size.Dot, alpha = alpha.Dot))
layer.Trend.Low <- c(geom_point(data = filter(data.Prices.Trends.Period, tag=="prices: low"),
  aes(x = schema.date, y = size.Dot / 5 * 0, fill = tag),
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
## ad hoc area
plot.Base + geom_boxplot(data = dplyr::filter(data.Prices.Gbp, commodity=="barley", unit=="kg"),
  aes(x = year %m+% months(6), # add six months to move box to center of the year
  group = year,y = price.avg, colour = "price.avg"), na.rm = T)

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
  # layer: average prices
  layer.Wheat.Price.Avg.Daily.Scatter +
# layer with connecting lines between min and max prices
#geom_segment(data = data.Prices.Wheat.Daily.Period, 
#             aes(x = schema.date, xend = schema.date, y = mean.price.min, yend = mean.price.max),
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
  # add labels
  labs(title = paste("Wheat prices in Bilād al-Shām","between",year(date.Start), "and", year(date.Stop)), 
       subtitle= "Daily averages of minimum and maximum prices", 
       y = "Prices (piaster/kile)") +
  scale.Colours
plot.Wheat.Daily.Mean.Line

ggsave(filename = paste("plots/rplot_prices-wheat-", period.String ,"_daily-avg-line.png", sep = ""), 
       plot = plot.Wheat.Daily.Mean.Line,
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
  #layer.Bread.Price.Avg.Scatter +
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
               aes(x = schema.date, xend = schema.date, y = -100, yend = -50, colour = type),
               size = 1, show.legend = T, na.rm = T, linetype=1)+
  # first layer: min prices of wheat
  geom_line(data = data.Prices.Wheat.Daily.Period, 
            aes(x = schema.date,y = dmp.avg, linetype = "wheat"),
            na.rm=TRUE, color="black") +
  # second layer: min prices of barley
  geom_line(data = data.Prices.Barley.Period, 
            aes(x = schema.date,y = dmp.avg, linetype = "barley"),
            na.rm=TRUE, color="black") +
  # second layer: min prices of bread
  geom_line(data = data.Prices.Bread.Period, 
            aes(x = schema.date,y = dmp.avg, linetype = "bread"),
            na.rm=TRUE, color="black") +
  labs(title=paste("Food prices in Bilād al-Shām","between", year(date.Start), "and", year(date.Stop)),
       subtitle="Deviation of wheat, barley and bread prices from the mean", 
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
              aes(x = schema.date, # select period: date, year, quarter, month
                  y = price.min),
              na.rm=TRUE,width = 100, # width controls the jitter around the original position. High values are required for my data
              size=1) +
  # second layer: max prices
  geom_jitter(data = data.Prices.Wheat.Period, 
              aes(x = schema.date, # select period: date, year, quarter, month
                  y = price.max),
              na.rm=TRUE,width = 100, # width controls the jitter around the original position. High values are required for my data
              size=1) +
  # second layer: fitted line
  stat_smooth(data = data.Prices.Wheat.Period, aes(x = schema.date, # select period: date, year, quarter, month
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
             aes(x = schema.date, y = price.max),
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
