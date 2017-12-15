#!/bin/bash

echo -e "\n--- updating dicts..."
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

if [ ! -e "${cfg_db}" ]; then
	"$DS/ifs/tls.sh" create_cfg
fi

if [ "$(cdb "${cfgdb}" 1 opts clipw)" = 'TRUE' ]; then
	cdb "${cfgdb}" 3 opts clipw 'FALSE'
fi

