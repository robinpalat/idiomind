#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
include "$DS/ifs/mods/add"

if [ "$1" = new_item ]; then

    DMC="$DM_tl/Podcasts/cache"
    DCP="$DM_tl/Podcasts/.conf"
    fname="$(nmfile "${item}")"
    if [ -s "$DCP/2.cfg" ]; then
    sed -i -e "1i$item\\" "$DCP/2.cfg"
    else
    echo "$item" > "$DCP/2.cfg"; fi
    check_index1 "$DCP/2.cfg" "$DCP/.22.cfg"
    notify-send -i info "$(gettext "Archive")" "$item" -t 3000
    exit
        
fi
