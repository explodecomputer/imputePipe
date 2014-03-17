#!/bin/bash

#PBS -N imp
#PBS -t 1-22
#PBS -o job_reports/imp-output
#PBS -e job_reports/imp-error
#PBS -l walltime=12:00:00
#PBS -l nodes=1:ppn=1

# 1. vote on haplotypes
# 2. spawn imputation script
# - calculate the 5mb start and end positions
# - run imputation
# - convert output to binary plink format using gtool

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

if [ ! -d "${impdatadir}" ]; then
  mkdir ${impdatadir}
fi

if [ ! -d "${impdatadir}job_reports" ]; then
  mkdir ${impdatadir}job_reports
fi


# 1. Split chromosome into chunks
# Use 5mb regions from reference

R --no-save --args ${reflegend} ${interval} Distance ${maxgap} ${impdatadir}split${chr}.txt < ${splitrefR}


# 2. spawn imputation script
# - this will be broken up into windows
# - impute2 will be used for imputation
# - it uses 250kb overlaps automatically

nsplit=`wc -l ${impdatadir}split${chr}.txt | awk '{print $1}'`
echo "nsplit = ${nsplit}"

sub_imp="${impdatadir}submit_impute${chr}.sh"
cp ${imptemplate} ${sub_imp}

sed -i "s/NSPLIT/${nsplit}/g" ${sub_imp}
sed -i "s/SHORTNAME/${shortname}/g" ${sub_imp}
sed -i "s/CHR/${chr}/g" ${sub_imp}

chmod 755 ${sub_imp}