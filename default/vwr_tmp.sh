#!/bin/bash
# -*- ENCODING: UTF-8 -*-

u=$USER
nmt=$(sed -n 1p "/tmp/.idmtp1.$u/dir$1/folder")
dir="/tmp/.idmtp1.$u/dir$1/$nmt"
re='^[0-9]+$'
item_name="$2"
index_pos="$3"
cd "$dir"

if ! [[ $index_pos =~ $re ]]; then
index_pos=$(cat "$dir/0.cfg" | grep -Fxon "$item_name" \
| sed -n 's/^\([0-9]*\)[:].*/\1/p')
nll='echo  " "'; fi

item="$(sed -n "$index_pos"p "$dir/0.cfg")"
if [ -z "$item" ]; then
item="$(sed -n 1p "$dir/0.cfg")"
index_pos=1; fi

fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"

if [ -f "$dir/words/$fname.mp3" ]; then

    file="$dir/words/$fname.mp3"
    listen="--button=Listen:play '$dir/words/$fname.mp3'"
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
    
    yad --form --title="$item " \
    --text="<span font_desc='Sans Free Bold 22'>$trgt</span>\n\n<i>$srce</i>\n\n" \
    --selectable-labels --quoted-output \
    --window-icon="/usr/share/idiomind/images/icon.png" \
    --skip-taskbar --scroll --text-align=center --center --on-top \
    --width=650 --height=400 --borders=20 \
    --field="":lbl \
    --field="<i><span color='#808080'>$exmp1</span></i>\\n:lbl" "$dfnts" "$ntess" \
    "$listen" --button=gtk-go-up:3 \
    --button=gtk-go-down:2

elif [ -f "$dir/$fname.mp3" ]; then

    file="$dir/$fname.mp3"
    listen="--button=Listen:play '$dir/$fname.mp3'"
    dwck="'/usr/share/idiomind/ifs/tls.sh' 'play_temp' '$1'"
    tags="$(eyeD3 "$file")"
    trgt="$(grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' <<<"$tags")"
    srce="$(grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)' <<<"$tags")"
    lwrd="$(grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' <<<"$tags" | tr '_' '\n')"
    
    echo "$lwrd" | awk '{print $0""}' | yad --list --title=" " \
    --text="<span font_desc='Sans Free 15'>$trgt</span>\n\n<i>$srce</i>\n\n" \
    --selectable-labels --dclick-action="$dwck" \
    --window-icon="/usr/share/idiomind/images/icon.png" \
    --scroll --no-headers \
    --expand-column=0 --skip-taskbar --center --on-top \
    --width=650 --height=400 --borders=15 \
    --column="":TEXT \
    --column="":TEXT \
    "$listen" --button=gtk-go-up:3 \
    --button=gtk-go-down:2
   
else
    item_pos=$((index_pos-1))
    echo "_" >> /tmp/.sc
    [[ $(wc -l < /tmp/.sc) -ge 5 ]] && rm -f /tmp/.sc & exit 1 \
    || "/usr/share/idiomind/default/vwr_tmp.sh" "$1" "$nll" "$item_pos" & exit 1
fi

ret=$?
if [ $ret -eq 2 ]; then
item_pos=$((index_pos-1))
"/usr/share/idiomind/default/vwr_tmp.sh" "$1" "$nll" "$item_pos" &
elif [ $ret -eq 3 ]; then
item_pos=$((index_pos+1))
"/usr/share/idiomind/default/vwr_tmp.sh" "$1" "$nll" "$item_pos" &
fi

