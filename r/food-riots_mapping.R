# Remember it is good coding technique to add additional packages to the top of your script 
library(anytime) # for working with dates
library(scales)   # to access breaks/formatting functions
library(gridExtra) # for arranging plots
## tidyverse
#library(tidyverse)
library(lubridate) # for working with dates
library(ggplot2)  # for creating graphs
library(ggrepel)
library(ggthemes) # install themes for ggplots
library(gridExtra) # add graphical objects (grob) to ggplot
library(cowplot) # to arrange plots on a canvas
library(plotly) # interactive plots based on ggplot
library(dplyr) # for data maipulation
library(tidyr) # for tidying data
#library(readr) # for reading data
# mapping packages
library(sp)
library(rgdal)
#library(geojsonio)
library(maps)  # contains outliens of continents, countries etc. Higher resolution is available from mapdata
library(ggmap)
library(maptools)
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")
# set a general theme for all ggplots
theme_set(theme_bw())

# set a working directory
setwd("/BachCloud/BTSync/FormerDropbox/FoodRiots/food-riots_data") #Volumes/Dessau HD/

# read data
data.Events.FoodRiots <- read.csv("csv/events_food-riots.csv", header=TRUE, sep = ";", quote = "\"")

## convert data types
## anydate() converts dates from Y0001 to Y0001-M01-D01
data.Events.FoodRiots$date <- anydate(data.Events.FoodRiots$date)

# prepare data for mapping 
data.Events.FoodRiots <- data.Events.FoodRiots %>%
  dplyr::mutate(date.common = as.Date(paste0("2000-",format(data.Events.FoodRiots$date, "%j")), "%Y-%j")) %>% # add a column that sets all month/day combinations to the same year
  # separate lat and long for publication place
  tidyr::separate(location.coordinates, c("lat", "long"),sep = ", ", extra = "drop") %>%
  # change data type for coordinates to numeric
  dplyr::mutate(lat = as.numeric(lat), 
                long = as.numeric(long))



# specify period
## function to create subsets for periods
func.Period.Date <- function(f,x,y){f[f$date >= x & f$date <= y,]}
func.Period.Year <- function(f,x,y){f[f$year >= x & f$year <= y,]}
date.Start <- anydate("1874-01-01")
date.Stop <- anydate("1916-12-31")
data.Events.FoodRiots.Period <- func.Period.Date(data.Events.FoodRiots,date.Start,date.Stop)


## summarise data
data.Events.FoodRiots.Period.Summary <- data.Events.FoodRiots.Period %>%
  group_by(location.name, lat, long) %>%
  summarise(number.of.foodriots = n()) %>%
  arrange(desc(number.of.foodriots))


# 2. plot: all layers can be stored as variables!
## simple  map; use geom_polygon in ggplot2 to map dataframes
map.Base <- ggplot() +
  labs(x="", y="",
       caption = "Till Grallert, CC BY-SA 4.0")+ # provides title, subtitle, x, y, caption
  geom_polygon(data = map_data("world"), aes(x=long, y = lat, group = group),
               #fill = "#E8E8E8", 
               fill = "#8290C1",
               #color = "#B7B7B7", 
               color = "#48417D",
               alpha = 0.6) + 
  coord_fixed(1.3)+ # fixes the relationship/aspect ratio between coordinates
  guides(fill=FALSE)  # do this to leave off the color legend
map.Base

# specify text sizes
# in themes size is measured in px
size.Base.Mm = 7
# font sizes are measured in mm
size.Base.Px = (5/14) * size.Base.Mm

# specify viewports / zoom levels
# all data points
viewport.Events.All <- c(coord_fixed(xlim = c(max(data.Events.FoodRiots.Period$long)+1, 
    min(data.Events.FoodRiots.Period$long) -1),  
  ylim = c(max(data.Events.FoodRiots.Period$lat), 
    min(data.Events.FoodRiots.Period$lat)), ratio = 1.3))
# Middle East 
viewport.ME <- c(coord_fixed(xlim = c(22, 46),  ylim = c(28, 42), ratio = 1.3))

# variable to store the locations of bylines as points
geom.Events.FoodRiots <- c(geom_point(data = data.Events.FoodRiots.Period.Summary, 
    aes(x = long, y= lat),
    size = data.Events.FoodRiots.Period.Summary$number.of.foodriots,
    shape = 21, stroke = 2,
    #color = "#FEEE00",
    color = "#F2D902", fill = "#FEFDB2", 
    alpha = 0.5))

# variable to store the labels for locations
geom.FoodRiots.Labels <- c(geom_text(data = data.Events.FoodRiots.Period.Summary, 
   aes(x = long, y = lat, 
       label = ifelse(number.of.foodriots > 0,paste(as.character(location.name),":",number.of.foodriots),''),
       hjust = -0.1, vjust = 0), 
   color = "#000426", check_overlap = FALSE, size = 1.8 * size.Base.Px))


# generate final map: Muqtabas, bylines
map.FoodRiots.All <- map.Base + 
  geom.Events.FoodRiots +
  geom.FoodRiots.Labels +
  labs(title = paste("Food riots in Bilād al-Shām","between",date.Start, "and", date.Stop),
       subtitle="") + 
  viewport.Events.All
map.FoodRiots.All



# add data table to plot
theme.table <- ttheme_minimal(base_size = size.Base.Mm)
tbl <- tableGrob(data.Muqtabas.Bylines.Locations.Summary.1,
                 cols = ,
                 rows=NULL, 
                 theme = theme.table)
tbl.1 <- ggtexttable(data.Muqtabas.Bylines.Locations.Summary.1, rows = NULL, 
                     theme = theme.table)

# arrange plots with gridExtra packa

grid.arrange(arrangeGrob(map.Muqtabas.Bylines.ME, tbl, ncol = 2))
grid.arrange(tbl)
grid.arrange(map.Muqtabas.Bylines.ME, tbl, ncol = 2)
grid.arrange(map.Muqtabas.Bylines.ME, tbl,
             nrow=2, ncol = 2, 
             as.table=F,
             heights=c(1,1))

# arrange plots with cowplot() package

ggdraw() +
  draw_plot(map.Muqtabas.Bylines.ME, x = 0, y = 0, width = 0.6, height = 1) +
  draw_plot(tbl, x = 0.7, y = 0, width = 0.3, height = 1)

## using ggmap
# view port
v.viewport <- make_bbox(lon = data.Muqtabas.Articles.Locations$long, lat = data.Muqtabas.Articles.Locations$lat, f = .1)
# First get the map. By default it gets it from Google.  I want it to be a satellite map
map.Base <- get_map(location = v.viewport, maptype = "terrain-background", source = "osm", color = "bw")
ggmap(v.viewport)