#!/bin/bash

set -e

hostdir=${1}
destdir=${2}
impname=${3}
filtername1=${4}
filtername2=${5}
hapname=${6}
chr=${7}

i=${chr}


function check_cp {
	if [ ! -f ${2} ]; then
		cp ${1} ${2}
	fi
}


if [ ! -d "${destdir}" ]; then
    mkdir ${destdir}
fi

if [ ! -d "${destdir}/haplotypes" ]; then
    mkdir ${destdir}/haplotypes
fi

if [ ! -d "${destdir}/chr${i}" ]; then
    mkdir ${destdir}/chr${i}
fi

# First copy haplotypes
hap=${hostdir}/data/haplotypes/chr${i}/${hapname}${i}.haps
sample=${hostdir}/data/haplotypes/chr${i}/${hapname}${i}.sample

echo "Compressing ${hap}"
if [ -f ${hap} ]; then
	gzip -f ${hap}
fi

echo "Copying ${hap}"
check_cp ${hap}.gz ${destdir}/haplotypes/${haplotypes}/${hapname}${i}.haps.gz
check_cp ${sample} ${destdir}/haplotypes/${haplotypes}/${hapname}${i}.sample

# Next copy the imputed data
imp=${hostdir}/data/imputed/chr${i}/${impname}_${i}

echo "Copying ${imp}"
check_cp ${imp}.bed ${destdir}/chr${i}/${impname}_${i}.bed
check_cp ${imp}.bim ${destdir}/chr${i}/${impname}_${i}.bim
check_cp ${imp}.fam ${destdir}/chr${i}/${impname}_${i}.fam
check_cp ${imp}.gz ${destdir}/chr${i}/${impname}_${i}.gz
check_cp ${imp}_haps.gz ${destdir}/chr${i}/${impname}_${i}_haps.gz
check_cp ${imp}_info.txt.gz ${destdir}/chr${i}/${impname}_${i}_info.txt.gz

# ./backup.sh ~/ibimp/twge /fileserver/group/wrayvisscher/gib/imputed/twge twge_1kg_p1v3 twge_1kg_p1v3_ _polygenic TWGE 22
