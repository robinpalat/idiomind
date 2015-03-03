#!/bin/bash
# -*- ENCODING: UTF-8 -*-


function notebook_1() {
    
    cat "$ls1" | awk '{print $0"\n"}' | yad \
    --no-headers --list --plug=$KEY --tabnum=1 \
    --dclick-action='./vwr.sh v1' --print-all \
    --expand-column=1 --ellipsize=END \
    --column=Name:TEXT --column=Learned:CHK > "$cnf1" &
    cat "$ls2" | yad \
    --no-headers --list --plug=$KEY --tabnum=2 \
    --expand-column=0 --ellipsize=END --print-all \
    --column=Name:TEXT \
    --dclick-action='./vwr.sh v2' &
    yad --text-info --plug=$KEY --margins=14 \
    --tabnum=3 --text="$itxt2" --fore='gray40' --wrap --editable \
    --show-uri --fontname=vendana \
    --filename="$nt" > "$cnf3" &
    yad --notebook --name=idiomind --center --key=$KEY \
    --class=Idiomind --align=right \
    --window-icon=$DS/images/idiomind.png \
    --tab-borders=0 --center --title="Idiomind" \
    --image="$img" --text="$itxt" \
    --tab="  $(gettext "Learning") ($tb1) " \
    --tab="  $(gettext "Learned") ($tb2) " \
    --tab=" $(gettext "Notes") " \
    --ellipsize=END --image-on-top --always-print-result \
    --width="$wth" --height="$eht" --borders=0 \
    --button="$(gettext "Play")":$DS/play.sh \
    --button="$(gettext "Practice")":5 \
    --button="$(gettext "Edit")":3
}


function notebook_2() {
    
    yad --align=center --borders=80 \
    --text="$pres" --bar="":NORM $RM \
    --multi-progress --plug=$KEY --tabnum=1 &
    cat "$ls2" | yad \
    --no-headers --list --plug=$KEY --tabnum=2 \
    --expand-column=1 --ellipsize=END --print-all \
    --column=Name:TEXT \
    --dclick-action='./vwr.sh v2' &
    yad --text-info --plug=$KEY --margins=14 --text="$itxt2" \
    --tabnum=3 --fore='gray40' --wrap --filename="$nt" \
    --show-uri --fontname=vendana --editable > "$cnf3" &
    yad --notebook --name=idiomind --center \
    --class=Idiomind --align=right --key=$KEY \
    --tab-borders=0 --center --title="Idiomind" \
    --image="$img" --text="$itxt" \
    --window-icon=$DS/images/idiomind.png \
    --tab=" $(gettext "Review") " \
    --tab=" $(gettext "Learned") ($tb2) " \
    --tab=" $(gettext "Notes") " \
    --ellipsize=END --image-on-top --always-print-result \
    --width="$wth" --height="$eht" --borders=0 \
    --button="$(gettext "Edit")":3
}


function dialog_1() {
    
    yad --title="$tpc" --window-icon=idiomind \
    --borders=20 --buttons-layout=edge \
    --image=dialog-question --on-top --center \
    --window-icon=$DS/images/idiomind.png \
    --buttons-layout=edge --class=idiomind \
    --button="       $(gettext "Not Yet")       ":1 \
    --button="        $(gettext "Review")        ":2 \
    --text="$(gettext "days have passed since you mark\n  this topic as learned, you want to review it?")" \
    --name=idiomind --width=420 --height=150
}


function dialog_2() {
    
    yad --title="$tpc" --window-icon=idiomind \
    --borders=5 --name=idiomind \
    --image=dialog-question \
    --on-top --window-icon=idiomind \
    --center --class=idiomind \
    --button="$(gettext "Only New items")":3 \
    --button="$(gettext "All Items")":2 \
    --text="  $(gettext "Go over whole list or only new items?") " \
    --width=420 --height=150
}


function calculate_review() {
    
    dts=$(cat "$DC_tlt/cfg.9" | wc -l)
    if [ $dts = 1 ]; then
        dte=$(sed -n 1p "$DC_tlt/cfg.9")
        adv="<b>   10 $cuestion_review </b>"
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/10))
        tdays=10
    elif [ $dts = 2 ]; then
        dte=$(sed -n 2p "$DC_tlt/cfg.9")
        adv="<b> 15 $cuestion_review </b>"
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/15))
        tdays=15
    elif [ $dts = 3 ]; then
        dte=$(sed -n 3p "$DC_tlt/cfg.9")
        adv="<b>  30 $cuestion_review </b>"
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/30))
        tdays=30
    elif [ $dts = 4 ]; then
        dte=$(sed -n 4p "$DC_tlt/cfg.9")
        adv="<b>  60 $cuestion_review </b>"
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/60))
        tdays=60
    fi
}
