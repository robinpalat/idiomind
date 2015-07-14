#!/bin/bash
# -*- ENCODING: UTF-8 -*-

DCP="$DM_tl/Podcasts/.conf"

if [ -f "$DCP/2.lst" ] && [[ `wc -l < "$DCP/2.lst"` != `wc -l < "$DCP/.2.lst"` ]]; then
cp "$DCP/.2.lst" "$DCP/2.lst"; fi

if [ -f "$DCP/2.lst" ] && [[ `wc -l < "$DCP/1.lst"` != `wc -l < "$DCP/.1.lst"` ]]; then
cp "$DCP/.1.lst" "$DCP/1.lst"; fi

if [ -f "$DCP/0.lst" ]; then
    if [ "$(grep -o 'update="[^"]*' "$DCP/0.lst" |grep -o '[^"]*$')" = TRUE ]; then
    (sleep 100 && "$DS_a/Podcasts/strt.sh" 0) & fi
fi
