#!/bin/bash

#$ -N stitch
#$ -t 1-22
#$ -cwd
#$ -S /bin/bash
#$ -o job_reports/
#$ -e job_reports/
#$ -l h_vmem=50G

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

# rm ${impdatadir}${chrdata}_*.bed ${impdatadir}${chrdata}_*.bim ${impdatadir}${chrdata}_*.fam ${impdatadir}${chrdata}_*.log



