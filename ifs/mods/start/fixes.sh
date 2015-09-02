#!/bin/bash


$DS_a/Dics/cnfg.sh updt_dicts &

if grep -o 'rplay' "$DC_s/1.cfg"; then rm "$DC_s/1.cfg"; fi

if [ ! -d "${DM_tls}/images" ]; then mkdir -p "${DM_tls}/images"; fi