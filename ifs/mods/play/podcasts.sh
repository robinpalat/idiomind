#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [[ ! -n "$_videos" ]]; then
_videos="$(sed -n 10p "$DC_s/1.cfg" \
| grep -o videos=\"[^\"]* | grep -o '[^"]*$')"
_news="$(sed -n 19p "$DC_s/1.cfg" \
| grep -o news=\"[^\"]* | grep -o '[^"]*$')"
_saved="$(sed -n 20p "$DC_s/1.cfg" \
| grep -o saved=\"[^\"]* | grep -o '[^"]*$')"
export _videos _news _saved
fi
_file="$DM_tl/Podcasts/cache/$fname"
if [[ -f "$_file.item" ]]; then
channel="$(sed -n 1p "$_file.item" \
| grep -o channel=\"[^\"]* | grep -o '[^"]*$')"
if [ "$_videos" = "TRUE" ] && ([ "$_news" = "TRUE" ] || [ "$_saved" = "TRUE" ]); then
find "$DM_tl/Podcasts/cache"/ -type f \( -name "*.avi" -o -name "*.mp4" -o -name "*.m4v" \) > "$DT/index.m3u"
"$DS/stop.sh" 3 && mplayer -fs -playlist "$DT/index.m3u"
else
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
fi
else
stop_loop "$_file.item"
fi
