#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf

function podcast() {
    
        DMF="$DM_tl/Podcasts"
        DCF="$DC_a/Podcasts"
        DSF="$DS/addons/Podcasts"
        FEED=$(cat "$DCF/$lgtl/.rss")
        ICON="$DSF/images/rss.png"
        c=$(echo $(($RANDOM%100000)))
        [ -f $DT/.uptp ] && STT="$(cat $DT/.uptp)" || STT=""
        KEY=$c
        if echo "$STT" | grep "updating"; then
            info=$(echo "<i>"$(gettext "Updating")"...</i>")
            FEED=$(cat "$DT/.rss")
        else
            info=$(cat $DM_tl/Podcasts/.dt)
        fi
        if [[ ! -f "$DM_tl/Podcasts/.conf/cfg.1" ]]; then
        cp -f "$DM_tl/Podcasts/.conf/.cfg.11" \
        "$DM_tl/Podcasts/.conf/cfg.1"
        fi
        cd "$DSF"

        cat "$DM_tl/Podcasts/.conf/cfg.1" | yad \
        --no-headers --list --listen --plug=$KEY --tabnum=1 \
        --text=" <small>$info</small>" \
        --expand-column=1 --ellipsize=END --print-all \
        --column=Name:TEXT --dclick-action='./vwr.sh V1' &
        cat "$DMF/.conf/cfg.2" | yad --no-headers \
        --list --listen --plug=$KEY --tabnum=2 \
        --expand-column=1 --ellipsize=END --print-all \
        --column=Name:TEXT --dclick-action='./vwr.sh V2' &
        yad --notebook --name=Idiomind --center \
        --class=Idiomind --align=right --key=$KEY \
        --text=" <big><big>$(gettext "Podcasts") </big></big>\\n <small>$FEED</small>" \
        --image="$ICON" --image-on-top  \
        --tab-borders=0 --center --title="$FEED" \
        --tab="  $(gettext "Episodes")  " \
        --tab=" $(gettext "Saved Episodes") " \
        --ellipsize=END --image-on-top \
        --window-icon=$DS/images/idiomind.png \
        --width="$wth" --height="$eht" --borders=0 \
        --button="Play":/usr/share/idiomind/play.sh \
        --button="$(gettext "Update")":2 \
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
