#!/bin/bash
# -*- ENCODING: UTF-8 -*-

DCP="$DM_tl/Podcasts/.conf"

if [ -f "$DCP/podcasts.cfg" ]; then
    if [ "$(grep -o 'update="[^"]*' "$DCP/podcasts.cfg" |grep -o '[^"]*$')" = TRUE ]; then
    ( sleep 1 && "$DS_a/Podcasts/cnfg.sh" update 0 ) & fi
fi
