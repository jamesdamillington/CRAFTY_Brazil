source("/PATH-TO/simp-machine_cluster.R")

simp$sim$folder 	<- "parentFolder/_version"

setwd(paste(simp$dirs$simp, simp$sim$folder, "createbatch", sep="/"))
source("../simp.R")
simp$sim$parentf	<- "_setA"

simp$batchcreation$inputdatadir 		<- sprintf("%s/data/%s/", simp$dirs$project, simp$sim$folder)
simp$batchcreation$agentparam_tmpldir	<- paste(simp$dirs$project, "data", simp$sim$parentf, "agents/templates/", sep="/")
simp$batchcreation$production_tmpldir	<- paste(simp$dirs$project, "data", simp$sim$parentf, "production/defined/", sep="/")


simp$paramcreation$startrun <- 0

## adapt templates
## adapt parameters in scripts


## create basic configuration:
#source("./createAftMultifunctionalProductivityManual.R")
source("./createAftProductionCSV.R")
source("./createAftParamCSV.R")
source("./create1by1RunCSV.R")

## generate basic social network configurations using python script

## RUN initial run to generate network 

# for evaluation purposes:
#source("./createAftParamVariationMatrixCSV.R")