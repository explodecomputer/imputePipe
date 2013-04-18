#!/bin/bash

#$ -t 1-22
#$ -S /bin/bash
#$ -cwd
#$ -o job_reports/
#$ -e job_reports/
#$ -l vf=20G

set -e

if [ -n "${1}" ]; then
  echo "${1}"
  SGE_TASK_ID=${1}
fi

chr=${SGE_TASK_ID}

rootname="phase1_release_v3.20101123.snps_indels_svs.genotypes.refpanel.EUR.vcf.gz"

vcftools="/clusterdata/uqgheman/hpscratch/exe/vcftools/bin/vcftools"
plink="/clusterdata/uqgheman/hpscratch/exe/plink/plink"
maf=0.05
vcf="chr${chr}.${rootname}"
outname="1kg_eur_maf0.05_${chr}"

zcat ${vcf} | tail -n +29 | cut -f 1-5 > codes_${chr}
R --no-save --args codes_${chr} < keepsnps.R

${vcftools} --gzvcf ${vcf} --plink --maf ${maf} --out ${outname} --positions codes_${chr}_keep
${plink} --noweb --file ${outname} --make-bed --out ${outname}
