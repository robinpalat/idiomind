#!/bin/bash
# -*- ENCODING: UTF-8 -*-


function vwr() {
    if [ ${1} = 1 ]; then 
        index="$(tpc_db 5 learning)"
        item_name="$(sed 's/<[^>]*>//g' <<< "${2}")"
    elif [ ${1} = 2 ]; then
        index="$(tpc_db 5 learnt)"
        item_name="$(sed 's/<[^>]*>//g' <<< "${2}")"
    fi
    re='^[0-9]+$'; index_pos="$3"
    
    if ! [[ ${index_pos} =~ $re ]]; then
        index_pos="grep -Fxon -m 1 \"${item_name}\" <<< \"${index}\" |sed -n 's/^\([0-9]*\)[:].*/\1/p'"
        if ! [[ ${index_pos} =~ $re ]]; then
            index_pos="$(awk 'match($0,v){print NR; exit}' v="${item_name}" <<< "${index}")"
        fi
        nll=""
    fi
    _item="$(sed -n ${index_pos}p <<< "${index}")"
    if [ -z "${_item}" ]; then
        _item="$(sed -n 1p <<< "${index}")"; export index_pos=1
    fi
    item="$(grep -F -m 1 "trgt{${_item}}" "$DC_tlt/data" |sed 's/}/}\n/g')"
    type="$(grep -oP '(?<=type{).*(?=})' <<< "${item}")"
    export trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
    export srce="$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")"
    export exmp="$(grep -oP '(?<=exmp{).*(?=})' <<< "${item}" |sed -e 's/^ *//' -e 's/ *$//')"
    export defn="$(grep -oP '(?<=defn{).*(?=})' <<< "${item}")"
    export note="$(grep -oP '(?<=note{).*(?=})' <<< "${item}")"
    export grmr="$(grep -oP '(?<=grmr{).*(?=})' <<< "${item}")"
    export mark="$(grep -oP '(?<=mark{).*(?=})' <<< "${item}")"
    export link="$(grep -oP '(?<=link{).*(?=})' <<< "${item}")"
    export tags="$(grep -oP '(?<=tags{).*(?=})' <<< "${item}")"
    export wrds="$(grep -oP '(?<=wrds{).*(?=})' <<< "${item}")"
    export cdid="$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")"
    export exmp="$(sed "s|${trgt,,}|<span color='#404040' background='#FDFBCF'>${trgt,,}<\/\span>|g" <<< "${exmp}")"
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
    font_size=27; [ ${#trgt} -gt 20 ] && font_size=20
    [ -n "${tags}" ] && field_tag="--field=<small>$tags</small>:lbl"
    [ -n "${defn}" ] && field_defn="--field=$defn:lbl"
    [ -n "${note}" ] && field_note="--field=💬  <span font_desc='Arial 9'>$note</span>:lbl"
    [ -n "${exmp}" ] && field_exmp="--field=<span font_desc='Sans Free italic 11'>\"$exmp\"</span>:lbl"
    [ -n "${link}" ] && link=" <a href='$link'>$(gettext "link")</a>" || link=""
    local sentence="<span font_desc='Sans Free ${font_size}'>${trgt}</span>\n\n<span font_desc='Sans Free 14'><i>$srce</i></span>$link\n\n"
    yad --form --title=" " \
    --quoted-output \
    --text="${sentence}" \
    --window-icon=$DS/images/logo.png \
    --skip-taskbar --text-align=center \
    --image-on-top --center \
    --width=630 --height=390 --borders=18 \
    "${field_tag}" "${field_exmp}" "${field_defn}" "${field_note}" \
    --button="!gtk-edit":4 \
    --button="!audio-volume-high":"$cmd_listen" \
    --button="!media-seek-forward":2
    
} >/dev/null 2>&1

function sentence_view() {
    if [ `sqlite3 "$cfgdb" "select gramr from opts;"` = TRUE ]; then
    trgt_l="${grmr}"; else trgt_l="${trgt}"; fi
    [ -n "${note}" ] && field_note="💬  <span font_desc='Arial 9'>$note</span>\n"
    [ -n "${link}" ] && link=" <a href='$link'>$(gettext "link")</a>" || link=""
    local sentence="<span font_desc='Sans Free 16'>${trgt_l}</span>\n\n<span font_desc='Sans Free 11'><i>$srce</i>$link</span>\n<small>$tag</small>\n"
    cmd_words="$DS/add.sh list_words_edit "\"${wrds}\"""
    lwrds="$(tr '_' '\n' <<< "${wrds}")"

    echo -e "${lwrds}" |yad --list --title=" " \
    --text="${sentence}${field_note}" \
    --print-column=0 \
    --select-action="$DS/play.sh 'play_word'" \
    --dclick-action="$DS/play.sh 'play_word'" \
    --window-icon=$DS/images/logo.png \
    --skip-taskbar --image-on-top --center \
    --scroll --text-align=left --expand-column=0 --no-headers \
    --width=630 --height=390 --borders=18 \
    --column="":TEXT \
    --column="":TEXT \
    --button="!gtk-edit":4 \
    --button="!format-justify-left!$(gettext "Words")":"$cmd_words" \
    --button="!audio-volume-high":"$cmd_listen" \
    --button="!media-seek-forward":2
    
} >/dev/null 2>&1

export -f word_view sentence_view vwr

function notebook_1() {
    cmd_mark="'$DS/mngr.sh' 'mark_as_learned' "\"${tpc}\"" 1"
    cmd_play="$DS/play.sh play_list"
    btn1="$(gettext "Edit")"
    btn2="$(gettext "Resources")"
    btn3="$(gettext "Share")"
    btn4="$(gettext "Delete")"
    cmd1="'$DS/mngr.sh' edit_list "\"${tpc}\"""
    cmd2="'$DS/ifs/tls.sh' attatchs"
    cmd3="'$DS/ifs/upld.sh' upld "\"${tpc}\"""
    cmd4="'$DS/mngr.sh' 'delete_topic' "\"${tpc}\"""
    chk1=$(($(grep -c '[^[:space:]]' <<< "${ls1}")*3))
    chk5=$(grep -c '[^[:space:]]' < "${DC_tlt}/index")

    list() { if [[ ${chk1} = ${chk5} ]]; then
    cat "${DC_tlt}/index"; else [ -n "${ls1}" ] && echo -e "${ls1}" | \
    awk '{print ""$0"\nFALSE\n"""}'; fi; }

    list | yad --list --tabnum=1 --window-icon=idiomind \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh 1" --select-action="/usr/share/idiomind/play.sh play_word" \
    --print-column=1 --expand-column=1 --grid-lines=hor  --no-headers \
    --ellipsize=end --wrap-width=460 --ellipsize-cols=2 \
    --search-column=1 --regex-search --hide-column=3 --tooltip-column=3 \
    --column=Name:TEXT \
    --column=Learned:CHK --column=@back@:TIP > "$cnf1" &
    ([ -n "${ls2}" ] && echo "${ls2}") |yad --list --tabnum=2 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh 2"  \
    --expand-column=0 --no-headers \
    --ellipsize=end --wrap-width=460 --ellipsize-cols=1 \
    --column=Name:TEXT &
    yad --text-info --tabnum=3 --window-icon=idiomind \
    --text="<small>$(gettext "Enter your text here, use it as a notice or scratch board")</small>" \
    --plug=$KEY \
    --always-print-result \
    --show-uri --uri-color="#6591AA" \
    --filename="${note}" --editable --wrap \
    --fontname='vendana 11' --margins=14 > "$cnf3" &
    yad --form --tabnum=4 --window-icon=idiomind \
    --plug=$KEY \
    --text="${lbl1}${info2}\n$label_review$label_level" \
    --borders=25 --columns=2 \
    --field=" $(gettext "Mark as learnt") "!'gtk-apply':FBTN "$cmd_mark" \
    --field=" ":LBL " " \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field="$(gettext "Auto-check learned notes")\t\t\t\t\t":CHK "$acheck" \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn3":FBTN "$cmd3" \
    --field="$btn4":FBTN "$cmd4" > "$cnf4" &
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right \
    --window-icon=$DS/images/logo.png \
    --tab="  $(gettext "Learning") ($cfg1) " \
    --tab="  $(gettext "Learnt") ($cfg2) " \
    --tab="  $(gettext "Note")  " \
    --tab="  $(gettext "Manage")  " \
    --width=530 --height=560 --borders=5 --tab-borders=0 \
    --button="$(gettext "Play")":"$cmd_play" \
    --button="$(gettext "Practice")":3 \
    --button="$(gettext "Close")"!'window-close':2
} >/dev/null 2>&1

# TODO
function notebook_2() {
	cmd_play="$DS/play.sh play_list"
    cmd_mark="'$DS/mngr.sh' 'mark_to_learn' "\"${tpc}\"" 1"
    btn1="$(gettext "Edit")"
    btn2="$(gettext "Resources")"
    btn3="$(gettext "Share")"
    btn4="$(gettext "Delete")"
    cmd1="'$DS/mngr.sh' edit_list "\"${tpc}\"""
    cmd2="'$DS/ifs/tls.sh' attatchs"
    cmd3="'$DS/ifs/upld.sh' upld "\"${tpc}\"""
    cmd4="'$DS/mngr.sh' 'delete_topic' "\"${tpc}\"""

	yad --multi-progress --tabnum=1 \
	--text="$pres" \
	--plug=$KEY \
	--align=center --borders=80 --bar="":NORM $days_to_review_porcent &
    ([ -n "${ls2}" ] && echo "${ls2}") |yad --list --tabnum=2 \
    --window-icon=idiomind --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh 2" --grid-lines=hor \
    --expand-column=0 --no-headers --ellipsize=end \
    --search-column=1 --regex-search \
    --column=Name:TEXT &
    yad --text-info --tabnum=3 --window-icon=idiomind \
    --plug=$KEY \
    --text="<small>$(gettext "Enter your text here, use it as a notice or scratch board")</small>" \
    --show-uri --uri-color="#6591AA" \
    --filename="${note}" --editable --wrap \
    --fontname='vendana 11' --margins=14 > "$cnf3" &
    yad --form --tabnum=4 --window-icon=idiomind \
    --plug=$KEY \
    --text="$lbl1\n$label_review$label_level" \
    --borders=25 --columns=2 \
    --field=" $(gettext "Review") "!'view-refresh':FBTN "$cmd_mark" \
    --field=" ":LBL " " \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field="\t\t\t\t\t\t\t\\t\t\t\t\t":LBL "_" \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn3":FBTN "$cmd3" \
    --field="$btn4":FBTN "$cmd4" > "$cnf4" &
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right --ellipsize=END \
    --window-icon=$DS/images/logo.png \
    --tab="  $(gettext "Review") ($repass) " \
    --tab="  $(gettext "Learnt") ($cfg2) " \
    --tab="  $(gettext "Note")  " \
    --tab="  $(gettext "Manage")  " \
    --width=530 --height=560 --borders=5 --tab-borders=0 \
    --button="$(gettext "Close")"!'window-close':2
  
    
} >/dev/null 2>&1


function notebook_3() {
	
	cmd_play="$DS/play.sh play_list"
    cmd_mark="'$DS/mngr.sh' 'mark_to_learn' "\"${tpc}\"" 1"
    btn1="$(gettext "Edit")"
    btn2="$(gettext "Resources")"
    btn3="$(gettext "Share")"
    btn4="$(gettext "Delete")"
    cmd1="'$DS/mngr.sh' edit_list "\"${tpc}\"""
    cmd2="'$DS/ifs/tls.sh' attatchs"
    cmd3="'$DS/ifs/upld.sh' upld "\"${tpc}\"""
    cmd4="'$DS/mngr.sh' 'delete_topic' "\"${tpc}\"""

    ([ -n "${ls1}" ] && echo "${ls1}") |yad --list --tabnum=1 \
    --window-icon=idiomind --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh 1" --select-action="/usr/share/idiomind/play.sh play_word" \
    --expand-column=0 --no-headers --grid-lines=hor --ellipsize=end \
    --search-column=1 --regex-search \
    --column=Name:TEXT &
    yad --text-info --tabnum=2 --window-icon=idiomind \
    --text="<small>$(gettext "Enter your text here, use it as a notice or scratch board")</small>" \
    --plug=$KEY \
    --show-uri --uri-color="#6591AA" \
    --filename="${note}" --editable --wrap \
    --fontname='vendana 11' --margins=14 > "$cnf3" &
    yad --form --tabnum=3 --window-icon=idiomind \
    --plug=$KEY \
    --text="$lbl1" \
    --borders=25 --columns=2 \
    --field="$label_level\n":LBL " " \
    --field=" ":LBL " " \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field="\t\t\t\t\t\t\t\\t\t\t\t\t\t":LBL "_" \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn3":FBTN "$cmd3" \
    --field="$btn4":FBTN "$cmd4" > "$cnf4" &
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right --ellipsize=END \
    --window-icon=$DS/images/logo.png \
    --tab="  $(gettext "Learnt") ($cfg1) " \
    --tab="  $(gettext "Note")  " \
    --tab="  $(gettext "Manage")  " \
    --width=530 --height=560 --borders=5 --tab-borders=0 \
    --button="$(gettext "Play")":"$cmd_play" \
    --button="$(gettext "Practice")":3 \
    --button="$(gettext "Close")"!'window-close':2
} >/dev/null 2>&1


function dialog_1() {
    yad --title="$(gettext "Review")  \"${tpc}\"" \
    --class=idiomind --name=Idiomind \
    --text="$(gettext "<b>Would you like to review it?</b>\n The waiting period already has been completed.")" \
    --image="$DS/images/review.png" \
    --window-icon=$DS/images/logo.png \
    --buttons-layout=spread --fixed --center --on-top \
    --width=440 --height=115 --borders=8 \
    --button=" $(gettext "Not Yet") ":1 \
    --button=" $(gettext "Yes") ":2
}

#function tpc_view() {
    #yad --list --title="Idiomind" \
    #--text="${itxt}" --select-action="/usr/share/idiomind/play.sh play_word" \
    #--name=Idiomind --class=Idiomind \
    #--no-click --print-column=0 \
    #--wrap-width=420 --ellipsize-cols=0 \
    #--dclick-action=":" \
    #--window-icon=$DS/images/logo.png \
    #--hide-column=2 --tooltip-column=2 \
    #--no-headers --ellipsize=END --center \
    #--width=510 --height=560 \
    #--borders=8 --tab-borders=0 \
    #--column=" " --column=" " \
    #--button="$(gettext "Install")":0 \
    #--button="$(gettext "Close")!gtk-close":1
#}


function tpc_view() {

    _lst | yad --list --tabnum=1 --window-icon=idiomind \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="/usr/share/idiomind/play.sh play_word" \
    --select-action="/usr/share/idiomind/play.sh play_word" \
    --print-column=1 --expand-column=1 --grid-lines=hor  --no-headers \
    --ellipsize=end --wrap-width=460 --ellipsize-cols=2 \
    --search-column=1 --regex-search --hide-column=2 --tooltip-column=2 \
    --column=Name:TEXT --column=@back@:TIP &
    echo "$note" | yad --text-info --tabnum=2 --window-icon=idiomind \
    --text="${itxt}" \
    --plug=$KEY --borders=10 \
    --always-print-result \
    --show-uri --uri-color="#6591AA" \
    --wrap \
    --fontname='vendana 11' --margins=14  &
    yad --notebook --title="$name" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right \
    --window-icon=$DS/images/logo.png \
    --tab="  $(gettext "Notes") " \
    --tab="  $(gettext "Details")  " \
    --width=530 --height=560 --borders=5 --tab-borders=0 \
    --button="$(gettext "Install")":0 \
    --button="$(gettext "Close")!gtk-close":1
} >/dev/null 2>&1




function panelini() {
	
	(if [ -s "$DT/tasks"  ]; then cat "$DT/tasks"; \
	else echo "$(gettext "no tasks")"; fi) \
	| yad --title="Idiomind" --list \
    --name=Idiomind --class=Idiomind --dclick-action="" \
    --separator="" --expander="$(gettext "Tasks")" --scroll \
    --select-action="/usr/share/idiomind/ifs/tasks.sh" --grid-lines=hor \
    --dclick-action="/usr/share/idiomind/ifs/tasks.sh" \
    --window-icon=$DS/images/logo.png \
    --hscroll-policy=auto --vscroll-policy=never \
    --expand-column=1 --no-click --no-headers \
    --on-top --text-align=left --align=left --buttons-layout=spread \
    ${geometry} --borders=2  --column=Name:TEXT --fixed --width=20 --height=20 \
    --button=""!'list-add'!"$(gettext "Add Note, which can be a word or a sentence")":"$DS/add.sh 'new_items'" \
    --button=""!'go-home'!"$(gettext "My Active Topic")":"idiomind 'topic'" \
    --button=""!'gtk-index'!"$(gettext "My topics")":"$DS/chng.sh"  
}


