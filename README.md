imputePipe
==========

A pipeline to impute human SNP data to [1000 genomes][0] efficiently by parallelising across a compute cluster.

#### Summary

Provided here is simply a collection of scripts in `bash` and `R` that knit together a two stage imputation process:
 - Stage one uses [`hapi-ur`][1] to haplotype the **target** data
     - Williams AL, Patterson N, Glessner J, Hakonarson H, and Reich D. [Phasing of Many Thousands of Genotyped Samples][14]. American Journal of Human Genetics 2012 91(2) 238-251.
 - Stage two uses [`impute2`][2] to impute to the 1000 genomes **reference**
     - Howie BN, Donnelly P, and Marchini, J. [A Flexible and Accurate Genotype Imputation Method for the Next Generation of Genome-Wide Association Studies][15]. PLoS Genetics 2009 5(6):e1000529

It performs the following processes: 
 - Alignment of **target** data to **reference** data
 - Haplotyping
 - Imputing
 - Converting to best-guess genotypes
 - Filtering steps

Runtime is fast thanks to some great software that is freely available (see below). I typically have 400 or so cores available and for *e.g.* 1000 individuals this will complete in a few hours. Time complexity scales linearly.

#### Requirements

- A compute cluster using `SGE`
- Your genotype data (22 autosomes), QC'd, in [binary plink format][13], referred to as the **target** data set
- The downloads (including a **reference** data set) listed in the instructions below
- `R`, `awk`, `bash`, `git`, a text editor, *etc*


#### Outputs

- Haplotyped target and imputed data in `impute2` format
- Dosage imputed data in `impute2` format
- 'Best-guess' imputed data in binary `plink` format
- 'Best-guess' imputed data, filtered for MAF and imputation quality, in binary `plink` format



## Credits

Imputation is a big, slow, ugly, long-winded, hand-wavey, unpleasant process. In setting up this pipeline I have used plenty of scripts, programmes, and data found in various corners of the internet, and these have made the whole task much, much easier. Most of these resources have been used without permission from the original authors. If any of the authors are angry about this then let me know and I will take it down!

