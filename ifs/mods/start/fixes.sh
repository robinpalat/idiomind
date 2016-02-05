#!/bin/bash

$DS_a/Dics/cnfg.sh updt_dicts &


if [ ! -d "$DM_tl/.share/data" ]; then
    mv -f "$DM_tl/.share/Dictionary" "$DM_tl/.share/data"
    [ -d "$DM_tl/.share/data" ] && rm -r "$DM_tl/.share/data/.conf"
    for n in {0..6}; do
        if [ -e "$DM_tl/.${n}" ]; then
            mv "$DM_tl/.${n}" "$DM_tl/.share/${n}"
        fi
    done
fi
