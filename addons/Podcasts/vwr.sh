#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
DSP="$DS/addons/Podcasts"
wth=$(sed -n 5p $DC_s/cfg.18)
eht=$(sed -n 6p $DC_s/cfg.18)
D=($*)
Q=$((${#D[@]}-1))
for i in $(seq 0 $Q); do
item[$i]=${D[$i]}; done
item="${item[@]}"
dir="$DM_tl/Podcasts/content"
fname=$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)

if grep -Fxo "$item" < "$DM_tl/Podcasts/.conf/cfg.2"; then
btnlabel="Delete"
btncmd="'$DSP/mngr.sh' delete_item '$item'"
else
btnlabel="Save"
btncmd="'$DSP/add.sh' new_item '$item'"
fi

if [ -f "$dir/$fname.mp3" ]; then
    file="$dir/$fname.mp3"
    ftxt="$dir/$fname"
elif [ -f "$dir/$fname.ogg" ]; then
    file="$dir/$fname.ogg"
    ftxt="$dir/$fname"
elif [ -f "$dir/$fname.mp4" ]; then
     file="$dir/$fname.mp4"
     ftxt="$dir/$fname"
elif [ -f "$dir/$fname.m4v" ]; then
     file="$dir/$fname.m4v"
     ftxt="$dir/$fname"
elif [ -f "$dir/$fname.avi" ]; then
     file="$dir/$fname.avi"
     ftxt="$dir/$fname"
fi

source "$ftxt.i"
cmdplay="'$DSP/tls.sh' play '$fname'"
trgt="<span font_desc='Free Sans 9' color='#5A5C5D'>\
<big>$title</big></span>\n<a href='$link'>$channel</a>"

if [ -f "$file" ]; then
    sum="$(cat "$ftxt".txt)"
    printf "$sum" | yad --text-info --image="$dir/$fname".png \
    --window-icon=/usr/share/idiomind/images/idiomind.png \
    --center --title=" " --scroll --borders=5 --text="$trgt" \
    --editable --always-print-result --image-on-top \
    --width="$wth" --height="$(($eht+80))" --center --margins=20 \
    --wrap --show-uri --fontname='Free Sans 13' --name=idiomind \
    --button="$btnlabel":"$btncmd" \
    --button="Stop":"killall play" \
    --button="Play":"$cmdplay" > $DT/d.tmp
    mv -f $DT/d.tmp "$ftxt".txt
    
else
    exit 1
fi
