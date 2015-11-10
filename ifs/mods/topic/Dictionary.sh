#!/bin/bash
# -*- ENCODING: UTF-8 -*-

find_cmd='@bash -c "dictionary_edit \"$0\""'
function dictionary_edit() {
    $DS/play.sh play_word "$1"
    export word="$1"
}

edit_cmd='@bash -c "_edit"'
function _edit() {
    yad --text="$word"
}

export -f dictionary_edit _edit

function dictionary() {
    cmd_play="$DS/play.sh play_list"
    cdb="$DM_tls/Dictionary/${lgtl}.db"
    table="T`date +%m%y`"
    limit=0
    list() {
        exec 3< <(sqlite3 "$cdb" "select Word FROM  ${table}" |tac)
        exec 4< <(sqlite3 "$cdb" "select ${lgsl} FROM ${table}"|tac)
        while :; do
            read word <&3
            read tran <&4
            if [ -n "$word" -a -n "$tran" ]; then
                echo "<span font_desc='Arial Bold 14'>$word</span>"
                echo "<span font_desc='Arial 14'>$tran</span>"
            fi
            [ ${limit} -gt 200 ] && break
            let limit++
        done
    }
    list | yad --list --title="$(gettext "New Words")" \
    --dclick-action="$find_cmd" \
    --search-column=1 --regex-search --print-column=1 \
    --column="$(gettext "$lgtl")                                                        ":TEXT \
    --column="$(gettext "$lgsl")":TEXT \
    --name=Idiomind --class=Idiomind  \
    --center --align=right --ellipsize=END --image-on-top \
    --window-icon=idiomind --center \
    --width=620 --height=580 --borders=10 \
    --button="gtk-edit":"$edit_cmd" \
    --button="gtk-close":1
    
} >/dev/null 2>&1

dictionary
