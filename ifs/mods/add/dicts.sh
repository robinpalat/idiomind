#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
lgt=$(lnglss $lgtl)

if [ ! -d "$DC_a/dict/" ]; then
    mkdir -p "$DC_a/dict/enables"
    mkdir -p "$DC_a/dict/disables"
    cp -f "$DS_a/Dics/disables"/* "$DC_a/dict/disables"/; fi
[ ! -f "$DC_a/dict/.dicts" ] && touch "$DC_a/dict/.dicts"
[ ! -f "$DC_a/dict/.lng" ] && echo $lgtl > "$DC_a/dict/.lng"

if  [ -z "$(cat $DC_a/dict/.dicts)" ] || [ "$(cat $DC_a/dict/.lng)" != $lgtl ] ; then
    "$DS_a/Dics/cnfg.sh" "" f "$(gettext " Please select at least one dictionary.")"
    echo $lgtl > "$DC_a/dict/.lng"; fi

function dictt() {
    
    export lgt
    dird="$DC_a/dict/"

    while read dict; do
    
        sh "$dict" "$1" "$2"
        
            if [ -f "$2/$1.mp3" ]; then
            break; fi
            
    done < "$dird/.dicts"
}
