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
    if [ "$(grep -o gramr=\"[^\"]* < "$DC_s/1.cfg" | grep -o '[^"]*$')"  = TRUE ]; then
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
    --button=gtk-edit:4 \
    --button="!$DS/images/listen.png":"$cmd_listen" \
    --button=gtk-go-down:2 \
    --button=gtk-go-up:3
    
} >/dev/null 2>&1

export -f word_view sentence_view

function feeds_view() {
    c=$((RANDOM%100000)); KEY=$c
    cmd_update="$DS/add.sh 'fetch_feeds'"
    cmd_del="'$DS/mngr.sh' 'delete_topic' "\"${tpc}\"""
    cmd_play="$DS/play.sh play_list"
    chk1=$((`wc -l < "${DC_tlt}/1.cfg"`*3))
    chk5=`wc -l < "${DC_tlt}/5.cfg"`

    list() { if [[ ${chk1} = ${chk5} ]]; then
    tac "${DC_tlt}/5.cfg"; else tac "$ls1" | \
    awk '{print "/usr/share/idiomind/images/0.png\n"$0"\nFALSE"}'; fi; }
    
    yad --html --tabnum=1 \
    --plug=$KEY  \
    --uri="${DC_tlt}/news.html" --browser &
    tac "$ls2" | yad --list --tabnum=2 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh '2'" \
    --expand-column=0 --no-headers --ellipsize=END --tooltip-column=1 \
    --column=Name:TEXT &
    yad --form --tabnum=3 \
    --plug=$KEY \
    --text="$label_info1\n" \
    --scroll --borders=10 --columns=2 \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field="$(gettext "Update feeds at startup")\t\t\t":CHK "$auto_mrk" \
    --field="$(gettext "Delete")":FBTN "$cmd_del" \
    --field="$(gettext "Feeds")":FBTN "$cmd_eind"  &
    yad --notebook --title="Idiomind - ${tpc}" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right --ellipsize=END --image-on-top \
    --window-icon="$DS/images/icon.png" --center \
    --tab="  $(gettext "News")" \
    --tab="  $(gettext "Saved Items")" \
    --tab=" $(gettext "Edit") " \
    --width=600 --height=560 --borders=0 --tab-borders=3 \
    --button="$(gettext "Play")":"$cmd_play" \
    --button="$(gettext "Update")":5 \
    --button="gtk-close":1
    ret=$?
    if [ $ret -eq 5 ]; then
	"$DS/add.sh" fetch_feeds &
    fi
}
