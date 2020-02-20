'''

Create Grid Engine scripts to run CRAFTY on a linux cluster.

Created on 08.03.2014
Latest update on 05/10/2015

@author: Sascha Holzhauer
'''

import sys, os, shutil, stat
import time
from optparse import OptionParser

workingDir = "./"
targetDir = "../"

numRunsPerBatch = 1

scenarioFile = "xml/baseline/Scenario.xml"
dataFolder   = "./data/"
outputDataFolder = "./output"

startTick   = 2000
endTick     = 2025

numRuns     = 1
runStart    = 0

numRandomSeeds = 1

numRunsPerBatch = 1
randomSeedStart = 0

scenario    = "Scenario"

clusterMode       = "ParallelTC"


parser = OptionParser(usage="usage: %prog [options]", version="%prog 1.1")

parser.add_option("-d", "--directory", dest="data", default=dataFolder,
                  help="Location of data directory (default: %default)", metavar="DATA DIRECTORY")

parser.add_option("-f", "--file", dest="filename", default = scenarioFile,
                  help="Location and name of scenario file relative to directory (default: %default)", metavar="FILE")

parser.add_option("-s", "--start", dest="startTick", default=startTick,
                  help="Start tick of simulation (default: %default)", metavar="START")

parser.add_option("-e", "--end", dest="endTick", default=endTick,
                  help="End tick of simulation (default: %default)", metavar="END")

parser.add_option("-n", "--runs", dest="numRuns", default=numRuns,
                  help="Number of runs with distinct configuration (default: %default)", metavar="NUM")

parser.add_option("-k", "--kickOff", dest="startRun", default=runStart,
                  help="Number of run to start with, starting with 0 (default: %default)", metavar="START")

parser.add_option("-r", "--randomVariations", dest="numOfRandVariation", default=numRandomSeeds,
                  help="Number of runs of each configuration with distinct random seed (default: %default)", metavar="NUM")

parser.add_option("-o", "--randomOffset", dest="offset", default=randomSeedStart,
                  help="Random seed offset (default: %default)", metavar="OFFSET")

parser.add_option("-b", "--batchSize", dest="numRunsPerBatch", default=numRunsPerBatch,
                  help="Number of runs per batch (default: %default)", metavar="NUM")

parser.add_option("-t", "--scenarioTitle", dest="scenarioName", default=scenario,
                  help="Name of the output folder (default: %default)", metavar="TITLE")

parser.add_option("-m", "--clusterMode", dest="clusterMode", default=clusterMode,
                  help="Cluster setting to apply - usually one of Serial/SerialTC/Parallel/ParallelTC (default: %default)", metavar="MODE")

parser.add_option("-i", "--integrateResultsFolder", dest="integrateResultsFolder", action="store_true", default=False,
                  help="If specified, the results are integrated into a potentially existing result folder. Use with care since an existing folder with the same runid would be overwritten (default: %default)")
(options, args) = parser.parse_args()

dataFolder      = options.data
scenarioFile    = options.filename

startTick       = int(options.startTick)
endTick         = int(options.endTick)
    
numRuns         = int(options.numRuns)
runStart        = int(options.startRun)
        
numRunsPerBatch = int(options.numRunsPerBatch)

numRandomSeeds  = int(options.numOfRandVariation)
randomSeedStart = int(options.offset)
        
scenario        = options.scenarioName
clusterMode     = options.clusterMode

# specify target file (without file ending
torqueScriptTemplate =  "Eddie_Crafty_" + clusterMode

SinglesTargetDir = "./" + scenario + "/"

print("Build scripts for scenario file ")
print(scenarioFile + " (ticks " + str(startTick) + "-" + str(endTick) + ")\n")

print("Run(s) from " + str(runStart) + " to " + str(runStart + numRuns - 1) + " with " + str(numRandomSeeds) + " random seed variation(s) and offset " +
        str(randomSeedStart) + " applying " + str(numRunsPerBatch) + " run(s) per invocation.")

if options.integrateResultsFolder:
    print("Integrate into existing output folder (if existing).")
    
