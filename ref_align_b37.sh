#!/bin/bash

#PBS -N sort
#PBS -t 1-23
#PBS -o job_reports/sort-output
#PBS -e job_reports/sort-error
#PBS -l walltime=12:00:00
#PBS -l nodes=1:ppn=3


# This script will take a binary plink file and:

# 1. extract chromosome to text file
# 2. align to reference

module add languages/R-3.0.2
set -e

cd /projects/Imputation_extension_ALSPAC/Data-Bris/imputePipe


if [[ -n "${1}" ]]; then
  echo ${1}
  SGE_TASK_ID=${1}
fi

chr=${SGE_TASK_ID}
wd=`pwd`"/"

source parameters.sh



if [ ! -d "${hapdatadir}" ]; then
  mkdir ${hapdatadir}
fi
if [ ! -d "${targetdatadir}" ]; then
  mkdir ${targetdatadir}
fi
if [ ! -d "${impdatadir}" ]; then
  mkdir ${impdatadir}
fi


cd ${targetdatadir}


# 1. extract chromosomes, perform cleaning and alignment to reference data




# extract chromosome 
${plink} --noweb --bfile ${originaldata} --chr ${chr} --make-bed --out ${chrdata}

# 3. Some SNP positions will match but SNP IDs will have changed
cp ${chrdata}.bim ${chrdata}.bim.orig-snp-ids
R --no-save --args ${chrdata}.bim ${reflegend} ${chrdata}.newpos < ${rs_updateR}

# find SNPs not present in reference, create new SNP order based on reference positions
# R --no-save --args ${chrdata}.bim ${reflegend} ${chrdata}.newpos < ${positionsR}
if [ -e ${chrdata}.newpos.missingsnps ]; then
	${plink} --noweb --bfile ${chrdata} --exclude ${chrdata}.newpos.missingsnps --make-bed --out ${chrdata}
fi

# update sample SNP orders and positions
${plink} --noweb --bfile ${chrdata} --update-map ${chrdata}.newpos --make-bed --out ${chrdata}
${plink} --noweb --bfile ${chrdata} --make-bed --out ${chrdata}


# add genetic distances to bim file

R --no-save --args ${chrdata}.bim ${refgmap} < ${genetdistR}
${plink} --noweb --bfile ${chrdata} --exclude ${chrdata}.bim.nogenet --make-bed --out ${chrdata}

