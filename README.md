# EUForest_BCL_app

 This app displays the distribution of European forest tree genera in combination with histograms designed to show the bioclimatic limits of each genus. 
 
 [The interactive web interface of this app can be found here](https://thornbach.shinyapps.io/EUForest_BCL_app/)

## Abstract

The EUForest BCL App should help identify and visualize the most important bioclimatic limits (BCL) for european tree Species in Forests. Those BCL will be used to polish the LPJ-GUESS dynamic vegetation model.
 
## Authors

- Tobias Müller (ToMu94@outlook.de) 
 
## Overview

 - The Tree distribution data origined from _Mauri, Achille et al. 2022_.
 - The bioclimatic Limits origined from _Karger et al. 2017_.

The data was processed in QGIS with the following steps:

1. Load in Chelsea .tif files
2. reproject the raster to EPSG:3035
3. Load in the data from _Mauri, Achille et al. 2022_
4. Use the "Point sampling Tool" Plugin from QGIS to sample the Raster with the Tree Distribution
5. Change project CRS to ESPG:4326 and wrap the layers to it
6. Create new attribute fields (Lon, Lat) with the points on the new coordinate system as a reference
7. safe as .csv

The main idea for this project origined by the Shinyapps R Showcase Gallery - to be precise the App from Allez Cannes (https://github.com/AllezCannes/WorldCupSquads). But the Code itself was writte entirely by myself.
 
## Repository Structure

- `data`: data folder which can be easily expanded in the future. Contains a `.csv`file with coordinates (WGS 84, ESPG:4326) and bioclimatic limits.
- `rsconnect`: necessary folder for the web interface for shinyapps.io
- `app.R`: main R Script. Run this file to open the dynamic interface session
- `EUForest_BCL_app.Rproj`: RProject session file.
- `README.md`: Content of this page

## Usage
 
### External Files

TBA if needed
 
### Software Prequisites

- RStudio 2022.02.3 Build 492
- R version 4.2.1 (2022-06-23) -- "Funny-Looking Kid"
- GNU Wget 1.21.2 built on linux-gnu (Download Chelsa files)

#### R Packages
- leaflet_2.1.1
- tidyverse_1.3.1
- shiny_1.7.1
- shinyWidgets_0.7.1
 
### Hardware Prequisites

It can be runned on a ordinary computer but its quite memory heavy. Thats why the online application of shinyapps has some issues to run the program.
 
### How to Run

Two ways:

1. Open the App.R file in RStudio and hit `Run App`above the coding window
2. type in runApp() in the `Console`inside RStudio
 
### Post-processing

You can choose the different Genera at the top right with the absolutePanel menu. The histograms will be dynamically calculated according to the Bioclimatic Variable which can be selected beneath the map with the radio buttons.
 
## Known Bugs and Issues

1. Its SUPER slow for some species. Maybe go for a clustering approach?
2. Its not the … most beautiful of all apps. It works, but looks blank.
 
## To Do

- [x] Useful descriptions for histogram axes and header
- [x] Cut out 5% quantiles at the top and bottom
- [x] Include Thornthwaite PET
- [x] Fix GDD
- [x] Growing Seasonality - the map from chelsea is not realistic.
- [x] Soil moisture deficit during vegetation growing season
- [x] Arditiy Index
- [ ] Data References
 
## References
 
Mauri, Achille, Cescatti, Alessandro, GIRARDELLO, MARCO, Strona, Giovanni, Beck, Pieter, Caudullo, Giovanni, Manca, Federica, and Forzieri, Giovanni. 2022. “EU-Trees4F. A Dataset on the Future Distribution of European Tree Species.” https://doi.org/10.6084/M9.FIGSHARE.C.5525688.V1.

Karger, D.N., Conrad, O., Böhner, J., Kawohl, T., Kreft, H., Soria-Auza, R.W., Zimmermann, N.E., Linder, P., Kessler, M. (2017):  Climatologies at high resolution for the Earth land surface areas. **_Scientific Data_.** 4 170122. https://doi.org/10.1038/sdata.2017.122

Growing Season Length: https://sdi.eea.europa.eu/catalogue/srv/eng/catalog.search#/metadata/a21e58ad-ff91-436c-866a-fcbcf2615841

Soil moisture deficit during the vegetation growing season, annual time-series, 2000-2019, Sep. 2020 https://sdi.eea.europa.eu/catalogue/srv/eng/catalog.search#/metadata/a21e58ad-ff91-436c-866a-fcbcf2615841

# License

TBA

 
 