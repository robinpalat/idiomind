#!/bin/bash
# -*- ENCODING: UTF-8 -*-

DSP="$DS/addons/Podcasts"
item="${2}"
dir="$DM_tl/Podcasts/cache"
fname=$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)
export item
if grep -Fxo "$item" "$DM_tl/Podcasts/.conf/2.cfg"; then
btnlabel="$(gettext "Delete")"
btncmd="'$DSP/mngr.sh' delete_item"; else
btnlabel="$(gettext "Keep")"
btncmd="'$DSP/mngr.sh' new_item"; fi
btncmd2="'$DSP/mngr.sh' sv_as"
if [ -f "$dir/$fname.html" ]; then
uri="$dir/$fname.html"; else
uri=""; fi

yad --html --title="$item" \
--name=Idiomind --class=Idiomind \
--uri="$dir/$fname.html" \
--window-icon="$DS/images/icon.png" --center --on-top \
--width=680 --height=550 --borders=0 \
--button=gtk-save-as:"$btncmd2" \
--button="$(gettext "Save")":"$btncmd" \
--button="Close":1
