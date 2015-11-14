#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
function dicts() {
    cmsg() {
        sleep 5
        if [ ! -e "$DC_s/topics_first_run" ]; then
            source "$DS/ifs/mods/cmns.sh"
            msg_2 "$(gettext "You may need to configure the list of Internet resources. \nDo you want to do this now?")" \
            info "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Information")"
            if [ $? = 0 ]; then "$DS_a/Dics/cnfg.sh" 6; fi
            echo $lgtl > "$DC_a/dict/.dict"
        fi
    }
    s=0
    if [ ! -d "$DC_d" -o ! -d "$DC_a/dict/disables" ]; then
        mkdir -p "$DC_d"; mkdir -p "$DC_a/dict/disables"
        echo $lgtl > "$DC_a/dict/.dict"
        for re in "$DS_a/Dics/dicts"/*; do
            > "$DC_a/dict/disables/$(basename "$re")"
        done
    fi
    if  [ ! -f "$DC_a/dict/.dict" ]; then s=1
        echo -e "$lgtl" > "$DC_a/dict/.dict"
    fi
    if ! ls "$DC_d"/* 1> /dev/null 2>&1; then cmsg; fi
    if  [[ `sed -n 1p "$DC_a/dict/.dict"` != $lgtl ]] ; then cmsg; fi
}

dicts &
