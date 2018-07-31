# this R script loads (broadly-defined) price data from csv files, processes this data 
# and writes the results to a number of data frames and csv files

# Remember it is good coding technique to add additional packages to the top of your script 
library(tidyverse) # load the tidyverse, which includes dplyr, tidyr and ggplot2
library(lubridate) # for working with dates
library(anytime) # for parsing incomplete dates
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# set a working directory
setwd("/BachCloud/BTSync/FormerDropbox/FoodRiots/food-riots_data") #Volumes/Dessau HD/

# 1. read price data from csv, note that the first row is a date
data.Prices <- read.csv("csv/prices.csv", header=TRUE, sep = ",", quote = "\"") # this is the main source file for prices
data.Prices.Exports <- read.csv("csv/export-statistics_unit-prices.csv", sep = ",", quote = "\"")
data.Prices.Trends <- read.csv("csv/qualitative-prices.csv", header=TRUE, sep = ",", quote = "\"")

## amend data.Prices.Exports to data.Prices
data.Prices <- plyr::rbind.fill(data.Prices, data.Prices.Exports)
## toponyms have not been normalised in the source data, this should be done now for later filtering.
## load location data
data.Locations <- read.csv("csv/locations.csv", header=TRUE, sep = ",", quote = "\"")
## join data.Price with data.Locations
data.Prices <- data.Prices %>% 
  dplyr::left_join(data.Locations,  by =  c("schema.Place" = "schema.Place"))

## find a way to unify toponyms: use the identifier to look up an authoritative toponym
df1 <- data.Prices
df2 <- data.Locations %>%
  dplyr::filter(schema.language=="en")
  
df1$name.en <- with(df2, schema.Place[match(df1$schema.identifier, schema.identifier)])

# add daily data based on the 'duration' column

# fix date types
## convert date to Date class, note that dates supplied as years only will be turned into NA if one uses as.date()
## anydate() converts dates from Y0001 to Y0001-M01-D01
data.Prices$schema.date <- anydate(data.Prices$schema.date)
data.Prices.Trends$schema.date <- anydate(data.Prices.Trends$schema.date)
## numeric
#data.Prices$quantity.2 <- as.numeric(data.Prices$quantity.2)
#data.Prices$quantity.3 <- as.numeric(data.Prices$quantity.3)

# aggregate periods
## use cut() to generate summary stats for time periods
## create variables of the year, quarter week and month of each observation:
data.Prices <- data.Prices %>%
  dplyr::mutate(year = as.Date(cut(data.Prices$schema.date, breaks = "year")), # first day of the year
                quarter = as.Date(cut(data.Prices$schema.date,breaks = "quarter")), # first day of the quarter
                month = as.Date(cut(data.Prices$schema.date,breaks = "month")), # first day of the month
                week = as.Date(cut(data.Prices$schema.date,breaks = "week", start.on.monday = TRUE)), # first day of the week; allows to change weekly break point to Sunday
                date.common = as.Date(paste0("2000-",format(data.Prices$schema.date, "%j")), "%Y-%j")) # add a column that sets all month/day combinations to the same year
data.Prices <- data.Prices %>%  
  dplyr::mutate(month.common = as.Date(cut(data.Prices$date.common,breaks = "month"))) # add a column that sets all month/day combinations to first day of the month

data.Prices.Trends <- data.Prices.Trends %>%
  dplyr::mutate(year = as.Date(cut(data.Prices.Trends$schema.date, breaks = "year")), # first day of the year
                quarter = as.Date(cut(data.Prices.Trends$schema.date,breaks = "quarter")), # first day of the quarter
                month = as.Date(cut(data.Prices.Trends$schema.date,breaks = "month")), # first day of the month
                week = as.Date(cut(data.Prices.Trends$schema.date,breaks = "week", start.on.monday = TRUE)), # first day of the week; allows to change weekly break point to Sunday
                date.common = as.Date(paste0("2000-",format(data.Prices.Trends$schema.date, "%j")), "%Y-%j")) # add a column that sets all month/day combinations to the same year
data.Prices.Trends <- data.Prices.Trends %>%  
  dplyr::mutate(month.common = as.Date(cut(data.Prices.Trends$date.common,breaks = "month"))) # add a column that sets all month/day combinations to first day of the month
save(data.Prices.Trends, file = "rda/prices_trends.rda")

# filter data and rename columns
## exchange rates
data.Exchange <- data.Prices %>%
  dplyr::filter(commodity.1=="currency" & commodity.2=="currency") %>% # filter for rows containing exchange rates
  dplyr::select(-commodity.1, -commodity.2, -commodity.3) # delete redundant rows

## other commodity prices
# rename columns
data.Prices <- data.Prices %>%
  dplyr::filter(commodity.2=="currency") %>% # filter for rows containing prices only
  dplyr::rename(commodity = commodity.1,
                quantity = quantity.1,
                unit = unit.1,
                price.min = quantity.2,
                price.max = quantity.3,
                currency = unit.2)%>% # rename the columns relevant to later operations
  dplyr::select(-commodity.2)%>% # omit unnecessary column
  arrange(schema.date)
save(data.Prices, file = "rda/prices.rda")
# filter for prices in Ottoman piasters
data.Prices.Ops <- data.Prices %>%
  dplyr::filter(currency=="ops") %>% # filter for rows containing prices in Ottoman Piasters only
  dplyr::select(-commodity.3, -unit.3) %>% # omit columns not needed
  dplyr::mutate(price.avg = case_when(price.max!='' ~ (price.min + price.max)/2, TRUE ~ price.min)) # add average between minimum and maximum prices
