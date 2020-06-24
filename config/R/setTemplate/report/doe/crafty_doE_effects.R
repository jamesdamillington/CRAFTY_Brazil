##########################################################################################
# Create DoE Effect figure
# Set switch 'nointeractioneffects' to TRUE to show only single effects
# (applies to focus set only).
#
# Project:		TEMPLATE
# Last update: 	26/08/2016
# Author: 		Sascha Holzhauer
# Instructions:	Run maschine-specific SIMP file first (see craftyr documentation)
##########################################################################################

# Usually also in simp.R, but required here to find simp.R
simp$sim$folder 	<- "parentFolder/_version"	

simp$sim$task		<- "doe" # Name of surounding folder, usually a description of task 
preserve <- list()
preserve$task 		<- simp$sim$task

nointeractioneffects <-  TRUE

# simp$dirs$simp is set by maschine-specific file:
setwd(paste(simp$dirs$simp, simp$sim$folder, "cluster/common", sep="/"))
# usually, the setting/scenario specific simp.R is two levels above:
source("../../simp.R")

library(plyr)

runs = ADJUST:ADJUST
rseeds = 0:ADJUST

simp$fig$height			<- 1300
simp$fig$width			<- 1300
simp$fig$outputformat	<- "png"

metricColnames = c("VarChangesLu", "VarChangesCells",
		"MaxUnderSupply", "MaxOverSupply",
		"UnderSupply_Cereal", "UnderSupply_Timber","UnderSupply_Meat",
		"RegUnderSupply_Timber",
		"ConsPatches_NC", "ConsProp_NC", "ConsConnectivity",
		"NumActions", "NumActionsNC", "DivSupplyPerRegSimpson"
)
paramcolnames = c("ADJUST1", "ADJUST2")

rawfigurefilename = "crafty_TEMPLATE_analysis_doe_effects"

keyTranslationsFile = "../../reports/KeyTranslations.csv"

############### END of Parameter Section ######################

data <- data.frame()
for (run in runs) {
	for (rseed in rseeds) {
		# run = runs[1]; rseed = rseeds[1]
		
		simp$sim$runids 	<- c(paste(run, rseed, sep="-"))			# run to deal with
		simp$sim$id			<- c(paste(run, rseed, sep="-"))
		
		input_tools_load(simp, "data_metrics")
		
		runparams <- craftyr::input_csv_param_runs(simp, paramid = TRUE)

		agg_metrics <- data.frame(
			VarChangesLu 	= sum(data_metrics[data_metrics$Metric == "VarChangesLu", "Value"]),
			ConsPatches_NC 	= mean(data_metrics[data_metrics$Metric == "ConsPatches_NC_Cereal-NC_Livestock", "Value"]),
			MaxUnderSupply  = max(0, abs(data_metrics[data_metrics$Metric == "MaxUnderSupply_Cereal-Meat-Timber", "Value"])),
			MaxOverSupply  	= max(0, data_metrics[data_metrics$Metric == "MaxOverSupply_Cereal-Meat-Timber", "Value"]),
			
			VarChangesCells	= sum(data_metrics[data_metrics$Metric == "VarChangesCells", "Value"]),
			DivLuShannon	= mean(data_metrics[data_metrics$Metric == "DivLuShannon", "Value"]),
			ConsPatches_C 	= mean(data_metrics[data_metrics$Metric == "ConsPatches_C_Cereal-C_Livestock", "Value"]),
			ConsProp_C  	= mean(data_metrics[data_metrics$Metric == "ConsProp_C", "Value"]), 
			ConsProp_NC		= mean(data_metrics[data_metrics$Metric == "ConsProp_NC", "Value"]), 
			ConsConnectivity= mean(data_metrics[data_metrics$Metric == "ConsConnectivity_NC_Cereal-NC_Livestock", "Value"]),
			
			# correct under/oversupply data:
			UnderSupply_Total = abs(mean(data_metrics[data_metrics$Metric == "UnderSupplyPercent_Total", "Value"])),  
			UnderSupply_Meat  = abs(mean(data_metrics[data_metrics$Metric == "UnderSupplyPercent_Meat", "Value"])),     
			UnderSupply_Cereal = abs(mean(data_metrics[data_metrics$Metric == "UnderSupplyPercent_Cereal", "Value"])),
			UnderSupply_Timber = abs(mean(data_metrics[data_metrics$Metric == "UnderSupplyPercent_Timber", "Value"])),
			
			OverSupply_Total = abs(mean(data_metrics[data_metrics$Metric == "OverSupplyPercent_Total", "Value"])),  
			OverSupply_Meat  = abs(mean(data_metrics[data_metrics$Metric == "OverSupplyPercent_Meat", "Value"])),     
			OverSupply_Cereal = abs(mean(data_metrics[data_metrics$Metric == "OverSupplyPercent_Cereal", "Value"])),
			OverSupply_Timber = abs(mean(data_metrics[data_metrics$Metric == "OverSupplyPercent_Timber", "Value"])),
			
			RegUnderSupply_Cereal = abs(mean(data_metrics[data_metrics$Metric == "RegionalUnderSupplyPercent_Cereal", "Value"])),
			RegUnderSupply_Meat = abs(mean(data_metrics[data_metrics$Metric == "RegionalUnderSupplyPercent_Meat", "Value"])),
			RegUnderSupply_Timber = abs(mean(data_metrics[data_metrics$Metric == "RegionalUnderSupplyPercent_Timber", "Value"])),
			
			DivSupplyPerRegSimpson = mean(data_metrics[data_metrics$Metric == "DivSupplyPerRegSimpson", "Value"]),
			DivLuPerRegSimpson  = mean(data_metrics[data_metrics$Metric == "DivLuPerRegSimpson", "Value"]),
			DivSupplyAcrossRegSimpson  = mean(data_metrics[data_metrics$Metric == "DivSupplyAcrossRegSimpson", "Value"]),
			EffSupply  		= mean(data_metrics[data_metrics$Metric == "EffSupply", "Value"]),
			
			NumActions		= metric_agg_actions_number(simp),
			NumActionsNC	= metric_agg_actions_number(simp, pattern="NC"),
			
			ID 				= simp$sim$id,
			
			# Determine parameters
			ADJUST1	= runparams[,"ADJUST1"],
			ADJUST2	= runparams[,"ADJUST2"],
		)		
		data <- rbind(data, agg_metrics)
	}
}

