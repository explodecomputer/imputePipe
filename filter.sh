#!/bin/bash

#$ -N filter
#$ -t 1,5
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

if [ -f ${impdatadir}${plink1kg}_info.txt ];
then
  gzip -f ${impdatadir}${plink1kg}_info.txt
fi

# Filter out the info file
R --no-save --args ${impdatadir}${plink1kg}_info.txt.gz ${impdatadir}${plink1kg}.bim ${impdatadir}${filtername}_info.txt < ${filterinfoR}

gzip -f ${impdatadir}${filtername}_info.txt

${plink} --noweb --bfile ${impdatadir}${plink1kg} --exclude ${impdatadir}${plink1kg}.bim.removesnps --make-bed --out ${impdatadir}${filtername}



