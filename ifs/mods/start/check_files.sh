#!/bin/bash

echo -e "\n------------- updating dicts..."
"$DS_a/Dics/cnfg.sh" updt_dicts
echo -e "------------- dicts updated\n"

if [ ! -d "$DM_tls" ]; then
    mkdir -p "$DM_tls/audio"
    mkdir -p "$DM_tls/images"
    mkdir -p "$DM_tls/data"

fi
for n in {0..6}; do
    if [ ! -e "$DM_tls/${n}.cfg" ]; then
        touch "$DM_tls/${n}.cfg"
    fi
done

if [ ! -d "$DC" ]; then
    mkdir -p "$DC/addons"

fi
for n in {1..6}; do
    if [ ! -e "$DC/${n}.cfg" ]; then
        touch "$DC/${n}.cfg"
    fi
done
