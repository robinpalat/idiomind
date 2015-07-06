#!/bin/bash
# -*- ENCODING: UTF-8 -*-

DSP="$DS/addons/Podcasts"
item="${2}"
dir="$DM_tl/Podcasts/cache"
fname=$(echo -n "${item}" | md5sum | rev | cut -c 4- | rev)
channel="$(grep -o channel=\"[^\"]* < "$dir/${fname}.item" | grep -o '[^"]*$')"
export item
if grep -Fxo "$item" "$DM_tl/Podcasts/.conf/2.lst"; then
btnlabel="$(gettext "Delete")"
btncmd="'$DSP/mngr.sh' delete_item"; else
btnlabel="$(gettext "Save")"
btncmd="'$DSP/mngr.sh' new_item"; fi
btncmd2="'$DSP/mngr.sh' sv_as"
if [ -f "$dir/$fname.html" ]; then
uri="$dir/$fname.html"; else
source "$DS/ifs/mods/cmns.sh"
msg "$(gettext "No such file or directory")\n${topic}\n" error Error & exit 1; fi

yad --html --title="$channel" \
--name=Idiomind --class=Idiomind \
--encoding=UTF-8 --uri="${uri}" \
--window-icon="$DS/images/icon.png" --center --on-top \
--width=680 --height=550 --borders=0 \
--button=gtk-save-as:"$btncmd2" \
--button="$btnlabel":"$btncmd" \
--button="Close":1