save(data.Prices.Ops, file = "rda/prices_ops.rda")
# filter for prices in GBP
data.Prices.Gbp <- data.Prices %>%
  dplyr::filter(currency=="gbp") %>% # filter for rows containing prices in Ottoman Piasters only
  dplyr::select(-commodity.3, -unit.3) %>% # omit columns not needed
  dplyr::mutate(price.avg = case_when(price.max!='' ~ (price.min + price.max)/2, TRUE ~ price.min)) # add average between minimum and maximum prices
  save(data.Prices.Gbp, file = "rda/prices_gbp.rda")
# create a subset of rows based on conditions; this can also be achieved with the filter() function from dplyr
## wheat prices
data.Prices.Wheat <- subset(data.Prices.Ops,commodity=="wheat" & unit=="kile")
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
  save(data.Prices.Wheat, file = "rda/prices_wheat-kile.rda")
  write.table(data.Prices.Wheat, "csv/summary/prices_wheat-kile.csv" , row.names = F, quote = T , sep = ",")
  
data.Prices.Wheat.Gbp <- subset(data.Prices.Gbp,commodity=="wheat" & unit=="kg")%>%
  ## deviation from the mean
  dplyr::mutate(dm.min = (price.min - mean(price.min, na.rm=T, trim = 0.1)),
    dm.max = (price.max - mean(price.max, na.rm=T, trim = 0.1)),
    dm.avg = (price.avg - mean(price.avg, na.rm=T, trim = 0.1))) %>%
    ## the same as percentages of mean
  dplyr::mutate(dmp.min = 100 * dm.min / mean(price.min, na.rm=T, trim = 0.1),
    dmp.max = 100 * dm.max / mean(price.max, na.rm=T, trim = 0.1),
    dmp.avg = 100 * dm.avg / mean(price.avg, na.rm=T, trim = 0.1))
  # write result to file
  save(data.Prices.Wheat.Gbp, file = "rda/prices_wheat-kg-gbp.rda")
  write.table(data.Prices.Wheat.Gbp, "csv/summary/prices_wheat-kg-gbp.csv" , row.names = F, quote = T , sep = ",")
## barley prices
data.Prices.Barley <- subset(data.Prices.Ops,commodity=="barley" & unit=="kile")%>%
  ## deviation from the mean
  dplyr::mutate(dm.min = (price.min - mean(price.min, na.rm=T, trim = 0.1)),
                dm.max = (price.max - mean(price.max, na.rm=T, trim = 0.1)),
                dm.avg = (price.avg - mean(price.avg, na.rm=T, trim = 0.1))) %>%
  ## the same as percentages of mean
  dplyr::mutate(dmp.min = 100 * dm.min / mean(price.min, na.rm=T, trim = 0.1),
                dmp.max = 100 * dm.max / mean(price.max, na.rm=T, trim = 0.1),
                dmp.avg = 100 * dm.avg / mean(price.avg, na.rm=T, trim = 0.1))
  # write result to file
  save(data.Prices.Barley, file = "rda/prices_barley-kile.rda")
  write.table(data.Prices.Barley, "csv/summary/prices_barley-kile.csv" , row.names = F, quote = T , sep = ",")
data.Prices.Bread <- subset(data.Prices.Ops,commodity=="bread" & unit=="kg")%>%
  ## deviation from the mean
  dplyr::mutate(dm.min = (price.min - mean(price.min, na.rm=T, trim = 0.1)),
                dm.max = (price.max - mean(price.max, na.rm=T, trim = 0.1)),
                dm.avg = (price.avg - mean(price.avg, na.rm=T, trim = 0.1))) %>%
  ## the same as percentages of mean
  dplyr::mutate(dmp.min = 100 * dm.min / mean(price.min, na.rm=T, trim = 0.1),
                dmp.max = 100 * dm.max / mean(price.max, na.rm=T, trim = 0.1),
                dmp.avg = 100 * dm.avg / mean(price.avg, na.rm=T, trim = 0.1))
  # write result to file
  save(data.Prices.Bread, file = "rda/prices_bread-kg.rda")
  write.table(data.Prices.Bread, "csv/summary/prices_bread-kg.csv" , row.names = F, quote = T , sep = ",")
# there is a customary threshold price for the ratl of bread at about Ps 3 per raṭl
data.Price.Bread.Threshold <- 1.169 
data.Prices.Newspapers <- subset(data.Prices,commodity=="newspaper")
  # write result to file
  save(data.Prices.Newspapers, file = "rda/prices_newspapers.rda")
  write.table(data.Prices.Newspapers, "csv/summary/prices_newspapers.csv" , row.names = F, quote = T , sep = ",")

# calculate means for periods
## annual means: not used
## data frame with annual mean for min and max prices)
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
  save(data.Prices.Wheat.Summary.Annual, file = "rda/prices_wheat-summary-annual.rda")
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
  save(data.Prices.Wheat.Summary.Quarterly, file = "rda/prices_wheat-summary-quarterly.rda")
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
  save(data.Prices.Wheat.Summary.Monthly, file = "rda/prices_wheat-summary-monthly.rda")
  write.table(data.Prices.Wheat.Summary.Monthly, "csv/summary/prices_wheat-summary-monthly.csv" , row.names = F, quote = T , sep = ",")

## data frame with daily mean for min and max prices
data.Prices.Wheat.Summary.Daily <- data.Prices.Wheat %>%
	group_by(schema.date) %>%
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
  save(data.Prices.Wheat.Summary.Daily, file = "rda/prices_wheat-summary-daily.rda")
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
  
# descriptive statistics
mean(data.Prices.Wheat$price.avg, na.rm=T, trim = 0.1)
mean(data.Prices.Barley$price.avg, na.rm=T, trim = 0.1)
median(data.Prices.Wheat$price.avg, na.rm=T)
quantile(data.Prices.Wheat$price.avg, na.rm=T)
sd(data.Prices.Wheat$price.avg, na.rm=T)
  