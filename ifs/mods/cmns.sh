#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function internet() {
    curl -v www.google.com 2>&1 \
    | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { zenity --info \
    --text="$(gettext "No network connection\nPlease connect to a network, then try again.")  " \
    >&2; exit 1;}
}

function msg() {
    [ -n "$3" ] && title="$3" || title=Idiomind
    [ -n "$4" ] && btn="$4" || btn="$(gettext "OK")"
    yad --title="$title" --text="$1" --image="$2" \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind \
    --image-on-top --center --sticky --on-top \
    --width=410 --height=130 --borders=3 \
    --button="$btn":0
}

function msg_2() {
    [ -n "$5" ] && title="$5" || title=Idiomind
    [ -n "$6" ] && btn3="--button=$6:2" || btn3=""
    yad --title="$title" --text="$1" --image="$2" \
    --name=Idiomind --class=Idiomind \
    --always-print-result \
    --window-icon=idiomind \
    --image-on-top --on-top --sticky --center \
    --width=400 --height=120 --borders=3 \
    "$btn3" --button="$4":1 --button="$3":0
}

numer='^[0-9]+$'

function nmfile() {
    echo -n "${1}" | md5sum | rev | cut -c 4- | rev
}

function set_name_file() {
    id=":[type={$1},trgt={$2},srce={$3},exmp={$4},defn={$5},note={$6},wrds={$7},grmr={$8},]."
    echo -n "${id}" | md5sum | rev | cut -c 4- | rev
}

function include() {
  for f in "$1"/*; do source "$f"; done
}

function f_lock() {
    brk=0
    while true; do
        if [ ! -e "${1}" -o ${brk} -gt 20 ]; then touch "${1}" & break
        elif [ -e "${1}" ]; then sleep 1; fi
        let brk++
    done
}

function check_index1() {
    for i in "${@}"; do
        if [ -n "$(sort -n < "$i" | uniq -dc)" ]; then
            awk '!array_temp[$0]++' < "$i" > "$DT/tmp"
            sed '/^$/d' "$DT/tmp" > "$i"; rm -f "$DT/tmp"
        fi
    done
}

function list_inadd() {
    if ls -tNd "$DM_tl"/*/ 1> /dev/null 2>&1; then
        while read -r topic; do
            if ! echo -e "$(ls -1a "$DS/addons/")\n$(cat "$DM_tl/.3.cfg")" \
            |grep -Fxo "${topic}" >/dev/null 2>&1; then
                [ ! -L "$DM_tl/${topic}" ] && echo "${topic}"
            fi
        done < <(cd "$DM_tl"; ls -tNd */ |head -n 20 |sed 's/\///g')
    fi
}

function cleanups() {
    for fl in "$@"; do
        if [ -d "${fl}" ]; then
            rm -fr "${fl}"
        elif [ -f "${fl}" ]; then
            rm -f "${fl}"
        fi
    done
}

function get_item() {
    export item="$(sed 's/},/}\n/g' <<<"${1}")"
    export type="$(grep -oP '(?<=type={).*(?=})' <<<"${item}")"
    export trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
    export srce="$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")"
    export exmp="$(grep -oP '(?<=exmp={).*(?=})' <<<"${item}")"
    export defn="$(grep -oP '(?<=defn={).*(?=})' <<<"${item}")"
    export note="$(grep -oP '(?<=note={).*(?=})' <<<"${item}")"
    export wrds="$(grep -oP '(?<=wrds={).*(?=})' <<<"${item}")"
    export grmr="$(grep -oP '(?<=grmr={).*(?=})' <<<"${item}")"
    export mark="$(grep -oP '(?<=mark={).*(?=})' <<<"${item}")"
    export link="$(grep -oP '(?<=link={).*(?=})' <<<"${item}")"
    export tag="$(grep -oP '(?<=tag={).*(?=})' <<<"${item}")"
    export id="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${item}")"
}

function progress() {
    yad --progress \
    --progress-text="$1" \
    --width 50 --height 35 --undecorated \
    --pulsate --auto-close \
    --skip-taskbar --center --no-buttons
}


function calculate_review() {
    DC_tlt="$DM_tl/${1}/.conf"
    dts=$(sed '/^$/d' < "${DC_tlt}/9.cfg" | wc -l)
    
    if [ ${dts} = 1 ]; then
        dte=$(sed -n 1p "${DC_tlt}/9.cfg")
        adv="<b>  6 $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/6))
        tdays=6
    elif [ ${dts} = 2 ]; then
        dte=$(sed -n 2p "${DC_tlt}/9.cfg")
        adv="<b>  6 $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/6))
        tdays=6
    elif [ ${dts} = 3 ]; then
        dte=$(sed -n 3p "${DC_tlt}/9.cfg")
        adv="<b>  10 $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/10))
        tdays=10
    elif [ ${dts} = 4 ]; then
        dte=$(sed -n 4p "${DC_tlt}/9.cfg")
        adv="<b>  15 $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/15))
        tdays=15
    elif [ ${dts} = 5 ]; then
        dte=$(sed -n 5p "${DC_tlt}/9.cfg")
        adv="<b>  20 $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/20))
        tdays=20
    elif [ ${dts} = 6 ]; then
        dte=$(sed -n 6p "${DC_tlt}/9.cfg")
        adv="<b>  30 $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/30))
        tdays=30
    elif [ ${dts} = 7 ]; then
        dte=$(sed -n 7p "${DC_tlt}/9.cfg")
        adv="<b>  40 $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/40))
        tdays=40
    elif [ ${dts} = 8 ]; then
        dte=$(sed -n 8p "${DC_tlt}/9.cfg")
        adv="<b>  60 $cuestion_review </b>"
        TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
        RM=$((100*TM/60))
        tdays=60
    fi
    return ${RM}
}


