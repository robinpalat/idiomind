#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function word_view() {
    [ -n "$exmp" ] && field_exmp="--field=<span font_desc='Verdana 11' color='#5C5C5C'><i>$exmp</i></span>:lbl"
    local text="<span font_desc='Sans Free 24'>${trgt}</span>\n\n<span font_desc='Sans Free 14'><i>$srce</i></span>\n\n"
    yad --form --title="" \
    --selectable-labels --quoted-output \
    --text="${text}" \
    --window-icon="$DS/images/icon.png" \
    --scroll --skip-taskbar --text-align=center \
    --image-on-top --center --on-top \
    --width=630 --height=390 --borders=20 \
    --field="":lbl "${field_exmp}"  \
    --button="!$DS/images/listen.png":"$cmd_listen" 
    
} >/dev/null 2>&1

export -f word_view sentence_view

function Dictionary() {
    cmd_play="$DS/play.sh play_list"
    cdb="$DM_tls/Dictionary/${lgtl}.db"
    table=`date +%b%y`
    sqlite3 "$cdb" "select * FROM  ${table^^}" \
    |sed 's/|/\n/g' | yad --list --title="${tpc}" \
    --text="$(gettext "$lgtlLorem ipsum dolor sit amet, consectetur adipisicing elit, sed doeiusmod tempor incididunt ut labore et dolore magna aliq")\n" \
    --print-all \
    --dclick-action="$DS/vwr.sh '3'" \
    --search-column=1 --hide-column=3 --regex-search \
    --column="$(gettext "$lgtl")                                 ":TEXT \
    --column="$(gettext "$lgsl")":TEXT \
    --column='Example':TEXT \
    --name=Idiomind --class=Idiomind  \
    --center --align=right --ellipsize=END --image-on-top \
    --window-icon="$DS/images/icon.png" --center \
    --width=600 --height=560 --borders=5 \
    --button="$(gettext "Edit")":"$cmd_play" \
    --button="$(gettext "Practice")":5 \
    --button="gtk-close":1
    
} >/dev/null 2>&1
