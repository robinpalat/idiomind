#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source "/usr/share/idiomind/ifs/mods/cmns.sh"
lgt=$(lnglss "$lgtl")
v=vj27

if [ ! -d "$DC_a/dict/enables" ]; then
mkdir -p "$DC_a/dict/enables"
mkdir -p "$DC_a/dict/disables"
cp -f "$DS_a/Dics/disables"/* "$DC_a/dict/disables"/; fi

[ ! -f "$DC_a/dict/.lng" ] && echo -e "$lgtl\n$v" > "$DC_a/dict/.lng"

if  [[ -z "$(ls "$DC_a/dict/enables/")" ]] || [[ "$(sed -n 1p "$DC_a/dict/.lng")" != "$lgtl" ]] ; then
"$DS_a/Dics/cnfg.sh" "" f " $(gettext "Please, select at least one resource for each task")"
echo -e "$lgtl\n$v" > "$DC_a/dict/.lng"; fi

