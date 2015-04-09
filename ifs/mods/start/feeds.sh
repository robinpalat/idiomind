#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf; cfg="$DM_tl/Feeds/.conf/0.cfg"
if [ -f "$cfg" ]; then update="$(sed -n 1p < "$cfg" | grep -o 'update="[^"]*' | grep -o '[^"]*$')"
if [ "$update" = TRUE ]; then (sleep 200 "$DS_a/Feeds/strt.sh" A) & fi
fi
