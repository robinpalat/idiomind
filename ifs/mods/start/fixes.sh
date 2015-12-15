#!/bin/bash

$DS_a/Dics/cnfg.sh updt_dicts &

if [ -d "$DC_s/s" ]; then
    mv "$DC_s/s"/* "$DC_s"/; rm -r "$DC_s/s"
fi

if ! grep -o 'dlaud' "$DC_s/1.cfg">/dev/null 2>&1; then
    rm "$DC_s/1.cfg"
fi
