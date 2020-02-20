'''

Create qsub script with given parameters substituted in template.

Created on 11.09.2015

@author: Sascha Holzhauer
'''

from optparse import OptionParser

versiondir  = "./"
task        = "task"

templatefile    = "./python/resources/Eddie_R_TC_template.sh"
outputfile      = "Eddie_R_TC.sh"

parser = OptionParser(usage="usage: %prog [options]", version="%prog 1.1")

parser.add_option("-v", "--version-directory", dest="versiondir", default=versiondir,
                  help="Path segment from ./config/R/cluster/ to process.R (default: %default)", 
                  metavar="VERSION DIRECTORY")

parser.add_option("-t", "--task", dest="task", default=task,
                  help="Task name (default: %default)", 
                  metavar="TASK NAME")

parser.add_option("-f", "--template-file", dest="templatefile", default=templatefile,
                  help="Template file (default: %default)", 
                  metavar="TASK NAME")

(options, args) = parser.parse_args()

versiondir  = options.versiondir
task        = options.task
templatefile= options.templatefile

infile  = open(templatefile, 'r')
outFile = open("./config/R/" + versiondir + "/cluster/" + task + "/" + outputfile, 'w')
inputLine =  infile.readline()
while inputLine != "":
    inputLine = inputLine.replace("%VERSIONDIR%", versiondir)
    inputLine = inputLine.replace("%TASK%", task)
    outFile.write(inputLine)
    inputLine =  infile.readline()
infile.close()
outFile.close()