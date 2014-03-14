#!/bin/bash

#PBS -N hap
#PBS -t 1-23
#PBS -o job_reports/hap-output
#PBS -e job_reports/hap-error
#PBS -l walltime=12:00:00
#PBS -l nodes=1:ppn=16

# This script will take a reference-aligned binary plink file and:
# 1. For each chromosome perform hapi-ur haplotyping 3 times

set -e

cd ~/imputePipe


if [ -n "${1}" ]; then
  PBS_ARRAYID=${1}
fi

echo "Running on host: ${HOSTNAME}"

chr=${PBS_ARRAYID}
wd=`pwd`"/"


source parameters.sh

if [ ! -d "${hapdatadir}" ]; then
  mkdir ${hapdatadir}
fi
if [ ! -d "${impdatadir}" ]; then
  mkdir ${impdatadir}
fi

cd ${targetdatadir}

flags="--thread 16 --noped"
if [ "${chr}" -eq "23" ]; then
	flags="$flags --chrX"
fi

hapout="${hapdatadir}${chrdata}"
${shapeit2} --input-bed ${chrdata}.bed ${chrdata}.bim ${chrdata}.fam --input-map ${chrmap} --output-max ${hapout}.haps ${hapout}.sample ${flags}

