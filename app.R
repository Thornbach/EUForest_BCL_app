#
# Tobias Müller
# ToMu94@outlook.de
# SBIK-F Research Group: Biogeography and Ecosystem Ecology
# 2022-07-18
# 

#-----------------------------------------------------------------------------#
# The build in generation of legend entries is absolutly trash
# There is no way to invert the legend entries and in some cases it makes
# 0 sense to take the build in solution. Thanks to user mpriem89 on Github
# we have this quite long but necessary workaround 
# https://github.com/rstudio/leaflet/issues/256#issuecomment-440290201
#-----------------------------------------------------------------------------#

addLegend_decreasing <- function (map, position = c("topright", "bottomright", "bottomleft", 
                                                    "topleft"), pal, values, na.label = "NA", bins = 7, colors, 
                                  opacity = 0.5, labels = NULL, labFormat = labelFormat(), 
                                  title = NULL, className = "info legend", layerId = NULL, 
                                  group = NULL, data = getMapData(map), decreasing = FALSE) {
  position <- match.arg(position)
  type <- "unknown"
  na.color <- NULL
  extra <- NULL
  if (!missing(pal)) {
    if (!missing(colors)) 
      stop("You must provide either 'pal' or 'colors' (not both)")
    if (missing(title) && inherits(values, "formula")) 
      title <- deparse(values[[2]])
    values <- evalFormula(values, data)
    type <- attr(pal, "colorType", exact = TRUE)
    args <- attr(pal, "colorArgs", exact = TRUE)
    na.color <- args$na.color
    if (!is.null(na.color) && col2rgb(na.color, alpha = TRUE)[[4]] == 
        0) {
      na.color <- NULL
    }
    if (type != "numeric" && !missing(bins)) 
      warning("'bins' is ignored because the palette type is not numeric")
    if (type == "numeric") {
      cuts <- if (length(bins) == 1) 
        pretty(values, bins)
      else bins	
      
      if (length(bins) > 2) 
        if (!all(abs(diff(bins, differences = 2)) <= 
                 sqrt(.Machine$double.eps))) 
          stop("The vector of breaks 'bins' must be equally spaced")
      n <- length(cuts)
      r <- range(values, na.rm = TRUE)
      cuts <- cuts[cuts >= r[1] & cuts <= r[2]]
      n <- length(cuts)
      p <- (cuts - r[1])/(r[2] - r[1])
      extra <- list(p_1 = p[1], p_n = p[n])
      p <- c("", paste0(100 * p, "%"), "")
      if (decreasing == TRUE){
        colors <- pal(rev(c(r[1], cuts, r[2])))
        labels <- rev(labFormat(type = "numeric", cuts))
      }else{
        colors <- pal(c(r[1], cuts, r[2]))
        labels <- rev(labFormat(type = "numeric", cuts))
      }
      colors <- paste(colors, p, sep = " ", collapse = ", ")
      
    }
    else if (type == "bin") {
      cuts <- args$bins
      n <- length(cuts)
      mids <- (cuts[-1] + cuts[-n])/2
      if (decreasing == TRUE){
        colors <- pal(rev(mids))
        labels <- rev(labFormat(type = "bin", cuts))
      }else{
        colors <- pal(mids)
        labels <- labFormat(type = "bin", cuts)
      }
      
    }
    else if (type == "quantile") {
      p <- args$probs
      n <- length(p)
      cuts <- quantile(values, probs = p, na.rm = TRUE)
      mids <- quantile(values, probs = (p[-1] + p[-n])/2, 
                       na.rm = TRUE)
      if (decreasing == TRUE){
        colors <- pal(rev(mids))
        labels <- rev(labFormat(type = "quantile", cuts, p))
      }else{
        colors <- pal(mids)
        labels <- labFormat(type = "quantile", cuts, p)
      }
    }
    else if (type == "factor") {
      v <- sort(unique(na.omit(values)))
      colors <- pal(v)
      labels <- labFormat(type = "factor", v)
      if (decreasing == TRUE){
        colors <- pal(rev(v))
        labels <- rev(labFormat(type = "factor", v))
      }else{
        colors <- pal(v)
        labels <- labFormat(type = "factor", v)
      }
    }
    else stop("Palette function not supported")
    if (!any(is.na(values))) 
      na.color <- NULL
  }
  else {
    if (length(colors) != length(labels)) 
      stop("'colors' and 'labels' must be of the same length")
  }
  legend <- list(colors = I(unname(colors)), labels = I(unname(labels)), 
                 na_color = na.color, na_label = na.label, opacity = opacity, 
                 position = position, type = type, title = title, extra = extra, 
                 layerId = layerId, className = className, group = group)
  invokeMethod(map, data, "addLegend", legend)
}

#-----------------------------------------------------------------------------#
# Load in libraries
#-----------------------------------------------------------------------------#

