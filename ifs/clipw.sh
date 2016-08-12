#!/bin/bash
# -*- ENCODING: UTF-8 -*-

cbwatch() {
    while [ 1 ]; do
        [ ! -e $DT/clipw ] && break
        xclip -selection clipboard /dev/null
        sleep 0.5
        if [[ -n "$(xclip -selection clipboard -o)" ]]; then
            idiomind add "$(xclip -selection clipboard -o)"
            xclip -selection clipboard /dev/null
        fi
    done
    return 0
}

DT="/tmp/.idiomind-$USER"

if [[ $1 =  1 ]]; then
    yad --form --title="$(gettext "Clipboard watcher")" \
    --name=Idiomind --class=Idiomind \
    --text="$(gettext "Deactivate Clipboard watcher?")" \
    --window-icon=idiomind \
    --fixed --skip-taskbar --center --on-top \
    --width=270 --height=90 --borders=4 \
    --button="$(gettext "No")":2 \
    --button="$(gettext "Yes")":1
    ret="$?"
    if [ $ret = 1 ]; then
        source /usr/share/idiomind/default/c.conf
        sed -i "s/clipw=.*/clipw=\"FALSE\"/g" "$DC_s/1.cfg"
        [ -f $DT/clipw ] && rm -f $DT/clipw
        exit 1 & "$DS/add.sh" new_items
    fi
else
    #notify-send -i idiomind "$(gettext "Clipboard watcher active")" " " -t 10000
    echo $$ > $DT/clipw
    cbwatch
fi
