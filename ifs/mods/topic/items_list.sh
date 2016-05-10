#!/bin/bash
# -*- ENCODING: UTF-8 -*-

sz=(600 560); [[ ${swind} = TRUE ]] && sz=(480 440)
function vwr() {
    [ ${1} = 1 ] && index="${DC_tlt}/1.cfg" && item_name="$(sed 's/<[^>]*>//g' <<< "${3}")"
    [ ${1} = 2 ] && index="${DC_tlt}/2.cfg" && item_name="$(sed 's/<[^>]*>//g' <<< "${2}")"
    re='^[0-9]+$'; index_pos="$3"
    if ! [[ ${index_pos} =~ $re ]]; then
        index_pos=`grep -Fxon -m 1 "${item_name}" "${index}" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
        nll=""
    fi
    _item="$(sed -n ${index_pos}p "${index}")"
    if [ -z "${_item}" ]; then
        _item="$(sed -n 1p "${index}")"; export index_pos=1
    fi
    item="$(grep -F -m 1 "trgt{${_item}}" "$DC_tlt/0.cfg" |sed 's/}/}\n/g')"
    type="$(grep -oP '(?<=type{).*(?=})' <<< "${item}")"
    export trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
    export srce="$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")"
    export exmp="$(grep -oP '(?<=exmp{).*(?=})' <<< "${item}")"
    export defn="$(grep -oP '(?<=defn{).*(?=})' <<< "${item}")"
    export note="$(grep -oP '(?<=note{).*(?=})' <<< "${item}")"
    export grmr="$(grep -oP '(?<=grmr{).*(?=})' <<< "${item}")"
    export mark="$(grep -oP '(?<=mark{).*(?=})' <<< "${item}")"
    export link="$(grep -oP '(?<=link{).*(?=})' <<< "${item}")"
    export tags="$(grep -oP '(?<=tags{).*(?=})' <<< "${item}")"
    export wrds="$(grep -oP '(?<=wrds{).*(?=})' <<< "${item}")"
    export cdid="$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")"
    export exmp="$(sed "s/${trgt,,}/<span background='#FDFBCF'>${trgt,,}<\/\span>/g" <<< "${exmp}")"
    text_missing=0

    if [ ${type} = 1 ]; then
        export cmd_listen="$DS/play.sh play_word "\"${trgt}\"" ${cdid}"
        [ "$mark" = TRUE ] && trgt="<b>$trgt</b>" && grmr="<b>$grmr</b>"
        word_view
    elif [ ${type} = 2 ]; then
        export cmd_listen="$DS/play.sh play_sentence ${cdid}"
        [ "$mark" = TRUE ] && trgt="<b>$trgt</b>" && grmr="<b>$grmr</b>"
        sentence_view
    else
        trgt="${_item} <small>[Text missing]</small>"
        grmr="${trgt}"
        if [[ $(wc -w <<< "${_item}") -lt 2 ]]; then
            export cmd_listen="$DS/play.sh play_word "\"${trgt}\"" ${cdid}"
            text_missing=1
            word_view
        else 
            export cmd_listen="$DS/play.sh play_sentence ${cdid}"
            text_missing=2
            sentence_view
        fi
    fi
        ret=$?
        if ps -A | pgrep -f 'play'; then killall play & fi
        if [ $ret -eq 4 ]; then
            "$DS/mngr.sh" edit ${1} ${index_pos} ${text_missing} &
            
        elif [ $ret -eq 2 ]; then
            ff=$((index_pos+1))
            "$DS/vwr.sh" ${1} "" ${ff} &
            
        else
            if ps -A | pgrep -f 'play'; then killall play & fi
            exit 1
        fi
    return
} >/dev/null 2>&1


function word_view() {
    font_size=25; [ ${#trgt} -gt 20 ] && font_size=18
    [ -n "${tags}" ] && field_tag="--field=<small>$tags</small>:lbl"
    [ -n "${defn}" ] && field_defn="--field=$defn:lbl"
    [ -n "${note}" ] && field_note="--field=<i>$note</i>\n:lbl"
    [ -n "${exmp}" ] && field_exmp="--field=<span font_desc='Verdana 11' color='#6D6D6D'>$exmp</span>:lbl"
    [ -n "${link}" ] && link=" <a href='$link'>$(gettext "link")</a>" || link=""
    local sentence="<span font_desc='Sans Free ${font_size}'>${trgt}</span>\n\n<span font_desc='Sans Free 14'><i>$srce</i></span>$link\n\n"
   
    yad --form --title=" " \
    --selectable-labels --quoted-output \
    --text="${sentence}" \
    --window-icon=idiomind \
    --skip-taskbar --text-align=center \
    --image-on-top --center --on-top \
    --width=630 --height=390 --borders=20 \
    "${field_tag}" "${field_exmp}" "${field_defn}" "${field_note}" \
    --button="gtk-edit":4 \
    --button="!$DS/images/listen.png":"$cmd_listen" \
    --button="$(gettext "Next")":2
    
} >/dev/null 2>&1

function sentence_view() {
    if [ $(grep -oP '(?<=gramr=\").*(?=\")' "$DC_s/1.cfg") = TRUE ]; then
    trgt_l="${grmr}"; else trgt_l="${trgt}"; fi
    [ -n "${note}" ] && field_note="💬  <span font_desc='Arial 8' color='#676767'>$note</span>\n"
    [ -n "${link}" ] && link=" <a href='$link'>$(gettext "link")</a>" || link=""
    local sentence="<span font_desc='Sans Free 16'>${trgt_l}</span>\n\n<span font_desc='Sans Free 11'><i>$srce</i>$link</span>\n<small>$tag</small>\n"
    cmd_words="$DS/add.sh list_words_edit "\"${wrds}\"""
    lwrds="$(tr '_' '\n' <<< "${wrds}")"

    echo -e "${lwrds}" |yad --list --title=" " \
    --text="${sentence}${field_note}" \
    --selectable-labels --print-column=0 \
    --select-action="$DS/play.sh 'play_word'" \
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

export -f word_view sentence_view vwr

function notebook_1() {
    cmd_mark="'$DS/mngr.sh' 'mark_as_learned' "\"${tpc}\"" 1"
    cmd_play="$DS/play.sh play_list"
    btn1="$(gettext "Edit list")"
    btn2="$(gettext "Share")"
    btn3="$(gettext "Delete")"
    cmd1="'$DS/mngr.sh' edit_list "\"${tpc}\"""
    cmd2="'$DS/ifs/upld.sh' upld "\"${tpc}\"""
    cmd3="'$DS/mngr.sh' 'delete_topic' "\"${tpc}\"""
    chk1=$(($(wc -l < "${DC_tlt}/1.cfg")*3))
    chk5=$(wc -l < "${DC_tlt}/5.cfg")
    list() { if [[ ${chk1} = ${chk5} ]]; then
    cat "${DC_tlt}/5.cfg"; else cat "${ls1}" | \
    awk '{print "/usr/share/idiomind/images/0.png\n"$0"\nFALSE"}'; fi; }
    
    list | yad --list --tabnum=1 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh 1" \
    --expand-column=2 --no-headers --ellipsize=END \
    --search-column=2 --regex-search \
    --column=Name:IMG --column=Name:TEXT --column=Learned:CHK > "$cnf1" &
    cat "${ls2}" | yad --list --tabnum=2 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh 2"  \
    --expand-column=0 --no-headers --ellipsize=END --tooltip-column=1 \
    --column=Name:TEXT &
    yad --text-info --tabnum=3 \
    --plug=$KEY \
    --always-print-result \
    --filename="${nt}" --editable --wrap --back='#FFFDF7' --fore='gray30' \
    --fontname='vendana 11' --margins=14 > "$cnf3" &
    yad --form --tabnum=4 \
    --plug=$KEY \
    --text="$lbl1\n" \
    --borders=10 --columns=2 \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field=" $(gettext "Mark as learnt") ":FBTN "$cmd_mark" \
    --field="$(gettext "Auto-checked of checkbox on list Learning")\t\t":CHK "$acheck" \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn2":FBTN "$cmd2" \
    --field="$btn3":FBTN "$cmd3" > "$cnf4" &
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right --ellipsize=END \
    --window-icon=idiomind \
    --tab="  $(gettext "Learning") ($cfg1) " \
    --tab="  $(gettext "Learnt") ($cfg2) " \
    --tab="  $(gettext "Note")  " \
    --tab="  $(gettext "Edit")  " \
    --width=${sz[0]} --height=${sz[1]} --borders=0 --tab-borders=3 \
    --button="$(gettext "Play")":"$cmd_play" \
    --button="$(gettext "Practice")":3 \
    --button="$(gettext "Close")"!'window-close':2
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
    cat "${ls2}" | yad --list --tabnum=2 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh 2" \
    --expand-column=0 --no-headers --ellipsize=END \
    --search-column=1 --regex-search \
    --column=Name:TEXT &
    yad --text-info --tabnum=3 \
    --plug=$KEY \
    --filename="${nt}" --editable --wrap --back='#FFFDF7' --fore='gray30' \
    --fontname='vendana 11' --margins=14 > "$cnf3" &
    yad --form --tabnum=4 \
    --plug=$KEY \
    --text="$lbl1\n" \
    --borders=10 --columns=2 \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field=" $(gettext "Review") ":FBTN "$cmd_mark" \
    --field="\t\t\t\t\t\t\t\t\t\t\t":LBL "_" \
    --field="$label_info2\n":LBL " " \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn2":FBTN "$cmd2" \
    --field=" ":LBL " " > "$cnf4" &
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right --ellipsize=END \
    --window-icon=idiomind \
    --tab="  $(gettext "Review")  " \
    --tab="  $(gettext "Learnt") ($cfg2) " \
    --tab="  $(gettext "Note")  " \
    --tab="  $(gettext "Edit")  " \
    --width=${sz[0]} --height=${sz[1]} --borders=0 --tab-borders=3 \
    --button="$(gettext "Close")"!'window-close':2
} >/dev/null 2>&1

function dialog_1() {
    yad --title="$(gettext "Review") - ${tpc}" \
    --class=idiomind --name=Idiomind \
    --text="$(gettext "<b>Would you like to review it?</b>\n The waiting period already has been completed.")" \
    --image='view-refresh' \
    --window-icon=idiomind \
    --buttons-layout=edge --center --on-top \
    --width=440 --height=140 --borders=10 \
    --button=" $(gettext "Not Yet") ":1 \
    --button=" $(gettext "Yes") ":2
}
