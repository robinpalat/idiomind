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
    if [ "$(grep -o gramr=\"[^\"]* "$DC_s/1.cfg" |grep -o '[^"]*$')"  = TRUE ]; then
    trgt_l="${grmr}"; else trgt_l="${trgt}"; fi
    [ -n "${link}" ] && link=" <a href='$link'>$(gettext "link")</a>" || link=""
    local sentence="<span font_desc='Sans Free 15'>${trgt_l}</span>\n\n<span font_desc='Sans Free 11'><i>$srce</i>$link</span>\n<span font_desc='Sans Free 6'>$tag</span>\n"
    cmd_words="$DS/add.sh list_words_edit "\"${wrds}\"""
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

export -f word_view sentence_view

function notebook_1() {
    cmd_mark="'$DS/mngr.sh' 'mark_as_learned' "\"${tpc}\"" 1"
    cmd_play="$DS/play.sh play_list"
    btn1="$(gettext "Share")"
    btn3="$(gettext "Delete")"
    btn2="$(gettext "Edit list")"
    cmd1="'$DS/ifs/upld.sh' upld "\"${tpc}\"""
    cmd3="'$DS/mngr.sh' 'delete_topic' "\"${tpc}\"""
    cmd2="'$DS/mngr.sh' edit_list "\"${tpc}\"""
    chk1=$((`wc -l < "${DC_tlt}/1.cfg"`*3))
    chk5=`wc -l < "${DC_tlt}/5.cfg"`
    list() { if [[ ${chk1} = ${chk5} ]]; then
    tac "${DC_tlt}/5.cfg"; else tac "$ls1" | \
    awk '{print "/usr/share/idiomind/images/0.png\n"$0"\nFALSE"}'; fi; }
    
    list | yad --list --tabnum=1 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh '1'" \
    --expand-column=2 --no-headers --ellipsize=END \
    --search-column=2 --regex-search \
    --column=Name:IMG --column=Name:TEXT --column=Learned:CHK > "$cnf1" &
    tac "$ls2" | yad --list --tabnum=2 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh '2'" \
    --expand-column=0 --no-headers --ellipsize=END --tooltip-column=1 \
    --column=Name:TEXT &
    yad --text-info --tabnum=3 \
    --plug=$KEY \
    --filename="${nt}" --editable --wrap --fore='gray30' \
    --show-uri --fontname='vendana 11' --margins=14 > "$cnf3" &
    yad --form --tabnum=4 \
    --plug=$KEY \
    --text="$lbl1\n" \
    --scroll --borders=10 --columns=2 \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field=" $(gettext "Mark as learnt") ":FBTN "$cmd_mark" \
    --field="$(gettext "Auto-checked of checkbox on list Learning")\t\t\t":CHK "$auto_mrk" \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn2":FBTN "$cmd2" \
    --field="$btn3":FBTN "$cmd3" > "$cnf4" &
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right --ellipsize=END --image-on-top \
    --window-icon=idiomind --center \
    --tab="  $(gettext "Learning") ($inx1) " \
    --tab="  $(gettext "Learnt") ($inx2) " \
    --tab="  $(gettext "Note")  " \
    --tab="  $(gettext "Edit")  " \
    --width=600 --height=560 --borders=0 --tab-borders=3 \
    --button="$(gettext "Play")":"$cmd_play" \
    --button="$(gettext "Practice")":5 \
    --button="gtk-close":1
} >/dev/null 2>&1

function notebook_2() {
    cmd_mark="'$DS/mngr.sh' 'mark_to_learn' "\"${tpc}\"" 1"
    btn1="$(gettext "Share")"
    btn2="$(gettext "Delete")"
    cmd1="'$DS/ifs/upld.sh' upld "\"${tpc}\"""
    cmd2="'$DS/mngr.sh' 'delete_topic' "\"${tpc}\"""

    yad --multi-progress --tabnum=1 \
    --text="$pres" \
    --plug=$KEY \
    --align=center --borders=80 --bar="":NORM $RM &
    tac "$ls2" | yad --list --tabnum=2 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh '2'" \
    --expand-column=0 --no-headers --ellipsize=END \
    --search-column=1 --regex-search \
    --column=Name:TEXT &
    yad --text-info --tabnum=3 \
    --plug=$KEY \
    --filename="${nt}" --editable --wrap --fore='gray30' \
    --show-uri --fontname='vendana 11' --margins=14 > "$cnf3" &
    yad --form --tabnum=4 \
    --plug=$KEY \
    --text="$label_info1\n" \
    --scroll --borders=10 --columns=2 \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field=" $(gettext "Review") ":FBTN "$cmd_mark" \
    --field="\t\t\t\t\t\t\t\t\t\t\t\t\t\t":LBL "_" \
    --field="$label_info2\n":LBL " " \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn2":FBTN "$cmd2" \
    --field=" ":LBL " " > "$cnf4" &
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right "$img" --ellipsize=END --image-on-top \
    --window-icon=idiomind --center \
    --tab="  $(gettext "Review")  " \
    --tab="  $(gettext "Learnt") ($inx2) " \
    --tab="  $(gettext "Note")  " \
    --tab="  $(gettext "Edit")  " \
    --width=600 --height=560 --borders=0 --tab-borders=3 \
    --button="gtk-close":1
} >/dev/null 2>&1

function dialog_1() {
    yad --title="$(gettext "Review")" \
    --class=idiomind --name=Idiomind \
    --text="\"${tpc}\"\n$(gettext "<b>Would you like to review it?</b>\n The waiting period already has been completed.")" \
    --image=gtk-refresh \
    --window-icon=idiomind \
    --buttons-layout=edge --center --on-top \
    --width=420 --height=140 --borders=10 \
    --button=" $(gettext "Not Yet") ":1 \
    --button=" $(gettext "Yes") ":2
}
