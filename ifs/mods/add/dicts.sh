#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf

if [ ! -d "$DC_a/dict/" ]; then
    mkdir -p $DC_a/dict/enables
    mkdir -p $DC_a/dict/disables
    cp -f $DS_a/Dics/disables/* $DC_a/dict/disables/; fi
[[ ! -f $DC_a/dict/.dicts ]] && touch $DC_a/dict/.dicts
[[ ! -f $DC_a/dict/.lng ]] && echo $lgtl > $DC_a/dict/.lng
if  [ -z "$(cat $DC_a/dict/.dicts)" ]; then
    $DS_a/Dics/cnfg.sh "" f "$(gettext "  Not indicated a dictionary\\n
  Select one or more of the list")"; fi
if [ "$(cat $DC_a/dict/.lng)" != $lgtl ]; then
    $DS_a/Dics/cnfg.sh "" f "$(gettext " You changed the language to learn\\n
  Please select the corresponding dictionaries")"
    echo $lgtl > $DC_a/dict/.lng; fi

function dictt() {
    
    w="$1"
    dird="$DC_a/dict/"

    while read dict; do
    
        sh "$dict" "$w" "$2"
        
            if [ -f "$2/$w.mp3" ]; then
            break; fi
            
    done < $dird/.dicts
}
