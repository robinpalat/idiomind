#!/bin/bash
# -*- ENCODING: UTF-8 -*-

u=$USER
nmt=$(sed -n 1p "/tmp/.idmtp1.$u/dir$1/folder")
vwr="/usr/share/idiomind/default/vwr_tmp.sh"
dir="/tmp/.idmtp1.$u/dir$1/$nmt"
re='^[0-9]+$'
item_name="$2"
cfg1_pos="$3"
cfg1="$dir/conf/1.cfg"
cfg0="$dir/conf/0.cfg"
cd "$dir"

re='^[0-9]+$'; cfg1_pos="$3"
if ! [[ ${cfg1_pos} =~ $re ]]; then
cfg1_pos=`grep -Fxon -m 1 "${item_name}" "${cfg1}" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
nll=""; fi

item=`sed -n ${cfg1_pos}p "${cfg1}"`
if [ -z "${item}" ]; then item="$(sed -n 1p "${cfg1}")"; cfg1_pos=1; fi
pos=`grep -Fon -m 1 "trgt={${item}}" "${cfg0}" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
item=`sed -n ${pos}p "${cfg0}" |sed 's/},/}\n/g'`

type=`grep -oP '(?<=type={).*(?=})' <<<"${item}"`
trgt=`grep -oP '(?<=trgt={).*(?=})' <<<"${item}"`
srce=`grep -oP '(?<=srce={).*(?=})' <<<"${item}"`
exmp=`grep -oP '(?<=exmp={).*(?=})' <<<"${item}"`
defn=`grep -oP '(?<=defn={).*(?=})' <<<"${item}"`
note=`grep -oP '(?<=note={).*(?=})' <<<"${item}"`
grmr=`grep -oP '(?<=grmr={).*(?=})' <<<"${item}"`
tag=`grep -oP '(?<=tag={).*(?=})' <<<"${item}"`
mark=`grep -oP '(?<=mark={).*(?=})' <<<"${item}"`
lwrd=`grep -oP '(?<=wrds={).*(?=})' <<<"${item}" |tr '_' '\n'`
exmp=`sed "s/"${trgt,,}"/<span background='#FDFBCF'>"${trgt,,}"<\/\span>/g" <<<"$exmp"`
id=`grep -oP '(?<=id=\[).*(?=\])' <<<"${item}"`

if [[ ${type} = 1 ]]; then

    cmd_play="play "\"$dir/share/${trgt,,}.mp3\"""
    yad --form --title=" " \
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
    cmd_play="play "\"$dir/$id.mp3\"""
    echo "$lwrd" | awk '{print $0""}' | yad --list --title=" " \
    --text="$tm<span font_desc='Sans Free 15'>$trgt</span>\n\n<i>$srce</i>\n\n\n" \
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
    if [[ $cfg1_pos = 1 ]]; then
    item=`tail -n 1 < "$cfg1"`
    "$vwr" "$1" "$item" &
    else
    item_pos=$((cfg1_pos-1))
    "$vwr" "$1" "$nll" "$item_pos" &
    fi
elif [ $ret -eq 3 ]; then
    item_pos=$((cfg1_pos+1))
    "$vwr" "$1" "$nll" "$item_pos" &
fi

