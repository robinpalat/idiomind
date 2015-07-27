#!/bin/bash
# -*- ENCODING: UTF-8 -*-
v=vj27
if [ -e "$DC_a/dict/.lng" ]; then 
if [[ `sed -n 2p "$DC_a/dict/.lng"` != $v ]]; then
mv -f "$DC_a/dict/enables"/* "$DC_a/dict/disables"/
cp -f "$DS_a/Dics/disables"/* "$DC_a/dict/disables"/
echo -e "$lgtl\n$v" > "$DC_a/dict/.lng"; fi; fi

if grep -o 'rplay' "$DC_s/1.cfg"; then rm "$DC_s/1.cfg"; fi

[ ! -d "${DM_tls}/images" ] && mkdir -p "${DM_tls}/images"
