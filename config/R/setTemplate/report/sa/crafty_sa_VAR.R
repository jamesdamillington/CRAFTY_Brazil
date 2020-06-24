##########################################################################################
# Create Sensitivity Analysis plot for Subsidy rate
#
# Project:		TEMPLATE
# Last update: 	26/08/2016
# Author: 		Sascha Holzhauer
# Instructions:	Run maschine-specific SIMP file first (see craftyr documentation)
##########################################################################################
# Usually also in simp.R, but required here to find simp.R
simp$sim$folder 	<- "parentFolder/_version"	

# Name of surounding folder, usually a description of task 
simp$sim$task		<- "SA" 
preserve <- list()
preserve$task 		<- simp$sim$task


# simp$dirs$simp is set by maschine-specific file:
setwd(paste(simp$dirs$simp, simp$sim$folder, "cluster/common", sep="/"))
# usually, the setting/scenario specific simp.R is two levels above:
source("../../simp.R")

keyTranslationsFile = "../../reports/KeyTranslations.csv"

metriccolnames = c("VarChangesLu", "VarChangesCells",
		"MaxOverSupply", "UnderSupply_Cereal", "UnderSupply_Meat",
		"RegUnderSupply_Cereal", "OverSupply_Cereal",
		"ConsProp_NC", "ConsConnectivity", "NumActions",
		"DivSupplyAcrossRegSimpson",
		"MaxUnderSupply",  "UnderSupply_Timber", "ConsPatches_NC", 
		"DivLuPerRegSimpson", "DivSupplyPerRegSimpson", "NumActionsNC"
)

setBmetrics <- c("VarChangesLu", "MaxOverSupply", "OverSupply_Cereal",
				"NumActions")

varname	<- "TriggeringThreshold"

runs = ADJUST:ADJUST
rseeds = 0:ADJUST

setsimp <- simp
setsimp$sim$id <- "ADJUST"

simp$fig$height <- 700
simp$fig$width <- 1000
simp$fig$linewidth 	<- 1

############### END of Parameter Section ######################

library(plyr)

data <- shbasic::sh_tools_loadorsave(SIP = setsimp, OBJECTNAME = "data_metrics", 
		PRODUCTIONFUN = function() { 
	data <- data.frame()
	for (run in runs) {
		for (rseed in rseeds) {
			# run = runs[7]; rseed = rseeds[1]
			
			simp$sim$runids 	<- c(paste(run, rseed, sep="-"))			# run to deal with
			simp$sim$id			<- c(paste(run, rseed, sep="-"))
			
			input_tools_load(simp, "data_metrics")
		
			numactions <- data.frame(
					Metric = "NumActions",
					Value  = metric_agg_actions_number(simp),
					Tick   = 2025) # arbitrary
			
			numactionsNC <- data.frame(
					Metric = "NumActionsNC",
					Value  = metric_agg_actions_number(simp, pattern="NC"),
					Tick   = 2025) # arbitrary
			
			data_metrics <- rbind(data_metrics, numactions, numactionsNC)
			
			runparams <- craftyr::input_csv_param_runs(simp, paramid = TRUE)
			
			# ADJUST:
			data_metrics$ADJUST = runparams[,"ADJUST"]
			data_metrics$Rseed <- rseed
		
			data <- rbind(data, data_metrics)
		}
	}
	return(data)
})

