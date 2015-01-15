#!/bin/bash
DS=/usr/share/idiomind
DADOS=($*)
QTD=$((${#DADOS[@]}-1))
for i in $(seq 0 $QTD)
do
    CMD[$i]=${DADOS[$i]}
done
CMD="${CMD[@]}"
echo "$CMD"
"$DS/addons/$CMD/cnfg.sh"
