#!/bin/bash

#PBS -N sort
#PBS -t 1-22
#PBS -o job_reports/sort-output
#PBS -e job_reports/sort-error
#PBS -l walltime=12:00:00
#PBS -l nodes=1:ppn=2

# This script will take a binary plink file and:

# 1. extract chromosome to text file
# 2. align to reference

set -e

if [[ -n "${1}" ]]; then
  echo ${1}
  PBS_ARRAYID=${1}
fi

chr=${PBS_ARRAYID}
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

# perform liftOver
# This will lead to new positions, some new SNP names (particularly HLA region of chr 6 from hg18 to hg19)
# First get new positions - then update the plink files
# Then read in the bim file and match SNP IDs to positions
# Then do the other alignment stuff.

awk '{ print "chr"$1, $4-1, $4, $2 }' ${chrdata}.bim > ${chrdata}.lo.orig
${liftOver} ${chrdata}.lo.orig ${lochain} ${chrdata}.lo.new ${chrdata}.lo.unmapped

# 1. remove unmapped SNPs
grep -v "#" ${chrdata}.lo.unmapped | cut -f 4 > ${chrdata}.lo.exclude
${plink} --noweb --bfile ${chrdata} --exclude ${chrdata}.lo.exclude --make-bed --out ${chrdata}

# 2. reposition SNPs
awk '{print $4, $3}' ${chrdata}.lo.new > ${chrdata}.lo.update-map
${plink} --noweb --bfile ${chrdata} --update-map ${chrdata}.lo.update-map --make-bed --out ${chrdata}
${plink} --noweb --bfile ${chrdata} --make-bed --out ${chrdata}

# 3. Some SNP positions will match but SNP IDs will have changed
cp ${chrdata}.bim ${chrdata}.bim.orig-snp-ids
R --no-save --args ${chrdata}.bim ${reflegend} ${chrdata}.newpos < ${rs_updateR}

# Remove duplicated SNPs
R --no-save --args ${chrdata} ${plink} < ${removedupsnpsR}

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

