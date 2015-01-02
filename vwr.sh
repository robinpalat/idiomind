#!/bin/bash
source /usr/share/idiomind/ifs/c.conf
wth=$(sed -n 5p $DC_s/.rd)
eht=$(sed -n 6p $DC_s/.rd)
ap=$(cat $DC_s/cnfg1 | sed -n 5p)
echo "_" >> $DC/addons/stats/.tmp &
re='^[0-9]+$'
v="$1"
now="$2" # es el nombre de la lista (file name)
nuw="$3" # es el numero de posicion del item (file name) en la lista
if [ "$v" = v1 ]; then
	ind="$DC_tlt/.tlng-inx"
elif [ "$v" = v2 ]; then
	ind="$DC_tlt/.tok-inx"
fi
if ! [[ $nuw =~ $re ]]; then
	nuw=$(cat "$ind" \
	| grep -Fxon "$now" \
	| sed -n 's/^\([0-9]*\)[:].*/\1/p') # busca el numero de posicion del item (file name) en la lista
	nll=" "
fi
nme=$(sed -n "$nuw"p "$ind")
if [ -z "$nme" ]; then
	nme=$(sed -n 1p "$ind")
	nuw=1
fi

if [ -f "$DM_tlt/words/$nme.mp3" ]; then

	file="$DM_tlt/words/$nme.mp3"
	tgs=$(eyeD3 "$file")
	trgt="$nme"
	src=$(echo "$tgs" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
	exmp=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
	mrk=$(echo "$tgs" | grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)')
	exm1=$(echo "$exmp" | sed -n 1p)
	dftn=$(echo "$exmp" | sed -n 2p)
	ntes=$(echo "$exmp" | sed -n 3p)
	dfnts="--field=<span color='#696464'>$dftn</span>\\n:lbl"
	ntess="--field=<span color='#868686'>$ntes</span>\\n:lbl"
	hlgt=$(echo $trgt | awk '{print tolower($0)}')
	exmp1=$(echo "$exm1" \
	| sed "s/"$hlgt"/<span background='#CFFF8B'>"$hlgt"<\/\span>/g")
	if [ "$mrk" = TRUE ]; then
		trgt=$(echo "<span color='#00335E'><b>"$trgt"</b></span>")
	fi
	if [ "$ap" = TRUE ]; then
		(killall play & sleep 1 && play "$DM_tlt/words/$nme.mp3") &
	fi

	$yad --columns=1 --form \
	--window-icon=idiomind --scroll --text-align=center \
	--skip-taskbar --center --title=" " --borders=10 \
	--quoted-output --on-top --selectable-labels \
	--text="<big><big><big>$trgt</big></big></big>\\n\\n<i>$src</i>\\n\\n" \
	--field="":lbl \
	--field="<i><span color='#808080'>$exmp1</span></i>\\n:lbl" "$dfnts" "$ntess" \
	--width="$wth" --height="$eht" --center \
	--button=gtk-edit:4 --button="Listen:play '$DM_tlt/words/$nme.mp3'" \
	--button=gtk-go-up:3 --button=gtk-go-down:2 \
	--dclick-action=/usr/share/idiomind/audio/pl >/dev/null 2>&1
	
elif [ -f "$DM_tlt/$nme.mp3" ]; then

	file="$DM_tlt/$nme.mp3"
	tgs=$(eyeD3 "$file")
	if [ $(sed -n 4p $DC_s/cnfg1) = TRUE ]; then
		trgt=$(echo "$tgs" | grep -o -P '(?<=IGMI3I0I).*(?=IGMI3I0I)')
	else
		trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
	fi
	src=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
	lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
	
	if [ ! -f "$file" ]; then
		exit 1
	fi
	if [ "$ap" = TRUE ]; then
		(killall play & sleep 1 && play "$DM_tlt/$nme.mp3") &
	fi
	
	echo "$lwrd" | $yad --list --print-column=0 \
	--window-icon=idiomind --scroll --text-align=center \
	--skip-taskbar --center --title=" " --borders=10 \
	--on-top --selectable-labels --expand-column=0 \
	--text="<big><big>$trgt</big></big>\\n\\n<i>$src</i>\\n\\n\\n" \
	--width="$wth" --height="$eht" --center \
	--column="$lgtl":TEXT --column="$lgsl":TEXT \
	--button=gtk-edit:4 --button="Listen:$DS/audio/ply2 '$nme'" \
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
