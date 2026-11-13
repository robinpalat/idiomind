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

# La lista Learned representa el estado Learned en verde, independientemente
# de si la promoción fue automática o manual.
learnt_list_feed() {
    [ -n "${ls2}" ] || return 0
    printf '%s\n' "$ls2" | awk '{print "<span color=\"#4C8C12\">" $0 "</span>\n"NR}'
}

# YAD returns 252 when the dialog is closed through the window manager
# button (or Esc). main.sh interprets 2 as "apply the marked notes", so
# remap the close event to that code without adding a visible button.
# The caller must pass the notebook's exit code as $1, captured
# immediately after "wait", before running any other command (e.g. kill
# of the watchdog): any intervening command overwrites $? and the
# remapping would be lost. Without an argument, falls back to $?.
yad_close_code() {
    local ret=${1:-$?}
    [ "$ret" -eq 252 ] && ret=2
    return "$ret"
}

# A plugged list only prints its result when it receives SIGUSR1. The
# notebook sends that signal when one of its buttons is pressed, but not
# when the window is closed with the X button, so the checkbox state would
# be lost and apply would find an empty cnf1. Ask the child for its state
# periodically and keep the last value of each row, so cnf1 always holds
# the current selection when the dialog closes.
yad_list_print() {
    local tmpfifo
    tmpfifo="$DT/.yad_list_print_$$"
    mkfifo "$tmpfifo" 2>/dev/null
    awk -F'|' '{a[$1]=$0} END{for (k in a) print a[k]}' < "$tmpfifo" &
    local awkpid=$!
    yad "$@" > "$tmpfifo" 2>>"$DT/ylp_$$.err" &
    local ypid=$!
    ( sleep 0.3; while kill -0 "$ypid" 2>/dev/null; do kill -USR1 "$ypid" 2>/dev/null; sleep 0.05; done ) &
    wait "$ypid"
    wait "$awkpid"
    rm -f "$tmpfifo"
}

# Wait for a background producer (e.g. the yad_list_print pipeline that
# writes cnf1, or a plug writing cnf3/cnf4) to finish, with a bounded
# timeout. When the notebook host closes, its XEMBED plugs exit and
# flush their final output, so this normally returns at once; the
# timeout only guards against a plug that never exits, so apply()
# (called by main.sh after the notebook returns) never reads a
# half-written cnf1 and never hangs indefinitely.
#
# Do NOT use the `wait` builtin on the cnf1 producer: it is the last
# component of a pipeline (`listfeed | yad_list_print`), and `wait`
# on a pipeline job waits for *all* its components — including
# listfeed, which stays alive looping on its live fifo until oclean
# removes it. Waiting for it would hang the close indefinitely.
# Poll /proc instead: the producer is done when it disappears or
# becomes a zombie; bash reaps the zombie between commands.
wait_bounded() {
    local pid=$1 secs=${2:-3} i=0 max state
    [ -n "$pid" ] || return 0
    max=$((secs * 20))
    while [ "$i" -lt "$max" ]; do
        [ -d "/proc/$pid" ] || return 0
        state="$(awk '{print $3}' "/proc/$pid/stat" 2>/dev/null)"
        [ "$state" = "Z" ] && return 0
        sleep 0.05
        i=$((i + 1))
    done
    # Timeout: stop the producer (and its own children) and move on.
    pkill -9 -P "$pid" 2>/dev/null
    kill -9 "$pid" 2>/dev/null
    return 0
}

