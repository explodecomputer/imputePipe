#!/bin/bash

wd=`pwd`"/"
for chr in {1..22}
do
  source parameters.sh
  cd ${impdatadir}
  qsub -p -100 submit_impute${chr}.sh
  cd ${wd}
done



