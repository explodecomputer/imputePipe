#!/bin/bash

#PBS -N stitch
#PBS -t 1-23
#PBS -o job_reports/stitch-output
#PBS -e job_reports/stitch-error
#PBS -l walltime=12:00:00
#PBS -l nodes=1:ppn=8


set -e

if [ -n "${1}" ]; then
  SGE_TASK_ID=${1}
fi

chr=${SGE_TASK_ID}
wd=`pwd`"/"
source parameters.sh

cd ${impdatadir}

nsplit=`wc -l ${impdatadir}split${chr}.txt | awk '{print $1}'`

echo "${nsplit} CHUNKS"
echo "---------------------"
echo ""
echo ""

R --no-save --args split${chr}.txt stitch${chr}.txt ${targetdatadir}${chrdata}.bim ${plink} ${impdatadir}${chrdata} ${impdatadir}${plink1kg} < ${stitchplinkR}

gzip ${impdatadir}${plink1kg}_info.txt

# rm ${impdatadir}${chrdata}_*.bed ${impdatadir}${chrdata}_*.bim ${impdatadir}${chrdata}_*.fam ${impdatadir}${chrdata}_*.log



