#!/bin/bash

#PBS -N stitch
#PBS -t 1-23
#PBS -o job_reports/stitch-output
#PBS -e job_reports/stitch-error
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

function check_cp {
	if [ ! -f ${2} ]; then
		cp ${1} ${2}
	fi
}


if [ ! -d "${backupdir}" ]; then
    mkdir ${backupdir}
fi

if [ ! -d "${backupdir}/haplotypes" ]; then
    mkdir ${backupdir}/haplotypes
fi

if [ ! -d "${backupdir}/chr${chr}" ]; then
    mkdir ${backupdir}/chr${chr}
fi

# First copy haplotypes
hap="${hapdatadir}${chrdata}.haps"
sample="${hapdatadir}${chrdata}.sample"

echo "Compressing ${hap}"
if [ -f ${hap} ]; then
	gzip -f ${hap}
fi

echo "Copying ${hap}"
check_cp ${hap}.gz ${backupdir}/haplotypes/${haplotypes}/${chrdata}.haps.gz
check_cp ${sample} ${backupdir}/haplotypes/${haplotypes}/${chrdata}.sample

# Next copy the imputed data
impname=${impdatadir}${plink1kg}

echo "Copying ${plink1kg}"
check_cp ${impname}.bed ${backupdir}/chr${chr}/${plink1kg}.bed
check_cp ${impname}.bim ${backupdir}/chr${chr}/${plink1kg}.bim
check_cp ${impname}.fam ${backupdir}/chr${chr}/${plink1kg}.fam
check_cp ${impname}.gz ${backupdir}/chr${chr}/${plink1kg}.gz
check_cp ${impname}_haps.gz ${backupdir}/chr${chr}/${plink1kg}_haps.gz
check_cp ${impname}_info.txt.gz ${backupdir}/chr${chr}/${plink1kg}_info.txt.gz

# Now copy the filtered data
fil=${impdatadir}${filtername}

echo "Copying ${fil}"
check_cp ${fil}.bed ${backupdir}/chr${chr}/${filtername}.bed
check_cp ${fil}.bim ${backupdir}/chr${chr}/${filtername}.bim
check_cp ${fil}.fam ${backupdir}/chr${chr}/${filtername}.fam
check_cp ${fil}_info.txt.gz ${backupdir}/chr${chr}/${filtername}_info.txt.gz

# ./backup.sh ~/ibimp/twge /fileserver/group/wrayvisscher/gib/imputed/twge twge_1kg_p1v3 twge_1kg_p1v3_ _polygenic TWGE 22