library(shiny)
library(shinyWidgets)
library(tidyverse)
library(leaflet)
library(RColorBrewer)

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
BioClimaticLimits$Aridity <- BioClimaticLimits$Aridity/10000


# Generate list of Genera for easier menu generation

SPECIES <- levels(BioClimaticLimits$SPECIES)
COUNTRY <- levels(BioClimaticLimits$COUNTRY)

#-----------------------------------------------------------------------------#
# Quantile calculation to kick out the top and bottom 5% of each variable
# This is modular and can be expanded easily
#-----------------------------------------------------------------------------#

# BioClimaticLimits <- BioClimaticLimits %>%
# filter(CHELSA_gdd <= quantile(CHELSA_gdd, 0.95) & CHELSA_gdd >= quantile(CHELSA_gdd, 0.05) &
#        TMAX <= quantile(TMAX, 0.95) & TMAX >= quantile(TMAX, 0.05) &
#        TMIN <= quantile(TMIN, 0.95) & TMIN >= quantile(TMIN, 0.05) &
#        Cth <= quantile(Cth, 0.95) & Cth >= quantile(Cth, 0.05))
#   

#-----------------------------------------------------------------------------#
# UI
#-----------------------------------------------------------------------------#

ui <- bootstrapPage(
  
  # Application title
  titlePanel("Bioclimatic limits for European Forest Species"),
  
  leafletOutput("species_map"),
  
  pickerInput("Species", label = "Select a Species:",
              choices = list(`Species` = SPECIES),
              options = list(`live-search` = TRUE)
  ),
  
  
  
  pickerInput("Country", label = "Select a Country:",
              choices = list("All countries",
                             `COUNTRY` = COUNTRY),
              options = list(`live-search` = TRUE)
  ),
  
  sidebarPanel(
    radioButtons("BCV", "Bioclimatic Variables",
                 choices = list(`TMIN` = "TMIN",
                                `TMAX` = "TMAX",
                                `CHELSA_gdd` = "CHELSA_gdd",
                                `GSL` = "GSL",
                                `Aridity` = "Aridity",
                                `SMD` = "SMD")
                 
    ),
    downloadButton("downloadData", "Download")
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
  
  # Cut out the quantiles
  
  TreeFilter <- reactive({
    Tree() %>% 
      filter(Tree()[[input$BCV]]<= quantile(Tree()[[input$BCV]], 0.95) &
               Tree()[[input$BCV]] >= quantile(Tree()[[input$BCV]], 0.05))
  })
  
  
  
  output$species_map <- renderLeaflet({
    
    # Colorpicker
    
    if(input$BCV == "TMIN"){
      palette <- colorNumeric(palette = "Spectral", domain = TreeFilter()[[input$BCV]], reverse = TRUE)
    } else if (input$BCV == "TMAX") {
      palette <- colorNumeric(palette = "Spectral", domain = TreeFilter()[[input$BCV]], reverse = TRUE)
    } else if (input$BCV == "CHELSA_gdd"){
      palette <- colorNumeric(palette = "Greens", domain = TreeFilter()[[input$BCV]])
    } else if  (input$BCV == "GSL"){
      palette <- colorNumeric(palette = "Greens", domain = TreeFilter()[[input$BCV]])
    } else if (input$BCV == "SMD"){
      palette <- colorNumeric(palette = "Spectral", domain = TreeFilter()[[input$BCV]])
    } else {
      palette <- colorNumeric(palette = "Spectral", domain = TreeFilter()[[input$BCV]])
    }
    
    # Render the Map!
    
    leaflet(TreeFilter()) %>%
      addProviderTiles(providers$Esri.WorldTopoMap) %>%
      addCircleMarkers(~Lon, ~Lat,
                       color = ~palette(TreeFilter()[[input$BCV]]),
                       opacity = 0.5,
                       radius = 0.1) %>%
      addLegend_decreasing("bottomright",
                           pal = palette,
                           values = ~TreeFilter()[[input$BCV]],
                           title = input$BCV,
                           opacity = 1,
                           decreasing = TRUE)
  })
  
  output$histogram <- renderPlot({
    color = "#434343"
    hist(TreeFilter()[[input$BCV]], 
         main = paste0("Histogram of ", input$BCV, " ", input$Species),
         xlab = paste0(input$BCV),
         breaks = 100)
  })
  
  # DOWNLOAD BUTTON IS NOT WORKING
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("download", ".csv", sep = "")
    },
    content = function(BioClimaticLimits){
      sum <- Tree() %>% summarize(min = min(Tree()[[input$BCV]]), 
                                  max = max(Tree()[[input$BCV]]))
      write.csv(sum)
    }
    
  )
  
}

# Run the application 
shinyApp(ui = ui, server = server)

#-----------------------------------------------------------------------------#
#     __
# ___( o)>    QUACK - makes the program faster
# \ <_. )
#  `---'   
#-----------------------------------------------------------------------------#