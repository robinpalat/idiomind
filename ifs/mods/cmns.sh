#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function internet() {

    curl -v www.google.com 2>&1 \
    | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
    yad --title="$(gettext "No network connection")" --image=info \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --image-on-top --center --sticky --on-top --skip-taskbar \
    --text="$(gettext "No network connection\nPlease connect to a network, then try again.")" \
    --width=380 --height=120 --borders=3 \
    --button="$(gettext "OK")":0 >&2; exit 1;}
}

function msg() {
        
    [ -n "$3" ] && title="$3" || title=Idiomind
    [ -n "$4" ] && btn="$4" || btn="$(gettext "OK")"
    yad --title="$title" --text="$1" --image="$2" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --image-on-top --center --sticky --on-top \
    --width=380 --height=120 --borders=3 \
    --button="$btn":0
}

function msg_2() {
        
    [ -n "$5" ] && title="$5" || title=Idiomind
    [ -n "$6" ] && btn3="--button=$6:2" || btn3=""
    yad --title="$title" --text="$1" --image="$2" \
    --name=Idiomind --class=Idiomind \
    --always-print-result \
    --window-icon="$DS/images/icon.png" \
    --image-on-top --on-top --sticky --center \
    --width=380 --height=120 --borders=3 \
    "$btn3" --button="$4":1 --button="$3":0
}

function nmfile() {
        
  echo -n "${1^}" | md5sum | rev | cut -c 4- | rev
}

function include() {
        
  for f in "$1"/*; do source "$f"; done

}

function lnglss() {

    [ "${1^}" = English ] && lg=en
    [ "${1^}" = French ] && lg=fr
    [ "${1^}" = German ] && lg=de
    [ "${1^}" = Chinese ] && lg=zh-cn
    [ "${1^}" = Italian ] && lg=it
    [ "${1^}" = Japanese ] && lg=ja
    [ "${1^}" = Portuguese ] && lg=pt
    [ "${1^}" = Spanish ] && lg=es
    [ "${1^}" = Vietnamese ] && lg=vi
    [ "${1^}" = Russian ] && lg=ru
    echo "$lg"
}

function check_index1() {
    
    for i in "${@}"; do
        if [ -n "$(sort -n < "$i" | uniq -dc)" ]; then
            awk '!array_temp[$0]++' < "$i" > "$DT/tmp"
            sed '/^$/d' "$DT/tmp" > "$i"; rm -f "$DT/tmp"
        fi
    done
}


function calculate_review() {
    
    dts=$(sed '/^$/d' < "$DC_tlt/9.cfg" | wc -l)
    if [[ $dts = 1 ]]; then
    dte=$(sed -n 1p "$DC_tlt/9.cfg")
    adv="<b>  6 $cuestion_review </b>"
    TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
    RM=$((100*TM/6))
    tdays=6
    elif [[ $dts = 2 ]]; then
    dte=$(sed -n 2p "$DC_tlt/9.cfg")
    adv="<b>  10 $cuestion_review </b>"
    TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
    RM=$((100*TM/10))
    tdays=10
    elif [[ $dts = 3 ]]; then
    dte=$(sed -n 3p "$DC_tlt/9.cfg")
    adv="<b>  15 $cuestion_review </b>"
    TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
    RM=$((100*TM/15))
    tdays=15
    elif [[ $dts = 4 ]]; then
    dte=$(sed -n 4p "$DC_tlt/9.cfg")
    adv="<b>  20 $cuestion_review </b>"
    TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
    RM=$((100*TM/20))
    tdays=20
    elif [[ $dts = 5 ]]; then
    dte=$(sed -n 5p "$DC_tlt/9.cfg")
    adv="<b>  30 $cuestion_review </b>"
    TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
    RM=$((100*TM/30))
    tdays=30
    elif [[ $dts = 6 ]]; then
    dte=$(sed -n 6p "$DC_tlt/9.cfg")
    adv="<b>  40 $cuestion_review </b>"
    TM=$(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) ))
    RM=$((100*TM/40))
    tdays=40
    fi
}
