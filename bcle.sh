#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
cfg="$DC_tlt/10.cfg"
cfgp="$DM_tl/Podcasts/.conf/podcasts.cfg"
f=0
ritem=0
stnrd=0
nu='^[0-9]+$'

[ -z "$tpc" -a ! -d "$DC_tlt" ] && exit 1
export tpc DC_tlt cfg cfgp f ritem stnrd nu
export -f include msg

if [ "$(grep -o rplay=\"[^\"]* "$DC_tlt/10.cfg" \
|grep -o '[^"]*$')" = TRUE ]; then

    while [ 1 ]; do

        "$DS/chng.sh" 0
        sleep 10
    done
    
else
    "$DS/chng.sh" 0

    rm -fr "$DT/.p_" & exit 0
fi
