# LU_WiSe_21-22
Land use change cuantification

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
and extracted as a Geotiff (name: Raster_stack_Harz)