function notebook_1() {
    local nbret=0 printpid="" cnf3pid="" cnf4pid=""

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

    # El notebook crea el socket XEMBED; debe existir antes de que los plugs
    # intenten incrustarse, si no su ventana queda sin mapear y no aparece.
    rm -f "$DT/nb.xid"
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right \
    --window-icon=$DS/images/logo.png \
    --tab="  $(gettext "Learning") ($cfg1) " \
    --tab="  $(gettext "Learnt") ($cfg2) " \
    --tab="  $(gettext "Note")  " \
    --tab="  $(gettext "Manage")  " \
    --width=530 --height=560 --borders=0 --tab-borders=0 \
    --button="$(gettext "Play")":"$cmd_play" \
    --button="$(gettext "Practice")":"$cmd_prac" \
    --print-xid="$DT/nb.xid" &
    local nbid=$!
    for _ in {1..30}; do [ -s "$DT/nb.xid" ] && break; sleep 0.1; done
    if [ ! -s "$DT/nb.xid" ]; then kill "$nbid" 2>/dev/null; return 1; fi
    # Vigilante: si el notebook no llega a mapearse (carrera de registro de
    # plugs de YAD), se mata para no dejar procesos huérfanos.
    ( sleep 5; X=$(cat "$DT/nb.xid" 2>/dev/null)
      if [ -n "$X" ] && ! xprop -id "$X" WM_STATE 2>/dev/null | grep -q "WM_STATE(WM_STATE)"; then
        kill -9 "$nbid" 2>/dev/null; pkill -9 -f "plug=$KEY" 2>/dev/null
      fi ) &
    local wdog=$!

    listfeed | yad_list_print --list --tabnum=1 \
    --plug=$KEY --print-all --separator='|' --listen \
    --image="$DS/images/$((stts%2)).png" --image-on-top \
    --dclick-action="$DS/vwr.sh 1" \
    --print-column=1 --expand-column=1 --grid-lines=hor  --no-headers \
    --ellipsize=end --wrap-width=460 --ellipsize-cols=2 \
    --search-column=1 --regex-search --hide-column=4 --tooltip-column=4 \
    --column=Name:TEXT \
    --scroll \
    --column=@fore@ --column=Learned:CHK --column=@back@:TIP > "$cnf1" &
    printpid=$!
    sleep 0.15
    learnt_list_feed | \
    yad --list --tabnum=2 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh 2"  \
    --expand-column=0 --no-headers \
    --ellipsize=end --wrap-width=460 --ellipsize-cols=1 \
    --column=Name:TEXT --column=@fore@ &
    sleep 0.15
    yad --text-info --tabnum=3 \
    --text="<small>$(gettext "A space for notes, reminders, or anything you want to write down")</small>" \
    --plug=$KEY \
    --always-print-result \
    --show-uri --uri-color="#6591AA" \
    --filename="${note}" --editable --wrap \
    --fontname='vendana 11' --margins=14 > "$cnf3" &
    cnf3pid=$!
    sleep 0.15
    yad --form --tabnum=4 \
    --plug=$KEY \
    --scroll \
    --text="${lbl1}${info2}${native_lang_info}<small>$(gettext "Status:") $label_review</small>\n" \
    --borders=25 --columns=2 \
    --field=" $btn_review "!'gtk-apply':FBTN "$cmd_mark" \
    --field=" ":LBL " " \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field="\t\t\t\t\t\t\t\\t\t":LBL "_" \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn3":FBTN "$cmd3" \
    --field="$btn4":FBTN "$cmd4" > "$cnf4" &
    cnf4pid=$!
    sleep 0.15
    wait "$nbid"
    nbret=$?
    kill "$wdog" 2>/dev/null
    # The plugs die with the host and flush on exit; wait (bounded) for
    # the cnf1/cnf3/cnf4 producers so main.sh's apply() sees complete
    # files, without ever blocking indefinitely on a stuck plug.
    [ -n "$printpid" ] && wait_bounded "$printpid" 3
    [ -n "$cnf3pid" ] && wait_bounded "$cnf3pid" 3
    [ -n "$cnf4pid" ] && wait_bounded "$cnf4pid" 3
    yad_close_code "$nbret"
} >/dev/null 2>&1

