#!/bin/bash
# -*- ENCODING: UTF-8 -*-

u=$(echo "$(whoami)")
nmt=$(sed -n 1p "/tmp/.idmtp1.$u/dir$1/ls")
dir="/tmp/.idmtp1.$u/dir$1/$nmt"
#yad --text="-$1 -$2 -$3"
wth=650; eht=400
re='^[0-9]+$'
now="$2"
nuw="$3"
cd "$dir"

if ! [[ $nuw =~ $re ]]; then
nuw=$(cat "$dir/0.cfg" | grep -Fxon "$now" \
| sed -n 's/^\([0-9]*\)[:].*/\1/p')
nll='echo  " "'; fi

item="$(sed -n "$nuw"p "$dir/0.cfg")"
if [ -z "$item" ]; then
item="$(sed -n 1p "$dir/0.cfg")"
nuw=1; fi

fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"

if [ -f "$dir/words/$fname.mp3" ]; then

    file="$dir/words/$fname.mp3"
    listen="--button=Listen:play '$dir/words/$fname.mp3'"
    tgs="$(eyeD3 "$file")"
    trgt="$(grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)' <<<"$tgs")"
    src="$(grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)' <<<"$tgs")"
    exmp="$(grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' <<<"$tgs" | tr '_' '\n')"
    exm1="$(sed -n 1p <<<"$exmp")"
    dftn="$(sed -n 2p <<<"$exmp")"
    ntes="$(sed -n 3p <<<"$exmp")"
    dfnts="--field=<i><span color='#696464'>$dftn</span></i>\\n:lbl"
    ntess="--field=<span color='#868686'>$ntes</span>\\n:lbl"
    exmp1="$(echo "$exm1" | sed "s/"$trgt"/<span background='#F8F4A2'>"$trgt"<\/\span>/g")"
    
    yad --form --title="$item " \
    --text="<span font_desc='Sans Free Bold 22'>$trgt</span>\n\n<i>$src</i>\n\n" \
    --selectable-labels --quoted-output \
    --window-icon=idiomind \
    --skip-taskbar --scroll --text-align=center --center --on-top \
    --width=$wth --height=$eht --borders=20 \
    --field="":lbl \
    --field="<i><span color='#808080'>$exmp1</span></i>\\n:lbl" "$dfnts" "$ntess" \
    "$listen" --button=gtk-go-up:3 \
    --button=gtk-go-down:2

elif [ -f "$dir/$fname.mp3" ]; then

    file="$dir/$fname.mp3"
    listen="--button=Listen:play '$dir/$fname.mp3'"
    dwck="'/usr/share/idiomind/default/p2.sh' $1"
    tgs="$(eyeD3 "$file")"
    trgt="$(grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' <<<"$tgs")"
    src="$(grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)' <<<"$tgs")"
    lwrd="$(grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' <<<"$tgs" | tr '_' '\n')"
    
    echo "$lwrd" | awk '{print $0""}' | yad --list --title=" " \
    --text="<span font_desc='Sans Free 15'>$trgt</span>\n\n<i>$src</i>\n\n" \
    --selectable-labels --dclick-action="$dwck" \
    --window-icon=idiomind --scroll --no-headers \
    --expand-column=0 --skip-taskbar --center --on-top \
    --width=$wth --height=$eht --borders=15 \
    --column="":TEXT \
    --column="":TEXT \
    "$listen" --button=gtk-go-up:3 \
    --button=gtk-go-down:2
   
else
    ff=$((nuw - 1))
    echo "_" >> /tmp/.sc
    [[ $(wc -l < /tmp/.sc) -ge 5 ]] && rm -f /tmp/.sc & exit 1 \
    || "/usr/share/idiomind/default/p1.sh" "$1" "$nll" "$ff" & exit 1
fi

ret=$?
if [ $ret -eq 2 ]; then
ff=$((nuw-1))
"/usr/share/idiomind/default/p1.sh" "$1" "$nll" "$ff" &
elif [ $ret -eq 3 ]; then
ff=$((nuw+1))
"/usr/share/idiomind/default/p1.sh" "$1" "$nll" "$ff" &
fi

