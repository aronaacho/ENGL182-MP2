#  server
library(dplyr)
library(plotly)
library(ggplot2)
library(shiny)
library(lubridate)
library(dplyr)

# importing netflix data
imported <- read.csv("netflix_titles.csv")
## converting character date to date type
imported$date_added <- mdy(imported$date_added)

# sorting the data

## all titles with all years and "" country
noCountry <- imported %>% 
  select(title, date_added, country) %>% 
  filter(country == "") %>% 
  select(date_added, title, country) %>% 
  as.data.frame()

## all titles with all years without "" country
hasCountry <- imported %>% 
  select(title, date_added, country) %>% 
  filter(country != "") %>% 
  select(date_added, title, country) %>% 
  as.data.frame()

## all titles with all years and country != "United States" && != "" 
## to represent all the outsourced (including multiple countries)
nonUS <- imported %>% 
  select(title, date_added, country) %>% 
  filter(country != "", country != "United States") %>% 
  filter(!grepl("United States", country)) %>% 
  select(date_added, title, country) %>% 
  as.data.frame()

## all US associated media
USAssociated <- imported %>% 
  select(title, date_added, country) %>% 
  filter(country != "") %>% 
  filter(grepl("United States", country)) %>% 
  select(date_added, title, country) %>% 
  as.data.frame()

## total number of nonUS / hasCountry to get prop for ggplot
hasCountryCount <- hasCountry %>% 
  group_by(year = year(date_added)) %>% 
  count()

nonUSCount <- nonUS %>% 
  group_by(year = year(date_added)) %>% 
  count()

USAssociatedCount <- USAssociated %>% 
  group_by(year = year(date_added)) %>% 
  count()

totalCount <- merge(USAssociatedCount, nonUSCount, by = 'year', all = TRUE) %>% 
  group_by(year)

totalCount[is.na(totalCount)] = 0

totalCount <- totalCount %>% 
  mutate(total = n.x + n.y) %>% 
  rename("nonUS" = "n.y",
         "USAssociated" = "n.x")

totalCount <- subset(totalCount, year != 0)

# getting proportions
## USAssociated / total and nonUS / total

totalCount <- totalCount %>% 
  mutate(USprop = USAssociated / total,
         OUTprop = nonUS / total)

#___________________________________________________________________________________
# getting amount of joint sourcing vs total pure US sourcing
pureUS <- USAssociated %>% 
  filter(country == "United States")

withUS <- USAssociated %>% 
  filter(country != "United States") %>% 
  filter(grepl("United States", country))

pureUSCount <- pureUS %>% 
  group_by(year = year(date_added)) %>% 
  count()

withUSCount <- withUS %>% 
  group_by(year = year(date_added)) %>% 
  count()

totalUS <- merge(pureUSCount, withUSCount, by = 'year', all = TRUE) %>% 
  group_by(year)

totalUS[is.na(totalUS)] = 0
totalUS <- subset(totalUS, year != 0)

totalUS <- totalUS %>% 
  mutate(total = n.x + n.y) %>% 
  rename("pure_US" = "n.x",
         "with_others" = "n.y")

totalUS <- totalUS %>% 
  mutate(pure_us_prod = pure_US / total,
         US_prod_w_others = with_others / total)
#______________
currentAll <- merge(totalUS, nonUSCount, by = 'year', all = TRUE) %>% 
  group_by(year)

currentAll[is.na(currentAll)] = 0
currentAll <- subset(currentAll, year != 0)

currentAll <- currentAll %>% 
  mutate(total = pure_US + with_others + n,
         non_US_prod = n / total,
         pure_us_prod = pure_US / total,
         US_prod_w_others = with_others / total) %>% 
  rename("non_US" = "n")

#___________________________________________________________________________________
# current distribution pie
current_US <- data.frame(color = c("pureUS", "withUS"),
                         count = c(2812, 872)) %>% 
  mutate(percentage = count / (sum(current_US$count)))

# current all pie
current_all <- data.frame(color = c("Pure US Production", "US Production with Others", "Non-US Production"),
                          count = c(2812, 872, 4284)) %>% 
  mutate(percentage = count / (sum(current_all$count)))

#___________________________________________________________________________________



#  shiny server

server <- function(input, output) {
  output$scatter <- renderPlotly({
    out_plot <- ggplot(totalCount, mapping = aes_string(x = totalCount$year, y = input$count_choices)) + 
      geom_point(
        color = "#32bf97") + 
      labs(x = "Year", caption = "This is a scatter plot that shows the trends of the amount of Netflix media and their sources.") +
      theme_light()
    if(input$trendline_box) {
      out_plot <- out_plot +
        geom_smooth()
    }
    return(out_plot)
  })
  output$us_pie <- renderPlotly({
    us_pie_plot <- plot_ly(data = current_all, labels = ~color, values = ~count,
                        type = 'pie', sort = FALSE,
                        marker = list(colors = c("#8490FA", "#FAE084", "#E6945E"), line = list(color = "white", width = 2))) %>% 
      layout(title = "Pie Chart of Current Production Distributions (US Associated)")
    return(us_pie_plot)
  })
}

