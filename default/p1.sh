#!/bin/bash
YAD=yad
cd /tmp/.idmtp1.$u/idmimp_X015x/tmp
u=$(echo "$(whoami)")
nmt=$(sed -n 1p /tmp/.idmtp1.$u/idmimp_X015x/ls)
dir="/tmp/.idmtp1.$u/idmimp_X015x/$nmt"
lnglbl=$(sed -n 2p "/tmp/.idmtp1.$u/idmimp_X015x/$nmt/.AL")
lng=$(sed -n 3p "/tmp/.idmtp1.$u/idmimp_X015x/$nmt/.AL")
lngs=$(sed -n 4p "/tmp/.idmtp1.$u/idmimp_X015x/$nmt/.AL")
var2=$(sed -n 1p "/tmp/.idmtp1.$u/idmimp_X015x/$nmt/.AL")
wth=$(sed -n 5p $HOME/.config/idiomind/s/.rd)
eht=$(sed -n 6p $HOME/.config/idiomind/s/.rd)
re='^[0-9]+$'
now="$1"
nuw="$2"
cd "$dir"

if ! [[ $nuw =~ $re ]]; then
nuw=$(cat "$dir/.t-inx" | grep -Fxon "$now" \
| sed -n 's/^\([0-9]*\)[:].*/\1/p')
nll='echo  " "'
fi
nms=$(sed -n "$nuw"p "$dir/.t-inx")
if [ -z "$nms" ]; then
nms=$(sed -n 1p "$dir/.t-inx")
nuw=1
fi

if [[ "$(echo "$nms" | wc -w)" -eq "1" ]]; then

	if [ -f "$dir/words/$nms.mp3" ]; then
		file="$dir/words/$nms.mp3"
		listen="--button=►:play '$dir/words/$nms.mp3'"
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
	
	$YAD --columns=1 --form \
	--window-icon=idiomind --scroll --text-align=center \
	--skip-taskbar --center --title="$MPG " --borders=10 \
	--quoted-output --on-top --selectable-labels \
	--text="<big><big>$trgt</big></big>\\n\\n\
<small><big><i>$src</i></big></small>\\n\\n" \
	--field="":lbl \
	--field="<i><span color='#808080'>$exmp1\
	</span></i>\\n:lbl" "$dfnts" \
	"$ntess" \
	--width=$wth --height=$eht --center \
	"$listen" --button=gtk-go-up:3 --button=gtk-go-down:2
	
else

	if [ -f "$dir/$nms.mp3" ]; then
		file="$dir/$nms.mp3"
		listen="--button=►:play '$dir/$nms.mp3'"
	elif [ -f "$dir/$nms.omd" ]; then
		file="$dir/$nms.omd"
		listen="--list"
	fi
	
	dwck="/tmp/.idmtp1.$u/p2.X015x"
	tgs=$(eyeD3 "$file")
	trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
	src=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
	lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
	
	echo "$lwrd" | awk '{print $0""}' | $YAD --list \
	--window-icon=idiomind --scroll \
	--skip-taskbar --center --title=" " --borders=10 \
	--on-top --selectable-labels --expand-column=0 \
	--text="<big>$trgt</big>\\n\\n<small><i>$src</i></small>\\n" \
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

