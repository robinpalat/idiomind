#!/bin/bash
# -*- ENCODING: UTF-8 -*-

u=$USER
nmt=$(sed -n 1p "/tmp/.idmtp1.$u/dir$1/folder")
vwr="/usr/share/idiomind/default/vwr_tmp.sh"
dir="/tmp/.idmtp1.$u/dir$1/$nmt"
re='^[0-9]+$'
item="$2"
index_pos="$3"
index="$dir/conf/0.cfg"
cd "$dir"

if ! [[ $index_pos =~ $re ]]; then
index_pos=$(cat "$index" | grep -Fxon "$item" \
| sed -n 's/^\([0-9]*\)[:].*/\1/p')
nll='echo  " "'; fi

item="$(sed -n "$index_pos"p "$index")"
if [ -z "$item" ]; then
item="$(sed -n 1p "$index")"
index_pos=1; fi

fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"

if [ -f "$dir/words/$fname.mp3" ]; then

    file="$dir/words/$fname.mp3"
    cmd_play="play "\"$dir/words/$fname.mp3\"""
    tags="$(eyeD3 "$file")"
    trgt="$(grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)' <<<"$tags")"
    srce="$(grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)' <<<"$tags")"
    exmp="$(grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' <<<"$tags" | tr '_' '\n')"
    exm1="$(sed -n 1p <<<"$exmp")"
    dftn="$(sed -n 2p <<<"$exmp")"
    ntes="$(sed -n 3p <<<"$exmp")"
    dfnts="--field=<i><span color='#696464'>$dftn</span></i>\\n:lbl"
    ntess="--field=<span color='#868686'>$ntes</span>\\n:lbl"
    exmp1="$(sed "s/"$trgt"/<span background='#F8F4A2'>"$trgt"<\/\span>/g" <<<"$exm1")"
    [ -z "$trgt" ] && tm="<span color='#3F78A0'><tt>$(gettext "Text missing")</tt></span>"
    
    yad --form --title="$item " \
    --text="$tm<span font_desc='Sans Free Bold 22'>$trgt</span>\n\n<i>$srce</i>\n\n" \
    --selectable-labels --quoted-output \
    --window-icon="/usr/share/idiomind/images/icon.png" \
    --skip-taskbar --scroll --text-align=center --center --on-top \
    --width=650 --height=400 --borders=20 \
    --field="":lbl \
    --field="<i><span color='#808080'>$exmp1</span></i>\\n:lbl" "$dfnts" "$ntess" \
    --button=$(gettext "Listen"):"$cmd_play" \
    --button=gtk-go-down:2 \
    --button=gtk-go-up:3
    

else
    file="$dir/$fname.mp3"
    cmd_play="play "\"$dir/$fname.mp3\"""
    if [ -f "$file" ]; then
    dwck="'/usr/share/idiomind/ifs/tls.sh' 'play_temp' '$1'"
    tags="$(eyeD3 "$file")"
    trgt="$(grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' <<<"$tags")"
    srce="$(grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)' <<<"$tags")"
    lwrd="$(grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' <<<"$tags" | tr '_' '\n')"
    [ -z "$trgt" ] && tm="<span color='#3F78A0'><tt>$(gettext "Text missing")</tt></span>"
    else tm="<span color='#3F78A0'><tt>$(gettext "File not found")</tt></span>"; fi
    
    echo "$lwrd" | awk '{print $0""}' | yad --list --title=" " \
    --text="$tm<span font_desc='Sans Free 15'>$trgt</span>\n\n<i>$srce</i>\n\n" \
    --selectable-labels --dclick-action="$dwck" \
    --window-icon="/usr/share/idiomind/images/icon.png" \
    --scroll --no-headers \
    --expand-column=0 --skip-taskbar --center --on-top \
    --width=650 --height=400 --borders=15 \
    --column="":TEXT \
    --column="":TEXT \
    --button=$(gettext "Listen"):"$cmd_play" \
    --button=gtk-go-down:2 \
    --button=gtk-go-up:3
    
fi

ret=$?
if [ $ret -eq 2 ]; then
    if [[ $index_pos = 1 ]]; then
    item=`tail -n 1 < "$index"`
    "$vwr" "$1" "$item" &
    else
    item_pos=$((index_pos-1))
    "$vwr" "$1" "$nll" "$item_pos" &
    fi
elif [ $ret -eq 3 ]; then
    item_pos=$((index_pos+1))
    "$vwr" "$1" "$nll" "$item_pos" &
fi