Here is a list of resources that I have used:

 - `hapi-ur` developed by [Amy Williams][1]
 - `impute2` developed by [Bryan Howie][2]
 - `plink` developed by [Shaun Purcell][8]
 - Parts of the `GermLine` software developed by [Itsik Pe'er][7]
 - Some of the `BEAGLE` utilities, written by [Brian and Sharon Browning][9]
 - `liftOver` developed at [UCSC][4]
 - Reference data hosted by the [developers][2] of `impute2`
 - Strand alignment data files, produced and hosted by [Will Rayner][3]
 - Strand alignment script developed by [Neil Robertson][3]
 - The `plyr` library in `R`, written by [Hadley Wickham][10]
 - Help and guidelines from the `MaCH` and `minimac` [Imputation Cookbook][11], developed by [Goncalo Abecasis][12]

The pipeline was developed by Gibran Hemani under the [Complex Trait Genomics Group][16] at the University of Queensland (Diamantina Institute and Queensland Brain Institute). Valuable help was provided by members of Peter Visscher's and Naomi Wray's group, and Paul Leo from Matt Brown's lab.

## Instructions

### 1. Gather all the data and scripts required.

 1. First Clone this repository
    
        git clone https://github.com/explodecomputer/imputePipe.git


 2. Then `cp` your raw data in binary plink format to `data/target`
 3. Download the strand alignment files for your data's chip from Will Rayner's [page][3] and unzip.
 4. Download the chain file for the SNP chip's build from [UCSC][4] (most likely you will need HG18 to HG19 which is included in this repo)
 5. Download and unarchive the [reference data][5] from the [impute2][1] website, *e.g.*

        wget http://mathgen.stats.ox.ac.uk/impute/ALL_1000G_phase1integrated_v3_impute.tgz
        tar xzvf ALL_1000G_phase1integrated_v3_impute.tgz


* * *


### 2. Customise the `parameter.sh` file

This file has all the options required for the imputation process. It should be fairly self explanatory, just change the file names and options that are listed in the section marked `To be edited by user`


* * *


### 3. Align the **target** to the **reference** data

This is a two step process. 

 1. First, convert all alleles to be on the forward strand:

        ./strand_align.sh

 2. Second, convert the map to hg19, update SNP names and positions, remove SNPs that are not present in the reference data, and split the data into separate chromosomes. By running
        
        qsub ref_align.sh

 the script will be submitted to `SGE` to execute on all chromosomes in parallel. Alternatively you can run

        ./ref_align.sh <chr>

 and the script will only work on chromosome `<chr>`.


#### Output

The output from this will be binary `plink` files for each chromosome located in the `data/target` directory.


* * *


### 4. Perform haplotyping

This uses [Amy Williams][6]' excellent haplotyping programme [`hapi-ur`][1]. We perform the haplotyping three times on each chromosome:

    qsub hap.sh

and then `vote` on the most common outcome at each position to make a final haplotype:

    qsub imp.sh

This also creates a new `SGE` submit script for each chromosome, where each chromosome has been split into 5Mb chunks with 250kb overlapping regions (these options can be amended in the `parameter.sh` file.

For both scripts the script can run on a specified chromosome in the front end by using

    ./hap.sh <chr>
    ./imp.sh <chr>

which might be useful for testing to see if it is working etc.

#### Output

The output from this will be three haplotype file sets for each chromosome, as well as a final, democratically elected (!) file set in `impute2` format, located in the `data/haplotypes` directory.


* * *


### 5. Imputation

Most likely the lengthiest and most memory demanding stage. By running

    ./submit_imp.sh

the scripts spawned for each in the last step will be submitted to `SGE`.

With large sample sizes *e.g.* >10k individuals, my cluster will occasionally kill a particular chunk. Should this happen it is safe to run the submit script in its entirety again at the end - it will not overwrite anything that is already completed, and only those chunks that are incomplete will continue running. 

This script will perform the imputation using `impute2`, and then convert the dosage output to best-guess genotypes in binary `plink` format.

Again, to test that it is working you can simply run the submit script in the front end for a particular chunk of the chromosome, *e.g.*

    cd data/imputed/chr22
    ./submit_imp.sh 4

will run the 4th 5Mb chunk of chromosome 22.


#### Output

The outputs from this script will be imputed dosages, haplotypes and best-guess genotypes in chromosomes broken into 5Mb chunks. These will be located in `data/imputed`.


* * *


### 6. Stitching the imputation chunks into whole chromosomes

This will stitch together the 5Mb chunks for each chromosome:

    qsub stitch_plink.sh

Again, a single chromosome can be executed in the frontend by running:

    ./stitch_plink.sh


#### Output

Imputed data for entire chromosomes in:
- Dosages (`impute2` format)
- Haplotypes (`impute2` format)
- Best-guess genotypes (binary `plink` format)
- `impute2` info files


* * *


### 7. Filtering

The final stage is to filter on MAF and quality. The thresholds can be amended in the `parameter.sh` file.

    qsub filter.sh

or

    ./filter.sh <chr>

#### Output

Best-guess genotypes (in binary `plink` format) for each chromosome.


## Disclaimer

This pipeline works for me. I use it regularly, and I thought it was a good idea to share it given that I am using so much stuff that has been shared by others.

I have never tried it on another cluster, and I imagine that some of the parameters will have to be customised for different cluster setups.

It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


[0]: http://1000genomes.org/
[1]: http://code.google.com/p/hapi-ur/
[2]: http://mathgen.stats.ox.ac.uk/impute/impute_v2.html
[3]: http://www.well.ox.ac.uk/~wrayner/strand/
[4]: http://hgdownload.cse.ucsc.edu/downloads.html#liftover
[5]: http://mathgen.stats.ox.ac.uk/impute/data_download_1000G_phase1_integrated.html
[6]: http://genepath.med.harvard.edu/~reich/Reich_People.htm
[7]: http://ron.cs.columbia.edu/drupal/software/Germline/Utility
[8]: http://pngu.mgh.harvard.edu/~purcell/plink/
[9]: http://faculty.washington.edu/browning/beagle_utilities/utilities.html
[10]: http://plyr.had.co.nz/
[11]: http://genome.sph.umich.edu/wiki/Minimac:_1000_Genomes_Imputation_Cookbook
[12]: http://genome.sph.umich.edu/wiki/Abecasis_Lab
[13]: http://pngu.mgh.harvard.edu/~purcell/plink/data.shtml#bed
[14]: http://www.cell.com/AJHG/abstract/S0002-9297%2812%2900322-9
[15]: http://www.plosgenetics.org/article/info%3Adoi%2F10.1371%2Fjournal.pgen.1000529
[16]: http://www.complextraitgenomics.com