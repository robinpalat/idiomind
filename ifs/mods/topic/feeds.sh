#!/bin/bash
# -*- ENCODING: UTF-8 -*-


function list_1() {
    while read list1; do
        echo "$DMF/cache/$(nmfile "$list1").png"
        echo "$list1"
    done < "$DCF/1.cfg"
}

function list_2() {
    while read list2; do
        echo "$DMF/cache/$(nmfile "$list2").png"
        echo "$list2"
    done < "$DCF/2.cfg"
}

function feedmode() {
    
    DMF="$DM_tl/Feeds"
    DCF="$DM_tl/Feeds/.conf"
    DSF="$DS/addons/Feeds"
    nt="$DCF/cnf.10"; ntmp=$(mktemp $DT/XXX)
    c=$(echo $(($RANDOM%100000))); KEY=$c
    [ -f "$DT/.uptp" ] && \
    info=$(echo "<i>"$(gettext "Updating")"...</i>") || \
    info=$(cat "$DM_tl/Feeds/.dt")
    nt="$(cat "$nt")"

    list_1 | yad --limit=100 --hide-column=2 \
    --no-headers --list --plug=$KEY --tabnum=1 --print-all \
    --text="  <small>${info^}</small>" --listen \
    --expand-column=1 --ellipsize=END --column=Name:IMG \
    --column=Name:TIP --dclick-action="'$DSF/vwr.sh'" &
    list_2 | yad --no-headers --list --plug=$KEY --tabnum=2 \
    --expand-column=2 --ellipsize=END --print-all \
    --column=Name:IMG --column=Name --dclick-action="$DSF/vwr.sh" &
    yad --form --borders=10 --plug=$KEY --tabnum=3 --columns=2 \
    --field="Notes":txt "$nt" \
    --field=" ":lbl "tpc" --field=" ":lbl " " \
    --field="\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t":lbl " " \
    --field=" ":lbl " " \
    --field="Syncronize":btn "$DS/mngr.sh 'mkok-'" \
    --field="Delete":btn "$DS/mngr.sh 'mklg-'" &
    yad --notebook --name=idiomind --center \
    --class=Idiomind --align=right --key=$KEY \
    --tab-borders=0 --center --title="$FEED" \
    --tab=" $(gettext "News") " \
    --tab=" $(gettext "Saved News") " \
    --tab=" $(gettext "Edit") " --always-print-result \
    --ellipsize=END --image-on-top \
    --window-icon=$DS/images/idiomind.png \
    --width="$wth" --height="$eht" --borders=0 \
    --button="Playlist":/usr/share/idiomind/play.sh \
    --button="gtk-refresh":2
    ret=$?
        
    if [ $ret -eq 0 ]; then
        "$DSF/cnfg.sh" & killall topic.sh;
    
    elif [ $ret -eq 3 ]; then
        "$DSF/cnfg.sh" edit;
    
    elif [ $ret -eq 2 ]; then
        "$DSF/strt.sh";
    fi
    
    if [ "$(cat $nt)" != "$(cat "$ntmp")" ]; then
        mv -f "$ntmp" "$nt";
    fi
}

if echo "$mde" | grep "fd"; then
    feedmode
    exit 1
fi
