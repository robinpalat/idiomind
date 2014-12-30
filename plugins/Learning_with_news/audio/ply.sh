#!/bin/bash

source /usr/share/idiomind/ifs/c.conf
audio="$DM_tl/Feeds/kept/.audio"
contn="$DM_tl/Feeds/conten"
wdr="$(echo $2 | awk '{print tolower($0)}')"

echo "$wdr" > $DT/.dzmxx.x
var="$1"

if [ -f "$audio/$wdr.mp3" ]; then 
	play "$audio/$wdr.mp3"
else
	play "$contn/$var/$wdr.mp3"
fi

