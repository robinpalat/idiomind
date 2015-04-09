#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
DSP="$DS/addons/Feeds"
wicon="$DS/images/logo.png"
item="${2}"
dir="$DM_tl/Feeds/cache"
fname=$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)

if grep -Fxo "$item" < "$DM_tl/Feeds/.conf/2.cfg"; then
btnlabel="<small>Delete</small>"
btncmd="'$DSP/mngr.sh' delete_item '$item'"; else
btnlabel="<small>Save</small>"
btncmd="'$DSP/add.sh' new_item '$item'"; fi
if [ -f "$dir/$fname.html" ]; then
uri="$dir/$fname.html"; else
uri=""; fi

yad --html --title="$item" \
--name=Idiomind --class=Idiomind \
--uri="$dir/$fname.html" \
--window-icon=$wicon --center --on-top \
--width=650 --height=580 --borders=0 \
--button="$btnlabel":"$btncmd" \
--button="Close":1
