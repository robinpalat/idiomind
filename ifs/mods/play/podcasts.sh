#!/bin/bash
# -*- ENCODING: UTF-8 -*-


source "$DC_s/1.cfg"
if [ "$videos" = "TRUE" ] && ([ "$news" = "TRUE" ] || [ "$saved" = "TRUE" ]); then
find "$DM_tl/Feeds/cache"/ -type f \( -name "*.avi" -o -name "*.mp4" -o -name "*.m4v" \) > "$DT/index.m3u"
"$DS/stop.sh" playm && mplayer -fs -playlist "$DT/index.m3u";
else
[ -f "$DM_tl/Feeds/cache/$fname.mp3" ] && file="$DM_tl/Feeds/cache/$fname.mp3" && t=3
[ -f "$DM_tl/Feeds/cache/$fname.ogg" ] && file="$DM_tl/Feeds/cache/$fname.ogg" && t=3
[ -f "$DM_tl/Feeds/cache/$fname.m4v" ] && file="$DM_tl/Feeds/cache/$fname.m4v" && t=4
[ -f "$DM_tl/Feeds/cache/$fname.mp4" ] && file="$DM_tl/Feeds/cache/$fname.mp4" && t=4
[ -f "$DM_tl/Feeds/cache/$fname.avi" ] && file="$DM_tl/Feeds/cache/$fname.avi" && t=4

if [ "$t" = 3 ]; then
trgt="$title"
srce="$channel"
play=play
elif [ "$t" = 4 ]; then
trgt="$title"
srce="$channel"
play=mplayer
fi
fi
