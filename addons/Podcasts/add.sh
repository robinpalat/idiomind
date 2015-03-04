#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
include $DS/ifs/mods/add

if [ "$1" = new_item ]; then

    trgt="$2"
    DMK="$DM_tl/Podcasts/kept"
    DMC="$DM_tl/Podcasts/content"
    DCP="$DM_tl/Podcasts/.conf"

    if [ ! -d "$DM_tl/Podcasts/kept" ]; then
        mkdir -p "$DM_tl/Podcasts/kept"
    fi

    fname="$(nmfile "${trgt^}")"
    echo "$trgt" >> "$DCP/cfg.2"
    echo "$trgt" >> "$DCP/.cfg.22"
    cp -f "$DMC/$fname.mp3" "$DMK/$fname.mp3"
    cp -f "$DMC/$fname.txt" "$DMK/$fname.txt"
    cp -f "$DMC/$fname.png" "$DMK/$fname.png"
    cp -f "$DMC/$fname.i" "$DMK/$fname.i"
    check_index1 "$DCP/cfg.2" "$DCP/.cfg.22"
    notify-send -i idiomind "$(gettext "Archive")" "$trgt" -t 3000

    exit
        
fi
