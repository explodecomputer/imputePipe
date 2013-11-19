#!/usr/bin/env bash


plink="${wd}exe/plink"
hapi_ur="${wd}exe/hapi-ur"
impute2="${wd}exe/impute2"
liftOver="${wd}exe/liftOver"
vote_phase="${wd}exe/vote-phase"
bgl_to_ped="${wd}exe/bgl_to_ped"

positionsR="${wd}exe/positions.R"
modmarkersR="${wd}exe/modmarkers.R"
rs_updateR="${wd}exe/rs_update.R"
splitbimR="${wd}exe/splitbim.R"
genetdistR="${wd}exe/genetdist.R"
makeheaderR="${wd}exe/makeheader.R"
gprobs2beagle="${wd}exe/gprobs2beagle.jar"
imp2plink="${wd}exe/imp2plink.sh"
stitchplinkR="${wd}exe/stitchplink.R"
removedupsnpsR="${wd}exe/removedupsnps.R"
cleanupR="${wd}exe/cleanup.R"
filterinfoR="${wd}exe/filterinfo.R"

########################
# TO BE EDITED BY USER #
########################

targetdatadir="${wd}data/target/chr${chr}/"
hapdatadir="${wd}data/haplotypes/chr${chr}/"
impdatadir="${wd}data/imputed/chr${chr}/"
refdatadir="/ibscratch/wrayvisscher/gib/reference_data/1000_genomes/impute2/ALL_1000G_phase1integrated_v3_impute/"

# Reference data file locations
reflegend="${refdatadir}ALL_1000G_phase1integrated_v3_chr${chr}_impute.legend.gz"
refhaps="${refdatadir}ALL_1000G_phase1integrated_v3_chr${chr}_impute.hap.gz"
refgmap="${refdatadir}genetic_map_chr${chr}_combined_b37.txt"

# impute2 interval (default is 5Mb)
interval=5000000

# Target data information (after cleaning using strand_align.sh)
rawdata="${wd}data/target/dataname"
originaldata="${wd}data/target/dataname_flipped"
chrdata="DAT${chr}"
shortname="dat${chr}"
strand_file="${wd}data/target/strand/chipname.strand"

# LiftOver chain
lochain="${wd}exe/hg18ToHg19.over.chain"

# How many SNPs in the original data
nsnp=`wc -l ${originaldata}.bim | awk '{print $1}'`

# Output name
plink1kg="dataname_1kg_p1v3_${chr}"

# Filtering thresholds
filterMAF="0.01"
filterInfo="0.8"

# Filtering output name
filtername="${plink1kg}_maf${filterMAF}_info${filterInfo}"

