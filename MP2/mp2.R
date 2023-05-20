#  app
library(dplyr)
library(plotly)
library(ggplot2)
library(shiny)
library(lubridate)

source("mp2_server.R")
source("mp2_ui.R")

shinyApp(ui = ui, server = server)

