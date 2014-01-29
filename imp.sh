#!/bin/bash

#PBS -N imp
#PBS -t 1-22
#PBS -o job_reports/imp-output
#PBS -e job_reports/imp-error
#PBS -l walltime=12:00:00
#PBS -l nodes=1:ppn=3

# 1. vote on haplotypes
# 2. spawn imputation script
# - calculate the 5mb start and end positions
# - run imputation
# - convert output to binary plink format using gtool

set -e

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

# 1. haplotype voting



hapout="${hapdatadir}${chrdata}"
${vote_phase} -i ${hapout}_1.haps ${hapout}_2.haps ${hapout}_3.haps > ${hapout}.haps
cp ${hapout}_1.sample ${hapout}.sample


# 2. spawn imputation script
# - this will be broken up into windows
# - impute2 will be used for imputation
# - it uses 250kb overlaps automatically

maxbp=`zcat ${reflegend} | tail -n 1 | cut -d " " -f 2`

R --no-save --args ${interval} ${maxbp} ${impdatadir}split${chr}.txt < ${splitbimR}


nsplit=`wc -l ${impdatadir}split${chr}.txt | awk '{print $1}'`
echo "nsplit = ${nsplit}"

impout="${impdatadir}${chrdata}"

sub_imp="${impdatadir}submit_impute${chr}.sh"

echo "#!/bin/bash"                          >  ${sub_imp}
echo "#PBS -N ${shortname}"                 >> ${sub_imp}
echo "#PBS -o ${impdatadir}job_reports/imp" >> ${sub_imp}
echo "#PBS -e ${impdatadir}job_reports/imp" >> ${sub_imp}
echo "#PBS -t 1-${nsplit}"                  >> ${sub_imp}
echo "#PBS -l walltime=12:00:00"            >> ${sub_imp}
echo "#PBS -l nodes=1:ppn:16"               >> ${sub_imp}

echo ""                                     >> ${sub_imp}

echo "set -e"                               >> ${sub_imp}

echo ""                                     >> ${sub_imp}

echo "chr=${chr}"                           >> ${sub_imp}

echo ""                                     >> ${sub_imp}

echo "cd ${impdatadir}"                     >> ${sub_imp}

echo ""                                     >> ${sub_imp}


echo "if [ -n \"\${1}\" ]; then"            >> ${sub_imp}
echo "  echo \"region = \${1}\""            >> ${sub_imp}
echo "  PBS_ARRAYID=\${1}"                  >> ${sub_imp}
echo "fi"                                   >> ${sub_imp}

echo ""                                     >> ${sub_imp}

echo "region=\${PBS_ARRAYID}"               >> ${sub_imp}

echo ""                                     >> ${sub_imp}

echo "first=\`awk -v region=\${region} \
'{if(NR == region) { print \$2 } }' \
split\${chr}.txt\`"                         >> ${sub_imp}

echo ""                                     >> ${sub_imp}

echo "last=\`awk -v region=\${region} \
'{if(NR == region) { print \$3 } }' \
split\${chr}.txt\`"                         >> ${sub_imp}

echo ""                                     >> ${sub_imp}

echo "if [[ ! -f \"${impout}_\${region}.gz\" ]]; then" >> ${sub_imp}

echo "  ${impute2} \\"                      >> ${sub_imp}
echo "    -m ${refgmap} \\"                 >> ${sub_imp}
echo "    -known_haps_g ${hapout}.haps \\"  >> ${sub_imp}
echo "    -h ${refhaps} \\"                 >> ${sub_imp}
echo "    -l ${reflegend} \\"               >> ${sub_imp}
echo "    -Ne 10000 \\"                     >> ${sub_imp}
echo "    -k_hap 2000 \\"                   >> ${sub_imp}
echo "    -int \${first} \${last} \\"       >> ${sub_imp}
echo "    -o ${impout}_\${region} \\"       >> ${sub_imp}
#echo "   -align_by_maf_g \\"               >> ${sub_imp}
echo "    -allow_large_regions \\"          >> ${sub_imp}
echo "    -verbose \\"                      >> ${sub_imp}
echo "    -o_gz \\"                         >> ${sub_imp}
echo "    -phase"                           >> ${sub_imp}

echo "fi"                                   >> ${sub_imp}

echo ""                                     >> ${sub_imp}

echo "if [[ ! -f \"${impout}_\${region}.gz\" ]]; then" >> ${sub_imp}
echo "  touch ${impout}_\${region}.empty"   >> ${sub_imp}
echo "fi"                                   >> ${sub_imp}

echo ""                                     >> ${sub_imp}

# make the sample file
# gprobs format is the same as impute2
# convert using convert.sh in aric

echo "if [[ ! -f \"${impout}_\${region}.bed\" ]]; then" >> ${sub_imp}

echo "  ${imp2plink} \\"                    >> ${sub_imp}
echo "    ${impout}_\${region}.gz \\"       >> ${sub_imp}
echo "    ${targetdatadir}${chrdata}.fam \\" >> ${sub_imp}
echo "    ${impout}_\${region} \\"          >> ${sub_imp}
echo "    \${chr} \\"                       >> ${sub_imp}
echo "    ${gprobs2beagle} \\"              >> ${sub_imp}
echo "    ${bgl_to_ped} \\"                 >> ${sub_imp}
echo "    ${plink} \\"                      >> ${sub_imp}
echo "    ${makeheaderR}"                   >> ${sub_imp}

echo "fi"                                   >> ${sub_imp}

echo ""                                     >> ${sub_imp}

echo "R --no-save --args ${impout}_\${region} ${plink} < ${removedupsnpsR}" >> ${sub_imp}


chmod 755 ${sub_imp}

