#!/bin/bash

# Job Name:
#$ -N CRAFTY_Process_%TASK%

# Execute the job from the current working directory
#$ -cwd

# Requested total running time (?) (HH:MM:SS):
#$ -l h_rt=04:00:00

# To run on TerraCorrelator:
#$ -P geos_tc_lurg
#$ -q ecdf@tc02

# Large memory environments:
##$ -pe memory-5G 3
##$ -pe memory-40G 8
#$ -pe tc-memory 10

# Number of nodes and cores per node
##$ -l nodes=1:ppn=1

# RAM
##$ -l h_vmem=42000M
#$ -l h_vmem=6000M
##$ -l h_vmem=5200M
##$ -l h_vmem=63500M

# Name of output files:
#$ -o ./output/%VERSIONDIR%/%TASK%/R/R_Process_%TASK%.out
#$ -e ./output/%VERSIONDIR%/%TASK%/R/R_Process_%TASK%.out

# Send mail when job is aborted or terminates
#$ -m ae
#$ -M Sascha.Holzhauer@ed.ac.uk

echo "####################################################"
echo "Job started on " `hostname` `date`
echo "Current working directory:" `pwd`
echo "####################################################"

. /etc/profile.d/modules.sh
module load R/3.0.1


# Start des Jobs:
R --vanilla < ./config/R/%VERSIONDIR%/cluster/%TASK%/process.R
echo "##########################################################"
echo "Job finished: " `date`
exit 0
