#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
[ -z "$tpc" && -d "$DT" ] && exit 1
export tpc DC_tlt

if [ "$(grep -o rplay=\"[^\"]* "$DC_tlt/10.cfg" \
|grep -o '[^"]*$')" = TRUE ]; then

    while [ 1 ]; do

        "$DS/chng.sh" 0
        sleep 10
    done
    
else
    "$DS/chng.sh" 0

    rm -fr "$DT/.p_"; exit 0
fi
