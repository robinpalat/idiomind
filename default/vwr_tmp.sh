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
else item=`sed -n ${pos}p <<<"${cfg0}" |sed 's/},/}\n/g'`; fi

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
    yad --form --title=" " \
    --text="$tm<span font_desc='Sans Free Bold 22'>$trgt</span>\n\n<i>$srce</i>\n\n" \
    --quoted-output \
    --window-icon="/usr/share/idiomind/images/icon.png" \
    --skip-taskbar --scroll --text-align=center --center --on-top \
    --width=650 --height=400 --borders=15 \
    --field="":lbl \
    --field="<i><span color='#808080'>$exmp1</span></i>\\n:lbl" "$dfnts" "$ntess" \
    --button="$(gettext "Close")":1
    
elif [[ ${type} = 2 ]]; then
    echo "$lwrd" | awk '{print $0""}' | yad --list --title=" " \
    --text="$tm<span font_desc='Sans Free 15'>$trgt</span>\n\n<i>$srce</i>\n\n" \
    --window-icon="/usr/share/idiomind/images/icon.png" \
    --scroll --no-headers \
    --expand-column=0 --skip-taskbar --center --on-top \
    --width=650 --height=400 --borders=15 \
    --column="":TEXT \
    --column="":TEXT \
    --button="$(gettext "Close")":1
fi




