#!/bin/bash
# -*- ENCODING: UTF-8 -*-

find_cmd='@bash -c "item \"$0\""'
function item() {
    $DS/play.sh play_word "$1" &
    sed 's/<[^>]*>//g' <<<"$1" |xclip -i
} >/dev/null 2>&1
export -f item

function dictionary() {
    cmd_play="$DS/play.sh play_list"
    cdb="$DM_tls/data/${lgtl}.db"
    table="T`date +%m%y`"
    limit=0
    list() {
        exec 3< <(sqlite3 "$cdb" "select Word FROM  ${table}" |tac)
        exec 4< <(sqlite3 "$cdb" "select ${lgsl} FROM ${table}"|tac)
        while :; do
            read word <&3
            read tran <&4
            if [ -n "$word" -a -n "$tran" ]; then
                echo "<span font_desc='Arial Bold 12'>$word</span>"
                echo "<span font_desc='Arial 12'>$tran</span>"
            fi
            [ ${limit} -gt 100 ] && break
            let limit++
        done
    }
    list | yad --list --title="$(gettext "New Words")" \
    --dclick-action="$find_cmd" \
    --no-headers --search-column=1 --regex-search --print-column=1 \
    --column="$(gettext "$lgtl")":TEXT \
    --column="$(gettext "$lgsl")":TEXT \
    --align=right --image-on-top \
    --name=Idiomind --class=Idiomind \
    --orient=vert --window-icon=idiomind --on-top --center \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --width=620 --height=420 --borders=2 --splitter=280 \
    --button="<small>$(gettext "Close")</small>":1
    
} >/dev/null 2>&1

dictionary
