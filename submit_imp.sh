#!/bin/bash

wd=`pwd`"/"
for chr in {1..23}
do
  source parameters.sh
  cd ${impdatadir}
  qsub submit_impute${chr}.sh
  cd ${wd}
done



