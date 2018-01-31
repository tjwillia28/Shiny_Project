library(shiny)
library(shinydashboard)
library(shinythemes)
library(dplyr)
library(ggplot2)
library(googleVis)
library(leaflet)
library(maps)

#Read in cleaned csv
df_ps = read.csv('/Users/ty/Desktop/Shiny_Project_2/shiny_df_clean.csv', stringsAsFactors = F)

# National Park Icon Probably needs to go into UI
national_park_logo = makeIcon('/Users/ty/Desktop/Shiny_Project_2/USNP_logo.png', iconWidth = 30, iconHeight = 45)