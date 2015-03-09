#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
DSF="$DS/addons/Feeds"
wth=$(sed -n 5p $DC_s/18.cfg)
eht=$(sed -n 6p $DC_s/18.cfg)
D=($*)
Q=$((${#D[@]}-1))
for i in $(seq 0 $Q); do
item[$i]=${D[$i]}; done
item="${item[@]}"
dir="$DM_tl/Feeds/cache"
fname=$(echo -n "${item^}" | md5sum | rev | cut -c 4- | rev)

if grep -Fxo "$item" < "$DM_tl/Feeds/.conf/2.cfg"; then
btnlabel="Delete"
btncmd="'$DSF/mngr.sh' delete_item '$item'"
else
btnlabel="Save"
btncmd="'$DSF/add.sh' new_item '$item'"
fi

source "$dir/$fname.i"
trgt="<span font_desc='Free Sans 9' color='#5A5C5D'>\
<big>$title</big></span>\n<a href='$link'>$channel</a>"

sum="$(cat "$dir/$fname.txt")"
printf "$sum" | yad --text-info \
--window-icon=/usr/share/idiomind/images/idiomind.png \
--center --title=" " --scroll --borders=5 --text="$trgt" \
--editable --always-print-result --on-top \
--width="$(($wth+150))" --height="$(($eht+180))" --center --margins=20 \
--wrap --show-uri --fontname='Sans 13' --name=idiomind \
--button="$btnlabel":"$btncmd" \
--button="Stop":"killall play" > "$DT/d.tmp"
mv -f "$DT/d.tmp" "$dir/$fname.txt"
