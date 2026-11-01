#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#


if [ -z "${__GUI_COMMON_SH:-}" ] && [ -n "${DS:-}" ] && [ -r "$DS/gui/common.sh" ]; then
    # shellcheck source=/dev/null
    source "$DS/gui/common.sh"
fi

if [ -z "${__GUI_VWR_TERM_SH:-}" ] && [ -n "${DS:-}" ] && [ -r "$DS/gui/vwr_term.sh" ]; then
    # shellcheck source=/dev/null
    source "$DS/gui/vwr_term.sh"
fi


function vwr() {

    if [ -f "${DC_tlt}/slng_err" ]; then
        yad --title="Idiomind" --class=Idiomind --name=Idiomind \
        --text="$(gettext "This topic has no source in your language.")\n" \
        --window-icon=$DS/images/logo.png --center --on-top --fixed \
        --width=420 --borders=12 \
        --button="$(gettext "Automatic translation")":0 \
        --button="$(gettext "Close")":1
        if [ $? -eq 0 ]; then
            "$DS/ifs/tls.sh" translate
            if [ -f "${DC_tlt}/slng_err" ]; then
                return 1
            fi
        else
            return 1
        fi
    fi
    vwr_resolve "${1}" "${2}" "${3}"

    vwr_term_view "${1}"
    ret=$?
        if ps -A | pgrep -f 'play'; then killall play & fi
        if [ ${ret} -eq 4 ]; then
            vwr_do_edit ${1} ${index_pos} ${text_missing} &
        elif [ ${ret} -eq 2 ]; then
            ff=$((index_pos+1))
            vwr_spawn ${1} "" ${ff} &
        elif [ ${ret} -eq 3 ]; then
            pp=$((index_pos-1))
            if [ ${pp} -ge 1 ]; then
                vwr_spawn ${1} "" ${pp} &
            fi
        elif [ ${ret} -eq 5 ]; then
            vwr_words_edit "${wrds}" &
            exit 1
        else
            if ps -A | pgrep -f 'play'; then killall play & fi
            exit 1
        fi
    return
} >/dev/null 2>&1

export -f vwr vwr_resolve vwr_term_view vwr_term_open vwr_do_edit vwr_spawn vwr_words_edit

topic_language_notice() {
    local topic_slng active_trans effective_slng
    topic_slng="$(tpc_db 1 id slng)"
    active_trans="$(sed -n 1p "${DC_tlt}/translations/active" 2>/dev/null)"
    effective_slng="${active_trans:-$topic_slng}"
    if [ -n "$effective_slng" ] && [ "$effective_slng" != "$slng" ]; then
        printf '%s\n%s\n' \
            "<big><span color='#A83D00'>⚠</span></big> $(gettext "Native languages do not match.")\n\n"
    fi
}

# Injects the learning-table position (NR) as an extra line after each
# displayed Name, turning 3-line groups (name, chk, tip) into 4-line
# groups (name, pos, chk, tip). pos is resolved by exact unique match
# against the table snapshot in $ls1, so it stays correct even if the
# displayed order differs from the table order; unknown names fall back
# to the display counter. Feeds the hidden @fore@ column whose value
# yad appends to --dclick-action, so vwr() receives it as numeric $3.
add_pos_col() {
    awk 'NR==FNR { if (!($0 in pos)) pos[$0]=FNR; next }
        { f=(FNR-1)%3; if (f==0) { nm=$0; c++ } else if (f==1) { ck=$0 }
          else { print nm; print ((nm != "" && nm in pos) ? pos[nm] : c); print ck; print } }' \
        <(printf '%s\n' "${ls1}") -
}

