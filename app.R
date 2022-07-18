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

BioClimaticLimits$Genus.name <- as.factor(BioClimaticLimits$Genus.name)
BioClimaticLimits$GDD0 <- as.double(BioClimaticLimits$GDD0)
BioClimaticLimits$GDD5 <- as.double(BioClimaticLimits$GDD5)
BioClimaticLimits$GDD10 <- as.double(BioClimaticLimits$GDD10)

# omit NA

BioClimaticLimits <- na.omit(BioClimaticLimits)

# Variables / 10

BioClimaticLimits$TMAX <- BioClimaticLimits$TMAX/10
BioClimaticLimits$TMIN <- BioClimaticLimits$TMIN/10
BioClimaticLimits$GDD0 <- BioClimaticLimits$GDD0/10
BioClimaticLimits$GDD5 <- BioClimaticLimits$GDD5/10
BioClimaticLimits$GDD10 <- BioClimaticLimits$GDD10/10


# Generate list of Genera for easier menu generation

Genera <- levels(BioClimaticLimits$Genus.name)

#-----------------------------------------------------------------------------#
# UI
#-----------------------------------------------------------------------------#

ui <- bootstrapPage(
  
  # Application title
  titlePanel("Bioclimatic limits for European Forest genera"),
  
  leafletOutput("genus_map"),
  
  absolutePanel(top = 10, right = 10,
                pickerInput("Genus", label = "Select a Genus:",
                            choices = list(`Genus` = Genera),
                            options = list(`live-search` = TRUE)
                )
  ),
  
  sidebarPanel(
    radioButtons("BCV", "Bioclimatic Variables",
                 choices = list(`TMIN` = "TMIN",
                                `TMAX` = "TMAX",
                                `GDD0` = "GDD0",
                                `GDD5` = "GDD5",
                                `GDD10` = "GDD10")
                                
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
 
  filteredData <- reactive({
      filter(BioClimaticLimits, Genus.name == input$Genus)
  }) 
  
 output$histogram <- renderPlot({
   color = "#434343"
   hist(filteredData()[[input$BCV]])
 })
  
  output$genus_map <- renderLeaflet({
    leaflet(filteredData()) %>%
      addProviderTiles(providers$Esri.WorldTopoMap) %>%
      addCircleMarkers(~Lon, ~Lat,
                       color = "Green",
                       opacity = 0.5,
                       radius = 0.1)
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