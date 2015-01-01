#!/bin/bash
source /usr/share/idiomind/ifs/c.conf
DS_pf="$DS/addons/Learning_with_news"
vwr.sh="$DS_pf/vwr.sh"

if [[ $1 = V1 ]]; then

	DS_pf="$DS/addons/Learning_with_news"
	wth=$(sed -n 5p $DC_s/.rd)
	eht=$(sed -n 6p $DC_s/.rd)
	c=$(echo $(($RANDOM%100)))
	re='^[0-9]+$'
	now="$2"
	nuw="$3"

	if ! [[ $nuw =~ $re ]]; then
		nuw=$(cat "$DC_tl/Feeds/.lst" | grep -Fxon "$now" \
		| sed -n 's/^\([0-9]*\)[:].*/\1/p')
		nll=" "
	fi

	nme=$(sed -n "$nuw"p "$DC_tl/Feeds/.lst")
	if [ -z "$nme" ]; then
		nme=$(sed -n 1p "$DC_tl/Feeds/.lst")
		nuw=1
	fi

	listen="--button=Play:$DS_pf/audio/ply '$nme'"
	echo "$nme" > $DT/.dzmx.x

	n_i="$DS_pf/add n_i '$nme'"
	tgs=$(eyeD3 "$DM_tl/Feeds/conten/$nme.mp3")
	trg=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
	srce=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
	lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
	lnk=$(cat "$DM_tl/Feeds/conten/$nme.lnk")

	echo "$lwrd" | awk '{print $0""}' | $yad --list \
	--window-icon=idiomind --scroll --quoted-output \
	--skip-taskbar --center --title=" " --borders=10 \
	--text="<big>$trg </big><a href='$lnk'><small>More</small></a>\\n\\n<small><i>$srce</i></small>\\n" \
	--width="$wth" --height="$eht" --center \
	--column=$lgtl:TEXT --column=$lgsl:TEXT \
	--expand-column=0 --limit=20 \
	--button=gtk-save:"$DS_pf/add n_i '$nme'" "$listen" \
	--button=gtk-go-up:3 --button=gtk-go-down:2 \
	--dclick-action="$DS_pf/audio/ply.sh '$nme'"

		ret=$?
		if [[ $ret -eq 2 ]]; then
			ff=$(($nuw + 1))
			$vwr.sh V1 "$nll" "$ff" &
		elif [[ $ret -eq 3 ]]; then
			ff=$(($nuw - 1))
			$vwr.sh V1 "$nll" "$ff" &
		else
			rm -f $DT/.*.x &
		exit 1
		fi
		
elif [[ $1 = V2 ]]; then
	
	DM_tlfk="$DM_tl/Feeds/kept"
	DS_pf="$DS/addons/Learning_with_news"
	trgt="$DS_pf/trgt1"
	wth=$(sed -n 5p $DC_s/.rd)
	eht=$(sed -n 6p $DC_s/.rd)
	c=$(echo $(($RANDOM%100)))
	re='^[0-9]+$'
	now="$2"
	nuw="$3"
	
	if ! [[ $nuw =~ $re ]]; then
		nuw=$(cat "$DC_tl/Feeds/.t-inx" | grep -Fxon "$now" \
		| sed -n 's/^\([0-9]*\)[:].*/\1/p')
		nll=" "
	fi

	nme=$(sed -n "$nuw"p "$DC_tl/Feeds/.t-inx")
	if [ -z "$nme" ]; then
		nme=$(sed -n 1p "$DC_tl/Feeds/.t-inx")
		nuw=1
	fi

	listen="--button=gtk-media-play:play '$DM_tlfk/$nme.mp3'"
	echo "$nme" > $DT/.dzmx.x

	if [[ "$(echo "$nme" | wc -w)" -eq 1 ]]; then
		listen="--button=Play:play '$DM_tlfk/words/$nme.mp3'"
		tgs=$(eyeD3 "$DM_tlfk/words/$nme.mp3")
		trg=$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
		srce=$(echo "$tgs" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
		lswd=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
		exm=$(echo "$lswd" | sed -n 1p)
		exmp=$(echo "$exm" \
		| sed "s/"$trg"/<span background='#CFFF8B'>"$trg"<\/\span>/g")
		
		echo "$lwrd" | awk '{print $0""}' | $yad --columns=2 --form \
		--window-icon=idiomind --scroll --text-align=center \
		--skip-taskbar --center --title="$MPG " --borders=10 \
		--quoted-output  --selectable-labels \
		--text="<big><big>$trg</big></big>\\n\\n<small><big><i>$srce</i></big></small>\\n\\n" \
		--field="":lbl \
		--field="<i><span color='#696464'>$exmp</span></i>\\n:lbl" \
		--field="":lbl \
		--width="$wth" --height="$eht" --center \
		--button=Delete:"$DS_pf/del dlti '$nme'" \
		"$listen" --button=gtk-go-up:3 --button=gtk-go-down:2

	else
		listen="--button=Play:$DS_pf/audio/ply '$nme'"
		tgs=$(eyeD3 "$DM_tlfk/$nme.mp3")
		trg=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
		srce=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
		lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
		
		echo "$lwrd" | awk '{print $0""}' | $yad --list \
		--window-icon=idiomind --scroll \
		--skip-taskbar --center --title=" " --borders=10 \
		--quoted-output --selectable-labels \
		--text="<big>$trg</big>\\n\\n<small><i>$srce</i></small>\\n" \
		--width="$wth" --height="$eht" --center \
		--column=$lgtl:TEXT --column=$lgsl:TEXT \
		--expand-column=0 --limit=20 \
		--button=Delete:"$DS_pf/del dlti '$nme'" \
		"$listen" --button=gtk-go-up:3 --button=gtk-go-down:2 \
		--dclick-action="$DS_pf/audio/ply.sh '.audio'"
	fi
	
		ret=$?
		if [[ $ret -eq 2 ]]; then
			ff=$(($nuw + 1))
			$vwr.sh V2 "$nll" "$ff" &
		elif [[ $ret -eq 3 ]]; then
			ff=$(($nuw - 1))
			$vwr.sh V2 "$nll" "$ff" &
		else
			rm -f $DT/.*.x & exit 1
		fi
fi
