#
# Tobias Müller
# ToMu94@outlook.de
# SBIK-F Research Group: Biogeography and Ecosystem Ecology
# 2022-07-18
# 

#-----------------------------------------------------------------------------#
# Load in libraries
#-----------------------------------------------------------------------------#

library(shiny)
library(shinyWidgets)
library(tidyverse)
library(leaflet)

#-----------------------------------------------------------------------------#
# Load in Data and create list based on genus levels
#-----------------------------------------------------------------------------#

BioClimaticLimits <- read.csv("./data/FORESTGENERA_ALLDATA.csv")

# change variable type

BioClimaticLimits$SPECIES <- as.factor(BioClimaticLimits$SPECIES)
BioClimaticLimits$COUNTRY <- as.factor(BioClimaticLimits$COUNTRY)
BioClimaticLimits$CHELSA_gdd <- as.double(BioClimaticLimits$CHELSA_gdd)

# omit NA

BioClimaticLimits <- na.omit(BioClimaticLimits)

# Variables / 10 (just for the absolute values)

BioClimaticLimits$TMAX <- BioClimaticLimits$TMAX/10
BioClimaticLimits$TMIN <- BioClimaticLimits$TMIN/10


# Generate list of Genera for easier menu generation

SPECIES <- levels(BioClimaticLimits$SPECIES)
COUNTRY <- levels(BioClimaticLimits$COUNTRY)

#-----------------------------------------------------------------------------#
# Quantile calculation to kick out the top and bottom 5% of each variable
# This is modular and can be expanded easily
#-----------------------------------------------------------------------------#

BioClimaticLimits <- BioClimaticLimits %>%
filter(CHELSA_gdd <= quantile(CHELSA_gdd, 0.95) & CHELSA_gdd >= quantile(CHELSA_gdd, 0.05) &
       TMAX <= quantile(TMAX, 0.95) & TMAX >= quantile(TMAX, 0.05) &
       TMIN <= quantile(TMIN, 0.95) & TMIN >= quantile(TMIN, 0.05) &
       Cth <= quantile(Cth, 0.95) & Cth >= quantile(Cth, 0.05))
  

#-----------------------------------------------------------------------------#
# UI
#-----------------------------------------------------------------------------#

ui <- bootstrapPage(
  
  # Application title
  titlePanel("Bioclimatic limits for European Forest Species"),
  
  leafletOutput("species_map"),
  
  absolutePanel(top = 10, right = 10,
                pickerInput("Species", label = "Select a Species:",
                            choices = list(`Species` = SPECIES),
                            options = list(`live-search` = TRUE)
                )
  ),
  
  absolutePanel(top = 10, left = 10,
                pickerInput("Country", label = "Select a Country:",
                            choices = list("All countries",
                                           `COUNTRY` = COUNTRY),
                            options = list(`live-search` = TRUE)
                )
  ),
  
  sidebarPanel(
    radioButtons("BCV", "Bioclimatic Variables",
                 choices = list(`TMIN` = "TMIN",
                                `TMAX` = "TMAX",
                                `CHELSA_gdd` = "CHELSA_gdd",
                                `GSL` = "GSL",
                                `Cth` = "Cth",
                                `SMD` = "SMD")
                                
                )
  ),
  
   mainPanel(
     plotOutput(outputId = "histogram", height = "300px")
   )
)




#-----------------------------------------------------------------------------#
# Server Logic
#-----------------------------------------------------------------------------#

server <- function(input, output, session) {
  
  # reactive Variable to render a new map each time a new genus is selected

  Tree <- reactive({
    if (input$Country == "All countries"){
      BioClimaticLimits %>%
        filter(SPECIES %in% input$Species)
    } else {
      BioClimaticLimits %>%
        filter(COUNTRY %in% input$Country,
               SPECIES %in% input$Species)
    }
  }) 

  
  #-----------------------------------------------------------------------------#
  # Colorpalettes
  #-----------------------------------------------------------------------------#



  output$species_map <- renderLeaflet({
    leaflet(Tree()) %>%
      addProviderTiles(providers$Esri.WorldTopoMap) %>%
      addCircleMarkers(~Lon, ~Lat,
                       color = "Green",
                       opacity = 0.5,
                       radius = 0.1)
  })
  
  output$histogram <- renderPlot({
    color = "#434343"
    hist(Tree()[[input$BCV]], 
         main = paste0("Histogram of ", input$BCV, " ", input$Species),
         xlab = paste0(input$BCV),
         breaks = 100)
 })
 
}

# Run the application 
shinyApp(ui = ui, server = server)

#-----------------------------------------------------------------------------#
#     __
# ___( o)>    QUACK - makes the program faster
# \ <_. )
#  `---'   
#-----------------------------------------------------------------------------#