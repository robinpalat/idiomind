#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
[ -z "$tpc" && -d "$DT" ] && exit 1

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
