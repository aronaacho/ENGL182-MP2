# ui
library(dplyr)
library(plotly)
library(ggplot2)
library(shiny)
library(lubridate)

source("mp2_server.R")

# intro page


intro_main_content <- tabPanel(
  img("", src = "/source/netflixCircleCrop.png", height="30%", width="30%"),
  h4("Arona Cho"),
  h4(" ENGL 182 for Sp23"),
  p("This project is for English 182, as we explore and understand Cohen's Monster Thesis 3."),
  p(""),
  p("This is a visualization of the different sources that Netflix brings in their shows from"),
  align = "center")

intro_tab_panel <- tabPanel("Introduction", 
                            titlePanel("Netflix's Sourcing of Shows"),
                            img("", src = "/Users/AronaCho_1/Desktop/uni/classes/archived/Au22/info201/project-group-4-section-ae/source/netflixCircleCrop.png", height="30%", width="30%"),
                            p("This is a project for English 182, as we explore and understand Cohen's Monster Thesis 3."),
                            align = "center")

# interactive visualization page

viz_main_content <- mainPanel(
  plotlyOutput("scatter"),
  p(""),
  p(em("This scatter plot presents the various proportions of Netflix's sourcing of their content. This data is recent as of 2021."))
)

viz_sidebar_content <- sidebarPanel(
  selectInput("count_choices",
              "Percentage of Netflix's Content Sourced from...",
              choices = list("US Production" = "USprop",
                             "Non-US Production" = "OUTprop")),
  checkboxInput("trendline_box",
                "Show Trendline",
                value = TRUE),
  "This scatter plot presents the percentage of media from Netflix that sourced from US production and non-US production sources.")

viz_tab_panel <- tabPanel("Sourcing Visualization",
                          titlePanel("Production of Netflix"),
                          sidebarLayout(
                            viz_sidebar_content,
                            viz_main_content))

#________________________________________________________
# pie chart for us associated

us_pie_main_content <- mainPanel(
  plotlyOutput("us_pie"),
  p(""),
  p(em("This is a pie chart for the current distribution of US associated media."))
)

us_pie_tab_panel <- tabPanel("Pie Charts",
                             titlePanel("The Current Distribution"),
                             us_pie_main_content)

ui <- navbarPage("Contents",
                 tags$head(
                   tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Jost:ital,wght@0,400;0,500;1,400;1,500&family=Scheherazade+New:wght@400;700&display=swap');
body {
  background-color: white;
  color: #474747;
}
h1 {
  font-family: 'Scheherazade New', serif;
  font-weight: 600;
  color: #472F04;
}
h2 {
  font-family: 'Scheherazade New', sans-serif;
  font-weight: 700;
  font-style: bold;
  color: #472F04;
}
h3 {
  font-family: 'Scheherazade New', sans-serif;
  color: #472F04;
}
h4 {
  font-family: 'Scheherazade New', sans-serif;
  font-weight: 700;
  font-style: bold;
  color: #472F04;
}
p {
  font-family: 'Jost', sans-serif;
  font-size: 15px;
  color: #472F04;
}
/* Make text visible on inputs */
.shiny-input-container {
  color: #472F04;
}
.navbar { 
  background-color: #FAEAB1 !important;
  font-family: 'Scheherazade New', serif;
  font-weight: 700;
  font-style: bold;
  font-size: 20px;
  font-color: #472F04;
}
.navbar-default .navbar-brand {
  color:#472F04;
}



"))), 
                 intro_tab_panel,
                 viz_tab_panel,
                 us_pie_tab_panel
)



