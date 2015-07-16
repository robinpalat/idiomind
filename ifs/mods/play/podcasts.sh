#!/bin/bash
# -*- ENCODING: UTF-8 -*-

f=0
get_itep() {
    
    if [ ${f} -gt 5 ] || [ ! -d "${DM_tl}/Podcasts/cache" ]; then
    msg "$(gettext "An error has occurred. Playback stopped")" info &
    "$DS/stop.sh" 2; fi
        
    fname=$(echo -n "${item}" | md5sum | rev | cut -c 4- | rev)
    item="$DM_tl/Podcasts/cache/$fname.item"
    
    if [ -f "${item}" ]; then
    
        channel="$(grep -o channel=\"[^\"]* < "${item}" | grep -o '[^"]*$')"
        title="$(grep -o title=\"[^\"]* < "${item}" | grep -o '[^"]*$')"
        [ -f "$DMC/$fname.mp3" ] && file="$DMC/$fname.mp3" && type=3
        [ -f "$DMC/$fname.ogg" ] && file="$DMC/$fname.ogg" && type=3
        [ -f "$DMC/$fname.m4v" ] && file="$DMC/$fname.m4v" && type=4
        [ -f "$DMC/$fname.mp4" ] && file="$DMC/$fname.mp4" && type=4
        [ -f "$DMC/$fname.avi" ] && file="$DMC/$fname.avi" && type=4
        
        if [ ${type} = 3 ]; then
        trgt="${title}"
        srce="${channel}"
        icon=idiomind
        
        elif [ ${type} = 4 ]; then
        trgt="${title}"
        srce="${channel}"
        icon=idiomind
        
        else ((f=f+1)); fi
        
    else ((f=f+1)); fi
    
    export trgt srce icon
}

if [ ${ne} = TRUE ] || [ ${se} = TRUE ]; then

    DMC="$DM_tl/Podcasts/cache"
    DPC="$DM_tl/Podcasts/.conf"
    
    if [ ${v} = TRUE ]; then

        _filename() {
            fname=$(echo -n "${1}" | md5sum | rev | cut -c 4- | rev)
            [ -f "$DMC/$fname.m4v" ] && echo "$DMC/$fname.m4v"
            [ -f "$DMC/$fname.mp4" ] && echo "$DMC/$fname.mp4"
        }
        rm -f "$DT/index.m3u"
        
        if [ ${ne} = TRUE ]; then
            while read item; do
            echo "$(_filename "$item")" >> "$DT/index.m3u"
            done < "$DPC/1.lst"
        fi
            
        if [ ${se} = "TRUE" ]; then
            while read item; do
            echo "$(_filename "$item")" >> "$DT/index.m3u"
            done < "$DPC/2.lst"
        fi
        
        sed -i '/^$/d' "$DT/index.m3u"
        if [ -z "$(< "$DT/index.m3u")" ]; then
        notify-send "$(gettext "No videos to play")" \
        "$(gettext "Exiting...")" -i idiomind -t 3000
        "$DS/stop.sh" 2 & exit
        else 
        "$DS/stop.sh" 3
        mplayer -noconsolecontrols -title "$(gettext "Videos")" -playlist "$DT/index.m3u" & exit
        fi
    
    else
        if [ ${ne} = TRUE ]; then
        while read -r item; do get_itep; _play; sleep 2
        done < "$DPC/1.lst"; fi
        
        if [ ${se} = TRUE ]; then
        while read -r item; do get_itep; _play; sleep 2
        done < "$DPC/2.lst"; fi
    fi
fi
