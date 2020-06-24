#######################################################################
# ApplicationScript for Storing CRAFTY ouptut as R data (both
# raw and aggregated) when peforming as cluster job via craftybatch.py.
#
# Project:		TEMPLATE
# Last update: 	26/08/2016
# Author: 		Sascha Holzhauer
#######################################################################

# Only contained when the particular script is only executed on a specific maschine!
# Otherwise. the maschine=specific file needs to be executed before.

source("/PATH-TO/simp-machine_cluster.R")
require(methods)

option_list <- list(
			optparse::make_option(c("-k", "--firstrun"), action="store", default= "0",
				help="First run to process (lowest run id to process)"),
			optparse::make_option(c("-n", "--numrun"), action="store", default= "1",
				help="Total Number of runs (1 more than highest run id to process - needs to respect available variables for CRAFTY invocation)"),
			optparse::make_option(c("-o", "--seedoffset"), action="store", default= "0",
				help="First random seed to process"),
			optparse::make_option(c("-r", "--numrandomseeds"), action="store", default= "1",
				help="Number of random seed to process, beginning with seed offset"),
			optparse::make_option(c("-p", "--noreport"), action="store_true",
				help="If given, no report is generated"))
opt	<- optparse::parse_args(optparse::OptionParser(option_list=option_list))


# Usually also in simp.R, but required here to find simp.R
simp$sim$folder 	<- "parentFolder/_version"	

simp$sim$task		<- paste(opt$run, opt$seed, sep="-") # Name of surounding folder, usually a description of task 

preserve <- list()
preserve$task 		<- simp$sim$task

# simp$dirs$simp is set by maschine-specific file:
setwd(paste(simp$dirs$simp, simp$sim$folder, "cluster/common", sep="/"))
# usually, the setting/scenario specific simp.R is two levels above:
source("../../simp.R")

library(plyr)

