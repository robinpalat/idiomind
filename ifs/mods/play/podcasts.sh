#!/bin/bash
# -*- ENCODING: UTF-8 -*-
f=0

get_itep() {
    
    if [ ${f} -gt 5 ] || [ ! -d "${DM_tl}/Podcasts/cache" ]; then
    msg "$(gettext "An error has occurred. Playback stopped")" info &
    "$DS/stop.sh" 2; fi
        
    fname=$(echo -n "${item}" | md5sum | rev | cut -c 4- | rev)
    item="$DM_tl/Podcasts/cache/$fname"
    
    if [ -f "${item}.item" ]; then
    
        channel="$(grep -o channel=\"[^\"]* < "${item}.item" | grep -o '[^"]*$')"
        title="$(grep -o title=\"[^\"]* < "${item}.item" | grep -o '[^"]*$')"
        [ -f "$item.mp3" ] && file="$item.mp3" && t=3
        [ -f "$item.ogg" ] && file="$item.ogg" && t=3
        [ -f "$item.m4v" ] && file="$item.m4v" && t=4
        [ -f "$item.mp4" ] && file="$item.mp4" && t=4
        [ -f "$item.avi" ] && file="$item.avi" && t=4
        
        if [[ "$t" = 3 ]]; then
        e_file "${file}"
        trgt="${title}"
        srce="${channel}"
        play=play
        icon=idiomind
        
        elif [[ "$t" = 4 ]]; then
        e_file "$file"
        trgt="${title}"
        srce="${channel}"
        play=mplayer
        icon=idiomind
        fi
    else ((f=f+1)); fi
}

if [ ${ne} = TRUE ] || [ ${se} = TRUE ]; then


    DMC="$DM_tl/Podcasts/cache"
    DPC="$DM_tl/Podcasts/.conf"
    
    if [ ${v} = TRUE ]; then

        _filename() {
            fname=$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)
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
        mplayer -fs -playlist "$DT/index.m3u" & exit
        fi
    
    else
        if [ ${ne} = TRUE ]; then
        while read -r item; do get_itep; _play
        done < "$DPC/1.lst"; fi
        
        if [ ${se} = TRUE ]; then
        while read -r item; do get_itep; _play
        done < "$DPC/2.lst"; fi
    fi
fi
