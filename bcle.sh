#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#source /usr/share/idiomind/ifs/c.conf
[ -z "$tpc" && -d "$DT/p" ] && exit 1
> "$DT/.p_"
cd "$DT/p"
n=1

if ([ -n "$(cat ./indx)" ] && [ $(wc -l < ./indx) -gt 0 ]); then
    if [ "$(sed -n 5p "$DC_s/1.cfg")" = "TRUE" ]; then

        while [ 1 ]; do
            while [ $n -le $(wc -l < ./indx) ]; do
                "$DS/chng.sh" chngi "$n"
                let n++
            done
        done
        
    else
        while [ $n -le $(wc -l < ./indx) ]; do
        "$DS/chng.sh" chngi "$n"
            let n++
        done
        rm -fr "$DT/.p_" "$DT/p"
    fi
else
    exit 1
fi
