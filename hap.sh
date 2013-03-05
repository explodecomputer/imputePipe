#!/bin/bash

#$ -N hap
#$ -t 1
#$ -S /bin/bash
#$ -cwd
#$ -o job_reports/
#$ -e job_reports/
#$ -l vf=8G

# This script will take a reference-aligned binary plink file and:
# 1. For each chromosome perform hapi-ur haplotyping 3 times



nrep="3"
nchr="22"

if [ -n "${1}" ]; then
  SGE_TASK_ID=${1}
fi


SGE_TASK_ID=`expr ${SGE_TASK_ID} - 1`

chr=`expr ${SGE_TASK_ID} % ${nchr} + 1`
rep=`expr ${SGE_TASK_ID} % ${nrep} + 1`

set -e

echo "chr = ${chr}"
echo "rep = ${rep}"

wd=`pwd`"/"

source parameters.sh

cd ${targetdatadir}


wsize=`echo "36.62 + ${nsnp} * 0.00007" | bc -l | xargs printf "%1.0f"`
echo "window size = ${wsize}"
if [ ${wsize} -lt 64 ]; then
  wsize=64
fi


hapout="${hapdatadir}${chrdata}_${rep}"
${hapi_ur} -p ${chrdata} -o ${hapout} -w ${wsize} --impute2

