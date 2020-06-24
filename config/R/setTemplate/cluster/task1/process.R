#######################################################################
# ApplicationScript for Storing CRAFTY ouptut as R data (both
# raw and aggregated) when individually configured (per run) and run.
#
# Project:		TEMPLATE
# Last update: 	26/08/2016
# Author: 		Sascha Holzhauer
#######################################################################

# Only contained when the particular script is only executed on a specific maschine!
# Otherwise. the maschine=specific file needs to be executed before.
source("/PATH-TO/simp-machine_cluster.R")

# Usually also in simp.R, but required here to find simp.R
simp$sim$folder 	<- "parentFolder/_version"	


simp$sim$task		<- "task1"			# Name of surounding folder, usually a description of task 

# simp$dirs$simp is set by maschine-specific file:
setwd(paste(simp$dirs$simp, simp$sim$folder, "cluster/", simp$sim$task, sep="/"))
# usually, the setting/scenario specific simp.R is two levels above:
source("../../simp.R")

library(plyr)

runs = 1:1
for (run in runs) {
	simp$sim$runids 	<- c(paste(run,"-0", sep=""))			# run to deal with
	simp$sim$id			<- c(paste(run,"-0", sep=""))
	
	#######################################################################
	futile.logger::flog.threshold(futile.logger::INFO, name='crafty')
	
	simp$sim$rundesc 		<- c("2"="Homo", "3"="Hetero")
	simp$sim$rundesclabel	<- "Runs"
	
	
	###########################################################################
	### Read and Aggregate CSV data
	###########################################################################
	
	futile.logger::flog.threshold(futile.logger::TRACE, name='crafty')
	
	simp$sim$filepartorder 	<- c("runid", "D", "tick", "D", "regions", "D", "datatype")
	aggregationFunction <- function(simp, data) {
		#print(str(data))
		plyr::ddply(data, .(Runid,Region,Tick,LandUseIndex,Competitiveness), .fun=function(df) {
					df$Counter <- 1
					with(df, data.frame(
									Runid				= unique(Runid),
									Region				= unique(Region),
									Tick				= mean(Tick),
									LandUseIndex		= mean(LandUseIndex),
									Competitiveness		= mean(Competitiveness),
									AFT					= sum(Counter),
									Service.Meat		= sum(Service.Meat), 
									Service.Cereal		= sum(Service.Cereal),
									Service.Recreation 	= sum(Service.Recreation),
									Service.Timber		= sum(Service.Timber)) )
				})
	}
	
	data <- input_csv_data(simp, dataname = NULL, datatype = "Cell", columns = c("Service.Meat", "Service.Cereal",
					"Service.Recreation", "Service.Timber",  "LandUseIndex","Competitiveness", "AFT"), pertick = TRUE,
			tickinterval = simp$csv$tickinterval_cell,
			attachfileinfo = TRUE, bindrows = TRUE,
			aggregationFunction = aggregationFunction,
			skipXY = TRUE)
	
	rownames(data) <- NULL
	dataAgg <- data
	input_tools_save(simp, "dataAgg")
	
	###########################################################################
	### Store PreAlloc Data for Maps etc. 
	###########################################################################
	simp$sim$filepartorder	<- c("regions", "D", "datatype")
	csv_preAllocTable <- input_csv_prealloccomp(simp)
	input_tools_save(simp, "csv_preAllocTable")
	
	###########################################################################
	### Take Overs
	###########################################################################
	simp$sim$filepartorder 	<- c("regions", "D", "datatype")
	
	dataTakeOvers <- input_csv_data(simp, dataname = NULL, datatype = "TakeOvers", pertick = FALSE,
			bindrows = TRUE,
			skipXY = TRUE)
	
	input_tools_save(simp, "dataTakeOvers")
	
	
	###########################################################################
	### AFT composition data
	###########################################################################
	simp$sim$filepartorder 	<- c("regions", "D", "datatype")
	
	dataAggregateAFTComposition <- input_csv_data(simp, dataname = NULL, datatype = "AggregateAFTComposition", pertick = FALSE,
			bindrows = TRUE,
			skipXY = TRUE)
	
	input_tools_save(simp, "dataAggregateAFTComposition")
	
	
	###########################################################################
	### Aggregated Demand and Supply
	###########################################################################
	simp$sim$filepartorder 	<- c("regions", "D", "datatype")
	
	dataAggregateSupplyDemand <- input_csv_data(simp, dataname = NULL, datatype = "AggregateServiceDemand",
			pertick = FALSE, bindrows = TRUE)
	input_tools_save(simp, "dataAggregateSupplyDemand")
	
	
	###########################################################################
	### Giving In Statistics
	###########################################################################
	simp$sim$filepartorder 	<- c("regions", "D", "datatype")
	csv_aggregateGiStatistics <- craftyr::input_csv_data(simp, dataname = NULL, datatype = "GivingInStatistics",
			pertick = FALSE,
			bindrows = TRUE,
			skipXY = TRUE)
	craftyr::input_tools_save(simp, "csv_aggregateGiStatistics")
	
	
	###########################################################################
	### Aggregated Connectivity
	###########################################################################

	simp$sim$filepartorder 	<- c("regions", "D", "datatype")

	dataAggregateConnectivity <- input_csv_data(simp, dataname = NULL, datatype = "LandUseConnectivity",
		pertick = FALSE, bindrows = TRUE)
	input_tools_save(simp, "dataAggregateConnectivity")

	
	###########################################################################
	### Store Cell Data for Maps etc. 
	###########################################################################
	simp$sim$filepartorder	<- c("runid", "D", "tick", "D", "regions", "D", "datatype", "D", "dataname")
	data <- input_csv_data(simp, dataname = NULL, datatype = "Cell", columns = "LandUseIndex",
			pertick = TRUE, attachfileinfo = TRUE, tickinterval = simp$csv$tickinterval_cell)
	data <- do.call(rbind.data.frame, data)
	
	csv_LandUseIndex_rbinded <- data
	input_tools_save(simp, "csv_LandUseIndex_rbinded")
	
	
	
	###########################################################################
	### Draw Maps
	###########################################################################
	simp$fig$height			<- 400
	simp$fig$width			<- 300
	
	hl_aftmap(simp, ncol = 2, ggplotaddon = ggplot2::theme(legend.position = c(0.85, 0),
					legend.justification = c(0.85, 0)), secondtick = 2040)
	}