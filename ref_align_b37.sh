#!/bin/bash

#$ -N sort
#$ -t 1-22
#$ -S /bin/bash
#$ -cwd
#$ -o job_reports/
#$ -e job_reports/
#$ -l h_vmem=8G

# This script will take a binary plink file and:

# 1. extract chromosome to text file
# 2. align to reference

set -e

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


exit

# 2. convert to eigenstrat format



# Create parameter file for convertf

# awk '{print $1, $2, $3, $4, $5, "0"}' ${chrdata}.fam > ${chrdata}.fam.mod

# echo "genotypename:    ${chrdata}.bed"     >  cp.txt
# echo "snpname:         ${chrdata}.bim"     >> cp.txt
# echo "indivname:       ${chrdata}.fam.mod" >> cp.txt
# echo "outputformat:    EIGENSTRAT"         >> cp.txt
# echo "genotypeoutname: ${chrdata}.geno"    >> cp.txt
# echo "snpoutname:      ${chrdata}.snp"     >> cp.txt
# echo "indivoutname:    ${chrdata}.ind"     >> cp.txt
# echo "familynames:     NO"                 >> cp.txt

# ${convertf} -p cp.txt




# 3. Run hapi-ur

wsize=`echo "36.62 + ${nsnp} * 0.00007" | bc`
echo "window size = ${wsize}"
if [ ${wsize} -lt 64 ]; then
  wsize=64
fi


hapout="${hapdatadir}/${chrdata}"
${hapi_ur} -b ${chrdata} -o ${hapout} -w ${wsize}




# 4. Create imputation script
# - split into 5Mb sections (or larger)



R --no-save --args ${interval} ${chrdata}.bim ${impdatadir}split${chr}.txt < ${splitbimR}


nsplit=`wc -l ${impdatadir}split${chr}.txt | awk '{print $1}'`
echo "nsplit = ${nsplit}"

exit


sub_imp="${impdatadir}/submit_impute${chr}.sh"

echo "#!/bin/bash"                         >  ${sub_imp}
echo "#$ -N ${shortname}"                  >> ${sub_imp}
echo "#$ -cwd"                             >> ${sub_imp}
echo "#$ -t 1-${nsplit}"                   >> ${sub_imp}
echo "#$ -S /bin/bash"                     >> ${sub_imp}
echo ""                                    >> ${sub_imp}
echo "chr=${chr}"                          >> ${sub_imp}
echo "wd=${impdatadir}"                    >> ${sub_imp}

echo "cd ${wd}"                            >> ${sub_imp}

echo "# SGE_TASK_ID=${1}"                  >> ${sub_imp}
echo "region=${SGE_TASK_ID}"               >> ${sub_imp}

echo "first=`awk -v region=${region} \
'{if(NR == region) { print $2 } }' \
split${chr}.txt`"                          >> ${sub_imp}

echo "last=`awk -v region=${region} \
'{if(NR == region) { print $3 } }' \
split${chr}.txt`"                          >> ${sub_imp}

cat ${impscript} >> ${sub_imp}

