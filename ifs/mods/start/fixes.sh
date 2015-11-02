#!/bin/bash

$DS_a/Dics/cnfg.sh updt_dicts &
if ! grep -o 'dlaud' "$DC_s/1.cfg"; then rm "$DC_s/1.cfg"; fi
if [ ! -d "${DM_tls}/images" ]; then mkdir -p "${DM_tls}/images"; fi

if ls "${DM_tls}"/*.mp3 1> /dev/null 2>&1; then
    if [ ! -d "${DM_tls}/audio" ]; then
        mkdir "${DM_tls}/audio"
    fi
    mv -f "${DM_tls}"/*.mp3 "${DM_tls}/audio"/
fi
