#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh

function list_1() {
    while read list1; do
        echo "$DM_tl/Podcasts/content/$(nmfile "$list1").png"
        echo "$list1"
    done < "$DMF/.conf/cfg.1"
    
}

function list_2() {
    while read list2; do
        echo "$DM_tl/Podcasts/kept/$(nmfile "$list2").png"
        echo "$list2"
    done < "$DMF/.conf/cfg.2"
}

function podcast() {
    
        DMF="$DM_tl/Podcasts"
        DCF="$DC_a/Podcasts"
        DSF="$DS/addons/Podcasts"
        ICON="$DSF/images/rss.png"
        c=$(echo $(($RANDOM%100000)))
        [ -f $DT/.uptp ] && updt="$(cat $DT/.uptp)" || updt=""
        KEY=$c
        if echo "$updt" | grep "updating"; then
            info=$(echo "<i>"$(gettext "Updating")"...</i>")
        else
            info=$(cat $DM_tl/Podcasts/.dt)
        fi
        #if [[ ! -f "$DM_tl/Podcasts/.conf/cfg.1" ]]; then
        #cp -f "$DM_tl/Podcasts/.conf/.cfg.11" \
        #"$DM_tl/Podcasts/.conf/cfg.1"
        #fi
        cd "$DSF"

        list_1 | yad \
        --no-headers --list --plug=$KEY --tabnum=1 \
        --text=" <small>$info</small>" --print-all \
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
        --tab="  $(gettext "Episodes")  " \
        --tab=" $(gettext "Saved Episodes") " \
        --ellipsize=END --image-on-top \
        --window-icon=$DS/images/idiomind.png \
        --width="$wth" --height="$eht" --borders=0 \
        --button="Play":/usr/share/idiomind/play.sh \
        --button="gtk-refresh":2 \
        --button="$(gettext "Edit")":3
        ret=$?
            
            if [ $ret -eq 0 ]; then
                rm -f $DT/*.x
                "$DSF/cnfg.sh" & killall topic.sh & exit
            
            elif [ $ret -eq 3 ]; then
                rm -f $DT/*.x
                "$DSF/cnfg.sh" edit & exit
            
            elif [ $ret -eq 2 ]; then
                rm -f $DT/*.x
                "$DSF/strt.sh" & exit
            fi
}


if echo "$mde" | grep "pd"; then
    podcast
    exit 1
fi
