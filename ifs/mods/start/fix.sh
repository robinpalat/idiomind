#!/bin/bash

if [ -e "$DC_a/dict/.lng" ]; then 
if [[ `sed -n 2p "$DC_a/dict/.lng"` != $v_dicts ]]; then
rm "$DC_a/dict/enables"/* 
rm "$DC_a/dict/disables"/*
cp -f "$DS_a/Dics/disables"/* "$DC_a/dict/disables"/
echo -e "$lgtl\n$v_dicts" > "$DC_a/dict/.lng"; fi; fi

if grep -o 'rplay' "$DC_s/1.cfg"; then rm "$DC_s/1.cfg"; fi

[ ! -d "${DM_tls}/images" ] && mkdir -p "${DM_tls}/images"

DCP="$DM_tl/Podcasts/.conf"
if [ -d "$DM_tl/Podcasts/.conf" ]; then

    if [[ "$(< "$DCP/8.cfg")" != 11 ]]; then
    echo 11 > "$DCP/8.cfg"; fi
    
    if [ -f "$DCP/podcasts.cfg" ]; then
    if ! grep -o 'svepi' "$DCP/podcasts.cfg" >/dev/null 2>&1; then
    rm "$DCP/podcasts.cfg"; fi; fi
    
fi
