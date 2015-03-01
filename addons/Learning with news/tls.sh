#!/bin/bash

source /usr/share/idiomind/ifs/c.conf

if [ "$1" = s ]; then

    if [ -f "$DM_tl/Feeds/content/$2.mp3" ]; then
        drtx="$DM_tl/Feeds/content"
    elif [ -f "$DM_tl/Feeds/kept/$2.mp3" ]; then
        drtx="$DM_tl/Feeds/kept"
    fi

    killall play
    play "$drtx/$2.mp3" && exit
    
elif [ "$1" = dclk ]; then

    audio="$DM_tl/Feeds/kept/.audio"
    contn="$DM_tl/Feeds/content"
    echo "$3" > $DT/word.x
    var="$2"
    if [ -f "$audio/${3,,}.mp3" ]; then 
        play "$audio/${3,,}.mp3"
    else
        play "$contn/$var/${3,,}.mp3"
    fi

fi
