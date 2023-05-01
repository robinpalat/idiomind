#!/bin/bash


d=($*)
q=$((${#d[@]}-1))
for i in $(seq 0 $q); do
    cmd[$i]=${d[$i]}
done
cmd="${cmd[@]}"
../addons/"$cmd"/cnfg.sh
