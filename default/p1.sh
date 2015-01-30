#!/bin/bash
YAD=yad

u=$(echo "$(whoami)")
nmt=$(sed -n 1p /tmp/.idmtp1.$u/idmimp_X015x/ls)
dir="/tmp/.idmtp1.$u/idmimp_X015x/$nmt"
lnglbl=$(sed -n 2p "/tmp/.idmtp1.$u/idmimp_X015x/$nmt/cfg.13")
lng=$(sed -n 3p "/tmp/.idmtp1.$u/idmimp_X015x/$nmt/cfg.13")
lngs=$(sed -n 4p "/tmp/.idmtp1.$u/idmimp_X015x/$nmt/cfg.13")
var2=$(sed -n 1p "/tmp/.idmtp1.$u/idmimp_X015x/$nmt/cfg.13")
wth=$(sed -n 5p $HOME/.config/idiomind/s/cfg.18)
eht=$(sed -n 6p $HOME/.config/idiomind/s/cfg.18)
re='^[0-9]+$'
now="$1"
nuw="$2"
cd "$dir"

if ! [[ $nuw =~ $re ]]; then
nuw=$(cat "$dir/cfg.0" | grep -Fxon "$now" \
| sed -n 's/^\([0-9]*\)[:].*/\1/p')
nll='echo  " "'
fi
nms="$(sed -n "$nuw"p "$dir/cfg.0" | cut -c 1-100 \
| sed 's/[ \t]*$//' | sed s'/&//'g | sed s'/://'g | sed "s/'/ /g")"
if [ -z "$nms" ]; then
nms="$(sed -n 1p "$dir/cfg.0" | cut -c 1-100 \
| sed 's/[ \t]*$//' | sed s'/&//'g | sed s'/://'g | sed "s/'/ /g")"
nuw=1
fi

if [[ "$(echo "$nms" | wc -w)" -eq "1" ]]; then

	if [ -f "$dir/words/$nms.mp3" ]; then
		file="$dir/words/$nms.mp3"
		listen="--button=Listen:play '$dir/words/$nms.mp3'"
	else
		file="$dir/words/$nms.omd"
		listen="--form"
	fi
	
	tgs=$(eyeD3 "$file")
	trgt=$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
	src=$(echo "$tgs" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
	exmp=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
	exm1=$(echo "$exmp" | sed -n 1p)
	dftn=$(echo "$exmp" | sed -n 2p)
	ntes=$(echo "$exmp" | sed -n 3p)
	dfnts="--field=<i><span color='#696464'>$dftn</span></i>\\n:lbl"
	ntess="--field=<span color='#868686'>$ntes</span>\\n:lbl"
	exmp1=$(echo "$exm1" \
	| sed "s/"$trgt"/<span background='#CFFF8B'>"$trgt"<\/\span>/g")
	
	yad --columns=1 --form --width=$wth --height=$eht --center \
	--window-icon=idiomind --scroll --text-align=center \
	--skip-taskbar --center --title="$MPG " --borders=15 \
	--quoted-output --on-top --selectable-labels \
	--text="<big><big><big><b>$trgt</b></big></big></big>\n\n<i>$src</i>\n\n" \
	--field="":lbl \
	--field="<i><span color='#808080'>$exmp1\
	</span></i>\\n:lbl" "$dfnts" \
	"$ntess" \
	"$listen" --button=gtk-go-up:3 --button=gtk-go-down:2
	
else

	if [ -f "$dir/$nms.mp3" ]; then
		file="$dir/$nms.mp3"
		listen="--button=Listen:play '$dir/$nms.mp3'"
	elif [ -f "$dir/$nms.omd" ]; then
		file="$dir/$nms.omd"
		listen="--list"
	fi
	
	dwck="/tmp/.idmtp1.$u/p2.X015x"
	tgs=$(eyeD3 "$file")
	trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
	src=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
	lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
	
	echo "$lwrd" | awk '{print $0""}' | yad --list \
	--window-icon=idiomind --scroll --no-headers \
	--skip-taskbar --center --title=" " --borders=15 \
	--on-top --selectable-labels --expand-column=0 \
	--text="<big><big>$trgt</big></big>\\n\\n<i>$src</i>\\n\\n" \
	--width=$wth --height=$eht --center \
	--column=$lnglbl:TEXT --column=$lngs:TEXT \
	"$listen" --button=gtk-go-up:3 --button=gtk-go-down:2 \
	--dclick-action="$dwck"
fi

ret=$?
if [[ $ret -eq 2 ]]; then
ff=$(($nuw + 1))
/tmp/.idmtp1.$u/p1.X015x "$nll" "$ff" &
elif [[ $ret -eq 3 ]]; then
ff=$(($nuw - 1))
/tmp/.idmtp1.$u/p1.X015x "$nll" "$ff" &
exit 1
fi

