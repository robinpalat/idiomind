#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "/usr/share/idiomind/ifs/mods/cmns.sh"
DC_a="$HOME/.config/idiomind/addons"
lgtl="$(sed -n 1p "$HOME/.config/idiomind/s/6.cfg")"
lgt=$(lnglss "$lgtl")

if [ ! -d "$DC_a/dict/" ]; then
mkdir -p "$DC_a/dict/enables"
mkdir -p "$DC_a/dict/disables"
cp -f "$DS_a/Dics/disables"/* "$DC_a/dict/disables"/; fi
[ ! -f "$DC_a/dict/.dicts" ] && touch "$DC_a/dict/.dicts"
[ ! -f "$DC_a/dict/.lng" ] && echo "$lgtl" > "$DC_a/dict/.lng"

if  [ -z "$(ls "$DC_a/dict/enables/")" ] \
|| [ "$(< $DC_a/dict/.lng)" != "$lgtl" ] ; then
"$DS_a/Dics/cnfg.sh" "" f " $(gettext "Please select at least one dictionary.")"
echo "$lgtl" > "$DC_a/dict/.lng"; fi

function dictt() {
    
    export lgt
    dir_tmp="$2"
    w="$1"

    while read -r dict; do
    
        sh "$dict" "$w" "$dir_tmp"
            if [ -f "$dir_tmp/$w.mp3" ]; then
            break; fi
            
    done < <(find "$DC_a"/dict/enables/ -type f)
}
