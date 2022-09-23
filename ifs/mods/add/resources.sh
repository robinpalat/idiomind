#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf

function scripts() {
    dlg=0
    cmsg() {
        if [ ! -e "$DT/scripts" ]; then
            touch "$DT/scripts"
            sleep 3
            if [ ! -e "$DC_s/topics_first_run" ]; then
                source "$DS/ifs/cmns.sh"
                msg_2 "$(gettext "You may need to configure a list of Internet resources. \nDo you want to do this now?")" \
                dialog-information "$(gettext "Yes")" "$(gettext "Cancel")" "Idiomind"
                if [ $? = 0 ]; then 
                    if ps -A |pgrep -f "yad --form --title"; then 
                        kill -9 $(pgrep -f "yad --form --title") &
                    fi
                    rm -f "$DT/scripts"; "$DS_a/Resources/cnfg.sh" 6 &
                    
                    if ps -A |pgrep -f "/usr/share/idiomind/add.sh"; then 
                        killall add.sh & 
                    fi
                fi
                echo "$tlng" > "$DC_a/resources/.res"
            fi
            [ -f "$DT/scripts" ] && rm -f "$DT/scripts"
        fi
        return 0
    }
    if [ ! -d "$DC_d" -o ! -d "$DC_a/resources/disables" ]; then
        mkdir -p "$DC_d"; mkdir -p "$DC_a/resources/disables"
        echo "$tlng" > "$DC_a/resources/.res"
        for re in "$DS_a/Resources/scripts"/*; do
            > "$DC_a/resources/disables/$(basename "$re")"
        done
    fi
    if  [ ! -e "$DC_a/resources/.res" ]; then
        echo "$tlng" > "$DC_a/resources/.res"
    fi
    if ! ls "$DC_d"/* 1> /dev/null 2>&1; then dlg=1; fi
    if  [[ "$(sed -n 1p "$DC_a/resources/.res")" != $tlng ]] ; then dlg=1; fi
    
    [[ ${dlg} = 1 ]] && cmsg
}

scripts &
