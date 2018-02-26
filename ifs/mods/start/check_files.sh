#!/bin/bash

echo -e "\n--- dicts..."
"$DS_a/Dics/cnfg.sh" updt_dicts
echo -e "--- dicts updated\n"

if [ ! -d "$DM_tls" ]; then
    mkdir -p "$DM_tls/audio"
    mkdir -p "$DM_tls/images"
    mkdir -p "$DM_tls/data"
fi

if [ ! -d "$DC" ]; then
    mkdir -p "$DC/addons"
fi

if [ ! -f "${cfg_db}" ]; then
    "$DS/ifs/tls.sh" create_cfg
fi

if [ -f "$DC_s/dics_first_run" ]; then
    "$DS_a/Dics/test.sh" 1
fi
