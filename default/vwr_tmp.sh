#!/bin/bash
# -*- ENCODING: UTF-8 -*-

vwr="/usr/share/idiomind/default/vwr_tmp.sh"
re='^[0-9]+$'
item="$2"
pos="$3"
cfg0="$(head -n -2 < "${1}")"

re='^[0-9]+$'
if ! [[ ${pos} =~ $re ]]; then
pos=`grep -F -m 1 "trgt={${item}}" <<<"${cfg0}" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
pos=$((pos+2))
item=`grep -F -m 1 "trgt={${item}}" <<<"${cfg0}" |sed 's/},/}\n/g'`
else
item=`sed -n ${pos}p <<<"${cfg0}" |sed 's/},/}\n/g'`
nll=""
fi

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
    --no-buttons --skip-taskbar --scroll --text-align=center --center --on-top \
    --width=650 --height=400 --borders=20 \
    --field="":lbl \
    --field="<i><span color='#808080'>$exmp1</span></i>\\n:lbl" "$dfnts" "$ntess" \
    
else
    cmd_play="play "\"$dir/$id.mp3\"""
    echo "$lwrd" | awk '{print $0""}' | yad --list --title=" " \
    --text="$tm<span font_desc='Sans Free 15'>$trgt</span>\n\n<i>$srce</i>\n\n\n" \
    --selectable-labels --dclick-action="$dwck" \
    --window-icon="/usr/share/idiomind/images/icon.png" \
    --no-buttons --scroll --no-headers \
    --expand-column=0 --skip-taskbar --center --on-top \
    --width=650 --height=400 --borders=15 \
    --column="":TEXT \
    --column="":TEXT \
    
fi

ret=$?
if [ $ret -eq 3 ]; then
    if [[ $pos = 1 ]]; then
    item=`tail -n 1 < "$cfg1"`
    "$vwr" "$1" "$item" &
    else
    item_pos=$((pos-1))
    "$vwr" "$1" "$nll" "$item_pos" &
    fi
elif [ $ret -eq 2 ]; then
    item_pos=$((pos+1))
    "$vwr" "$1" "$nll" "$item_pos" &
fi

