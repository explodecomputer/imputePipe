#!/bin/bash

#PBS -N filter
#PBS -t 1-23
#PBS -o job_reports/filter-output
#PBS -e job_reports/filter-error
#PBS -l walltime=12:00:00
#PBS -l nodes=1:ppn=8

module add languages/R-3.0.2
set -e

cd ~/imputePipe

if [ -n "${1}" ]; then
  echo "${1}"
  PBS_ARRAYID=${1}
fi

chr=${PBS_ARRAYID}
wd=`pwd`"/"

source parameters.sh


# Filter based on maf and info thresholds

# gzip ${impdatadir}${plink1kg}_info.txt
zcat ${impdatadir}${plink1kg}_info.txt.gz | awk -v minmaf=${filterMAF} -v mininfo=${filterInfo} '{ if(NR == 1 || ($4 >= minmaf && $4 <= (1-minmaf) && $5 >= mininfo)) {print $0}}' | gzip -f > ${impdatadir}${filtername}_info.txt.gz

# Extract SNPs for plink to use
zcat ${impdatadir}${filtername}_info.txt.gz | tail -n +2 | cut -d " " -f 2 | uniq > ${impdatadir}${filtername}.keepsnps

${plink} --noweb --bfile ${impdatadir}${plink1kg} --extract ${impdatadir}${filtername}.keepsnps --make-bed --out ${impdatadir}${filtername}
