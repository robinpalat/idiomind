#!/bin/bash
# -*- ENCODING: UTF-8 -*-

DSP="$DS/addons/Podcasts"
item="${2}"
dir="$DM_tl/Podcasts/cache"
fname=$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)

if grep -Fxo "$item" < "$DM_tl/Podcasts/.conf/2.cfg"; then
btnlabel="$(gettext "Delete")"
btncmd="'$DSP/mngr.sh' delete_item '$item'"; else
btnlabel="$(gettext "Save")"
btncmd="'$DSP/add.sh' new_item '$item'"; fi
if [ -f "$dir/$fname.html" ]; then
uri="$dir/$fname.html"; else
uri=""; fi

yad --html --title="$item" \
--name=Idiomind --class=Idiomind \
--uri="$dir/$fname.html" \
--window-icon=idiomind --center --on-top \
--width=650 --height=580 --borders=0 \
--button="$btnlabel":"$btncmd" \
--button="Close":1
