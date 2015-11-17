#!/bin/bash

$DS_a/Dics/cnfg.sh updt_dicts &
if ! grep -o 'dlaud' "$DC_s/1.cfg">/dev/null 2>&1; then
    rm "$DC_s/1.cfg"
fi
