#!/bin/sh

# Job Name:
#$ -N CRAFTY_%SCENARIONAME%_%FIRST_RUN%-%RANDOM_SEED_OFFSET%

# Execute the job from the current working directory
#$ -cwd


# Requested total running time (?) (HH:MM:SS):
#$ -l h_rt=2:00:00

# Requested total memory:
#$ -l h_vmem=4G

# Name of output files:
#$ -o ./output/%SCENARIO%/%FIRST_RUN%-%RANDOM_SEED_OFFSET%/CRAFTY_%SCENARIONAME%_%FIRST_RUN%-%RANDOM_SEED_OFFSET%.out
#$ -e ./output/%SCENARIO%/%FIRST_RUN%-%RANDOM_SEED_OFFSET%/CRAFTY_%SCENARIONAME%_%FIRST_RUN%-%RANDOM_SEED_OFFSET%.err

# Send mail when job is aborted or terminates
#$ -m ae
#$ -M TEMPLATE@TEMPLATE

echo "####################################################"
echo "Job started on " `hostname` `date`
echo "Current working directory:" `pwd`
echo "####################################################"

. /etc/profile.d/modules.sh
module load java/jdk/1.8.0
module load openmpi/1.6.5
module load R/3.2.2
module load igmm/apps/texlive/2015

export LD_PRELOAD=$JAVA_HOME/jre/lib/amd64/libjsig.so
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/exports/csce/eddie/geos/groups/LURG/mpiJava/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/users/sholzhau/R/R-3.0.0/library/rJava/jri

mkdir -p ./output/%SCENARIO%/%FIRST_RUN%-%RANDOM_SEED_OFFSET%

echo "########## Start R Scripts...#######################"
Rscript ./config/R/%SCENARIO%/cluster/common/process.R "--firstrun=%FIRST_RUN%" "--numrun=%NUM_RUNS%" "--seedoffset=%RANDOM_SEED_OFFSET%" "--numrandomseeds=%NUM_RANDOM_SEEDS%" "--noreport"

echo "##########################################################"
echo "Job finished: " `date`
exit 0
