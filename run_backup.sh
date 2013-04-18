#!/bin/bash

for i in {1..22}
do
	./backup.sh ~/hpscratch/imputed_data/bsgs /fileserver/group/wrayvisscher/gib/imputed/bsgs bsgs_1kg_p1v3 twge_1kg_p1v3_ _polygenic BSGS ${i}
done
