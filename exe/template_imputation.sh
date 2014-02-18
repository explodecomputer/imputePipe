#!/bin/bash
#PBS -N SHORTNAME
#PBS -o job_reports/imp
#PBS -e job_reports/imp
#PBS -t 1-NSPLIT
#PBS -l walltime=12:00:00
#PBS -l nodes=1:ppn:16

set -e

chr=CHR
cd ${impdatadir}

flag="backend"

if [ -n "${1}" ]; then
	echo "region = ${1}"
	flag="interactive"
	PBS_ARRAYID=${1}
fi

region=${PBS_ARRAYID}
hapout="${hapdatadir}${chrdata}"


# Need to create directory in scratch space
# Need to set output variables to point to scratch
# Copy large input files to scratch

if [ "${flag}" == "backend" ]; then

	touch ${impout}_${region}.backend

	JOBNO=`echo ${PBS_JOBID}_${PBS_ARRAYID} | sed s/.bluequeue1.cvos.cluster//`
	WORKDIR="/local/${PBS_O_LOGNAME}.${JOBNO}"
	mkdir ${WORKDIR}

	cd ${WORKDIR}
	
	# Input files
	cp ${impdatadir}split${chr}.txt .
	cp ${refgmap} refgmap
	refgmap="refgmap"
	cp ${refhaps} refhaps
	refhaps="refhaps"
	cp ${reflegend} reflegend
	reflegend="reflegend"
	cp ${hapout}.haps target.haps
	cp ${hapout}.sample target.sample
	hapout="target"	

	cp ${impout}_${region}* .
fi


# Get the region coordinates

first=`awk -v region=${region} \
'{if(NR == region) { print $2 } }' \
split${chr}.txt`

last=`awk -v region=${region} \
'{if(NR == region) { print $3 } }' \
split${chr}.txt`


# Do the imputation

if [[ ! -f "${chrdata}_${region}.gz" ]]; then

	${impute2} \
		-m ${refgmap} \
		-known_haps_g ${chrdata}.haps \
		-h ${refhaps} \
		-l ${reflegend} \
		-Ne 10000 \
		-k_hap 2000 \
		-int ${first} ${last} \
		-o ${chrdata}_${region} \
		#   -align_by_maf_g \
		-allow_large_regions \
		-verbose \
		-o_gz \
		-phase
fi


# Copy completed files back

if [ "${flag}" == "backend" ]; then
	cp ${chrdata}_${region}.gz ${impdatadir}
	cp ${chrdata}_${region}_haps.gz ${impdatadir}
	cp ${chrdata}_${region}_info.txt.gz ${impdatadir}
fi


# Convert impute2 format to binary plink format

if [[ ! -f "${impout}_${region}.bed" ]]; then

	${imp2plink} \
		${chrdata}_${region}.gz \
		${targetdatadir}${chrdata}.fam \
		${chrdata}_${region} \
		${chr} \
		${gprobs2beagle} \
		${bgl_to_ped} \
		${plink} \
		${makeheaderR}

	R --no-save --args ${chrdata}_${region} ${plink} < ${removedupsnpsR}

fi


# Copy completed files back

if [ "${flag}" == "backend" ]; then
	cp ${chrdata}_${region}.bed ${impdatadir}
	cp ${chrdata}_${region}.bim ${impdatadir}
	cp ${chrdata}_${region}.fam ${impdatadir}

	cd ${MYDIR}
	rm -fr $WORKDIR	
fi
