#!/bin/bash

$DS_a/Dics/cnfg.sh updt_dicts &

if [ ! -d "$DM_tl/.share/data" ]; then

    if [ -d "$DM_tl/.share/Dictionary" ]; then
        [ -d "$DM_tl/.share/Dictionary/.conf" ] && \
        rm -r "$DM_tl/.share/Dictionary/.conf"
        mv -f "$DM_tl/.share/Dictionary" "$DM_tl/.share/data"
    else
        mkdir "$DM_tl/.share/data"; fi

    for n in {0..6}; do
        if [ -e "$DM_tl/.${n}.cfg" ]; then
            mv "$DM_tl/.${n}.cfg" "$DM_tl/.share/${n}.cfg"
        fi
    done
fi
