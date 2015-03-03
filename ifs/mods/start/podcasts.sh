#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
if [ -f "$DC_a/Podcasts/.cnf" ]; then
    if [ "$(sed -n 1p "$DC_a/Podcasts/.cnf")" = "TRUE" ]; then
        (sleep 200
        "$DS_a/Podcasts/strt.sh" A
        ) &
    fi
fi
