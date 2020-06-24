#######################################################################
# ApplicationScript for Visualisation of Model Setup
# raw and aggregated).
#
# Project:		TEMPLATE
# Last update: 	26/08/2016
# Author: 		Sascha Holzhauer
#######################################################################

source(simp$simpDefinition)

simp$sim$folder 	<- "parentFolder/_version"
preserve$run		<- 8

setwd(paste(simp$dirs$simp, sep="/"))
source(paste(simp$dirs$simp, simp$sim$folder, "simp.R", sep="/"))

simp$sim$runids 	<- c(paste(preserve$run, "-0", sep=""))	# run to deal with
simp$sim$id			<- c(paste(preserve$run, "-0", sep=""))	# ID to identify specific data collections (e.g. regions)
simp$sim$task		<- c(paste(preserve$run, "-0", sep=""))	# Name of surounding folder, usually a description of task 


#demand functions
demand <- hl_aggregate_demand(simp,  ggplotaddons = ggplot2::theme(legend.position="none"))

#Benefit functions
compFuncs <- hl_printCompetitionFunctions(simp, xrange = c(-0.5,0.5))



#Regions
#hl_param_capital_map <- function(simp, capitals = simp$mdata$capitals, 
#		filenameorder = c("regionalisation", "U", "regions", "U", "datatype"))
	
input_tools_load(simp, "csv_LandUseIndex_rbinded")
cdata <- get("csv_LandUseIndex_rbinded")
celldata <- cdata[cdata$Tick == 2010,]
map <- visualise_cells_printPlots(simp, celldata, idcolumn = "Tick", valuecolumn = "LandUseIndex",
		title = "", filenamepostfix = "", legendtitle = "Land Use",
		factorial= TRUE, omitaxisticks = FALSE, ncol = if (!is.data.frame(celldata)) length(celldata) else 1, 
		coloursetname="AFT", legenditemnames = simp$mdata$aftNames,
		theme = visualisation_raster_legendonlytheme)
		

# FRs: production
afts <- hl_plotAgentProductionParameters(simp, filenameprefix = "AftProduction_",
		filenamepostfix = "_multi_medium", ggplotaddons = ggplot2::theme(legend.position="none"))


# compile:
simp$fig$init(simp, outdir = paste(simp$dirs$output$figures, "param", sep="/"), 
filename = "ModelSetup")
simp$debug$fig		<- 1
output_visualise_multiplot(sip = simp, cols=2, compFuncs, demand, map, afts)
simp$fig$close()