# TODO
function notebook_2() {
    local nbret=0 printpid="" cnf3pid="" cnf4pid=""

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
    
    # El notebook crea el socket XEMBED; debe existir antes de los plugs.
    rm -f "$DT/nb.xid"
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result --no-buttons \
    --center --align=right --ellipsize=END \
    --window-icon=$DS/images/logo.png \
    --tab="  $(gettext "Learning") (0) " \
    --tab="  $(gettext "Learnt") ($cfg2) " \
    --tab="  $(gettext "Note")  " \
    --tab="  $(gettext "Manage")  " \
    --width=530 --height=530 --borders=0 --tab-borders=0 \
    --print-xid="$DT/nb.xid" &
    local nbid=$!
    for _ in {1..30}; do [ -s "$DT/nb.xid" ] && break; sleep 0.1; done
    if [ ! -s "$DT/nb.xid" ]; then kill "$nbid" 2>/dev/null; return 1; fi
    # Vigilante: si el notebook no llega a mapearse (carrera de registro de
    # plugs de YAD), se mata para no dejar procesos huérfanos.
    ( sleep 5; X=$(cat "$DT/nb.xid" 2>/dev/null)
      if [ -n "$X" ] && ! xprop -id "$X" WM_STATE 2>/dev/null | grep -q "WM_STATE(WM_STATE)"; then
        kill -9 "$nbid" 2>/dev/null; pkill -9 -f "plug=$KEY" 2>/dev/null
      fi ) &
    local wdog=$!

	yad --multi-progress --tabnum=1 \
	--text="$pres\n\n\n<small>$info6 </small>" \
	--plug=$KEY --image=hourglass\
	--align=center --borders=60 --bar="":NORM $days_to_review_porcent &
    learnt_list_feed |yad --list --tabnum=2 \
    --plug=$KEY --print-all --separator='|' \
    --dclick-action="$DS/vwr.sh 2" --grid-lines=hor \
    --expand-column=0 --no-headers --ellipsize=end \
    --search-column=1 --regex-search \
    --column=Name:TEXT --column=@fore@ &
    sleep 0.15
    yad --text-info --tabnum=3 --window-icon=idiomind \
    --plug=$KEY \
    --text="<small>$(gettext "A space for notes, reminders, or anything you want to write down")</small>" \
    --show-uri --uri-color="#6591AA" \
    --filename="${note}" --editable --wrap \
    --fontname='vendana 11' --margins=14 > "$cnf3" &
    cnf3pid=$!
    sleep 0.15
    if [ $stts = 7 ] || [ $stts = 8 ] || [ $stts = 9 ] || [ $stts = 10 ] || [ ${days_to_review_porcent} -ge 100 ]; then 
    yad --form --tabnum=4 \
    --plug=$KEY \
    --scroll \
    --text="$lbl1${native_lang_info}<small>$(gettext "Status:") $label_review</small>\n" \
    --borders=25 --columns=2 \
    --field=" $btn_review  "!'view-refresh':FBTN "$cmd_mark" \
    --field=" ":LBL " " \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field="\t\t\t\t\t\t\t\\t\t":LBL "_" \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn3":FBTN "$cmd3" \
    --field="$btn4":FBTN "$cmd4" > "$cnf4" &
    cnf4pid=$!
    sleep 0.15
    else
    yad --form --tabnum=4 \
    --plug=$KEY \
    --text="$lbl1${native_lang_info}<small>$(gettext "Status:") $label_review</small>\n" \
    --borders=25 --columns=2 \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field="\t\t\t\t\t\t\t\\t\t":LBL "_" \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn3":FBTN "$cmd3" \
    --field="$btn4":FBTN "$cmd4" > "$cnf4" &
    cnf4pid=$!
    sleep 0.15
    fi
    wait "$nbid"
    nbret=$?
    kill "$wdog" 2>/dev/null
    # The plugs die with the host and flush on exit; wait (bounded) for
    # the cnf1/cnf3/cnf4 producers so main.sh's apply() sees complete
    # files, without ever blocking indefinitely on a stuck plug.
    [ -n "$printpid" ] && wait_bounded "$printpid" 3
    [ -n "$cnf3pid" ] && wait_bounded "$cnf3pid" 3
    [ -n "$cnf4pid" ] && wait_bounded "$cnf4pid" 3
    yad_close_code "$nbret"
     
} >/dev/null 2>&1


