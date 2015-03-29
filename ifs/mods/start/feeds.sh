#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
if [ -f "$DM_tl/Feeds/.conf/0.cfg" ]; then
    if [ "$(sed -n 1p "$DM_tl/Feeds/.conf/0.cfg")" = "TRUE" ]; then
    (sleep 200
    "$DS_a/Feeds/strt.sh" A
    ) &
    fi
fi
