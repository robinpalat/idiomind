#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function stats() {

    yad --html --uri="/usr/share/idiomind/ifs/stats/1.html" --browser \
    --title="$(gettext "Stats")" \
    --name=Idiomind --class=Idiomind \
    --orient=vert --window-icon=idiomind --on-top --center \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --width=620 --height=420 --borders=2 --splitter=280 \
    --button="<small>$(gettext "Close")</small>":1
    
} >/dev/null 2>&1

stats
