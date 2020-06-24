#######################################################################
# Parameter Creation Script (PSC) for AFT production template CSV files.
#
# Input:		Parameter meta definitions,
#				Mono/Multi-Productivities for each AFT andservice (dir defined)
#				Capital sensitiviteis per AFT (dir defined)
# Output:		<AFT>_mono/multi.csv files
#
# Project:		CRAFTY_ImpressionsEU
# Setting:		TEMPLATE
# Last update: 	08/09/2015
# Author: 		Sascha Holzhauer
#######################################################################


#######################################################################
# Input data
#######################################################################

sensis 		<- read.csv(paste(simp$batchcreation$production_tmpldir,
				simp$batchcreation$sensisfilename, sep=""), row.names=1)
monopro 	<- read.csv(paste(simp$batchcreation$production_tmpldir, 
				simp$batchcreation$monoprodfilename, sep=""), row.names=1)

if (!is.null(simp$batchcreation$multiprodfilename)) {
	multipro 	<- read.csv(paste(simp$batchcreation$production_tmpldir, 
					simp$batchcreation$multiprodfilename, sep=""), row.names=1)
} else {
	multipro 	<- NULL
}

prods		<- list("mono" = monopro, "multi" = multipro)

# Assignment of sensitivities for secondary services (of multifunction settings):
# says which AFT's sensitivities to apply for a specific service:
sensiAssignment2 <- c("Cereal" 			= "NC_Cereal",
					"Meat" 				= "NC_Livestock",
					"Recreation" 		= "VLI_Livestock",
					"Timber" 			= "Forester")

# Assignment of sensitivities for primary services (of multifunction settings):
sensiAssignment1 <- c("C_Cereal" 		= "Cereal",
					"C_Livestock"	 	= "Meat",
					"NC_Cereal" 		= "Cereal",
					"NC_Livestock"	 	= "Meat",
					"VLI_Livestock" 	= "Meat",
					"Forester" 			= "Timber")
			
#######################################################################
# File creation
#######################################################################

futile.logger::flog.info("Create AFT production template CSV files...",
		name = "template.create.aftparam")

afts <- simp$mdata$aftNames[!simp$mdata$aftNames %in% "Unmanaged"]

data <- data.frame()
for (aft in afts) {
	sh.ensurePath(paste(simp$batchcreation$inputdatadir, '/production/', aft, sep=""))
	for (multifunc in unique(simp$batchcreation$multifunctionality)) {
		#multifunc <- multifuncionality[1]
		#aft <- afts[6]
		
		data <- data.frame(matrix(rep(0.0, times = length(simp$mdata$services) * length(simp$mdata$capitals)), 
								nrow=length(simp$mdata$services), ncol=length(simp$mdata$capitals)))
		colnames(data) <- c(simp$mdata$capitals)
		rownames(data) <- simp$mdata$services
		
		data <- data.frame(data, "Production" = t(prods[[multifunc]][aft, simp$mdata$services]))
		colnames(data)[ncol(data)]	<- "Production"
		
		# assign sensitivities for secondary services 
		data[data$Production > 0, simp$mdata$capitals]	 <- sensis[sensiAssignment2[
						rownames(data)[data$Production > 0]],simp$mdata$capitals]
		
		# overwrite sensitivities for primary services
		data[sensiAssignment1[aft], simp$mdata$capitals]	 <- sensis[aft,simp$mdata$capitals]
		
		filename = paste(simp$batchcreation$inputdatadir, '/production/', aft, '/AftProduction_', aft,'_', multifunc, 
				'_medium', '.csv', sep='')
		cat(filename,'\n')
		write.csv(data, filename, row.names = TRUE)
	}
}