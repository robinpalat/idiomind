#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
du="$(du -b -h "$DM" | tail -1 | awk '{print ($1)}')"
sed -i "3s/size=.*/size=$du/" "$DC_a/1.cfg"
if ([ "$(date +%u)" = 6 ] && \
[ "$(sed -n 1p "$DC_a/1.cfg")" = "TRUE" ]); then
    "$DS/addons/User data/cnfg.sh" C &
fi
