#!/bin/bash
# -*- ENCODING: UTF-8 -*-

    
    
    #web="/tmp/.idmtp1.robin/Test_7_february/index.html"
    #yad --html --window-icon=idiomind --browser --plug=$KEY --tabnum=1 \
    #--title="$(gettext "Help")" --width=700 \
    #--height=600 --button="$(gettext "OK")":0 \
    #--name=Idiomind --class=Idiomind \
    #--uri="$web" >/dev/null 2>&1 &

function notebook_1() {
    
    cat "$ls1" | awk '{print $0"\n"}' | yad \
    --no-headers --list --plug=$KEY --tabnum=1 \
    --dclick-action='./vwr.sh v1' --print-all \
    --expand-column=1 --ellipsize=END \
    --column=Name:TEXT --column=Learned:CHK > "$cnf1" &
    cat "$ls2" | yad --no-headers --list --plug=$KEY --tabnum=2 \
    --expand-column=0 --ellipsize=END --print-all --separator='|' \
    --column=Name:TEXT --dclick-action='./vwr.sh v2' &
    yad --form --scroll --borders=10 --plug=$KEY --tabnum=3 --columns=2 \
    --text="$itxt" --image="$img" \
    --field="Notes\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t":txt "$nt" \
    --field=" <small>Rename</small>: " "$tpc" \
    --field="Marcar Tema Como Aprendido":FBTN "$DS/mngr.sh 'mkok-'" \
    --field="$itxt2":LBL " " \
    --field="$(gettext "Share")":FBTN "$DS/ifs/upld.sh" \
    --field="Delete":FBTN "$DS/mngr.sh 'delete_topic'" > "$cnf3" &
    yad --notebook --name=Idiomind --center --key=$KEY \
    --class=Idiomind --align=right \
    --window-icon=idiomind \
    --tab-borders=0 --center --title="Idiomind - $tpc" \
    --tab="  $(gettext "Learning") ($tb1) " \
    --tab="  $(gettext "Learned") ($tb2) " \
    --tab=" $(gettext "Edit") " \
    --ellipsize=END --image-on-top --always-print-result \
    --width="$wth" --height="$eht" --borders=0 \
    --button="<small>$(gettext "Play/Stop")</small>":$DS/play.sh \
    --button="$(gettext "Practice")":5 \
    --button="gtk-close":1
}


function notebook_2() {
    
    yad --align=center --borders=80 \
    --text="$pres" --bar="":NORM $RM \
    --multi-progress --plug=$KEY --tabnum=1 &
    cat "$ls2" | yad \
    --no-headers --list --plug=$KEY --tabnum=2 \
    --expand-column=1 --ellipsize=END --print-all \
    --column=Name:TEXT --dclick-action='./vwr.sh v2' &
    yad --form --scroll --borders=10 --plug=$KEY --tabnum=3 --columns=2 \
    --field="Notes\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t":txt "$nt" \
    --field=" <small>Rename</small>: " "$tpc" \
    --field="Review":FBTN "$DS/mngr.sh 'mklg-'" \
    --field="$itxt2":LBL " " \
    --field="$(gettext "Share")":FBTN "$DS/ifs/upld.sh" \
    --field="Delete":FBTN "$DS/mngr.sh 'delete_topic'" > "$cnf3" &
    yad --notebook --name=Idiomind --center \
    --class=Idiomind --align=right --key=$KEY \
    --tab-borders=0 --center --title="Idiomind - $tpc" \
    --window-icon=idiomind \
    --tab=" $(gettext "Review") " \
    --tab=" $(gettext "Learned") ($tb2) " \
    --tab=" $(gettext "Edit") " \
    --ellipsize=END --image-on-top --always-print-result \
    --width="$wth" --height="$eht" --borders=0 \
    --button="gtk-close":1
}


function dialog_1() {
    
    yad --title="$tpc" --window-icon=idiomind \
    --borders=20 --buttons-layout=edge \
    --image=dialog-question --on-top --center \
    --window-icon=idiomind \
    --buttons-layout=edge --class=idiomind \
    --button="       $(gettext "Not Yet")       ":1 \
    --button="        $(gettext "Review")        ":2 \
    --text="$(gettext "days have passed since you mark\n  this topic as learned, you want to review it?")" \
    --name=Idiomind --width=420 --height=150 --class=Idiomind
}


function dialog_2() {
    
    yad --title="$tpc" --window-icon=idiomind \
    --borders=5 --name=Idiomind \
    --image=dialog-question \
    --on-top --window-icon=idiomind \
    --center --class=Idiomind \
    --button="$(gettext "Only New items")":3 \
    --button="$(gettext "All Items")":2 \
    --text="  $(gettext "Go over whole list or only new items?") " \
    --width=420 --height=150
}


function calculate_review() {
    
    dts=$(cat "$DC_tlt/9.cfg" | wc -l)
    if [ $dts = 1 ]; then
        dte=$(sed -n 1p "$DC_tlt/9.cfg")
        adv="<b>   10 $cuestion_review </b>"
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/10))
        tdays=10
    elif [ $dts = 2 ]; then
        dte=$(sed -n 2p "$DC_tlt/9.cfg")
        adv="<b> 15 $cuestion_review </b>"
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/15))
        tdays=15
    elif [ $dts = 3 ]; then
        dte=$(sed -n 3p "$DC_tlt/9.cfg")
        adv="<b>  30 $cuestion_review </b>"
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/30))
        tdays=30
    elif [ $dts = 4 ]; then
        dte=$(sed -n 4p "$DC_tlt/9.cfg")
        adv="<b>  60 $cuestion_review </b>"
        TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
        RM=$((100*$TM/60))
        tdays=60
    fi
}
