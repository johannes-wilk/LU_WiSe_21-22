### Land Use - a Key Control of Earth System Processes: WiSe 2021-2022, 
# Exercise 1 - Data preparation + sensitivity to spatial/thematic resolution
# Prof. Dr. Bertrand Fournier


### Before you start:
# I suggest that you use Rstudio to run this script, it's much easier and comfortable...
# https://rstudio.com/products/rstudio/

# Make sure that you're using the latest version of R (4.1.0 or higher)
# Or the latest stable version (3.6.3)
# https://www.r-project.org/


### In today's exercise you will have to:
# 0) Download the data corresponding to the chosen landscape from Moodle to your home repository
# 1) Chose a Landkreis. This will be the topic of the final report for this course.
# 2) Upload the data for Germany into R
# 3) Crop and mask the data so that they fit the borders of your Landkreis
# 4) Chose the best resolution given the situation in your Landkreis
# 5) Make sure that all the data have the same projection (CRS) and resolution
# 6) Make a raster stack with all the variables
# 7) Save the data and your script

# Let's go...


### Install and load the required packages -----------------------------------------------

# start by cleaning the console 
rm(list = ls()) # !!! Be careful when using this command, it can erase your entire work !!!

# install packages
# install.packages("raster") # only do that once

# load packages
require(raster)


### download shapefile: Boundary of your Landkreis ----------------------------------
germany1 <- getData('GADM' , country="DE", level=2)   # see "?getData"
plot(germany1)
germany1$NAME_1 # list of Bundesland
germany1$NAME_2 # list of Landkreis
Brandenburg <- germany1[germany1$NAME_1 == c("Sachsen-Anhalt"), ]
Harz <- Brandenburg[Brandenburg$NAME_2 == c("Harz"), ]
plot(Harz)
### Upload tree cover data (Hansen et al. 2013)
# see: https://earthenginepartners.appspot.com/science-2013-global-forest/download_v1.2.html
setwd("C:/Users/Johannes/Documents/1. Dokumente/3. Studium/1. Uni Potsdam/1. Module/Land Use/Data")
tree <- raster(x = "Tree_cover_2000_germany.tif")
gain <- raster(x = "Gain_2020_germany.tif")
loss <- raster(x = "Loss_2020_germany.tif")

# crop rasters
tree <- crop(tree, Harz)
gain <- crop(gain, Harz)
loss <- crop(loss, Harz)
plot(tree)

# mask rasters
tree <- mask(tree, Harz)
gain <- mask(gain, Harz)
loss <- mask(loss, Harz)
plot(tree)


### Upload land cover data --------------------------------------------------
# see: https://land.copernicus.eu/pan-european/corine-land-cover

# 2000 
setwd("C:/Users/Johannes/Documents/1. Dokumente/3. Studium/1. Uni Potsdam/1. Module/Land Use/Data")
Harz_00 <- raster(x = "U2006_CLC2000_V2020_20u1.tif")

# 2018 
#setwd("C:/Users/Johannes/Documents/1. Dokumente/3. Studium/1. Uni Potsdam/1. Module/Land Use/Data")
Harz_18 <- raster(x = "U2018_CLC2018_V2020_20u1.tif")

# reproject the shapefile to match the CRS of the LU data
Harz <- spTransform(Harz, crs(Harz_00))

# crop the LULC data to the extent of the chosen Landkreis
Harz_00 <- crop(Harz_00, Harz)
Harz_18 <- crop(Harz_18, Harz)

# mask the LULC data to match Landkreis borders
Harz_00 <- mask(Harz_00, Harz)
Harz_18 <- mask(Harz_18, Harz)

# reproject LULC data to match the CRS of the tree data
Harz_00 <- projectRaster(Harz_00, crs = crs(loss), method="ngb")
Harz_18 <- projectRaster(Harz_18, crs = crs(loss), method="ngb")


### population density ---------------------------------------------------------
# see: https://www.eea.europa.eu/data-and-maps/data/population-density-disaggregated-with-corine-land-cover-2000-2
setwd("C:/Users/Johannes/Documents/1. Dokumente/3. Studium/1. Uni Potsdam/1. Module/Land Use/Data")
pop_dens_05 <- raster(x = "popu01clcv5.tif")

# do the same as for LULC data
Harz <- spTransform(Harz, crs(pop_dens_05)) 
pop_dens_05 <- crop(pop_dens_05, Harz)
pop_dens_05 <- mask(pop_dens_05, Harz)
pop_dens_05 <- projectRaster(pop_dens_05, crs = crs(loss), method="ngb")


### climate --------------------------------------------------------------------
#setwd("C:/Users/Bertrand/Dropbox/Teaching/Landuse/Data/Climate")

# annual mean precipitation 1981-2010 [mm]
an_prec <- raster(x = "CHELSA_bio10_12.tif")
Harz <- spTransform(Harz, crs(an_prec)) 
an_prec <- crop(an_prec, Harz)
an_prec <- mask(an_prec, Harz)
an_prec <- resample(an_prec, pop_dens_05, method='bilinear')  # resample to match resolution

# annual mean temperature 1981-2010 [deg*10]
an_temp <- raster(x = "CHELSA_bio10_01.tif")
Harz <- spTransform(Harz, crs(an_temp)) 
an_temp <- crop(an_temp, Harz)
an_temp <- mask(an_temp, Harz)
an_temp <- resample(an_temp, pop_dens_05, method='bilinear') # resample to match resolution

