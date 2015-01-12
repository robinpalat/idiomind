#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf

wth=$(sed -n 5p $DC_s/cnfg18)
eht=$(sed -n 6p $DC_s/cnfg18)
ap=$(cat $DC_s/cnfg1 | sed -n 5p)
echo "_" >> $DC/addons/stats/.tmp &
re='^[0-9]+$'
v="$1"
now="$2"
nuw="$3"

[[ "$v" = v1 ]] && ind="$DC_tlt/cnfg1"
[[ "$v" = v2 ]] && ind="$DC_tlt/cnfg2"

if ! [[ $nuw =~ $re ]]; then
	nuw=$(cat "$ind" \
	| grep -Fxon "$now" \
	| sed -n 's/^\([0-9]*\)[:].*/\1/p')
	nll=" "
fi
nme=$(sed -n "$nuw"p "$ind")
if [ -z "$nme" ]; then
	nme=$(sed -n 1p "$ind")
	nuw=1
fi

if [ -f "$DM_tlt/words/$nme.mp3" ]; then
	tgs=$(eyeD3 "$DM_tlt/words/$nme.mp3")
	trgt="$nme"
	src=$(echo "$tgs" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
	exmp=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
	mrk=$(echo "$tgs" | grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)')
	[[ $(echo "$exmp" | sed -n 2p) ]] \
	&& dfnts="--field=<span color='#696464'>$(echo "$exmp" | sed -n 2p)</span>\\n:lbl"
	[[ $(echo "$exmp" | sed -n 3p) ]] \
	&& ntess="--field=<span color='#868686'>$(echo "$exmp" | sed -n 3p)</span>\\n:lbl"
	hlgt=$(echo $trgt | awk '{print tolower($0)}')
	exmp1=$(echo "$(echo "$exmp" | sed -n 1p)" | sed "s/"$(echo $trgt \
	| awk '{print tolower($0)}')"/<span background='#CFFF8B'>"$(echo $trgt \
	| awk '{print tolower($0)}')"<\/\span>/g")
	[[ "$(echo "$tgs" | grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)')" = TRUE ]] \
	&& trgt=$(echo "<big><u><b>"$trgt"</b></u></big>")
	[[ "$ap" = TRUE ]] && (killall play & sleep 0.3 && play "$DM_tlt/words/$nme.mp3") &
	
	yad --form --window-icon=idiomind --scroll --text-align=center \
	--skip-taskbar --center --title=" " --borders=10 \
	--quoted-output --on-top --selectable-labels \
	--text="<big><big><big>$trgt</big></big></big>\\n\\n<i>$src</i>\\n\\n" \
	--field="":lbl \
	--field="<i><span color='#808080'>$exmp1</span></i>:lbl" "$dfnts" "$ntess" \
	--width="$wth" --height="$eht" --center \
	--button=gtk-edit:4 --button="Play":"play '$DM_tlt/words/$nme.mp3'" \
	--button=gtk-go-up:3 --button=gtk-go-down:2 \
	--dclick-action=/usr/share/idiomind/audio/pl >/dev/null 2>&1
	
elif [ -f "$DM_tlt/$nme.mp3" ]; then
	tgs=$(eyeD3 "$DM_tlt/$nme.mp3")
	[[ $(sed -n 4p $DC_s/cnfg1) = TRUE ]] \
	&& trgt=$(echo "$tgs" | grep -o -P '(?<=IGMI3I0I).*(?=IGMI3I0I)') \
	|| trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
	src=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
	lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
	[[ ! -f "$DM_tlt/$nme.mp3" ]] && exit 1
	[[ "$ap" = TRUE ]] && (killall play & sleep 0.3 && play "$DM_tlt/$nme.mp3") &
	
	echo "$lwrd" | yad --list --print-column=0 --no-headers \
	--window-icon=idiomind --scroll --text-align=center \
	--skip-taskbar --center --title=" " --borders=10 \
	--on-top --selectable-labels --expand-column=0 \
	--text="<big><big>$trgt</big></big>\\n\\n<i>$src</i>\\n\\n\\n" \
	--width="$wth" --height="$eht" --center \
	--column="$lgtl":TEXT --column="$lgsl":TEXT \
	--button=gtk-edit:4 --button="play":"$DS/audio/ply2 '$nme'" \
	--button=gtk-go-up:3 --button=gtk-go-down:2 \
	--dclick-action=/usr/share/idiomind/audio/pl >/dev/null 2>&1
else
	ff=$(($nuw + 1))
	$DS/vwr.sh "$v" "$nll" "$ff" & exit 1
fi
		ret=$?
		if [[ $ret -eq 4 ]]; then
			$DS/mngr.sh edt "$v" "$nme" $nuw & exit 1
		elif [[ $ret -eq 2 ]]; then
			ff=$(($nuw + 1))
			$DS/vwr.sh "$v" "$nll" $ff &
		elif [[ $ret -eq 3 ]]; then
			ff=$(($nuw - 1))
			$DS/vwr.sh "$v" "$nll" $ff &
		else 
			echo "vwr.$(cat $DC/addons/stats/.tmp | wc -l).vwr" >> \
			$DC/addons/stats/.log
			rm $DC/addons/stats/.tmp & exit 1
		fi
