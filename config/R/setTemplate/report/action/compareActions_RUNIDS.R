##########################################################################################
# Create action & metrics figure to compare runs
#
# Project:		TEMPLATE
# Last update: 	26/08/2016
# Author: 		Sascha Holzhauer
# Instructions:	Run maschine-specific SIMP file first (see craftyr documentation)
##########################################################################################

source(simp$simpDefinition)
simp$sim$folder 	<- "_setA/_RegGlobMax"
setwd(paste(simp$dirs$simp, simp$sim$folder, sep="/"))
source(paste(simp$dirs$simp, simp$sim$folder, "simp.R", sep="/"))

# Choose run to compare (ADAPT):
preserve$firstrunid <- ADJUST
preserve$lastrunid	<- ADJUST
preserve$run		<- preserve$firstrunid
preserve$seeds		<- c(0)	

scoreDoNothing		<- 0.5
addPerceivedGap		<- TRUE
addMetrics			<- TRUE

metrics2show		<- c("VarChangesLu", "ConsConnectivity_NC_Cereal-NC_Livestock",
						 "MaxOverSupply_Cereal-Meat-Timber")
metric4dots 		<- "MaxOverSupply_Cereal-Meat-Timber"
		
monitoredServices 	<- c("Cereal", "Meat", "Timber")

regionConversion = setNames(simp$sim$regions, simp$sim$regions)
runIdDescriptions	<- NULL

prefixes <- c("RegionalSubsidyPa", "GlobalSubsidyPa")
aftcolors <- setNames(simp$colours$AFT,
		simp$mdata$aftNames[match(names(simp$colours$AFT), names(simp$mdata$aftNames))]) 
aftcolors <- aftcolors[!is.na(names(aftcolors))]
actionfillcolours <- setNames(rep(aftcolors, times=length(prefixes)),
		paste(rep(prefixes, each=length(aftcolors)), gsub("_", "",names(aftcolors)), sep="_"))

customiseActionNames <- function(names) {
	names <- gsub("GlobalSubsidyPa", "Global Subsidy:", names)
	names <- gsub("RegionalSubsidyPa", "Regional subsidy:", names)
	names <- gsub("_C", " int. ", names)
	names <- gsub("_NC", " ext. ", names)
	names <- gsub("DoNothing", "Do nothing", names)
	names <- gsub("_", " ", names)
	return(names)
}

customiseActionDataComp <- function(dataActionsComp) {
	dataActionsComp <- dataActionsComp[as.character(dataActionsComp$Region) %in% regionConversion,]
	dataActionsComp$Region <- levels(dataActionsComp$Region)[dataActionsComp$Region]
	dataActionsComp[dataActionsComp$Agent %in% c("GlobalSubsidisingInst"), "Region"] <- "Global"
	dataActionsComp$Region <- as.factor(dataActionsComp$Region)
	return(dataActionsComp)
}

customiseMonitorData <- function(monitordata) {
	monitordata <- monitordata[monitordata$Region %in% c("Global"), ]
	
	monitordata <- plyr::ddply(monitordata, c("Region","Mode"), function(df) {
		#df <- monitordata[monitordata$Mode == metric4dots & as.character(monitordata$Region) == "Global",]
		if (unique(df$Mode) == metric4dots) {
			for(i in 2:length(df$Tick)) {
				if (df$Tick[i-1] != df$Tick[i]-1) {
					df[i, "Value"] <- NA
				}
			}
		}
		df
	})
	
	return(monitordata)
}

simp$fig$height <- 700
simp$fig$width <- 1000
filenameprefix <-  "ADJUST"

############### END of Parameter Section ######################

metriclabelsRaw <-  read.csv(file="./reports/KeyTranslations.csv", header=FALSE, stringsAsFactors = FALSE)
metriclabels <- setNames(paste("", metriclabelsRaw[,2]), metriclabelsRaw[,1])
metriccolours <- setNames(paste("", metriclabelsRaw[,3], sep=""), metriclabelsRaw[,1])

