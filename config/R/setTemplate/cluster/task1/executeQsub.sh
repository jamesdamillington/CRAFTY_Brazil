#!/bin/bash

export VERSIONDIR=TEMPLATE
export TASK=TASK

echo "Start R job in ${VERSIONDIR} for task ${TASK}..."

mkdir -p ./output/${VERSIONDIR}/${TASK}/R

python ./python/createQsubScript.py -t ${TASK} -v ${VERSIONDIR}

qsub ./config/R/${VERSIONDIR}/cluster/${TASK}/Eddie_R_TC.sh

echo "Done!"