if ((numRandomSeeds%numRunsPerBatch != 0) and (numRunsPerBatch % numRandomSeeds != 0)):
    print("The number of random seeds (" + str(numRandomSeeds) + ") must be a multiplicative of the number of runs per batch (" + str(numRunsPerBatch) + ") or vice verse!")
    exit()



if not os.path.exists("../" + SinglesTargetDir):
    os.makedirs("../" + SinglesTargetDir)

if not options.integrateResultsFolder:
    if os.path.exists("../" + outputDataFolder + "/" + scenario):
        timestr = time.strftime("%Y-%m-%d") # if day changes between executions of os.path.exists and os.rename and the next day already exists ;-) ...
        if os.path.exists("../" + outputDataFolder + "/" + scenario + "_" + time.strftime("%Y-%m-%d")):
            os.rename("../" + outputDataFolder + "/" + scenario, "../" + outputDataFolder + "/" + scenario + "_" + time.strftime("%Y-%m-%d_%H-%M"),)
        else:
            os.rename("../" + outputDataFolder + "/" + scenario, "../" + outputDataFolder + "/" + scenario + "_" + timestr,)    
    os.makedirs("../" + outputDataFolder + "/" + scenario)


qsubFilename = targetDir + "qsubScript_" + scenario.replace("/", "-") + "_" + str(startTick) +"-" + str(endTick) + "_" + str(runStart) + "_" + str(randomSeedStart)+ ".sh"
qsubScript = open(qsubFilename, "w")

qsubScript.write("#!/bin/bash\n")

runs = [None] * numRuns * numRandomSeeds
randomSeeds = [None] * numRuns * numRandomSeeds

for i in range(0, numRuns):
    for j in range(0, numRandomSeeds):
        runs[i*(numRandomSeeds) + j] = i + runStart
        randomSeeds[i*(numRandomSeeds) + j] = j + randomSeedStart
            
for k in range(0, numRuns * numRandomSeeds, numRunsPerBatch):
    print("Run " + str(k) + " (random seed: " + str(randomSeeds[k]) + ")")
    # adapt torque script:
    infile = open(workingDir + "resources/" + torqueScriptTemplate + ".sh", 'r')
    outFile = open("../" + SinglesTargetDir + torqueScriptTemplate +  "_" + str(runs[k]) + "-" + str(randomSeeds[k]) + ".sh", 'w')
    inputLine =  infile.readline()
    while inputLine != "":
        inputLine = inputLine.replace("%SCENARIO_FILE%", scenarioFile)
        inputLine = inputLine.replace("%DATA_FOLDER%", dataFolder)
        inputLine = inputLine.replace("%START_TICK%", str(startTick))
        inputLine = inputLine.replace("%END_TICK%", str(endTick))
        inputLine = inputLine.replace("%NUM_RUNS%", str(runs[k] + max(1, numRunsPerBatch/numRandomSeeds)))
        inputLine = inputLine.replace("%FIRST_RUN%", str(runs[k]))
        inputLine = inputLine.replace("%NUM_RANDOM_SEEDS%", str(numRandomSeeds) if numRunsPerBatch >= numRandomSeeds else str(numRunsPerBatch))
        inputLine = inputLine.replace("%RANDOM_SEED_OFFSET%", str(randomSeeds[k]))
        inputLine = inputLine.replace("%SCENARIO%", scenario)
        inputLine = inputLine.replace("%SCENARIONAME%", scenario.replace("/", "-"))
        outFile.write(inputLine)
        inputLine =  infile.readline()
    infile.close()
    outFile.close()
    qsubScript.write("mkdir -p ./output/" + scenario + "/" + str(runs[k]) + "-" + str(randomSeeds[k]) + "\n")
    qsubScript.write("qsub " + SinglesTargetDir  + torqueScriptTemplate +  "_" + str(runs[k]) + "-" + str(randomSeeds[k]) + ".sh\n")

qsubScript.close()

st = os.stat(qsubFilename)
os.chmod(qsubFilename, st.st_mode | stat.S_IEXEC)
    