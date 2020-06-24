#######################################################################
# Prameter Creation Script (PSC) for AFT parameter CSV files.
#
# Input:		Parameter meta definitions
# Output:		AftParams_<AFT>.csv files
#
# Project:		TEMPLATE
# Setting:		TEMPLATE
# Last update: 	02/09/2015
# Author: 		Sascha Holzhauer
#######################################################################


#######################################################################
# Factors for variations
#######################################################################

params <- c('givingIn',	'givingInDistributionMean',	'givingInDistributionSD', 'givingUp',
		'givingUpDistributionMean', 'givingUpDistributionSD', 'serviceLevelNoiseMin', 'serviceLevelNoiseMax')

capitalSensitivity <- "medium"

giStages <- c("medium")
guStages <- c("medium")


########### GU alteration factors #######################################
factorMatrix <- matrix(rep(1.0, times=length(simp$mdata$aftNames)*length(params)), ncol=length(params))
colnames(factorMatrix) <- params
rownames(factorMatrix) <- simp$mdata$aftNames

# GI and GU need do be defined separated because of cross variations:
paramFactorsGi <- list()
paramFactorsGi[["medium"]] <- factorMatrix
paramFactorsGi[["low"]] <- factorMatrix
paramFactorsGi[["low"]][,"givingIn"] <- 0.8
paramFactorsGi[["low"]][,"givingInDistributionMean"] <- 0.8
paramFactorsGi[["high"]] <- factorMatrix
paramFactorsGi[["high"]][,"givingIn"] <- 1.2
paramFactorsGi[["high"]][,"givingInDistributionMean"] <- 1.2

paramFactorsGu <- list()
paramFactorsGu[["medium"]] <- factorMatrix
paramFactorsGu[["low"]] <- factorMatrix
paramFactorsGu[["low"]][,"givingUp"] <- 0.8
paramFactorsGu[["low"]][,"givingUpDistributionMean"] <- 0.8
paramFactorsGu[["high"]] <- factorMatrix
paramFactorsGu[["high"]][,"givingUp"] <- 1.2
paramFactorsGu[["high"]][,"givingUpDistributionMean"] <- 1.2


aftFactorsLow <- c('C_Cereal' 	= 1, 
		'NC_Cereal' 			= 1,
		'C_Livestock' 			= 1,
		'NC_Livestock'			= 1,
		'Forester'				= 1,
		'Conservationist' 		= 1)

aftFactorsHigh <- c('C_Cereal' 	= 1, 
		'NC_Cereal' 			= 1,
		'C_Livestock' 			= 1,
		'NC_Livestock'			= 1,
		'Forester'				= 1,
		'Conservationist' 		= 1)

#######################################################################
# File creation
#######################################################################

###### Load Template
tData <- read.csv(paste(simp$batchcreation$agentparam_tmpldir, "AFT.csv", sep=""))

# uncomment for testing purposes:
# aft = afts[1]
# capSense = capitalSensitivity[1]
# scenario = scenarios[1]
# multifunc = multifuncionality[1]
# giStage = giStages[1]
# guStage = guStages[1]


adaptG <- function(factor, aft) {
	if(factor < 1) {
		factor = factor * aftFactorsLow[[aft]]
	} else {
		if(factor > 1) {
			factor = factor * aftFactorsHigh[[aft]]
		} else factor = 1
	}
	factor
}

afts <- simp$mdata$aftNames[!simp$mdata$aftNames %in% "Unmanaged"]

for (aft in afts) {
	data <- data.frame(stringsAsFactors=FALSE)
	aftParamId = -1
	for (scenario in simp$batchcreation$scenarios) {
		for (mode in simp$batchcreation$modes) {
			for (giStage in giStages) {
				for (guStage in guStages) {	
					aftParamId = aftParamId + 1
		
					d <- c()
					d["aftParamId"] <- aftParamId
					
					giFactor <- paramFactorsGi[[giStage]][aft,]
					giFactor <- unlist(lapply(giFactor, adaptG, aft))
					guFactor <- paramFactorsGu[[guStage]][aft,]
					guFactor <- unlist(lapply(guFactor, adaptG, aft))
					
					d <- c(d,tData[tData$Scenario == scenario & tData$AFT == aft,c(-1,-2)] * giFactor * guFactor)
			
					d["productionCsvFile"] <- paste(simp$batchcreation$versiondirs$production, 
							"/production/", aft, "/AftProduction_", aft, "_", simp$batchcreation$multifunctionality[mode], "_", 
							capitalSensitivity, ".csv", sep="")
					
					data <- rbind(data, as.data.frame(d, stringsAsFactors=FALSE))
				}
			}
		}
	}	
	filename = paste(simp$batchcreation$inputdatadir, '/worlds/', simp$sim$worldname,
			'/AftParams_', aft, '.csv', sep='')
	
	futile.logger::flog.info("Write AFT param file %s...",
				filename,
				name = "template.create.aftparam")
		
	shbasic::sh.ensurePath(filename, stripFilename = TRUE)
	write.csv(data, filename, row.names = FALSE)
}