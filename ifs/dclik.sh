#!/bin/bash
DS=/usr/share/idiomind
d=($*)
q=$((${#d[@]}-1))
for i in $(seq 0 $q)
do
    cmd[$i]=${d[$i]}
done
cmd="${cmd[@]}"
"$DS/addons/$cmd/cnfg.sh"
