#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh

function list_1() {
    while read list1; do
        echo "$DMP/content/$(nmfile "$list1").png"
        echo "$list1"
    done < "$DCP/cfg.1"
}

function list_2() {
    while read list2; do
        echo "$DMP/kept/$(nmfile "$list2").png"
        echo "$list2"
    done < "$DCP/cfg.2"
}

function podcast() {
    
    DMP="$DM_tl/Podcasts"
    DCP="$DM_tl/Podcasts/.conf"
    DSP="$DS/addons/Podcasts"
    c=$(echo $(($RANDOM%100000))); KEY=$c
    [ -f "$DT/.uptp" ] && \
    info=$(echo "<i>"$(gettext "Updating")"...</i>") || \
    info=$(cat "$DM_tl/Podcasts/.dt")
    
    cd "$DSP"; list_1 | yad \
    --no-headers --list --plug=$KEY --tabnum=1 \
    --text=" <small>${info^}</small>" --print-all \
    --expand-column=2 --ellipsize=END \
    --column=Name:IMG --column=Name \
    --dclick-action='./vwr.sh' &
    list_2 | yad --no-headers \
    --list --plug=$KEY --tabnum=2 \
    --expand-column=2 --ellipsize=END --print-all \
    --column=Name:IMG --column=Name \
    --dclick-action='./vwr.sh' &
    yad --notebook --name=idiomind --center \
    --class=Idiomind --align=right --key=$KEY \
    --tab-borders=0 --center --title="$FEED" \
    --tab=" $(gettext "Episodes") " \
    --tab=" $(gettext "Saved Episodes") " \
    --ellipsize=END --image-on-top \
    --window-icon=$DS/images/idiomind.png \
    --width="$wth" --height="$eht" --borders=0 \
    --button="Playlist":/usr/share/idiomind/play.sh \
    --button="gtk-refresh":2 \
    --button="$(gettext "Edit")":3
    ret=$?
        
    if [ $ret -eq 0 ]; then
        "$DSP/cnfg.sh" & killall topic.sh;
    
    elif [ $ret -eq 3 ]; then
        "$DSP/cnfg.sh" edit;
    
    elif [ $ret -eq 2 ]; then
        "$DSP/strt.sh";
    fi
    
    rm -f $DT/*.x & exit
}


if echo "$mde" | grep "pd"; then
    podcast; exit 1
fi
