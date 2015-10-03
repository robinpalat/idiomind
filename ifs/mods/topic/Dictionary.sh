#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function Dictionary() {
    cmd_play="$DS/play.sh play_list"
    cdb="$DM_tls/Dictionary/${lgtl}.db"
    table="T`date +%m%y`"
    list() {
        exec 3< <(sqlite3 "$cdb" "select Word FROM  ${table}")
        exec 4< <(sqlite3 "$cdb" "select ${lgsl} FROM ${table}")
        while :; do
            read word <&3
            read tran <&4
            read exam <&5
            echo "<span font_desc='Free Sans Bold 12'>$word</span>"
            echo "<span font_desc='Free Sans 12'>$tran</span>"
            [  -z "$word" -a -z "$tran" ] && break
        done
    }
    list | yad --list --title="${tpc}" \
    --print-all \
    --dclick-action="$DS/play.sh play_word" \
    --search-column=1 --hide-column=3 --regex-search \
    --column="$(gettext "$lgtl")                                            ":TEXT \
    --column="$(gettext "$lgsl")":TEXT \
    --name=Idiomind --class=Idiomind  \
    --center --align=right --ellipsize=END --image-on-top \
    --window-icon="$DS/images/icon.png" --center \
    --width=450 --height=380 --borders=5 \
    --button="$(gettext "Edit")":"$cmd_play" \
    --button="$(gettext "Practice")":5 \
    --button="gtk-close":1
    
} >/dev/null 2>&1
