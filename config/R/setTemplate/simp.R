################################################################################
# Version specific SIMulation Properties:
#
# Project:		TEMPLATE
# Last update: 	02/09/2015
# Author: 		Sascha Holzhauer
################################################################################

# General SIMulation Properties ################################################

if (!exists("simp")) simp <- craftyr::param_getDefaultSimp()

simp$sim$version				<- "VERSION"
simp$sim$parentf				<- ""
simp$sim$folder					<- paste("_", simp$sim$version, sep="")
simp$sim$scenario				<- "A1"
simp$sim$regionalisation		<- "26"
simp$sim$regions				<- c("AT", "BE", "BG", "CZ", "DE", "DK", "EE", "EL", "ES",
									"FI", "FR", "HU", "IE", "IT", "LT", "LU", "LV", "MT", 
									"NL", "PL", "PT", "RO", "SE", "SI", "SK", "UK")
simp$sim$runids					<- c("0-0")
simp$sim$id 					<- "A1-0"


### Directories ################################################################
simp = shbasic::shbasic_adjust_outputfolders(simp, pattern = "%VFOLDER%", value = simp$sim$folder)

### Figure Settings ############################################################
simp$fig$resfactor		<- 3
simp$fig$outputformat 	<- "png"
simp$fig$init			<- craftyr::output_visualise_initFigure
simp$fig$numfigs		<- 1
simp$fig$numcols		<- 1
simp$fig$height			<- 1000
simp$fig$width			<- 1500
simp$fig$splitfigs		<- FALSE
simp$fig$facetlabelsize <- 14

### Batch Run Creation Settings #################################################
simp$batchcreation$scenarios				<- c("A1", "B1")
simp$batchcreation$startrun 				<- 0
simp$batchcreation$regionalisations			<- c("2")
simp$batchcreation$percentage_takeovers 	<- c(30) 
simp$batchcreation$competition 				<- "Competition_linear.xml"
simp$batchcreation$institutions				<- "institutions/Institutions_CapitalDynamics.xml"
simp$batchcreation$multifunctionality 		<- c("plain" = "mono", "complex"= "multi")
simp$batchcreation$allocation				<- c("BestProductionFirstGiveUpGiveInAllocationModel.xml")

simp$batchcreation$socialnetwork 			<- "SocialNetwork_HDFF.xml"
simp$batchcreation$searchabilities			<- c(30)
simp$batchcreation$inputdatadir 			<- sprintf("%s/data/%s", simp$dirs$project, simp$sim$folder)
simp$batchcreation$agentparam_tmpldir		<- paste(simp$batchcreation$inputdatadir, "/agents/templates/", sep="")
simp$batchcreation$gu_stages				<- c("medium")
simp$batchcreation$gi_stages				<- c("medium")
simp$batchcreation$placeholders				<- c(0)

simp$batchcreation$versiondirs$production	<- simp$sim$version
simp$batchcreation$versiondirs$competition	<- simp$sim$version
simp$batchcreation$versiondirs$allocation	<- simp$sim$version
simp$batchcreation$versiondirs$worldfile	<- simp$sim$version
simp$batchcreation$versiondirs$agentdef 	<- simp$sim$version
