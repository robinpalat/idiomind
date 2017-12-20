#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"

cbwatch() {
    while [ 1 ]; do
        [[ ! -e $DT/clipw ]] && break
        xclip -selection clipboard /dev/null
        sleep 0.5
        if [[ -n "$(xclip -selection clipboard -o)" ]]; then
            if [[ "$(xclip -selection clipboard -o)" -gt 120 ]]; then
                notify-send -i idiomind "$(gettext "Text is too long")" \
                "$(gettext "The copied text cannot be added because it is too long")" -t 10000
            else
                idiomind add "$(xclip -selection clipboard -o)"
            fi
            xclip -selection clipboard /dev/null
        fi
    done & pid=$!
    sleep 300 && kill -TERM $pid
    [[ -f $DT/clipw ]] && rm -f $DT/clipw
    return 0
}

DT="/tmp/.idiomind-$USER"

if [[ "$1" =  1 ]]; then
    msg_2 "$(gettext "Deactivate Clipboard watcher?")\n" \
    'edit-paste' "$(gettext "Yes")" "$(gettext "No")"
    ret="$?"
    if [ $ret = 0 ]; then
        cdb "${cfgdb}" 3 opts clipw 'FALSE'
        [[ -f $DT/clipw ]] && rm -f $DT/clipw
        exit 1
    fi
else
    echo $$ > $DT/clipw
    cbwatch
fi
