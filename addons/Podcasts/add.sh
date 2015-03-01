#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
include $DS/ifs/mods/add

if [ "$1" = new_item ]; then

    trgt="$2"
    dir_kept="$DM_tl/Podcasts/kept"
    dir_content="$DM_tl/Podcasts/content"
    dir_conf="$DM_tl/Podcasts/.conf"

    if [ ! -d "$DM_tl/Podcasts/kept" ]; then
        mkdir -p "$DM_tl/Podcasts/kept"
    fi

    fname="$(nmfile "${trgt^}")"
    cp -f "$dir_content/$fname.mp3" "$dir_kept/$fname.mp3"
    cp -f "$dir_content/$fname.txt" "$dir_kept/$fname.txt"
    echo "$trgt" >> "$dir_conf/cfg.2"
    check_index1 "$dir_conf/cfg.2"
    notify-send -i idiomind "$(gettext "Archive")" "$trgt" -t 3000

    exit
        
fi
