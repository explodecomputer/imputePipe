#!/bin/bash


# looks like beagle and impute2 have very similar imputation outputs.
# adapt beagle conversion script for impute2

set -e

gprobs=${1}
famfile=${2}
plinkfile=${3}
chr=${4}

gprobs2beagle=${5}
bgl_to_ped=${6}
plink=${7}
makeheaderR=${8}


missing="?"
threshold="0.2"

beagleout="${gprobs}.bgl"


# rootdir="/clusterdata/uqgheman/hpscratch/imputed_data/aric/seattle/"
# gprobs=${rootdir}"imputed/combined/ARIC_EurAm_chr${chr}.gprobs.gz"
# genfile=${rootdir}"genfiles/ARIC_EurAm_chr${chr}.sample"
# beagleout=${rootdir}"convert/ARIC_Eur_Am_chr${chr}.bgl"
# plinkfile=${rootdir}"convert/ARIC_Eur_Am_chr${chr}"

# gprobs2beagle=${rootdir}"convert/gprobs2beagle.jar"
# bgl_to_ped=${rootdir}"convert/bgl_to_ped"
# plink="/clusterdata/uqgheman/hpscratch/exe/plink/plink"
# makeheaderR=${rootdir}"convert/makeheader.R"

echo "make first line of gprobs file"
R --no-save --args ${famfile} ${gprobs}.tempheader < ${makeheaderR}

echo "sanitising allele codes"
zcat ${gprobs} | awk '{ if (length($4) != 1 || length($5) != 1) { printf "%s %s %s %s %s ",$1,$2,$3,"Y","Z" } else { printf "%s %s %s %s %s ", $1,$2,$3,$4,$5 } { s = ""; for (i = 6; i <= NF; i++) s = s $i " "; print s }}' | gzip > ${gprobs}2


echo "converting using gprobs2beagle"
zcat ${gprobs}2 | cut -d " " -f 2,4- > ${gprobs}.temp
cat ${gprobs}.tempheader ${gprobs}.temp | java -jar ${gprobs2beagle} ${threshold} ${missing} > ${beagleout}
rm ${gprobs}.temp ${gprobs}.tempheader

echo "making fam file"

cp ${famfile} ${plinkfile}.tfam

#awk '{ if ( NR > 2 ) { print $1, "0", "0", $4, $5 } }' ${genfile} > ${plinkfile}.tfam.temp
#tr '_' ' ' < ${plinkfile}.tfam.temp > ${plinkfile}.tfam
#rm ${plinkfile}.tfam.temp

echo "converting bgl to tped"
# ${bgl_to_ped} ${beagleout} ${plinkfile}.fam 0 > ${plinkfile}.ped
zcat ${gprobs}2 | awk -v chr=$chr '{print chr, $2, "0", $3}' > ${plinkfile}.map
sed 1d ${beagleout} | cut -d " " -f 3- > ${gprobs}.temp.tped
paste -d " " ${plinkfile}.map ${gprobs}.temp.tped > ${plinkfile}.tped


${plink} --noweb --tfile ${plinkfile} --make-bed --out ${plinkfile}

rm ${beagleout} ${gprobs}.temp.tped ${plinkfile}.tped ${plinkfile}.map ${plinkfile}.tfam ${gprobs}2
