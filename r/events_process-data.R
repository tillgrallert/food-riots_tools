# this R script loads event data from csv files, processes this data 
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
data.Events <- read.csv("csv/events.csv", header=TRUE, sep = ",", quote = "\"")

# fix date types
## convert date to Date class, note that dates supplied as years only will be turned into NA if one uses as.date()
## anydate() converts dates from Y0001 to Y0001-M01-D01
data.Events$schema.date <- anydate(data.Events$schema.date)

# aggregate periods
## use cut() to generate summary stats for time periods
## create variables of the year, quarter week and month of each observation:
data.Events <- data.Events %>%
  dplyr::mutate(date.common = as.Date(paste0("2000-",format(data.Events$schema.date, "%j")), "%Y-%j")) %>% # add a column that sets all month/day combinations to the same year
  dplyr::arrange(schema.date) # sort by date
  
# filter data and rename columns
## events: food riots
data.Events.FoodRiots <- data.Events %>%
  dplyr::filter(type=="food riot")
data.Events.Mutinies <- data.Events %>%
  dplyr::filter(type=="mutiny")
data.Events.PrisonRiots <- data.Events %>%
  dplyr::filter(type=="prison riot")
data.Events.Famines <- data.Events %>%
  dplyr::filter(type=="famine")
## write results to file
save(data.Events.FoodRiots, file = "rda/events_food-riots.rda")
write.table(data.Events.FoodRiots, "csv/summary/events_food-riots.csv" , row.names = F, quote = T , sep = ",")
save(data.Events.Mutinies, file = "rda/events_mutinies.rda")
write.table(data.Events.Mutinies, "csv/summary/events_mutinies.csv" , row.names = F, quote = T , sep = ",")
save(data.Events.PrisonRiots, file = "rda/events_prison-riots.rda")
write.table(data.Events.PrisonRiots, "csv/summary/events_prison-riots.csv" , row.names = F, quote = T , sep = ",")
save(data.Events.Famines, file = "rda/events_famines.rda")
write.table(data.Events.Famines, "csv/summary/events_famines.csv" , row.names = F, quote = T , sep = ",")

