#!/bin/bash

$DS_a/Dics/cnfg.sh updt_dicts &

if ! grep 'itray' "$DC_s/1.cfg"; then rm -f "$DC_s/1.cfg"; fi

fix_share_dir() {
    if [ -d "$DM_tl/.share/Dictionary" ]; then
        if [ -d "$DM_tl/.share/Dictionary" ]; then
            [ -d "$DM_tl/.share/Dictionary/.conf" ] && rm -r "$DM_tl/.share/Dictionary/.conf"
            [ -d "$DM_tl/.share/data" ] && rm -r "$DM_tl/.share/data"
            mv -f "$DM_tl/.share/Dictionary" "$DM_tl/.share/data"
        fi
        for n in {0..6}; do
            if [ -e "$DM_tl/.${n}.cfg" ]; then
                mv "$DM_tl/.${n}.cfg" "$DM_tl/.share/${n}.cfg"
            fi
        done
    fi
}

fix_share_dir 
