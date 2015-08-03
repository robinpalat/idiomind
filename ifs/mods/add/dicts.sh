#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function chk_dicts() {
    s=0
    if [ ! -d "$DC_a/dict/enables" -o ! -d "$DC_a/dict/disables" ]; then
    mkdir -p "$DC_a/dict/enables"; mkdir -p "$DC_a/dict/disables"
    echo -e "$lgtl\n$v_dicts" > "$DC_a/dict/.dict"
    for re in "$DS_a/Dics/dicts"/*; do > "$DC_a/dict/disables/$(basename "$re")"; done; fi

    if  [ ! -f "$DC_a/dict/.dict" ] || [[ "$(sed -n 2p "$DC_a/dict/.dict")" != $v_dicts ]] ; then s=1
    rm "$DC_a/dict/enables"/*; rm "$DC_a/dict/disables"/*; echo -e "$lgtl\n$v_dicts" > "$DC_a/dict/.dict"
    for r in "$DS_a/Dics/dicts"/*; do > "$DC_a/dict/disables/$(basename "$r")"; done
    "$DS_a/Dics/cnfg.sh" 6; fi
    
    if ! ls "$DC_d"/* 1> /dev/null 2>&1; then s=1; "$DS_a/Dics/cnfg.sh" 6; fi

    if  [[ "$(sed -n 1p "$DC_a/dict/.dict")" != $lgtl ]] ; then s=1; "$DS_a/Dics/cnfg.sh" 6; fi

    [ $s = 1 ] && echo -e "$lgtl\n$v_dicts" > "$DC_a/dict/.dict"
}

chk_dicts
