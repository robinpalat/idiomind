#!/bin/bash
topic=$(sed -n 1p ~/.config/idiomind/s/topic.id)
lnglbl=$(sed -n 2p ~/.config/idiomind/s/lang)
audio="$HOME/.idiomind/topics/$lnglbl/Feeds/kept/.audio"
contn="$HOME/.idiomind/topics/$lnglbl/Feeds/conten"
wdr="$(echo $2 | awk '{print tolower($0)}')"
echo "$2" > /tmp/.idmtp1/.dzmxx.x
var="$1"

if [ -f "$audio/$wdr.mp3" ]; then 
	play "$audio/$wdr.mp3"
else
	play "$contn/$var/$wdr.mp3"
fi

