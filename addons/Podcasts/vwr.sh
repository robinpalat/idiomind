#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
DSP="$DS/addons/Podcasts"
wth=$(sed -n 5p $DC_s/cfg.18)
eht=$(sed -n 6p $DC_s/cfg.18)
D=($*)
Q=$((${#D[@]}-1))
for i in $(seq 0 $Q); do
    item[$i]=${D[$i]}
done
item="${item[@]}"


fname=$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)
fc="$DM_tl/Podcasts/.conf/cfg.1"

#echo
#echo
#echo
#echo
#echo "$item..."
#echo "$fname..."
#echo
#echo
#echo
#echo

btnlabel="Save"
btncmd="'$DSP/add.sh' new_item '$item'"
dirs="$(printf "content\nkept")"

while read dir; do

if [ -f "$DM_tl/Podcasts/$dir/$fname.mp3" ]; then
    file="$DM_tl/Podcasts/$dir/$fname.mp3"
    ftxt="$DM_tl/Podcasts/$dir/$fname"

elif [ -f "$DM_tl/Podcasts/$dir/$fname.ogg" ]; then
    file="$DM_tl/Podcasts/$dir/$fname.ogg"
    ftxt="$DM_tl/Podcasts/$dir/$fname"

elif [ -f "$DM_tl/Podcasts/$dir/$fname.mp4" ]; then
     file="$DM_tl/Podcasts/$dir/$fname.mp4"
     ftxt="$DM_tl/Podcasts/$dir/$fname"

elif [ -f "$DM_tl/Podcasts/$dir/$fname.m4v" ]; then
     file="$DM_tl/Podcasts/$dir/$fname.m4v"
     ftxt="$DM_tl/Podcasts/$dir/$fname"

elif [ -f "$DM_tl/Podcasts/$dir/$fname.avi" ]; then
     file="$DM_tl/Podcasts/$dir/$fname.avi"
     ftxt="$DM_tl/Podcasts/$dir/$fname"
fi

done <<< "$dirs"

#if echo "$file" | grep '/content'; then
#btnlabel="Save"
#btncmd="'$DSP/add.sh' new_item '$item'"
#else
#btnlabel="Delete"
#btncmd="'$DSP/mngr.sh' delete_item '$item'"
#fi

source "$ftxt.i"
cmdplay="'$DSP/tls.sh' play '$fname'"
trgt="<span color='#5A5C5D'><big>$title</big></span>\n<a href='$link'>$channel</a>"

if [ -f "$file" ]; then
    sum="$(cat "$ftxt".txt)"
     printf "$sum" | yad --text-info \
    --window-icon=/usr/share/idiomind/images/idiomind.png \
    --center --title=" " --scroll --borders=10 --text="$trgt" \
    --editable --always-print-result --image-on-top \
    --width="$wth" --height="$(($eht+80))" --center --margins=25 \
    --wrap --show-uri --fontname=vendana --name=idiomind \
    --button="$btnlabel":"$btncmd" \
    --button="Stop":"killall play" \
    --button="Play":"$cmdplay" > $DT/d.tmp
    mv -f $DT/d.tmp "$ftxt".txt
    
else
    exit 1
fi

