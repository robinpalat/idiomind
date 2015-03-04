#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function feedmode() {
    
        DMF="$DM_tl/Feeds"
        DCF="$DC/addons/Learning with news"
        DSF="$DS/addons/Learning with news"
        FEED=$(cat "$DCF/$lgtl/.rss")
        ICON="$DSF/images/rss.png"
        c=$(echo $(($RANDOM%100000)))
        STT="$(cat $DT/.uptf)"
        KEY=$c
        if echo "$STT" | grep "updating..."; then
            info=$(echo "<i>"$(gettext "Updating")"...</i>")
            FEED=$(cat "$DT/.rss")
        else
            info=$(cat $DM_tl/Feeds/.dt)
        fi
        if [[ ! -f "$DM_tl/Feeds/.conf/cfg.1" ]]; then
        cd "$DMF/content"
        ls -t *.mp3 > "$DM_tl/Feeds/.conf/cfg.1"
        sed -i 's/.mp3//g' "$DM_tl/Feeds/.conf/cfg.1"
        fi
        cd "$DSF"
        cat "$DM_tl/Feeds/.conf/cfg.1" | yad \
        --no-headers --list --listen --plug=$KEY --tabnum=1 \
        --text=" <small>$info | $FEED </small>" \
        --expand-column=1 --ellipsize=END --print-all \
        --column=Name:TEXT --dclick-action='./vwr.sh V1' &
        cat "$DM_tl/Feeds/.conf/cfg.0" | awk '{print $0""}' \
        | yad --no-headers --list --listen --plug=$KEY --tabnum=2 \
        --expand-column=1 --ellipsize=END --print-all \
        --column=Name:TEXT --dclick-action='./vwr.sh V2' &
        yad --notebook --name=Idiomind --center \
        --class=Idiomind --align=right --key=$KEY \
        --tab-borders=0 --center --title="$(gettext "News")" \
        --tab="  $(gettext "News")  " \
        --tab=" $(gettext "Saved Content") " \
        --ellipsize=END --image-on-top \
        --window-icon=$DS/images/idiomind.png \
        --width="$wth" --height="$eht" --borders=0 \
        --button="Playlist":/usr/share/idiomind/play.sh \
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

if echo "$mde" | grep "fd"; then
    feedmode
    exit 1
fi
