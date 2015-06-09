#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [[ ! -n "$_videos" ]]; then
_videos="$(sed -n 9p "$DC_s/1.cfg" \
| grep -o videos=\"[^\"]* | grep -o '[^"]*$')"
_news="$(sed -n 18p "$DC_s/1.cfg" \
| grep -o news=\"[^\"]* | grep -o '[^"]*$')"
_saved="$(sed -n 19p "$DC_s/1.cfg" \
| grep -o saved=\"[^\"]* | grep -o '[^"]*$')"
export _videos _news _saved
fi
DMC="$DM_tl/Podcasts/cache"
DPC="$DM_tl/Podcasts/.conf"

if [ "$_videos" = "TRUE" ] \
&& ([ "$_news" = "TRUE" ] || [ "$_saved" = "TRUE" ]); then

    _filename() {
        fname=$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)
        [ -f "$DMC/$fname.m4v" ] && echo "$DMC/$fname.m4v"
        [ -f "$DMC/$fname.mp4" ] && echo "$DMC/$fname.mp4"
    }
    rm -f "$DT/index.m3u"
    
    if [ "$_news" = "TRUE" ]; then
        while read item; do
        echo "$(_filename "$item")" >> "$DT/index.m3u"
        done < "$DPC/1.lst"
    fi
        
    if [ "$_saved" = "TRUE" ]; then
        while read item; do
        echo "$(_filename "$item")" >> "$DT/index.m3u"
        done < "$DPC/2.lst"
    fi
    
    sed -i '/^$/d' "$DT/index.m3u"
    if [ -z "$(< "$DT/index.m3u")" ]; then
    notify-send "$(gettext "No videos to play")" \
    "$(gettext "Exiting...")" -i idiomind -t 3000
    "$DS/stop.sh" 2
    else 
    "$DS/stop.sh" 3 && mplayer -fs -playlist "$DT/index.m3u"
    exit
    fi
    
else
    _file="$DM_tl/Podcasts/cache/$fname"
    if [[ -f "$_file.item" ]]; then
        channel="$(sed -n 1p "$_file.item" \
        | grep -o channel=\"[^\"]* | grep -o '[^"]*$')"
        [[ -f "$_file.mp3" ]] && file="$_file.mp3" && t=3
        [[ -f "$_file.ogg" ]] && file="$_file.ogg" && t=3
        [[ -f "$_file.m4v" ]] && file="$_file.m4v" && t=4
        [[ -f "$_file.mp4" ]] && file="$_file.mp4" && t=4
        [[ -f "$_file.avi" ]] && file="$_file.avi" && t=4

        if [[ "$t" = 3 ]]; then
        trgt="$title"
        srce="$channel"
        play=play
        icon=idiomind
        elif [[ "$t" = 4 ]]; then
        trgt="$title"
        srce="$channel"
        play=mplayer
        icon=idiomind
        fi
    else
        stop_loop "$_file.item"
    fi
fi
