#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf

function scripts() {
    dlg=0
    cmsg() {

        if [ "${IDIOMIND_NONINTERACTIVE:-}" = 1 ]; then
            echo "$tlng" > "$DC_a/resources/.res" 2>/dev/null
            return 0
        fi
    
        [ -d "$DT" ] || mkdir -p "$DT" 2>/dev/null
        if ! mkdir "$DT/scripts.lk" 2>/dev/null; then
            return 0
        fi
        touch "$DT/scripts" 2>/dev/null
        _scripts_unlock() { rm -f "$DT/scripts"; rmdir "$DT/scripts.lk" 2>/dev/null; }
        trap '_scripts_unlock' RETURN
        sleep 3
        if [ ! -e "$DC_s/topics_first_run" ]; then
            source "$DS/ifs/cmns.sh"
            if [ -r "$DS/addons/Resources/common.sh" ]; then
                # shellcheck source=/dev/null
                source "$DS/addons/Resources/common.sh"
                if ! resource_gui_allowed 2>/dev/null; then
                    echo "$tlng" > "$DC_a/resources/.res" 2>/dev/null
                    _scripts_unlock; trap - RETURN
                    return 0
                fi
                if resource_dlg_is_open 2>/dev/null; then
                    _scripts_unlock; trap - RETURN
                    return 0
                fi
            fi
            msg_2 "$(gettext "You may need to configure a list of Internet resources. \nDo you want to do this now?")" \
            dialog-information "$(gettext "Yes")" "$(gettext "Cancel")" "Idiomind"
            if [ $? = 0 ]; then
                if ps -A |pgrep -f "yad --form --title"; then
                    kill -9 $(pgrep -f "yad --form --title") &
                fi
                rm -f "$DT/scripts"; rmdir "$DT/scripts.lk" 2>/dev/null
                trap - RETURN
                "$DS_a/Resources/cnfg.sh" 6 &

                if ps -A |pgrep -f "/usr/share/idiomind/add.sh"; then
                    killall add.sh &
                fi
            fi
            echo "$tlng" > "$DC_a/resources/.res"
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
