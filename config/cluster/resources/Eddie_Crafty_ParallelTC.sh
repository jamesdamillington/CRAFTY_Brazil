#!/bin/bash

# Job Name:
#$ -N CRAFTY_%SCENARIONAME%_%FIRST_RUN%-%RANDOM_SEED_OFFSET%

# Execute the job from the current working directory
#$ -cwd

# To run on TerraCorrelator:
#$ -P geos_tc_lurg
#$ -q ecdf@tc02

# Large memory environments:
##$ -pe memory-5G 3
##$ -pe memory-40G 8
#$ -pe tc-memory 16

# Number of nodes and cores per node
##$ -l nodes=1:ppn=1

# Requested total running time (?) (HH:MM:SS):
#$ -l h_rt=15:00:00

#$ -l h_vmem=63500M

# Name of output files:
#$ -o ./output/%SCENARIO%/%FIRST_RUN%-%RANDOM_SEED_OFFSET%/CRAFTY_%SCENARIONAME%_%FIRST_RUN%-%RANDOM_SEED_OFFSET%.out
#$ -e ./output/%SCENARIO%/%FIRST_RUN%-%RANDOM_SEED_OFFSET%/CRAFTY_%SCENARIONAME%_%FIRST_RUN%-%RANDOM_SEED_OFFSET%.err

# Send mail when job is aborted or terminates
#$ -m ae
#$ -M TEMPLATE@TEMPLATE.TEMPLATE

echo "####################################################"
echo "Job started on " `hostname` `date`
echo "Current working directory:" `pwd`
echo "####################################################"

. /etc/profile.d/modules.sh
module load java
module load openmpi-gcc
module load R/3.0.1

export LD_PRELOAD=$JAVA_HOME/jre/lib/amd64/libjsig.so
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/exports/work/geos_lurg/TEMPLATE/mpiJava/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/users/0022/TEMPLATE/R/R-3.0.0/library/rJava/jri

mkdir -p ./output/%SCENARIO%/%FIRST_RUN%-%RANDOM_SEED_OFFSET%

# Start des Jobs:
mpirun -np 16 -output-filename output/%SCENARIO%/%FIRST_RUN%-%RANDOM_SEED_OFFSET%/CRAFTY_%SCENARIONAME%_%FIRST_RUN%-%RANDOM_SEED_OFFSET% java -classpath ./config/log/ -Xmx55g -Dlog4j.configuration=./config/log/log4j_cluster.properties -jar CRAFTY-TEMPLATE.jar -f "%SCENARIO_FILE%" -d "%DATA_FOLDER%" -s %START_TICK% -e %END_TICK% -n %NUM_RUNS% -sr %FIRST_RUN% -r %NUM_RANDOM_SEEDS% -o %RANDOM_SEED_OFFSET%

echo "########## Start R Scripts...#######################"
./config/R/%SCENARIO%/cluster/%FIRST_RUN%-%RANDOM_SEED_OFFSET%/executeQsub.sh

echo "##########################################################"
echo "Job finished: " `date`
exit 0
