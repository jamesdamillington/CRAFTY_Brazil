################################################################################
# General SIMulation Properties:
#
# Project:		TEMPLATE
# Last update: 	02/09/2015
# Author: 		Sascha Holzhauer
################################################################################

#### COMMON PACKAGES ###########################################################
library(craftyr)
library(kfigr)
library(shbasic)

#### FUNCTIONS #################################################################
#eg. for simp$dirs$param$getparamdir

### Simulation Data ############################################################
if (!exists("simp")) simp <-  craftyr::param_getDefaultSimp()

simp$sim$worldname 			<- "EU28"
simp$sim$version			<- "setA"
simp$sim$allocversion		<- "NN"
simp$sim$scenario			<- "A1"
simp$sim$regionalisation	<- "26"
simp$sim$regions			<- c("A")
simp$sim$runids				<- c("0-0")
simp$sim$hasregiondir		<- TRUE

### Directories ################################################################
simp$dirs$output$data		<- paste(simp$dirs$outputdir, "Data/", sep="")
simp$dirs$output$rdata		<- paste(simp$dirs$outputdir, "RData/", sep="") 
simp$dirs$output$raster		<- paste(simp$dirs$outputdir, "Raster/", sep="") 
simp$dirs$output$figures	<- paste(simp$dirs$outputdir, "Figures/", sep="")
simp$dirs$output$reports	<- paste(simp$dirs$outputdir, "Reports/", sep="")

### CSV Column Names ###########################################################
simp$csv$cname_region 		<- "Region"
simp$csv$cname_tick 		<- "Tick"
simp$csv$cname_aft 			<- "Agent"
simp$csv$cname_x			<- "X"
simp$csv$cname_y			<- "Y"

### Model Data ################################################################
simp$mdata$capitals 		<- c("Cprod", "Fprod", "Infra", "Grass", "Nat", "Econ")
simp$mdata$services			<- c("Meat", "Cereal" ,"Conservation", "Timber")
simp$mdata$aftNames			<- c("-1" = "Unmanaged", "0" = 'C_Cereal', "1" = 'NC_Cereal', 
								  "2" = 'C_Livestock', "3" = 'NC_Livestock',
								  "4" = 'Forester', "5" = 'Conservationist')

### Figure Settings ###########################################################
simp$fig$resfactor			<- 2
simp$fig$outputformat 		<- "png" #"jpeg"
simp$fig$init				<- craftyr::output_visualise_initFigure
simp$fig$numfigs			<- 1
simp$fig$numcols			<- 1
simp$fig$height				<- 500
simp$fig$width				<- 500
simp$fig$splitfigs			<- FALSE
simp$fig$facetlabelsize 	<- 14

simp$colours$AFT		<-  c("-1" = "black",
		"0" = "orange1",
		"1" = "lightgoldenrod",
		"2" = "indianred4",
		"3" = "indianred1",
		"4" = "green4",
		"5" = "royalblue2",
		"6" = "darkviolet")
