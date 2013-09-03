#!/bin/bash

for i in {1..22}
do
	./backup.sh ~/ibimp/mnd /fileserver/group/wrayvisscher/gib/imputed/mnd mnd_1kg_p1v3 mnd_1kg_p1v3_ _maf0.01_info0.8_HWE1e-6 MND ${i}
done