runs = as.numeric(opt$firstrun):(as.numeric(opt$numrun)-1)
rseeds = as.numeric(opt$seedoffset):(as.numeric(opt$seedoffset) + as.numeric(opt$numrandomseeds) - 1)
for (run in runs) {
	for (rseed in rseeds) {
		# run = 176; rseed = 0
		preserve$run = run
		preserve$seed = rseed

		simp$sim$runids 	<- c(paste(run, rseed, sep="-"))			# run to deal with
		simp$sim$id			<- c(paste(run, rseed, sep="-"))
		
		#######################################################################
		futile.logger::flog.threshold(futile.logger::INFO, name='crafty')
		
		simp$sim$rundesclabel	<- "Runs"
		
		###########################################################################
		### Read and Aggregate CSV data
		###########################################################################
		
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
#		csv_preAllocTable <- input_csv_prealloccomp(simp)
#		input_tools_save(simp, "csv_preAllocTable")
		
		
		###########################################################################
		### Take Overs
		###########################################################################
		dataTakeOvers <- input_csv_data(simp, dataname = NULL, datatype = "TakeOvers", pertick = FALSE,
				bindrows = TRUE,
				skipXY = TRUE)
		
		input_tools_save(simp, "dataTakeOvers")
		
		
		###########################################################################
		### AFT composition data
		###########################################################################
		dataAggregateAFTComposition <- input_csv_data(simp, dataname = NULL, datatype = "AggregateAFTComposition", pertick = FALSE,
				bindrows = TRUE,
				skipXY = TRUE)
		
		input_tools_save(simp, "dataAggregateAFTComposition")
		
		###########################################################################
		### AFT competitiveness data
		###########################################################################
		dataAggregateAFTCompetitiveness <- input_csv_data(simp, dataname = NULL, datatype = "AggregateAFTCompetitiveness", pertick = FALSE,
				bindrows = TRUE,
				skipXY = TRUE)
		
		input_tools_save(simp, "dataAggregateAFTCompetitiveness")
		
		###########################################################################
		### Aggregated Demand and Supply
		###########################################################################
		dataAggregateSupplyDemand <- input_csv_data(simp, dataname = NULL, datatype = "AggregateServiceDemand",
				pertick = FALSE, bindrows = TRUE)
		input_tools_save(simp, "dataAggregateSupplyDemand")
		
		
		###########################################################################
		### Giving In Statistics
		###########################################################################
		csv_aggregateGiStatistics <- craftyr::input_csv_data(simp, dataname = NULL, datatype = "GivingInStatistics",
				pertick = FALSE,
				bindrows = TRUE,
				skipXY = TRUE)
		craftyr::input_tools_save(simp, "csv_aggregateGiStatistics")
		
		
		###########################################################################
		### Aggregated Connectivity
		###########################################################################
		
#		simp$sim$filepartorder 	<- c("regions", "D", "datatype")
#		
#		dataAggregateConnectivity <- input_csv_data(simp, dataname = NULL, datatype = "LandUseConnectivity",
#				pertick = FALSE, bindrows = TRUE)
#		input_tools_save(simp, "dataAggregateConnectivity")
		
		
		###########################################################################
		### Store Actions
		###########################################################################
		dataActions <- input_csv_data(simp, dataname = NULL, datatype = "Actions",
				pertick = FALSE, bindrows = TRUE)
		input_tools_save(simp, "dataActions")
		
		###########################################################################
		### Store Cell Data for Maps etc. 
		###########################################################################
		data <- input_csv_data(simp, dataname = NULL, datatype = "Cell", columns = "LandUseIndex",
				pertick = TRUE, attachfileinfo = TRUE, tickinterval = 1)
		data <- do.call(rbind.data.frame, data)
		
		csv_LandUseIndex_rbinded <- data
		input_tools_save(simp, "csv_LandUseIndex_rbinded")
		
		
		###########################################################################
		### Store PerceivedSupplyDemandGaps
		###########################################################################
#		csv_PerceivedSupplyDemandGapTimber <- input_csv_data(simp, dataname = NULL, 
#				datatype = "GenericTableOutputter-PerceivedSupplyDemandGapTimber", pertick = FALSE,
#				bindrows = TRUE,
#				skipXY = TRUE)
#		if (nrow(csv_PerceivedSupplyDemandGapTimber) > 0) { 
#			csv_PerceivedSupplyDemandGapTimber$Service <- "Timber"
#		}
#		input_tools_save(simp, "csv_PerceivedSupplyDemandGapTimber")
#		
#		csv_PerceivedSupplyDemandGapCereal <- input_csv_data(simp, dataname = NULL, 
#				datatype = "GenericTableOutputter-PerceivedSupplyDemandGapCereal", pertick = FALSE,
#				bindrows = TRUE,
#				skipXY = TRUE)
#		if (nrow(csv_PerceivedSupplyDemandGapCereal) > 0) {
#			csv_PerceivedSupplyDemandGapCereal$Service <- "Cereal"
#		}
#		input_tools_save(simp, "csv_PerceivedSupplyDemandGapCereal")
		
		###########################################################################
		### Draw Maps
		###########################################################################
		simp$fig$height			<- 400
		simp$fig$width			<- 300
		
		hl_aftmap(simp, ncol = 2, ggplotaddon = ggplot2::theme(legend.position = c(0.85, 0),
						legend.justification = c(1.0, 0), legend.key.size=grid::unit(0.8, "lines")), secondtick = 2020)
		
		simp$fig$maptitle <- "WorldX-AFTsB"
		hl_aftmap(simp, ncol = 2, ggplotaddon = ggplot2::theme(legend.position = c(0.85, 0),
						legend.justification = c(1.0, 0), legend.key.size=grid::unit(0.8, "lines")), secondtick = 2011)
		
		###########################################################################
		### Store Changes in Land Use
		###########################################################################
		simp$sim$filepartorder <- c("runid", "D", "tick", "D", "regions", "D", "datatype", "D", "dataname")
		data_landuse_changes = data.frame(
					Tick = (simp$sim$starttick + 1):simp$sim$endtick,
					Changes = metric_rasters_changes(simp, dataname = "raster_landUseIndex"),
					Runid = simp$sim$runids)
		input_tools_save(simp, "data_landuse_changes")
		
		###########################################################################
		### Calculate Metrics
		###########################################################################
		storeRegions <- simp$sim$regions
		simp$sim$regions	<- "Unknown"
		
		metrics <- rbind(
				metric_rasters_changedcells(simp, aft = NULL, dataname = "raster_landUseIndex"),
				metric_rasters_changes(simp, dataname = "raster_landUseIndex"),
				metric_aggaft_diversity_shannon(simp, dataname = "dataAggregateAFTComposition"),
				metric_rasters_global_patches(simp, dataname = "raster_landUseIndex", 
						directions = 8, relevantafts = c("NC_Cereal", "NC_Livestock")),
				metric_rasters_global_patches(simp, dataname = "raster_landUseIndex", 
						directions = 8, relevantafts = c("C_Cereal", "C_Livestock")),
				metrics_rasters_connectivity(simp, afts = c("NC_Cereal", "NC_Livestock"),
						dataname = "raster_landUseIndex"))
				
		simp$sim$regions	<- storeRegions
		convert_aggregate_supply(simp, celldataname = "dataAgg")
		convert_aggregate_demand(simp, demanddataname = "csv_aggregated_demand", sourcedataname = "dataAggregateSupplyDemand")
		
		metrics <- rbind(metrics,		
				metric_aggaft_proportions(simp, afts = c("NC_Cereal", "NC_Livestock"), aftsname = "NC", 
						dataname = "dataAggregateAFTComposition"),
				metric_aggaft_proportions(simp, afts = c("C_Cereal", "C_Livestock"), aftsname = "C", 
						dataname = "dataAggregateAFTComposition"),
				metric_agg_supplydemand_maximum(simp, services=c("Cereal", "Meat", "Timber"), 
						datanamedemand = "csv_aggregated_demand",
						datanamesupply = "csv_aggregated_supply",
						considerundersupply = TRUE,
						consideroversupply = FALSE),
				metric_agg_supplydemand_maximum(simp, services=c("Cereal", "Meat", "Timber"), 
						datanamedemand = "csv_aggregated_demand",
						datanamesupply = "csv_aggregated_supply",
						considerundersupply = FALSE,
						consideroversupply = TRUE),
				# undersupply
				metric_agg_supplydemand_percentage(simp, service = "Total", datanamedemand = "csv_aggregated_demand",
						datanamesupply = "csv_aggregated_supply",
						considerundersupply = TRUE,
						consideroversupply = FALSE),
				metric_agg_supplydemand_percentage(simp, service = "Cereal", datanamedemand = "csv_aggregated_demand",
						datanamesupply = "csv_aggregated_supply",
						considerundersupply = TRUE,
						consideroversupply = FALSE),
				metric_agg_supplydemand_percentage(simp, service = "Meat", datanamedemand = "csv_aggregated_demand",
						datanamesupply = "csv_aggregated_supply",
						considerundersupply = TRUE,
						consideroversupply = FALSE),
				metric_agg_supplydemand_percentage(simp, service = "Timber", datanamedemand = "csv_aggregated_demand",
						datanamesupply = "csv_aggregated_supply",
						considerundersupply = TRUE,
						consideroversupply = FALSE),
				# oversupply
				metric_agg_supplydemand_percentage(simp, service = "Total", datanamedemand = "csv_aggregated_demand",
						datanamesupply = "csv_aggregated_supply",
						considerundersupply = FALSE,
						consideroversupply = TRUE),
				metric_agg_supplydemand_percentage(simp, service = "Cereal", datanamedemand = "csv_aggregated_demand",
						datanamesupply = "csv_aggregated_supply",
						considerundersupply = FALSE,
						consideroversupply = TRUE),
				metric_agg_supplydemand_percentage(simp, service = "Meat", datanamedemand = "csv_aggregated_demand",
						datanamesupply = "csv_aggregated_supply",
						considerundersupply = FALSE,
						consideroversupply = TRUE),
				metric_agg_supplydemand_percentage(simp, service = "Timber", datanamedemand = "csv_aggregated_demand",
						datanamesupply = "csv_aggregated_supply",
						considerundersupply = FALSE,
						consideroversupply = TRUE),
				metric_agg_supplyperreg_simpson(simp, region = NULL, 
						datanamesupply = "csv_aggregated_supply"),
				metric_agg_supplyaccrossreg_simpson(simp, service = NULL, 
						datanamesupply = "csv_aggregated_supply"),
				metric_aggaft_diversity_simpson(simp, region = NULL,
						dataname = "dataAggregateAFTComposition"),
				metric_agg_regionalsupply_efficiency(simp, service = NULL, 
					datanamesupply = "csv_aggregated_supply",
					datanameaft = "dataAggregateAFTComposition")
		)
		
		data <- do.call(rbind, lapply(simp$sim$regions, function(r) 
							metric_agg_supplydemand_percentage(simp, service = "Cereal", region = r, datanamedemand = "csv_aggregated_demand",
									datanamesupply = "csv_aggregated_supply",
									considerundersupply = TRUE, consideroversupply = FALSE)))
		if (nrow(data) > 0) {
			metrics <- rbind(metrics, data.frame(aggregate(data.frame(Value=data$Value), by=list(Tick= data$Tick), FUN=mean), 
							Metric="RegionalUnderSupplyPercent_Cereal"))
		}
		
		data <- do.call(rbind, lapply(simp$sim$regions, function(r) 
							metric_agg_supplydemand_percentage(simp, service = "Meat", region = r, datanamedemand = "csv_aggregated_demand",
									datanamesupply = "csv_aggregated_supply",
									considerundersupply = TRUE, consideroversupply = FALSE)))
		if (nrow(data) > 0) {
			metrics <- rbind(metrics, data.frame(aggregate(data.frame(Value=data$Value), by=list(Tick= data$Tick), FUN=mean), 
							Metric="RegionalUnderSupplyPercent_Meat"))
		}
		
		data <- do.call(rbind, lapply(simp$sim$regions, function(r) 
							metric_agg_supplydemand_percentage(simp, service = "Timber", region = r, datanamedemand = "csv_aggregated_demand",
									datanamesupply = "csv_aggregated_supply",
									considerundersupply = TRUE, consideroversupply = FALSE)))
		if (nrow(data) > 0) {
			metrics <- rbind(metrics, data.frame(aggregate(data.frame(Value=data$Value), by=list(Tick= data$Tick), FUN=mean), 
							Metric="RegionalUnderSupplyPercent_Timber"))
		}	
		
				
		data_metrics <-  metrics
		input_tools_save(simp, "data_metrics")
		
		
		###########################################################################
		### Create Report
		###########################################################################
		
		if (is.null(opt$noreport) || !opt$noreport) {
			source("./createReport.R")
		}
	}
}

###########################################################################
### Draw Changes in Land Use (not useful when only one runid is executed)
###########################################################################
#datas <- data.frame()
#for (run in runs) {
#	simp$sim$runids <- c(paste(run, rseed, sep="-"))
#	simp$sim$id 	<- c(paste(run, rseed, sep="-"))
#	input_tools_load(simp, "data_landuse_changes")
#	datas <- rbind(datas, data)
#}
#visualise_lines(simp, datas, "Changes", title = "Changes in Land Use",
#		colour_column = "Runid") 