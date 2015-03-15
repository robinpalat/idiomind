#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#source /usr/share/idiomind/ifs/c.conf
[[ -z "$tpc" && -d "$DT" ]] && exit 1
> "$DT/.p_"
cd "$DT"
n=1

if ([ -n "$(cat ./index)" ] && [ $(wc -l < ./index) -gt 0 ]); then
    if [ "$(sed -n 11p "$DC_s/1.cfg")" = "TRUE" ]; then
        while [ 1 ]; do
            while [ $n -le $(wc -l < ./index) ]; do
                "$DS/chng.sh" chngi "$n"
                let n++
            done
        done
        
    else
        while [ $n -le $(wc -l < ./index) ]; do
        "$DS/chng.sh" chngi "$n"
            let n++
        done
        rm -fr "$DT/.p_"
    fi
else
    exit 1
fi
