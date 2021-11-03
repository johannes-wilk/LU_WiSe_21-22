
### Land Use - a Key Control of Earth System Processes: WiSe 2021-2022, 
# Excersize 2 - Basic data manipulation + summary statistics
# Prof. Dr. Bertrand Fournier

### In today's exercise you will have to:
# 0) Upload the data you created during last session
# 1) Make simple data transformations and operations
# 2) Compute summary statistics for your chosen Landkreis
# 3) Compute summary statistics per land use type
# 4) Create plots of your results
# 4) Save the data, the plots, and your script

# Let's go...


#ras$[rasPopulation] -- is a code to modify the values within the raster


### Load the required packages -----------------------------------------------

# start by cleaning the console 
#rm(list = ls()) 
# Be careful when using this command, it can erase your entire work !!!

# load the raster package
require(raster)

### Load the required data -----------------------------------------------------

# load raster stack from last exercise
setwd("~/1. Dokumente/3. Studium/1. Uni Potsdam/1. Module/EE1_GEE-SE01_Land Use - a key control of earth system processes/Practicals/Data")
ras <- stack("1_Raster_stack_Harz.tif")

# rename the layer of the raster stack
names(ras) = c("tree_cover", "tree_loss", "tree_gain","LC_2000",
               "LC_2018","Pop_dens", "Slope","Prec_present",
               "Temp_present", "Prec_ssp585","Temp_ssp585","Prec_ssp370", 
               "Temp_ssp370","Prec_ssp126", "Temp_ssp126")

# make a simple plot
plot(ras)

# upload information about land use categories
labl <- read.delim("CLC_Legend_labels.txt")
labl
# this landuse dataset is from CORINE and contains several different categories
# it has different levels. the higher the level the more detailed the classes

### make some very simple operations on the data -------------------------------
# simplify the info in the tree loss raster
ras$tree_loss[ras$tree_loss>0 & ras$tree_loss<2013] = 1
ras$tree_loss[ras$tree_loss>2012] = 0

# adjust present temperature data to match the other datasets
ras$Temp_present = ras$Temp_present/10
plot(ras)


### Compute basic statistics for AOI(Harz) ---------------------------------------------------

# let's transform the data into a data frame
# this will facilitate the manipulation of data
mat.dat <- na.omit(as.data.frame(ras))
dim(mat.dat)
summary(mat.dat)

# total area in km2
area.tot = nrow(mat.dat)*0.01 # one cell = ~100x100m = 10000m2 = 0.01km2
#nrow finds the number of rows I have in the dataset

# total tree cover in km2
forest.tot = sum(mat.dat$tree_cover)/10000 # 1/100 * 1/100 = 1/10000

# estimated area where tree cover was lost/gained [km2]
gain.tot = length(which(mat.dat$tree_gain==1))*0.01
loss.tot = sum(mat.dat$tree_cover[mat.dat$tree_loss==1])/10000
#length = how many values do we have
#which = TRUE or FALSE
#== is a logical operator:is the value of object of observation equal?
# both lines are very similar when it comes to the results.
# but you can code the same thing with different lines/commands
# but still there is a little difference

# % of the total forested area lost/gained
gain.perc.tot = gain.tot/forest.tot
loss.perc.tot = loss.tot/forest.tot

# km2 and % change in tree cover
change.tot = gain.tot-loss.tot
change.perc.tot = (gain.tot-loss.tot)/forest.tot*100

#we have calculated statistics in the whole Landkreis
#in the following we want to calculate different statistics in different land cover types

### Compute basic statistics per land use type ---------------------------------------------------

# total tree cover per land use
tree.lu <- tapply(mat.dat$tree_cover,
                  as.factor(mat.dat$LC_2000),
                  sum)/10000
#tapply is a very useful function
#what exactly it does - i have no clue
#help(tapply)

# total tree loss per land use
loss.lu <- tapply(mat.dat$tree_cover*mat.dat$tree_loss,
                  as.factor(mat.dat$LC_2000),
                  sum)/10000

# total tree gain per land use
gain.lu <- tapply(mat.dat$tree_gain,
                  as.factor(mat.dat$LC_2000),
                  sum)*0.01

# relative loss per land use
loss.perc <- loss.lu/tree.lu*100

# relative gain per land use
gain.perc <- gain.lu/tree.lu*100

