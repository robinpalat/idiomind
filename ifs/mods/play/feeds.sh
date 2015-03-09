#!/bin/bash
# -*- ENCODING: UTF-8 -*-
DCP="$DM_tl/Feeds/.conf"

#if [ -n $(sed -n 11p $DCP/5.cfg | grep -o "TRUE") ]; then
    #find "$DM_tl/Feeds/cache"/ -type f \( -name "*.avi" -o -name "*.mp4" -o -name "*.m4v" \) > $DT/playlist.m3u
    #[ -f "$DCP/0.cfg" ] && st3=$(sed -n 2p "$DCP/0.cfg") || st3=FALSE
    #[ $st3 = FALSE ] && fs="" || fs='-fs'
    #mplayer "$fs" -playlist $DT/playlist.m3u & $DS/stop.sh play & exit 1
#fi

[ -f "$DM_tl/Feeds/cache/$fname.mp3" ] && file="$DM_tl/Feeds/cache/$fname.mp3" && t=3
[ -f "$DM_tl/Feeds/cache/$fname.ogg" ] && file="$DM_tl/Feeds/cache/$fname.ogg" && t=3
[ -f "$DM_tl/Feeds/cache/$fname.m4v" ] && file="$DM_tl/Feeds/cache/$fname.m4v" && t=4
[ -f "$DM_tl/Feeds/cache/$fname.mp4" ] && file="$DM_tl/Feeds/cache/$fname.mp4" && t=4
[ -f "$DM_tl/Feeds/cache/$fname.avi" ] && file="$DM_tl/Feeds/cache/$fname.avi" && t=4
[ -f "$DM_tl/Feeds/cache/$fname.i" ] && source "$DM_tl/Feeds/cache/$fname.i"

if [ "$t" = 3 ]; then
trgt="$title"
srce="$channel"
play=play
elif [ "$t" = 4 ]; then
trgt="$title"
srce="$channel"
play=mplayer
fi
