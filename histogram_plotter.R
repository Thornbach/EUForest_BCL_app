# Histogramm Tool for Bioclimatic Limits
# 
# Tobias Müller
# 2022-07-04

#----------------------------------------------------------------#
# Load in librarys
#----------------------------------------------------------------#

library(tidyverse)

#----------------------------------------------------------------#
# set working direction and load in data
#----------------------------------------------------------------#

setwd(".")

# +++ Loaders +++ #

AllData <- read.csv("./data/FORESTGENERA_ALLDATA.csv")


#----------------------------------------------------------------#
# Create ListLoop
#----------------------------------------------------------------#

AllData$SPECIES <- as.factor(AllData$SPECIES)
AllData <- na.omit(AllData)

# +++ GenusList +++ #

SpeciesList <- list()
SpeciesList_cut <- list()

#----------------------------------------------------------------#
# Use this for TMAX/TMIN! - change variable accordingly
#----------------------------------------------------------------#

for(g in 1:length(levels(AllData$SPECIES))){
  SpeciesList[[g]] <- AllData %>%
    # List of Genera
    filter(SPECIES == levels(AllData$SPECIES)[g]) %>%
    # Filtering Quantiles
    filter(DN <= quantile(DN, 0.95) & DN >= quantile(DN, 0.05))
  
  GenusList[[g]]$Genus.name <- factor(GenusList[[g]]$Genus.name)
}


#----------------------------------------------------------------#
# Use this for GDD!
#----------------------------------------------------------------#

for(g in 1:length(levels(AllData$Genus.name))){
  GenusList[[g]] <- AllData %>%
    # List of Genera
    filter(Genus.name == levels(AllData$Genus.name)[g]) %>%
    # Filtering Quantiles
    filter(GDD0 <= quantile(GDD0, 0.95) & GDD0 >= quantile(GDD0, 0.05))
  
  GenusList[[g]]$Genus.name <- factor(GenusList[[g]]$Genus.name)
}

#----------------------------------------------------------------#
# Use this for Thornthwaite!
#----------------------------------------------------------------#

for(g in 1:length(levels(AllData$Genus.name))){
  GenusList[[g]] <- AllData %>%
    # List of Genera
    filter(Genus.name == levels(AllData$Genus.name)[g]) %>%
    # Filtering Quantiles
    filter(C_Th <= quantile(C_Th, 0.95) & C_Th >= quantile(C_Th, 0.05))
  
  GenusList[[g]]$Genus.name <- factor(GenusList[[g]]$Genus.name)
}


#----------------------------------------------------------------#
# TMAX/TMIN Plot - change Variable manually
#----------------------------------------------------------------#

i = 1
for(i in 1:length(GenusList)){
  
  ggplot(data = GenusList[[i]], aes(x = DN))+
    geom_histogram(binwidth = 1)+
    labs(title = paste(levels(GenusList[[i]]$Genus.name) ,"min Temperature in Winter Histogram"),
         y = "Count", x = "Min Temperature °C * 10 in Winter")
  
  
  ggsave(paste("./plots/",levels(GenusList[[i]]$Genus.name),".png"))
}


#----------------------------------------------------------------#
# GDD Plot - change GDD Variable manually
#----------------------------------------------------------------#

i = 1
for(i in 1:length(GenusList)){
  
  ggplot(data = GenusList[[i]], aes(x = GDD10))+
    geom_histogram(binwidth = 1)+
    labs(title = paste(levels(GenusList[[i]]$Genus.name) ,"GDD10x10 in Winter Histogram"),
         y = "Count", x = "GDDx10 in Winter")
  
  
  ggsave(paste("./plots/",levels(GenusList[[i]]$Genus.name),".png"))
}

#----------------------------------------------------------------#
# C_Th Plot
#----------------------------------------------------------------#

i = 1
for(i in 1:length(GenusList)){
  
  ggplot(data = GenusList[[i]], aes(x = C_Th))+
    geom_histogram(binwidth = 1)+
    labs(title = paste(levels(GenusList[[i]]$Genus.name) ,"C_Th  Histogram"),
         y = "Count", x = "Thornthwaite PET")
  
  
  ggsave(paste("./plots/",levels(GenusList[[i]]$Genus.name),".png"))
}

