#!/bin/bash
# -*- ENCODING: UTF-8 -*-

DCP="$DM_tl/Podcasts/.conf"

if [ -f "$DCP/10.cfg" ]; then
    if [ "$(grep -o 'update="[^"]*' "$DCP/10.cfg" |grep -o '[^"]*$')" = TRUE ]; then
    (sleep 100 && "$DS_a/Podcasts/strt.sh" 0) & fi
fi
