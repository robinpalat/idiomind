#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function word_view() {
    [ -n "${tag}" ] && field_tag="--field=<small>$tag</small>:lbl"
    [ -n "${defn}" ] && field_defn="--field=$defn:lbl"
    [ -n "${note}" ] && field_note="--field=<i>$note</i>\n:lbl"
    [ -n "${exmp}" ] && field_exmp="--field=<span font_desc='Verdana 11' color='#5C5C5C'>$exmp</span>:lbl"
    [ -n "${link}" ] && link=" <a href='$link'>$(gettext "link")</a>" || link=""
    local sentence="<span font_desc='Sans Free 25'>${trgt}</span>\n\n<span font_desc='Sans Free 14'><i>$srce</i></span>$link\n\n"

    yad --form --title=" " \
    --selectable-labels --quoted-output \
    --text="${sentence}" \
    --window-icon=idiomind \
    --scroll --skip-taskbar --text-align=center \
    --image-on-top --center --on-top \
    --width=630 --height=390 --borders=20 \
    --field="":lbl "${field_tag}" "${field_exmp}" "${field_defn}" "${field_note}" \
    --button="gtk-edit":4 \
    --button="!$DS/images/listen.png":"$cmd_listen" \
    --button="$(gettext "Next")":2
    
} >/dev/null 2>&1

function sentence_view() {
    if [ $(grep -oP '(?<=gramr=\").*(?=\")' "$DC_s/1.cfg")  = TRUE ]; then
    trgt_l="${grmr}"; else trgt_l="${trgt}"; fi
    [ -n "${link}" ] && link=" <a href='$link'>$(gettext "link")</a>" || link=""
    local sentence="<span font_desc='Sans Free 15'>${trgt_l}</span>\n\n<span font_desc='Sans Free 11'><i>$srce</i>$link</span>\n<span font_desc='Sans Free 6'>$tag</span>\n"
    cmd_words="$DS/add.sh list_words_edit "\"${wrds}\"" "\"${trgt}\"""
    lwrds="$(tr '_' '\n' <<<"${wrds}")"

    echo -e "${lwrds}" |yad --list --title=" " \
    --text="${sentence}" \
    --selectable-labels --print-column=0 \
    --dclick-action="$DS/play.sh 'play_word'" \
    --window-icon=idiomind \
    --skip-taskbar --image-on-top --center --on-top \
    --scroll --text-align=left --expand-column=0 --no-headers \
    --width=630 --height=390 --borders=20 \
    --column="":TEXT \
    --column="":TEXT \
    --button="gtk-edit":4 \
    --button="$(gettext "Words")":"$cmd_words" \
    --button="!$DS/images/listen.png":"$cmd_listen" \
    --button="$(gettext "Next")":2
    
} >/dev/null 2>&1

function tags_list() {
    c=$((RANDOM%100000)); KEY=$c
    cmd_play="$DS/play.sh play_list"
    cmd_edit="'$DS/ifs/tls.sh' 'edit_tag' "\"${tpc}\"""
    chk1=$((`wc -l < "${DC_tlt}/1.cfg"`*3))
    chk5=`wc -l < "${DC_tlt}/5.cfg"`
    ls1="${DC_tlt}/1.cfg"
    desc="$(< "${DC_tlt}/info")"
    [ "${desc}" ] && text="--text=${desc}\n" || text="--center"
    list() { if [[ ${chk1} = ${chk5} ]]; then
    tac "${DC_tlt}/5.cfg"; else tac "$ls1" | \
    awk '{print "/usr/share/idiomind/images/0.png\n"$0""}'; fi; }
    
    list | yad --list --title="${tpc}" "${text}" \
    --name=Idiomind --class=Idiomind  \
    --dclick-action="$DS/vwr.sh '1'" \
    --no-headers --search-column=1 --hide-column=3 --regex-search \
    --always-print-result \
    --center --align=right --ellipsize=END \
    --window-icon=idiomind \
    --width=600 --height=560 --borders=8  \
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

export -f word_view sentence_view tags_list
