###############################################################################
# Machine=specific SIMP definition
#
# NOTE: Changes in super-level parameters that are used to derive further
# parameters need to trigger a re-evaluation of the derived parameters!
#
# Project:		TEMPLATE
# Last update: 	02/09/2015
# Author: 		Sascha Holzhauer
################################################################################

### Clean/Remove existing definitions ##########################################
rm(list=ls(pattern="[^{preserve}]", envir=globalenv()), envir=globalenv())


### Project Root ###############################################################
project			<- "PATH-TO-PROJECT"

#### Load default SIMP #########################################################
source(paste(project, "/config/R/simpBasic.R", sep=""))
simp$dirs$project <- project

#### Set path to itself ########################################################
simp$simpDefinition <- paste(simp$dirs$project, "config/R/simp-machine_cluster.R", sep="")

### Directories ###############################################################

simp$dirs$data 				<- paste(simp$dirs$project, "data/", sep="")
simp$dirs$simp				<- paste(simp$dirs$project, "./config/R/", sep="")

simp$dirs$outputdir			<- paste(simp$dirs$project, "/output/", sep="")

simp$dirs$output$simulation	<- paste(simp$dirs$outputdir, "Data/", sep="")
simp$dirs$output$data		<- paste(simp$dirs$outputdir, "Data/", sep="")
simp$dirs$output$rdata		<- paste(simp$dirs$outputdir, "RData/", sep="") 
simp$dirs$output$raster		<- paste(simp$dirs$outputdir, "Raster/", sep="") 
simp$dirs$output$figures	<- paste(simp$dirs$outputdir, "Figures/", sep="")
simp$dirs$output$reports	<- paste(simp$dirs$outputdir, "Reports/", sep="")
simp$dirs$output$tables		<- paste(simp$dirs$outputdir, "/Tables/", sep="")
simp$dirs$output$csv		<- paste(simp$dirs$outputdir, "/CSV/", sep="")

futile.logger::flog.info("Current working directory: %s",
			getwd(),
			name = "TEMPLATE.simp")
