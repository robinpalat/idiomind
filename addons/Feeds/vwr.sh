#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
DSP="$DS/addons/Feeds"
#wth=$(($(sed -n 2p $DC_s/10.cfg)-480))
#eht=$(($(sed -n 3p $DC_s/10.cfg)-140))

D=($*)
Q=$((${#D[@]}-1))
for i in $(seq 0 $Q); do
item[$i]=${D[$i]}; done
item="${item[@]}"
dir="$DM_tl/Feeds/cache"
fname=$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)

if grep -Fxo "$item" < "$DM_tl/Feeds/.conf/2.cfg"; then
btnlabel="Delete"
btncmd="'$DSP/mngr.sh' delete_item '$item'"
else
btnlabel="Save"
btncmd="'$DSP/add.sh' new_item '$item'"
fi

yad --html \
--window-icon=idiomind --uri="$dir/$fname.html" \
--center --title="$item" --borders=0 \
--on-top --class=Idiomind \
--width=700 --height=540 \
--name=Idiomind --no-buttons \
--button="$btnlabel":"$btncmd" \
--button="gtk-close":1