# Substitute letters by numbers:
#substit <- c("G" = 1, "F" = 2)
#data$ADJUST1 <- substit[data$ADJUST1]

dexp <- shdoe::shdoe_param_getDefaultDexp()

metriclabels <-  read.csv(file=keyTranslationsFile, header=FALSE, stringsAsFactors = FALSE)
metriclabels <- setNames(metriclabels[,2], metriclabels[,1])


# normalize data (divison by max/(mean)):
d <- apply(data[, metricColnames], MARGIN=2, FUN = function(x) max(abs(x)))
normd <- t(apply(data[, metricColnames], MARGIN=1, FUN= function(x) x/d))
colnames(normd) <- metricColnames


fxlist <- list()
for (i in metricColnames) {
	print(i)
	fx <- shdoe::shdoe_analyse_effectSizes(normd[,i], dexp, 
			data[,paramcolnames], id = "DoE", confidence= 0.9)
	fx$response <- i
	fxlist <- append(fxlist, list(fx))
}
fx <- do.call(rbind, fxlist)

# extract single effects from first response var (whose row names are not numbered)
substitutions <- shdoe::shdoe_get_paramname_substitutions(simp, varnames = unique(rownames(fx))[!grepl(":",unique(rownames(fx))) & 
						!grepl("[0-9]", unique(rownames(fx)))], preventPlotmathParsing=TRUE)


if (nointeractioneffects) {
	indices <- !grepl(":", rownames(fx))
	effectdata <- setNames(fx$effects[indices], paste(rownames(fx)[indices], ":Effect", sep=""))
	substitutions <- c(substitutions, "Effect" = "Effect")
	simp$fig$height			<- 920
	simp$fig$width			<- 920
	filename 				<-  paste(rawfigurefilename, "NoInteraction", sep="_")
	numcol					<- 2
} else {
	indices <- rep(TRUE, length(rownames(fx)))
	effectdata <- setNames(fx$effects, rownames(fx))
	filename 				<-  paste(rawfigurefilename, "Interaction", sep="_")
	numcol					<-  3
}

shdoe::shdoe_visualise_interaction_effects(dexp = simp, 
		effects = effectdata, 
		errors = fx$errors[indices],
		pvalues = fx$pvalues[indices],
		response = fx$response[indices], 
		substitutions = substitutions, 
		filename = filename,
		ggplotaddons = list(ggplot2::theme(legend.position="bottom"),
				ggplot2::scale_colour_discrete(guide=ggplot2::guide_legend(ncol=numcol, title.position="top", 
								title.hjust=0),
						name = "Metrics", labels = metriclabels)
		)
)