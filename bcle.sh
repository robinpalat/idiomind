#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#source /usr/share/idiomind/ifs/c.conf
[ -z "$tpc" ] && exit 1
> $DT/.p_
cd $DT/p

if [ -n "$(cat ./indx)" ] && [ $(cat ./indx | wc -l) -gt 0 ]; then
    if [ "$(sed -n 8p $DC_s/cfg.5)" = "TRUE" ]; then
            echo "--repeat"
            while [ 1 ]
            do
            n=1
            while [ $n -le $(cat ./indx | wc -l) ]; do
            $DS/chng.sh chngi $n
            let n++
            done
            done
    else
        n=1
        while [ $n -le $(cat ./indx | wc -l) ]; do
        $DS/chng.sh chngi $n
            let n++
        done
        rm -fr $DT/.p_ $DT/p
    fi
else
    exit 1
fi
