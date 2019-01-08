#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf

function dicts() {
    dlg=0
    cmsg() {
        if [ ! -e "$DT/dicts" ]; then
            touch "$DT/dicts"
            sleep 3
            if [ ! -e "$DC_s/topics_first_run" ]; then
                source "$DS/ifs/cmns.sh"
                msg_2 "$(gettext "You may need to configure a list of Internet resources. \nDo you want to do this now?")" \
                dialog-information "$(gettext "Yes")" "$(gettext "Cancel")" "Idiomind"
                if [ $? = 0 ]; then 
                    rm -f "$DT/dicts"; "$DS_a/Dics/cnfg.sh" 6
                fi
                echo "$tlng" > "$DC_a/dict/.dict"
            fi
            [ -f "$DT/dicts" ] && rm -f "$DT/dicts"
        fi
        return 0
    }
    if [ ! -d "$DC_d" -o ! -d "$DC_a/dict/disables" ]; then
        mkdir -p "$DC_d"; mkdir -p "$DC_a/dict/disables"
        echo "$tlng" > "$DC_a/dict/.dict"
        for re in "$DS_a/Dics/dicts"/*; do
            > "$DC_a/dict/disables/$(basename "$re")"
        done
    fi
    if  [ ! -e "$DC_a/dict/.dict" ]; then
        echo "$tlng" > "$DC_a/dict/.dict"
    fi
    if ! ls "$DC_d"/* 1> /dev/null 2>&1; then dlg=1; fi
    if  [[ "$(sed -n 1p "$DC_a/dict/.dict")" != $tlng ]] ; then dlg=1; fi
    
    [[ ${dlg} = 1 ]] && cmsg
}

dicts &
