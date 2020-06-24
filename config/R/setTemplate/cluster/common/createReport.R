require(knitr)
require(tools)
require(shbasic)

source(simp$simpDefinition)
source("../../simp.R")

futile.logger::flog.threshold(futile.logger::DEBUG, name='craftyr')

sh.ensurePath(paste(simp$dirs$simp, "/", simp$sim$folder, "/cluster/", preserve$task,"/", sep=""))
preserve$wd <- getwd()
setwd(paste(simp$dirs$simp, "/", simp$sim$folder, "/cluster/", preserve$task,"/", sep=""))
simp$sim$id 	<- c(paste(preserve$run, "-", preserve$seed, sep=""))

rnwFile =  paste(simp$dirs$simp, "/", simp$sim$folder, "/cluster/common/", "craftyr_report_", 
		"RUN", "-SEED.Rnw", sep="")

futile.logger::flog.debug("Knit %s", rnwFile,
		name = "craftyr.netsens.createreport")	
knit(input = rnwFile)


source(simp$simpDefinition)
source("../../simp.R")

futile.logger::flog.threshold(futile.logger::DEBUG, name='craftyr')


simp$sim$id 	<- c(paste(preserve$run, "-", preserve$seed, sep=""))
texFile =  paste(simp$dirs$simp, "/", simp$sim$folder, "/cluster/", preserve$task,"/", "craftyr_report_", 
		"RUN", "-SEED.tex", sep="")
file.rename(from=texFile, to=gsub("SEED", preserve$seed, gsub("RUN", preserve$run, texFile)))
texFile <- gsub("SEED", preserve$seed, gsub("RUN", preserve$run, texFile))

texi2dvi(file= texFile, pdf= TRUE, clean = FALSE)
texi2dvi(file= texFile, pdf= TRUE, clean = TRUE)

futile.logger::flog.debug("Copy to %s", simp$dirs$output$reports,
		name = "craftyr.netsens.createreport")
sh.ensurePath(simp$dirs$output$reports)
file.copy(from = paste(file_path_sans_ext(texFile), "pdf", sep="."), 
		to = simp$dirs$output$reports, overwrite = TRUE)

futile.logger::flog.debug("Remove %s",
		texFile,
		name = "craftyr.netsens.createreport")
file.remove(texFile)

futile.logger::flog.debug("Remove %s",
			paste(file_path_sans_ext(texFile), "aux", sep="."),
			name = "craftyr.netsens.createreport")
file.remove(paste(file_path_sans_ext(texFile), "aux", sep="."))

futile.logger::flog.debug("Remove %s",
		paste(file_path_sans_ext(texFile), "log", sep="."),
		name = "craftyr.netsens.createreport")
file.remove(paste(file_path_sans_ext(texFile), "log", sep="."))

futile.logger::flog.debug("Remove %s",
		paste(file_path_sans_ext(texFile), "out", sep="."),
		name = "craftyr.netsens.createreport")
file.remove(paste(file_path_sans_ext(texFile), "out", sep="."))

futile.logger::flog.debug("Remove %s",
		paste(file_path_sans_ext(texFile), "toc", sep="."),
		name = "craftyr.netsens.createreport")
file.remove(paste(file_path_sans_ext(texFile), "toc", sep="."))

futile.logger::flog.debug("Remove %s",
		paste(file_path_sans_ext(texFile), "pdf", sep="."),
		name = "craftyr.netsens.createreport")
file.remove(paste(file_path_sans_ext(texFile), "pdf", sep="."))

futile.logger::flog.debug("Remove %s",
		paste(file_path_sans_ext(texFile), "-1.cpt", sep="."),
		name = "craftyr.netsens.createreport")
file.remove(paste(file_path_sans_ext(texFile), "-1.cpt", sep=""))

outdir = texFile
futile.logger::flog.debug("Remove %s",
		paste(substr(outdir, 1, gregexpr(pattern ='/', 
								outdir)[[1]][length(gregexpr(pattern ='/', outdir)[[1]])]), "figure", sep="/"),
		name = "craftyr.netsens.createreport")
file.remove(list.files(full.names = TRUE, paste(substr(outdir, 1, gregexpr(pattern ='/', 
										outdir)[[1]][length(gregexpr(pattern ='/', outdir)[[1]])]), "figure", sep="/")))
# removing the folder does not work on windows!
unlink(paste(substr(outdir, 1, gregexpr(pattern ='/', 
								outdir)[[1]][length(gregexpr(pattern ='/', outdir)[[1]])]), "figure", sep="/"))
setwd(preserve$wd)