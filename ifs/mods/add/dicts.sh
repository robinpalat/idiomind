#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function chk_dicts() {
    s=0
    if [ ! -d "$DC_a/dict/enables" -o ! -d "$DC_a/dict/disables" ]; then
    mkdir -p "$DC_a/dict/enables"; mkdir -p "$DC_a/dict/disables"
    echo -e "$lgtl\n$v_dicts" > "$DC_a/dict/.dict"
    for r in "$DS_a/Dics/dicts"/*; do > "$DC_a/dict/disables/$(basename "$r")"; done; fi

    if  [ ! -f "$DC_a/dict/.dict" ] || [[ "$(sed -n 2p "$DC_a/dict/.dict")" != $v_dicts ]] ; then s=1
    rm "$DC_a/dict/enables"/*; rm "$DC_a/dict/disables"/*; echo -e "$lgtl\n$v_dicts" > "$DC_a/dict/.dict"
    for r in "$DS_a/Dics/dicts"/*; do > "$DC_a/dict/disables/$(basename "$r")"; done
    "$DS_a/Dics/cnfg.sh" "" 1 " $(gettext "Please, select at least one resource for each task")"; fi

    if  [[ -z "$(ls "$DC_d"/*."Traslator online.Translator".*)" ]]; then s=1
    "$DS_a/Dics/cnfg.sh" "" 1 " $(gettext "Please, select at least one resource for each task")"; fi

    if  [[ -z "$(ls "$DC_d"/*."TTS online.Pronunciation".*)" ]]; then s=1
    "$DS_a/Dics/cnfg.sh" "" 1 " $(gettext "Please, select at least one resource for each task")"; fi

    if  [[ -z "$(ls "$DC_d"/*."TTS online.Word pronunciation".*)" ]]; then s=1
    "$DS_a/Dics/cnfg.sh" "" 1 " $(gettext "Please, select at least one resource for each task")"; fi

    if  [[ "$(sed -n 1p "$DC_a/dict/.dict")" != $lgtl ]] ; then s=1
    "$DS_a/Dics/cnfg.sh" "" 1 " $(gettext "Please, select at least one resource for each task")"; fi

    [ $s = 1 ] && echo -e "$lgtl\n$v_dicts" > "$DC_a/dict/.dict"
}

chk_dicts
