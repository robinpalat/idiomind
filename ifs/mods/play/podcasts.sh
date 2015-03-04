#!/bin/bash
# -*- ENCODING: UTF-8 -*-
DCF="$DC/addons/Podcasts"

if [ -n $(sed -n 11p $DC_s/cfg.5 | grep -o "TRUE") ]; then
    find "$DM_tl/Podcasts/content"/ -type f \( -name "*.avi" -o -name "*.mp4" -o -name "*.m4v" \) > $DT/playlist.m3u
    [ -f "$DCF/.cnf" ] && st3=$(sed -n 2p "$DCF/.cnf") || st3=FALSE
    [ $st3 = FALSE ] && fs="" || fs='-fs'
    mplayer "$fs" -playlist $DT/playlist.m3u & $DS/stop.sh play & exit 1
fi

[ -f "$DM_tl/Podcasts/content/$fname.mp3" ] && file="$DM_tl/Podcasts/content/$fname.mp3" && t=3
[ -f "$DM_tl/Podcasts/content/$fname.ogg" ] && file="$DM_tl/Podcasts/content/$fname.ogg" && t=3
[ -f "$DM_tl/Podcasts/content/$fname.m4v" ] && file="$DM_tl/Podcasts/content/$fname.m4v" && t=4
[ -f "$DM_tl/Podcasts/content/$fname.mp4" ] && file="$DM_tl/Podcasts/content/$fname.mp4" && t=4
[ -f "$DM_tl/Podcasts/content/$fname.avi" ] && file="$DM_tl/Podcasts/content/$fname.avi" && t=4
[ -f "$DM_tl/Podcasts/kept/$fname.mp3" ] && file="$DM_tl/Podcasts/kept/$fname.mp3" && t=3
[ -f "$DM_tl/Podcasts/kept/$fname.ogg" ] && file="$DM_tl/Podcasts/kept/$fname.ogg" && t=3
[ -f "$DM_tl/Podcasts/kept/$fname.m4v" ] && file="$DM_tl/Podcasts/kept/$fname.m4v" && t=4
[ -f "$DM_tl/Podcasts/kept/$fname.mp4" ] && file="$DM_tl/Podcasts/kept/$fname.mp4" && t=4
[ -f "$DM_tl/Podcasts/kept/$fname.avi" ] && file="$DM_tl/Podcasts/kept/$fname.avi" && t=4
[ -f "$DM_tl/Podcasts/content/$fname" ] && source "$DM_tl/Podcasts/content/$fname"
[ -f "$DM_tl/Podcasts/kept/$fname" ] && source "$DM_tl/Podcasts/kept/$fname"

if [ "$t" = 3 ]; then
trgt="$title"
srce="$channel"
play=play
elif [ "$t" = 4 ]; then
trgt="$title"
srce="$channel"
play=mplayer
fi
