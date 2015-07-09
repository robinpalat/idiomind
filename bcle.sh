#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf

if [ -d "$DM_tlt" ] && [ -n "$tpc" ]; then
echo -e "$DM_tlt\n$tpc" > "$DT/.p_"
else "$DS/stop.sh" 2 && exit 1; fi
echo -e ".ply.$tpc.ply." >> "$DC_s/log" &
sleep 0.5
if [ "$(grep -o rplay=\"[^\"]* < "$DC_s/1.cfg" \
|grep -o '[^"]*$')" = TRUE ]; then

    while [ 1 ]; do

        "$DS/chng.sh" chngi
        sleep 10
    done
else
    "$DS/chng.sh" chngi

    rm -fr "$DT/.p_"; exit 0
fi