change.abs <- gain.lu-loss.lu
change.perc <- (gain.lu-loss.lu)/tree.lu*100

# surface per land use 2018
surf.LU <- summary(as.factor(mat.dat$LC_2000))*0.01
names(surf.LU) = labl$Level3[as.numeric(names(surf.LU))]


### plots --------------------------------------------------

# make a dataframe with the summary statistics 
tree.lu.dat <- data.frame(surface_LU = surf.LU, tree_cover=tree.lu, loss=loss.lu,
                          gain=gain.lu, gain.perc=gain.perc,
                          loss.perc=loss.perc, change.perc=change.perc,
                          lvl3 = labl$Level3[as.numeric(names(tree.lu))],
                          lvl2 = labl$Level2[as.numeric(names(tree.lu))],
                          lvl1 = labl$Level1[as.numeric(names(tree.lu))]
)
# add the names of the land use types (as row names)
#row.names(tree.lu.dat) = tree.lu.dat$lvl3
#this line is repetitive

# save the data
write.table(tree.lu.dat, "1_LU_Summary_statistics_Harz.txt", sep="\t")


# let's produce some exploratory plots
par(mar=c(3,10,2,2))
barplot(tree.lu.dat$tree_cover, names.arg = tree.lu.dat$lvl3,
        las=2, horiz=TRUE)
barplot(loss.lu, names.arg = tree.lu.dat$lvl3,         
        las=2, horiz=TRUE)
barplot(gain.lu, names.arg = tree.lu.dat$lvl3,         
        las=2, horiz=TRUE)
barplot(loss.perc, names.arg = tree.lu.dat$lvl3,         
        las=2, horiz=TRUE)
barplot(gain.perc, names.arg = tree.lu.dat$lvl3,         
        las=2, horiz=TRUE)
#bar means a horizontal Saulendiagramm -- also Balkendiagramm 
### -> what can you conclude?


### final plot

# chose appropriate colors
col.vec = c(rep("grey",9),rep("orange",5),
            rep("darkgreen",3),rep("lightgreen",3),
            rep("blue",3))

# divide the screen to make multi-panel plot
png("1_LU_barplpot_Harz.png", width = 600, height = 600)
par(mfrow=c(1,2), mar=c(5,10,2,2))

# let's first make a barplot of the % change in tree cover
barplot(change.perc, names.arg = tree.lu.dat$lvl3,         
        las=2, horiz=TRUE, 
        xlim=c(-80,50),
        col = col.vec,
        xlab="% change in tree cover 2000-2013") 
#change the green numbers from 2000 to 2013 !!

# then, let's make a plot of the surface covered by the different land use types
par(mar=c(5,10,2,5), xpd=TRUE)
barplot(surf.LU, las=2, xlim=c(0,1000), 
        col=col.vec, horiz=TRUE,
        xlab="Surface in km2")

# add a legend
legend("bottomright", 
       legend = rev(c("Artificial","Agricultural","Forest",
                      "Natural","Water")),
       col = rev(c("grey","orange","darkgreen","lightgreen","blue")),
       pch = c(15), 
       bty = "n", 
       pt.cex = 1.5, 
       cex = 1,
       inset=c(-0.5,0.05))

dev.off() 

### -> what can you conclude?


### let's make a map to visualize the spatial pattern
loss = ras$tree_loss
loss[loss!=1]=NA

gain = ras$tree_gain
gain[gain!=1]=NA

par(mar=c(2,2,2,2), mfrow=c(1,1), xpd=TRUE)

# with tree cover as background
require(RColorBrewer)
mypalette<-brewer.pal(7,"Greys")
pdf("1_Tree_cover_loss-gain_map.pdf", width = 6, height = 6)
plot(ras$tree_cover, col=mypalette, main="forest cover change 2000-2013")
plot(loss, col ="red", add=T, legend=FALSE)
plot(gain, col ="green", add=T, legend=FALSE)
dev.off()

# with coniferous forest as background
ras.conif <- ras$LC_2018
ras.conif[ras.conif!=24]=NA
plot(ras.conif, col="black", main="Confierous forests")
plot(loss, col ="red", add=T, legend=FALSE)
plot(gain, col ="green", add=T, legend=FALSE)

### -> Do you notice any particularities?
### -> What can you conclude?


