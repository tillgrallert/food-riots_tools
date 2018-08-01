# this R script loads trade data from csv files, processes this data 
# and writes the results to a number of data frames and csv files

# Remember it is good coding technique to add additional packages to the top of your script 
library(tidyverse) # load the tidyverse, which includes dplyr, tidyr and ggplot2
library(lubridate) # for working with dates
library(anytime) # for parsing incomplete dates
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# set a working directory
setwd("/BachCloud/BTSync/FormerDropbox/FoodRiots/food-riots_data") #Volumes/Dessau HD/

# read data
data.Exports <- read.csv("csv/export-statistics.csv", header=TRUE, sep = ",", quote = "\"")
# convert data types
## anydate() converts dates from Y0001 to Y0001-M01-D01
data.Exports$schema.date <- anydate(as.factor(data.Exports$schema.date))
# clean up data
data.Exports <- data.Exports %>%
  dplyr::rename(commodity = commodity.1,
                quantity = quantity.1,
                unit = unit.1,
                currency = unit.2,
                value = quantity.2) %>% # rename the columns relevant to later operations
  dplyr::select(-commodity.2) # omit columns not needed
# add location information based on another file
data.Locations <- read.csv("csv/locations.csv", header=TRUE, sep = ",", quote = "\"") # this file contains toponyms and coordinates
data.Exports <- data.Exports %>%
  dplyr::left_join(data.Locations,  by =  c("schema.Place" = "schema.Place"))

# save data
save(data.Exports, file = "rda/trade_exports.rda")
write.table(data.Exports, "csv/summary/trade_exports.csv" , row.names = F, quote = T , sep = ",")