function notebook_3() {
    local nbret=0 printpid="" cnf3pid="" cnf4pid=""

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

    # El notebook crea el socket XEMBED; debe existir antes de los plugs.
    rm -f "$DT/nb.xid"
    yad --notebook --title="Idiomind - $tpc" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right --ellipsize=END \
    --window-icon=$DS/images/logo.png \
    --tab="  $(gettext "Learnt") ($cfg2) " \
    --tab="  $(gettext "Note")  " \
    --tab="  $(gettext "Manage")  " \
    --width=530 --height=560 --borders=0 --tab-borders=0 \
    --button="$(gettext "Play")":"$cmd_play" \
    --button="$(gettext "Practice")":"$cmd_prac" \
    --print-xid="$DT/nb.xid" &
    local nbid=$!
    for _ in {1..30}; do [ -s "$DT/nb.xid" ] && break; sleep 0.1; done
    if [ ! -s "$DT/nb.xid" ]; then kill "$nbid" 2>/dev/null; return 1; fi
    # Vigilante: si el notebook no llega a mapearse (carrera de registro de
    # plugs de YAD), se mata para no dejar procesos huérfanos.
    ( sleep 5; X=$(cat "$DT/nb.xid" 2>/dev/null)
      if [ -n "$X" ] && ! xprop -id "$X" WM_STATE 2>/dev/null | grep -q "WM_STATE(WM_STATE)"; then
        kill -9 "$nbid" 2>/dev/null; pkill -9 -f "plug=$KEY" 2>/dev/null
      fi ) &
    local wdog=$!

    learnt_list_feed |yad --list --tabnum=1 \
    --window-icon=idiomind --plug=$KEY --print-all --separator='|' \
    --image="$DS/images/2.png" --image-on-top \
    --dclick-action="$DS/vwr.sh 2" \
    --expand-column=0 --no-headers --grid-lines=hor --ellipsize=end \
    --search-column=1 --regex-search \
    --column=Name:TEXT --column=@fore@ &
    sleep 0.15
    yad --text-info --tabnum=2 \
    --text="<small>$(gettext "A space for notes, reminders, or anything you want to write down")</small>" \
    --plug=$KEY \
    --show-uri --uri-color="#6591AA" \
    --filename="${note}" --editable --wrap \
    --fontname='vendana 11' --margins=14 > "$cnf3" &
    cnf3pid=$!
    sleep 0.15
    yad --form --tabnum=3 \
    --plug=$KEY \
    --scroll \
    --text="$lbl1${native_lang_info}\n" \
    --borders=25 --columns=2 \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field="<small>$(gettext "Rename")</small>" "${tpc}" \
    --field="\t\t\t\t\t\t\t\\t\t":LBL "_" \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field=" ":LBL " " \
    --field="$btn1":FBTN "$cmd1" \
    --field="$btn3":FBTN "$cmd3" \
    --field="$btn4":FBTN "$cmd4" > "$cnf4" &
    cnf4pid=$!
    sleep 0.15
    wait "$nbid"
    nbret=$?
    kill "$wdog" 2>/dev/null
    # The plugs die with the host and flush on exit; wait (bounded) for
    # the cnf1/cnf3/cnf4 producers so main.sh's apply() sees complete
    # files, without ever blocking indefinitely on a stuck plug.
    [ -n "$printpid" ] && wait_bounded "$printpid" 3
    [ -n "$cnf3pid" ] && wait_bounded "$cnf3pid" 3
    [ -n "$cnf4pid" ] && wait_bounded "$cnf4pid" 3
    yad_close_code "$nbret"
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

    # El notebook crea el socket XEMBED; debe existir antes de los plugs.
    rm -f "$DT/nb.xid"
    yad --notebook --title="$name" \
    --name=Idiomind --class=Idiomind --key=$KEY \
    --always-print-result \
    --center --align=right \
    --window-icon=$DS/images/logo.png \
    --tab="  $(gettext "Notes") " \
    --tab="  $(gettext "Details")  " \
    --width=530 --height=560 --borders=0 --tab-borders=0 \
    --button="$(gettext "Install")":0 \
    --print-xid="$DT/nb.xid" &
    local nbid=$!
    for _ in {1..30}; do [ -s "$DT/nb.xid" ] && break; sleep 0.1; done
    if [ ! -s "$DT/nb.xid" ]; then kill "$nbid" 2>/dev/null; return 1; fi
    # Vigilante: si el notebook no llega a mapearse (carrera de registro de
    # plugs de YAD), se mata para no dejar procesos huérfanos.
    ( sleep 5; X=$(cat "$DT/nb.xid" 2>/dev/null)
      if [ -n "$X" ] && ! xprop -id "$X" WM_STATE 2>/dev/null | grep -q "WM_STATE(WM_STATE)"; then
        kill -9 "$nbid" 2>/dev/null; pkill -9 -f "plug=$KEY" 2>/dev/null
      fi ) &
    local wdog=$!

    _lst | yad --list --tabnum=1 \
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
    wait "$nbid"
    kill "$wdog" 2>/dev/null
} >/dev/null 2>&1


function panelini() {
	
	geometry=$(cdb ${cfgdb} 1 geom vals)
    if [ -z "$geometry" ]; then geometry="0x0"; fi
	
	 #--select-action="/usr/share/idiomind/ifs/tasks.sh"
	(if [ -s "$DT/tasks"  ]; then cat "$DT/tasks"; \
	else echo "$(gettext "no tasks")"; fi) \
	| yad --title="Idiomind" --list \
    --name=Idiomind --class=Idiomind --dclick-action="" \
    --separator="" --expander="$(gettext "Tasks")" \
    --scroll --grid-lines=hor \
    --dclick-action="/usr/share/idiomind/ifs/tasks.sh" \
    --window-icon=$DS/images/logo.png \
    --hscroll-policy=auto --vscroll-policy=never \
    --expand-column=1 --no-click --no-headers \
    --text-align=left --align=left --buttons-layout=spread \
    --geometry="${geometry}" --borders=4  --column=Name:TEXT \
    --fixed --width=20 --height=20 \
    --button=""!'list-add'!"$(gettext "Add Note, which can be a word or a sentence")":"$DS/add.sh 'new_items'" \
    --button=""!'go-home'!"$(gettext "My Active Topic")":"idiomind 'topic'" \
    --button=""!'gtk-index'!"$(gettext "My topics")":"$DS/chng.sh"  \
    --button=""!'list-add'!"$(gettext "Add Note, which can be a word or a sentence")":"$DS/add.sh 'new_items'"
}