data_agg <- plyr::ddply(data, c("TriggeringThreshold","Rseed"), function(data_metrics) data.frame(
		
		ConsPatches_NC 	= mean(data_metrics[data_metrics$Metric == "ConsPatches_NC_Cereal-NC_Livestock", "Value"]),
		
		VarChangesCells	= sum(data_metrics[data_metrics$Metric == "VarChangesCells", "Value"]),
		DivLuShannon	= mean(data_metrics[data_metrics$Metric == "DivLuShannon", "Value"]),
		ConsPatches_C 	= mean(data_metrics[data_metrics$Metric == "ConsPatches_C_Cereal-C_Livestock", "Value"]),
		ConsProp_C  	= mean(data_metrics[data_metrics$Metric == "ConsProp_C", "Value"]), 
		ConsProp_NC		= mean(data_metrics[data_metrics$Metric == "ConsProp_NC", "Value"]), 
		ConsConnectivity= mean(data_metrics[data_metrics$Metric == "ConsConnectivity_NC_Cereal-NC_Livestock", "Value"]),
		
		# correct under/oversupply data:
		UnderSupply_Total = abs(mean(data_metrics[data_metrics$Metric == "UnderSupplyPercent_Total", "Value"])-100),  
		UnderSupply_Meat  = abs(mean(data_metrics[data_metrics$Metric == "UnderSupplyPercent_Meat", "Value"])-100),     
		UnderSupply_Cereal = abs(mean(data_metrics[data_metrics$Metric == "UnderSupplyPercent_Cereal", "Value"])-100),
		
		OverSupply_Total = abs(mean(data_metrics[data_metrics$Metric == "OverSupplyPercent_Total", "Value"])-100),  
		OverSupply_Meat  = abs(mean(data_metrics[data_metrics$Metric == "OverSupplyPercent_Meat", "Value"])-100),     
		OverSupply_Timber = abs(mean(data_metrics[data_metrics$Metric == "OverSupplyPercent_Timber", "Value"])-100),
		
		RegUnderSupply_Cereal = abs(mean(data_metrics[data_metrics$Metric == "RegionalUnderSupplyPercent_Cereal", "Value"])-100),
		RegUnderSupply_Meat = abs(mean(data_metrics[data_metrics$Metric == "RegionalUnderSupplyPercent_Meat", "Value"])-100),
		RegUnderSupply_Timber = abs(mean(data_metrics[data_metrics$Metric == "RegionalUnderSupplyPercent_Timber", "Value"])-100),
		
		DivSupplyPerRegSimpson = mean(data_metrics[data_metrics$Metric == "DivSupplyPerRegSimpson", "Value"]),
		DivLuPerRegSimpson  = mean(data_metrics[data_metrics$Metric == "DivLuPerRegSimpson", "Value"]),
		DivSupplyAcrossRegSimpson  = mean(data_metrics[data_metrics$Metric == "DivSupplyAcrossRegSimpson", "Value"]),
		EffSupply  		= mean(data_metrics[data_metrics$Metric == "EffSupply", "Value"]),
		
		
		VarChangesLu 	= sum(data_metrics[data_metrics$Metric == "VarChangesLu", "Value"]),
		MaxOverSupply  	= max(0, data_metrics[data_metrics$Metric == "MaxOverSupply_Cereal-Meat-Timber", "Value"]),
		MaxUnderSupply  = max(0, abs(data_metrics[data_metrics$Metric == "MaxUnderSupply_Cereal-Meat-Timber", "Value"])),
		
		OverSupply_Cereal = abs(mean(data_metrics[data_metrics$Metric == "OverSupplyPercent_Cereal", "Value"])-100),
		UnderSupply_Timber = abs(mean(data_metrics[data_metrics$Metric == "UnderSupplyPercent_Timber", "Value"])-100),
		
		NumActions		= mean(data_metrics[data_metrics$Metric == "NumActions", "Value"]),
		NumActionsNC	= mean(data_metrics[data_metrics$Metric == "NumActionsNC", "Value"])
))

columns <-  c("UnderSupply_Total", "UnderSupply_Meat", "UnderSupply_Cereal",
		"OverSupply_Total", "OverSupply_Meat", "OverSupply_Cereal", "OverSupply_Timber",
		"RegUnderSupply_Timber", "RegUnderSupply_Meat", "RegUnderSupply_Cereal")
data_agg[,columns] <- apply(data_agg[,columns], 2, function(x){replace(x, is.na(x), 0)})


# devide by means across rseeds:
d <- apply(data_agg[, -match(c(varname), colnames(data_agg))], 
		MARGIN=2, FUN = function(x) abs(if (is.na(mean(x[1:length(rseeds)])) || mean(x[1:length(rseeds)]) != 0) 
								mean(x[1:length(rseeds)]) else max(colMeans(matrix(x, nrow=length(rseeds))))))
normd <- as.data.frame(t(apply(data_agg[, -match(c(varname), colnames(data_agg))], 
		MARGIN=1, FUN= function(x) x/d)))
normd$TriggeringThreshold <- data_agg$TriggeringThreshold
normd$Rseed <- data_agg$Rseed

data_melted <- reshape2::melt(normd, id.vars = c(varname, "Rseed"),
		variable.name = "Metric",  value.name = "Value")


data_selected <- data_melted[data_melted$Metric %in% metriccolnames,]
data_selected$Facet <- "Normalised Set A"
data_selected[data_selected$Metric %in% setBmetrics, "Facet"] <- "Normalised Set B"

metriclabels <-  read.csv(file=keyTranslationsFile, header=FALSE, stringsAsFactors = FALSE)
metriclabels <- setNames(metriclabels[,2], metriclabels[,1])

colours <- RColorBrewer::brewer.pal(length(unique(data_selected[data_selected$Facet == "Normalised Set A","Metric"])), 
		"Set1")
colours <- c(colours,colours)

visualise_lines(simp, data_selected, x_column = varname, y_column="Value", title = NULL,
		colour_column = "Metric", colour_legendtitle = "Metric", colour_legenditemnames = metriclabels,
		facet_column = "Facet", facet_ncol = 1, filename = paste("SA", setsimp$sim$id, 
				setsimp$sim$id, sep="_"),
		alpha = simp$fig$alpha, ggplotaddons = list(
				ggplot2::guides(fill=FALSE),
				ggplot2::scale_fill_manual(values=colours),
				ggplot2::scale_color_manual(values=colours, labels=metriclabels, guide=ggplot2::guide_legend(ncol=2)),
				#viridis::scale_color_viridis(discrete=TRUE, labels=metriclabels, guide=ggplot2::guide_legend(ncol=2)),
				ggplot2::facet_wrap(as.formula(paste("~",  "Facet")), ncol = 2, scales="free_y"),
				ggplot2::theme(legend.position = "bottom")), showsd = TRUE,
		returnplot = FALSE)