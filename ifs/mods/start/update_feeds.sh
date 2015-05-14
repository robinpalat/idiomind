#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
cfg="$DM_tl/Podcasts/.conf/0.cfg"
if [ -f "$cfg" ]; then
update="$(sed -n 1p "$cfg" | grep -o 'update="[^"]*' | grep -o '[^"]*$')"
if [ "$update" = TRUE ]; then (sleep 100 && "$DS_a/Podcasts/strt.sh" 0) &
fi
fi
