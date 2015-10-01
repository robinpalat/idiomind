#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function word_view() {
    [ -n "$defn" ] && field_defn="--field=<small>$defn</small>:lbl"
    [ -n "$note" ] && field_note="--field=<small>$note</small>\n:lbl"
    [ -n "$exmp" ] && field_exmp="--field=<span font_desc='Verdana 11' color='#5C5C5C'><i>$exmp</i></span>:lbl"
    local sentence="$tag<span font_desc='Sans Free 25'>${trgt}</span>\n\n<span font_desc='Sans Free 14'><i>$srce</i></span>\n\n"

    yad --form --title=" " \
    --selectable-labels --quoted-output \
    --text="${sentence}" \
    --window-icon="$DS/images/icon.png" \
    --scroll --skip-taskbar --text-align=center \
    --image-on-top --center --on-top \
    --width=630 --height=390 --borders=20 \
    --field="":lbl "${field_exmp}" "${field_defn}" "${field_note}" \
    --button="gtk-edit":4 \
    --button="!$DS/images/listen.png":"$cmd_listen" \
    --button=gtk-go-down:2 \
    --button=gtk-go-up:3
    
} >/dev/null 2>&1

function sentence_view() {
    if [ "$(grep -o gramr=\"[^\"]* < "$DC_s/1.cfg" |grep -o '[^"]*$')"  = TRUE ]; then
    trgt_l="${grmr}"; else trgt_l="${trgt}"; fi
    local word="$tag<span font_desc='Sans Free 15'>${trgt_l}</span>\n\n<span font_desc='Sans Free 11'><i>$srce</i></span>\n\n"
    
    echo "${lwrd}" | yad --list --title=" " \
    --text="${word}" \
    --selectable-labels --print-column=0 \
    --dclick-action="$DS/play.sh 'play_word'" \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --image-on-top --center --on-top \
    --scroll --text-align=left --expand-column=0 --no-headers \
    --width=630 --height=390 --borders=20 \
    --column="":TEXT \
    --column="":TEXT \
    --button="gtk-edit":4 \
    --button="!$DS/images/listen.png":"$cmd_listen" \
    --button=gtk-go-down:2 \
    --button=gtk-go-up:3
    
} >/dev/null 2>&1

export -f word_view sentence_view

function tags_list() {
    c=$((RANDOM%100000)); KEY=$c
    cmd_play="$DS/play.sh play_list"
    cmd_edit="'$DS/ifs/tls.sh' 'edit_tag' "\"${tpc}\"""
    chk1=$((`wc -l < "${DC_tlt}/1.cfg"`*3))
    chk5=`wc -l < "${DC_tlt}/5.cfg"`
    ls1="${DC_tlt}/1.cfg"
    desc="$(< "${DC_tlt}/info")"
    [ "$desc" ] && text="$desc\n" || text=""
    list() { if [[ ${chk1} = ${chk5} ]]; then
    tac "${DC_tlt}/5.cfg"; else tac "$ls1" | \
    awk '{print "/usr/share/idiomind/images/0.png\n"$0""}'; fi; }
    
    list | yad --list --title="${tpc}" \
    --text="${text}" \
    --name=Idiomind --class=Idiomind  \
    --dclick-action="$DS/vwr.sh '1'" \
    --no-headers --search-column=1 --hide-column=3 --regex-search \
    --always-print-result \
    --center --align=right --ellipsize=END --image-on-top \
    --window-icon="$DS/images/icon.png" --center \
    --width=600 --height=560 --borders=5  \
    --column="$(gettext "$lgtl")":IMG \
    --column="$(gettext "$lgsl")":TEXT \
    --column="$(gettext "$lgsl")":TEXT \
    --button="$(gettext "Edit")":"$cmd_edit" \
    --button="$(gettext "Play")":"$cmd_play" \
    --button="$(gettext "Practice")":5 \
    --button="gtk-close":1
    ret=$?
    if [ $ret -eq 5 ]; then
	"$DS/practice/strt.sh" &
    fi

}

export -f word_view tags_list
