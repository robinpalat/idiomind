#!/bin/bash

source /usr/share/idiomind/ifs/c.conf

if [ $1 = s ]; then
if [ -f "$DM_tl/Feeds/conten/$2.mp3" ]; then
	drtx="$DM_tl/Feeds/conten"
elif [ -f "$DM_tl/Feeds/kept/$2.mp3" ]; then
	drtx="$DM_tl/Feeds/kept"
fi
if [[ "$(ps -A | grep -o "play")" = "play" ]]; then
	exit
fi
play "$drtx/$2.mp3" & sleep 0.2 && exit 1
	
elif [ $1 = dclk ]; then

audio="$DM_tl/Feeds/kept/.audio"
contn="$DM_tl/Feeds/conten"

wdr="$(echo $3 | awk '{print tolower($0)}')"
echo "$wdr" > $DT/word.x
var="$2"

if [ -f "$audio/$wdr.mp3" ]; then 
	play "$audio/$wdr.mp3"
else
	play "$contn/$var/$wdr.mp3"
fi
elif [ $1 = stop ]; then
killall rsstail
killall strt.sh
exit
fi