function notebook_1() {
	
    native_lang_info="$(topic_language_notice)"
    cmd_mark="'$DS/mngr.sh' 'mark_as_learned' "\"${tpc}\"" 1"
    cmd_play="$DS/play.sh play_list"
    cmd_prac="$DS/practice/strt.sh"
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

    # Live list: an external add.sh can append rows while open via --listen.
    # Fifo path formula is duplicated in ifs/extensions/add/add.sh index().
    listfifo="$DT/list_$(printf '%s' "$tpc" | md5sum | cut -c1-12).fifo"
    rm -f "$listfifo"; mkfifo "$listfifo" 2>/dev/null
    listfeed() {
        list | add_pos_col
        while [ -p "$listfifo" ]; do timeout 5 cat "$listfifo" 2>/dev/null; done
    }

    listfeed | yad --list --tabnum=1 --window-icon=idiomind \
    --plug=$KEY --print-all --separator='|' --listen \
    --image="$DS/images/$((stts%2)).png" --image-on-top \
    --dclick-action="$DS/vwr.sh 1" \
    --print-column=1 --expand-column=1 --grid-lines=hor  --no-headers \
    --ellipsize=end --wrap-width=460 --ellipsize-cols=2 \
    --search-column=1 --regex-search --hide-column=4 --tooltip-column=4 \
    --column=Name:TEXT \
    --column=@fore@ --column=Learned:CHK --column=@back@:TIP > "$cnf1" &
    ([ -n "${ls2}" ] && echo "${ls2}" | awk '{print $0"\n"NR}') |yad --list --tabnum=2 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh 2"  \
    --expand-column=0 --no-headers \
    --ellipsize=end --wrap-width=460 --ellipsize-cols=1 \
    --column=Name:TEXT --column=@fore@ &
    yad --text-info --tabnum=3 --window-icon=idiomind \
    --text="<small>$(gettext "A space for notes, reminders, or anything you want to write down")</small>" \
    --plug=$KEY \
    --always-print-result \
    --show-uri --uri-color="#6591AA" \
    --filename="${note}" --editable --wrap \
    --fontname='vendana 11' --margins=14 > "$cnf3" &
    yad --form --tabnum=4 --window-icon=idiomind \
    --plug=$KEY \
    --text="${lbl1}${info2}${native_lang_info}<small>$(gettext "Status:") $label_review</small>\n" \
    --borders=25 --columns=2 \
    --field=" $btn_review "!'gtk-apply':FBTN "$cmd_mark" \
    --field=" ":LBL " " \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
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
    --button="$(gettext "Practice")":"$cmd_prac" \
    --button="$(gettext "Close")"!'window-close':2
} >/dev/null 2>&1

# TODO
function notebook_2() {
	
	native_lang_info="$(topic_language_notice)"
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
	--text="$pres\n" \
	--plug=$KEY \
	--align=center --borders=80 --bar="<small>$info6 </small>":NORM $days_to_review_porcent &
    ([ -n "${ls2}" ] && echo "${ls2}" | awk '{print $0"\n"NR}') |yad --list --tabnum=2 \
    --window-icon=idiomind --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh 2" --grid-lines=hor \
    --expand-column=0 --no-headers --ellipsize=end \
    --search-column=1 --regex-search \
    --column=Name:TEXT --column=@fore@ &
    yad --text-info --tabnum=3 --window-icon=idiomind \
    --plug=$KEY \
    --text="<small>$(gettext "A space for notes, reminders, or anything you want to write down")</small>" \
    --show-uri --uri-color="#6591AA" \
    --filename="${note}" --editable --wrap \
    --fontname='vendana 11' --margins=14 > "$cnf3" &
    if [ $stts = 7 ] || [ $stts = 8 ] || [ $stts = 9 ] || [ $stts = 10 ] || [ ${days_to_review_porcent} -ge 100 ]; then 
    yad --form --tabnum=4 --window-icon=idiomind \
    --plug=$KEY \
    --text="$lbl1${native_lang_info}<small>$(gettext "Status:") $label_review</small>\n" \
    --borders=25 --columns=2 \
    --field=" $btn_review  "!'view-refresh':FBTN "$cmd_mark" \
    --field=" ":LBL " " \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field="\t\t\t\t\t\t\t\\t\t\t\t\t":LBL "_" \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn3":FBTN "$cmd3" \
    --field="$btn4":FBTN "$cmd4" > "$cnf4" &
    else
    yad --form --tabnum=4 --window-icon=idiomind \
    --plug=$KEY \
    --text="$lbl1${native_lang_info}<small>$(gettext "Status:") $label_review</small>\n" \
    --borders=25 --columns=2 \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field="\t\t\t\t\t\t\t\\t\t\t\t\t":LBL "_" \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn3":FBTN "$cmd3" \
    --field="$btn4":FBTN "$cmd4" > "$cnf4" &
    fi
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right --ellipsize=END \
    --window-icon=$DS/images/logo.png \
    --tab="  $(gettext "Learning") (0) " \
    --tab="  $(gettext "Learnt") ($cfg2) " \
    --tab="  $(gettext "Note")  " \
    --tab="  $(gettext "Manage")  " \
    --width=530 --height=560 --borders=5 --tab-borders=0 \
    --button="$(gettext "Close")"!'window-close':2
    
} >/dev/null 2>&1


