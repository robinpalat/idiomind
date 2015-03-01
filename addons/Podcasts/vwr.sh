#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
DS_pf="$DS/addons/Podcasts"
ap=$(cat $DC_s/cfg.1 | sed -n 6p)
wth=$(sed -n 5p $DC_s/cfg.18)
eht=$(sed -n 6p $DC_s/cfg.18)
re='^[0-9]+$'
now="$2"

nuw=$(cat "$DM_tl/Podcasts/.conf/cfg.1" | grep -Fxon "$now" \
| sed -n 's/^\([0-9]*\)[:].*/\1/p')
nll=" "
item="$(sed -n "$nuw"p "$DM_tl/Podcasts/.conf/cfg.1")"
fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"

if [ "$1" = V1 ]; then

    fc="$DM_tl/Podcasts/.conf/cfg.1"
    file="$DM_tl/Podcasts/content/$fname.mp3"
    filetxt="$DM_tl/Podcasts/content/$fname.txt"
    btnlabel="Save"
    btncmd="'$DS_pf/add.sh' new_item '$item'"
    
elif [ "$1" = V2 ]; then

    fc="$DM_tl/Podcasts/.conf/cfg.2"
    file="$DM_tl/Podcasts/kept/$fname.mp3"
    filetxt="$DM_tl/Podcasts/kept/$fname.txt"
    btnlabel="Delete"
    btncmd="'$DS_pf/mngr.sh' delete_item '$item'"
fi

cmdplay="'$DS_pf/tls.sh' play '$fname'"

by="$(eyeD3 --no-color -v "$file" \
| grep artist | sed 's/artist/||/g' \
| sed 's/title\:[^)]*||\://g' | \
sed -e "s/[[:space:]]\+/ /g" | \
sed 's/^ *//; s/ *$//g')"

if [[ -f "$file" ]]; then
    sum="$(cat "$filetxt")"
     printf "$sum" | yad --text-info --text-align=center \
    --window-icon=/usr/share/idiomind/images/idiomind.png \
    --center --title=" " --scroll --borders=10 \
    --text="<span color='#5A5C5D'><b>$2</b></span>  <small> By  <a href='http://idiomind.sourceforge.net/$lgs/$lgtl'>$by</a></small>\\n" \
    --editable --always-print-result --image-on-top \
    --width="$wth" --height="$(($eht+80))" --center \
    ---selectable-labels --margins=10 --back='#EEF0F2' \
    --wrap --show-uri --fontname=vendana \
    --button="<small>$btnlabel</small>":"$btncmd" \
    --button="<small>Stop</small>":"killall play" \
    --button="<small>Play</small>":"$cmdplay" > $DT/d.tmp
    mv -f $DT/d.tmp "$filetxt"
    
else
    exit 1
fi

