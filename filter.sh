#!/bin/bash

#$ -N filter
#$ -t 1-22
#$ -S /bin/bash
#$ -cwd
#$ -o job_reports/
#$ -e job_reports/
#$ -l mem_free=8G

# This script will take a binary plink file and:

# 1. extract chromosome to text file
# 2. align to reference

set -e

if [[ -n "${1}" ]]; then
  echo ${1}
  SGE_TASK_ID=${1}
fi

chr=${SGE_TASK_ID}
wd=`pwd`"/"

source parameters.sh

# Filter based on maf and info thresholds

zcat ${impdatadir}${plink1kg}_info.txt.gz | awk -v minmaf=${filterMAF} -v mininfo=${filterInfo} '{ if(NR == 1 || ($4 >= minmaf && $4 <= (1-minmaf) && $5 >= mininfo)) {print $0}}' | gzip > ${impdatadir}${filtername}_info.txt.gz

# Extract SNPs for plink to use
zcat ${impdatadir}${filtername}_info.txt.gz | tail -n +2 | cut -d " " -f 2 | uniq > ${impdatadir}${filtername}.keepsnps

${plink} --bfile ${impdatadir}${plink1kg} --extract ${impdatadir}${filtername}.keepsnps --make-bed --out ${impdatadir}${filtername}