#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
DSP="$DS/addons/Feeds"
#wth=$(($(sed -n 2p $DC_s/10.cfg)-480))
#eht=$(($(sed -n 3p $DC_s/10.cfg)-140))

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

yad --html \
--window-icon=idiomind --uri="$dir/$fname.html" \
--center --title="$item" --borders=0 \
--on-top --class=Idiomind \
--width=650 --height=580 --name=Idiomind \
--button="$btnlabel":"$btncmd" \
--button="Close":1
