# LU_WiSe_21-22
Land use change cuantification

Practice_1

At first we choose a Landkreis in Germany to limit our region to a certain region

After electing a Landkreis, several datasets were included such as 
tree gain, tree loss (from Hansen)
Land Cover Classes (from CORINE LUC)
population density (from CORINE EEA)
slope (from CORINE)
climate data:
  annual mean precipitation (Chelsa)
  annual mean temperature (Chelsa)
  amd expected future scenarios
    worst case: ssp585
    bad case: ssp370
    best case: ssp126
all data is cropped
all data is masked

At the end every data is stacked to a raster stack
and extracted as a Geotiff (name: 1_Raster_stack_Harz)

Practice_2

At first we load the raster stack 1_Raster_stack_Harz
  rename the fetures
  reset the scale
  plot the stack
Then we calculate some simple statistics to the whole Landkreis
  we constrain the time series to 2000-2013
  gain, loss, percentage, area, ...
Then we calculate some simple statistics to the different land cover classes
  tapply is an important function (i think this is a command which applys a function to each cell in the given variable)
Then everything is plotted
  A bar plot (Balkendiagramm) with land cover gain and land cover loss
  and a map with tree cover gain and loss in the Landkreis


