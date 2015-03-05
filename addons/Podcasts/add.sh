#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
include $DS/ifs/mods/add

if [ "$1" = new_item ]; then

    trgt="$2"
    DMC="$DM_tl/Podcasts/content"
    DCP="$DM_tl/Podcasts/.conf"
    fname="$(nmfile "${trgt}")"
    sed -i -e "1i$trgt\\" "$DCP/cfg.2"
    sed -i -e "1i$trgt\\" "$DCP/.cfg.22"
    check_index1 "$DCP/cfg.2" "$DCP/.cfg.22"
    notify-send -i idiomind "$(gettext "Archive")" "$trgt" -t 3000
    exit
        
fi
