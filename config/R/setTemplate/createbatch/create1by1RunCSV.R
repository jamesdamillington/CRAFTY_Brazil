#######################################################################
# Prameter Creation Script (PSC) for Runs parameter CSV file.
# Enables switching on/off variations per parameter.
#
# Input:		Parameter meta definitions
# Output:		Runs.csv
#
# Project:		TEMPLATE
# Setting:		TEMPLATE
# Last update: 	02/09/2015
# Author: 		Sascha Holzhauer
#######################################################################


run = simp$paramcreation$startrun - 1
aftParamId = 0
aftParamIdScenario = -1

d <- data.frame(stringsAsFactors=FALSE)                             # number of variations
for (percentageTakeOvers in simp$batchcreation$percentage_takeovers) {
	for (searchability in simp$batchcreation$searchabilities) {
		for (scenario in simp$batchcreation$scenarios) {  										#4
			for (regionalisation in simp$batchcreation$regionalisations) { 		#1-3		
				aftParamId = aftParamIdScenario
				for (mode in simp$batchcreation$modes) {			
					for (giStage in simp$batchcreation$gi_stages) {
						for (guStage in simp$batchcreation$gu_stages) {
							aftParamId = aftParamId + 1
							for (place in simp$batchcreation$placeholders) {			
								run = run + 1		
								data <- list()
								
			data["run"] 			<- run
			data["Scenario"] 		<- scenario
			data["Version"] 		<- simp$sim$version
			data["World"] 			<- simp$sim$worldname
			data["Regionalisation"] <- regionalisation
			
			data["aftParamId"] 		<- aftParamId
			data["RegionCsvFile"] 	<- paste("/", simp$batchcreation$versiondirs$worldfile, "/worlds/",
					simp$sim$worldname, "/regionalisations/", regionalisation, ".csv", sep="")
			
			data["FR_xml"] 		<- paste("/", simp$batchcreation$versiondirs$agentdef, "/agents/FunctionalRoles_", 
					simp$batchcreation$variationstages[mode], ".xml", sep="")
			
			data["Competition_xml"] <- paste("/", simp$batchcreation$versiondirs$competition, "/competition/", 
					simp$batchcreation$competitions[mode], sep="")
			
			data["Allocation_xml"]  <- paste("/", simp$batchcreation$versiondirs$allocation, "/allocation/",
					simp$batchcreation$allocation, sep="")
			
			data["Allocation_percentageCell"] 		<- searchability
			data["Allocation_percentageTakeovers"] 	<- percentageTakeOvers
			
			data["Insititutions_xml"] 				<- simp$batchcreation$institutions[mode]	
			data["SocialNetwork_xml"] 				<- simp$batchcreation$socialnetwork
			
			d <- rbind(d, as.data.frame(data, stringsAsFactors=FALSE))
							}
						}
					}
				}
			}
		}
	}
	aftParamIdScenario = -1
}

filename = paste(simp$batchcreation$inputdatadir , '/Runs.csv', sep='')
shbasic::sh.ensurePath(filename, stripFilename = TRUE)
futile.logger::flog.info("Write Run.csv file %s...",
		filename,
		name = "template.create.runsparam")
write.csv(d, filename, row.names = FALSE)