function notebook_3() {
	
	native_lang_info="$(topic_language_notice)"
	
	cmd_play="$DS/play.sh play_list"
	cmd_prac="$DS/practice/strt.sh"
    cmd_mark="'$DS/mngr.sh' 'mark_to_learn' "\"${tpc}\"" 1"
    btn1="$(gettext "Edit")"
    btn2="$(gettext "Resources")"
    btn3="$(gettext "Share")"
    btn4="$(gettext "Delete")"
    cmd1="'$DS/mngr.sh' edit_list "\"${tpc}\"""
    cmd2="'$DS/ifs/tls.sh' attatchs"
    cmd3="'$DS/ifs/upld.sh' upld "\"${tpc}\"""
    cmd4="'$DS/mngr.sh' 'delete_topic' "\"${tpc}\"""

    ([ -n "${ls2}" ] && echo "${ls2}" | awk '{print $0"\n"NR}') |yad --list --tabnum=1 \
    --window-icon=idiomind --plug=$KEY --print-all --separator='|' \
    --image="$DS/images/2.png" --image-on-top \
    --dclick-action="$DS/vwr.sh 2" \
    --expand-column=0 --no-headers --grid-lines=hor --ellipsize=end \
    --search-column=1 --regex-search \
    --column=Name:TEXT --column=@fore@ &
    yad --text-info --tabnum=2 --window-icon=idiomind \
    --text="<small>$(gettext "A space for notes, reminders, or anything you want to write down")</small>" \
    --plug=$KEY \
    --show-uri --uri-color="#6591AA" \
    --filename="${note}" --editable --wrap \
    --fontname='vendana 11' --margins=14 > "$cnf3" &
    yad --form --tabnum=3 --window-icon=idiomind \
    --plug=$KEY \
    --text="$lbl1${native_lang_info}\n" \
    --borders=25 --columns=2 \
    --field=" ":LBL " " \
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
    --tab="  $(gettext "Learnt") ($cfg2) " \
    --tab="  $(gettext "Note")  " \
    --tab="  $(gettext "Manage")  " \
    --width=530 --height=560 --borders=5 --tab-borders=0 \
    --button="$(gettext "Play")":"$cmd_play" \
    --button="$(gettext "Practice")":"$cmd_prac" \
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


function tpc_view() {

    _lst | yad --list --tabnum=1 --window-icon=idiomind \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="/usr/share/idiomind/play.sh play_word" \
    --select-action="/usr/share/idiomind/play.sh play_word" \
    --print-column=1 --expand-column=1 --grid-lines=hor  --no-headers \
    --ellipsize=end --wrap-width=460 --ellipsize-cols=2 \
    --search-column=1 --regex-search --hide-column=2 --tooltip-column=2 \
    --column=Name:TEXT --column=TIP:TEXT &
    echo "$note" | yad --text-info --tabnum=2 --window-icon=idiomind \
    --text="${itxt}\n" \
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
    --button="$(gettext "Close")!window-close":1
} >/dev/null 2>&1




function panelini() {



    # --------------------------------------------------
    # PANEL 2: ICONS (parte inferior)
    # --------------------------------------------------

    yad --icons \
        --single-click \
        --read-dir="$DS/default/" \
        --item-width=60 \
        --generic \
        --title="Idiomind" \
        --name=Idiomind \
        --class=Idiomind \
        --window-icon="$DS/images/logo.png" \
        --sticky --fixed \
        --width=197 \
        --height=205 \
        --on-top ${geometry} \
        --skip-taskbar \
        --borders=4 --no-buttons

}
        #--button=""!'list-add'!"$(gettext "Add Note, which can be a word or a sentence")":"$DS/add.sh 'new_items'" \
        #--button=""!'go-home'!"$(gettext "My Active Topic")":"idiomind 'topic'" \
        #--button=""!'gtk-index'!"$(gettext "My topics")":"$DS/chng.sh"