for (seed in preserve$seeds) {
	# for testing: seed = 1
	simps <- list()
	for(i in c(preserve$firstrunid,preserve$lastrunid)) {
		for(r in seed) {
			s <- simp
			s$sim$id					<- paste(i, "-", r, sep="")
			s$sim$shortid				<- paste(i, "-", r, sep="")
			s$sim$runids				<- c(paste(i, "-", r, sep=""))
			simps <- append(simps, list(s))
		}
	}
	
	simp$sim$endtick	<- 2040
	simp$sim$runids		<- paste(preserve$run, "-", preserve$seed, sep="")
	simp$sim$id			<- simp$sim$runids
	
	#####
	#####
	
	monitordata <- data.frame()
	dataActionsComp <- data.frame()
	dataSupplyComp <- data.frame()
	perceivedGap <- data.frame()
	metrics <- data.frame()
	
	for (simp in simps) {
		# for testing: simp = simps[[1]]
		
		# load actions data:
		input_tools_load(simp, "dataActions")
		dataActionsComp <- rbind(dataActionsComp, dataActions)
		
		# get supply/demand data:
		convert_aggregate_demand(simp)
		convert_aggregate_supply(simp, celldataname = "dataAgg")
		
		# store percental supply (regarding demand)
		input_tools_load(simp, objectName="csv_aggregated_demand")
		input_tools_load(simp, objectName="csv_aggregated_supply")
		colnames(csv_aggregated_demand)[colnames(csv_aggregated_demand) == "variable"] <- "Service"
		dataAggregatedPercentalSupply <- merge(csv_aggregated_supply, csv_aggregated_demand)
		
		# add totals of demand:
		data <- dataAggregatedPercentalSupply			
		sum <- aggregate(data[, c("Demand", "TotalProduction")], list(
						Tick	= data$Tick,
						Region	= data$Region,
						ID		= data$ID
				),
				FUN=sum)
		sum$Service <- "Total"
		
		world <- aggregate(data[, c("Demand", "TotalProduction")], list(
						Tick	= data$Tick,
						Service	= data$Service,
						ID		= data$ID
				),
				FUN=sum)
		world$Region <- "Global"
		
		dataAggregatedPercentalSupply <- rbind(data, sum, world)
		dataAggregatedPercentalSupply$PercentalSupply <- 100 * dataAggregatedPercentalSupply$TotalProduction / 
				dataAggregatedPercentalSupply$Demand
		dataSupplyComp <- rbind(dataSupplyComp, dataAggregatedPercentalSupply)
		
		# Misperception
		input_tools_load(simp, objectName="csv_PerceivedSupplyDemandGapTimber")
		input_tools_load(simp, objectName="csv_PerceivedSupplyDemandGapCereal")
		perceivedGap <- rbind(perceivedGap,
				csv_PerceivedSupplyDemandGapTimber,
				csv_PerceivedSupplyDemandGapCereal)
		
		
		# Metrics
		input_tools_load(simp, "data_metrics")
		
		metricsdata <-  data.frame()
		for (metric2show in metrics2show) {
			metricdata = data_metrics[data_metrics$Metric == metric2show,]
			colnames(metricdata)[colnames(metricdata)=="Metric"] <- "Mode"
			metricdata$Value <- metricdata$Value /
					metricdata[metricdata$Tick == min(metricdata$Tick), "Value"]
			if(nrow(metricdata) > 0) {
				metricdata$Region <- "Global"
				metricdata$Service <- metriclabels[metric2show]
				metricdata$Runid <- simp$sim$id
				metricdata$TotalProduction <- NA
				metricdata$Demand <- NA
				metricdata$Facet <- "Metrics"
				metricsdata <- rbind(metricsdata, metricdata)
			}
		}		
		
		metrics <- rbind(metrics, metricsdata)
	}
	
	# Process accumulated actions data:
	dataActionsComp <- hl_actions_fillDoNothing(simp, dataActionsComp, score = scoreDoNothing)
	
	# Process accumulated supply data:
	colnames(dataSupplyComp)[colnames(dataSupplyComp) == 
					"PercentalSupply"] <- "Value"
	colnames(dataSupplyComp)[colnames(dataSupplyComp) == 
					"ID"] <- "Runid"
	dataSupplyComp$Facet <- paste("Supply-demand gap")
	dataSupplyComp$Mode <- "PERCEIVED"

	
	## Add perceived Gap:
	if (addPerceivedGap) {
		perceivedgap <- reshape2::melt(data = perceivedGap, id.vars = c("Tick", "Region", "Runid", "Service"), 
				measure.vars = c("VALUE_REAL", "VALUE_PERCEIVED"),
				variable.name = "Mode", value.name ="Value")
		perceivedgap$Mode <- sapply(strsplit(as.character(perceivedgap$Mode), "_"), function(x) x[2])
		perceivedgap$Region <- paste(perceivedgap$Region, "Gap perception")
		
		monitordata <- merge(dataSupplyComp, perceivedgap, all = TRUE)
	} else {
		monitordata <- dataSupplyComp
	}
	
	## Add metrics:
	if (addMetrics) {
		monitordata <- rbind(monitordata, metrics)
	}
	
	monitordata$Runid <-  as.factor(monitordata$Runid)
	if (!is.null(runIdDescriptions)) {
		levels(dataActionsComp$Runid) <- runIdDescriptions[levels(dataActionsComp$Runid)]
		levels(monitordata$Runid) <- runIdDescriptions[levels(monitordata$Runid)]
	}
	
	# customise action labels
	actionLabels <- setNames(unique(dataActionsComp$Action), unique(dataActionsComp$Action))
	if (exists("customiseActionNames")) actionLabels <- customiseActionNames(actionLabels)
	names(actionLabels) <- unique(dataActionsComp$Action)
	
	dataActionsComp$Facet <- as.factor("Actions")
	monitordata <- monitordata[monitordata$Service %in% c(monitoredServices, metriclabels),]
		
	dataActionsComp$Region <- levels(dataActionsComp$Region)[dataActionsComp$Region]
	dataActionsComp <- dataActionsComp[dataActionsComp$Region %in% names(regionConversion),]
	dataActionsComp$Region <- as.factor(regionConversion[as.character(dataActionsComp$Region)])
	
	if (exists("customiseActionDataComp")) dataActionsComp <- customiseActionDataComp(dataActionsComp)
	
	monitordata <- monitordata[monitordata$Region %in% names(regionConversion),]
	monitordata$Facet <- as.factor(monitordata$Facet)
	if (exists("customiseMonitorData")) monitordata <- customiseMonitorData(monitordata)
	
	maxsupplydata 	<- monitordata[monitordata$Mode == metric4dots, ]
	
	visualise_actions(simp, 
			actiondata		= dataActionsComp,
			monitordata 	= monitordata,
			onlyselected 	= TRUE,
			y_column_measure = "Value",
			colour_column 	= "Service",
			size_column 	= NULL,
			facet_column 	= "Facet",
			lineseparator_column_actions = "Region",
			linetype_column_measures = "Region",
			linetype_column_actions = "Region",
			actionfillcolours 	= c("DoNothing" = "grey", 
					actionfillcolours),
			monitorcolours 	= c(simp$colours$Service, setNames(metriccolours[metrics2show], metriclabels[metrics2show]),
					"Total" = "black"),
			filename = paste(filenameprefix, preserve$firstrunid, 
					preserve$lastrunid, seed, sep="_"),
			ggplotaddons = list(
					ggplot2::facet_grid(as.formula("Facet ~ Runid"), scales="free_y"),
					ggplot2::scale_fill_manual(name= "Action", values = c("DoNothing" = "grey", 
									actionfillcolours), labels = actionLabels),
					ggplot2::scale_x_continuous(breaks= scales::pretty_breaks(n = 3)),
					ggplot2::guides(shape = ggplot2::guide_legend(order = 1),
									linetype = ggplot2::guide_legend(order = 2),
									colour=ggplot2::guide_legend("Service/Metric")),
					ggplot2::theme(legend.key.size=grid::unit(0.8, "lines"),
							axis.text=ggplot2::element_text(size=ggplot2::rel(0.6))),
					ggplot2::geom_point(data = maxsupplydata, ggplot2::aes_string(x="Tick", y="Value"), 
							colour=metriccolours[metric4dots])
		)
	)
}