# annual mean precipitation 2071-2100 ssp585 [mm]
an_prec_ssp585 <- raster(x = "CHELSA_bio12_2071-2100_mpi-esm1-2-hr_ssp585_V.2.1.tif")
Harz <- spTransform(Harz, crs(an_prec_ssp585)) 
an_prec_ssp585 <- crop(an_prec_ssp585, Harz)
an_prec_ssp585 <- mask(an_prec_ssp585, Harz)
an_prec_ssp585 <- resample(an_prec_ssp585, pop_dens_05, method='bilinear') # resample to match resolution
plot(an_prec_ssp585)

# annual mean precipitation 2071-2100 ssp370 [mm]
an_prec_ssp370 <- raster(x = "CHELSA_bio12_2071-2100_mpi-esm1-2-hr_ssp370_V.2.1.tif")
Harz <- spTransform(Harz, crs(an_prec_ssp370)) 
an_prec_ssp370 <- crop(an_prec_ssp370, Harz)
an_prec_ssp370 <- mask(an_prec_ssp370, Harz)
an_prec_ssp370 <- resample(an_prec_ssp370, pop_dens_05, method='bilinear') # resample to match resolution
plot(an_prec_ssp370)

# annual mean precipitation 2071-2100 ssp126 [mm]
an_prec_ssp126 <- raster(x = "CHELSA_bio12_2071-2100_mpi-esm1-2-hr_ssp126_V.2.1.tif")
Harz <- spTransform(Harz, crs(an_prec_ssp126)) 
an_prec_ssp126 <- crop(an_prec_ssp126, Harz)
an_prec_ssp126 <- mask(an_prec_ssp126, Harz)
an_prec_ssp126 <- resample(an_prec_ssp126, pop_dens_05, method='bilinear') # resample to match resolution
plot(an_prec_ssp126)

# annual mean temperature 2071-2100 ssp585 [mm]
an_temp_ssp585 <- raster(x = "CHELSA_bio1_2071-2100_mpi-esm1-2-hr_ssp585_V.2.1.tif")
Harz <- spTransform(Harz, crs(an_temp_ssp585)) 
an_temp_ssp585 <- crop(an_temp_ssp585, Harz)
an_temp_ssp585 <- mask(an_temp_ssp585, Harz)
an_temp_ssp585 <- resample(an_temp_ssp585, pop_dens_05, method='bilinear') # resample to match resolution
plot(an_temp_ssp585)

# annual mean precipitation 2071-2100 ssp370 [mm]
an_temp_ssp370 <- raster(x = "CHELSA_bio1_2071-2100_mpi-esm1-2-hr_ssp370_V.2.1.tif")
Harz <- spTransform(Harz, crs(an_temp_ssp370)) 
an_temp_ssp370 <- crop(an_temp_ssp370, Harz)
an_temp_ssp370 <- mask(an_temp_ssp370, Harz)
an_temp_ssp370 <- resample(an_temp_ssp370, pop_dens_05, method='bilinear') # resample to match resolution
plot(an_temp_ssp370)

# annual mean temperature 2071-2100 ssp126 [mm]
an_temp_ssp126 <- raster(x = "CHELSA_bio1_2071-2100_mpi-esm1-2-hr_ssp126_V.2.1.tif")
Harz <- spTransform(Harz, crs(an_temp_ssp126)) 
an_temp_ssp126 <- crop(an_temp_ssp126, Harz)
an_temp_ssp126 <- mask(an_temp_ssp126, Harz)
an_temp_ssp126 <- resample(an_temp_ssp126, pop_dens_05, method='bilinear') # resample to match resolution
plot(an_temp_ssp126)


### topography - slope ----------------------------------------------------
#setwd("C:/Users/Bertrand/Dropbox/Teaching/Landuse/Data/Topography")
slope <- raster(x = "eudem_slop_3035_germany.tif")
Harz <- spTransform(Harz, crs(slope)) 
slope <- crop(slope, Harz)
slope <- mask(slope, Harz)
slope <- projectRaster(slope, crs = crs(loss), method="ngb")
slope <- resample(slope, Harz_18, method='ngb') # resample to match resolution


### make a raster stack with all the variables ---------------------------------

# resample tree data to match the resolution of the other datasets
tree <- resample(tree, Harz_18, method='ngb')
loss <- resample(loss, Harz_18, method='ngb')
gain <- resample(gain, Harz_18, method='ngb')

# create the raster stack
ras.dat <- stack(tree, loss, gain, Harz_00, Harz_18, 
                 pop_dens_05, slope, an_prec, an_temp, 
                 an_prec_ssp585, an_temp_ssp585,
                 an_prec_ssp370, an_temp_ssp370,
                 an_prec_ssp126, an_temp_ssp126)
names(ras.dat) = c("tree_cover", "tree_loss", "tree_gain","LC_2000",
                   "LC_2018","Pop_dens", "Slope","Prec_present",
                   "Temp_present", "Prec_ssp585","Temp_ssp585","Prec_ssp370", 
                   "Temp_ssp370","Prec_ssp126", "Temp_ssp126")
plot(ras.dat)

# save the data on your computer
#setwd("C:/Users/Bertrand/Dropbox/Teaching/Landuse/Data")
writeRaster(ras.dat, "Raster_stack_Harz.tif", 
            format="GTiff", overwrite=TRUE)

# I advise making a copy on a USB-stick or directly on your own laptop

### Congrats, you've survived the first exercise session!



