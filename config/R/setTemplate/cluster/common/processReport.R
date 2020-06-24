#######################################################################
# ApplicationScript for Creating PDF Reports of CRAFTY CoBRA ouptut
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
				help="Number of random seed to process, beginning with seed offset"))
opt	<- optparse::parse_args(optparse::OptionParser(option_list=option_list))


# Usually also in simp.R, but required here to find simp.R
simp$sim$folder 	<- "parentFolder/_version"	

simp$sim$task		<- paste(opt$firstrun, opt$seedoffset, sep="-") # Name of surounding folder, usually a description of task 

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
		# run = 280; rseed = 0
		
		preserve$run = run
		preserve$seed = rseed
		preserve$task <- paste(preserve$run, preserve$seed, sep="-")
		
		simp$sim$scenario				<- "A1"
		simp$sim$runids 	<- c(paste(run, rseed, sep="-"))			# run to deal with
		simp$sim$id			<- c(paste(run, rseed, sep="-"))
		
		#######################################################################
		futile.logger::flog.threshold(futile.logger::INFO, name='crafty')
		
		simp$sim$rundesclabel	<- "Runs"
		
		source("./createReport.R")
	}
}