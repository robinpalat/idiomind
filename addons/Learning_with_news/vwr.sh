#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/rss.conf
DS_pf="$DS/addons/Learning_with_news"
vwr="$DS_pf/vwr.sh"
ap=$(cat $DC_s/cnfg1 | sed -n 5p)

if [[ $1 = V1 ]]; then

	DS_pf="$DS/addons/Learning_with_news"
	wth=$(sed -n 5p $DC_s/cnfg18)
	eht=$(sed -n 6p $DC_s/cnfg18)
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
	
	echo "$nme" > $DT/.dzmx.x
	n_i="$DS_pf/add n_i '$nme'"
	tgs=$(eyeD3 "$DM_tl/Feeds/conten/$nme.mp3")
	trg=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
	srce=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
	lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
	lnk=$(cat "$DM_tl/Feeds/conten/$nme.lnk")
	
	if [[ -f "$DM_tl/Feeds/conten/$nme.mp3" ]]; then
	
		if [ "$ap" = TRUE ]; then
			(killall play & sleep 0.3 && play "$DM_tl/Feeds/conten/$nme.mp3") &
		fi
		
		echo "$lwrd" | awk '{print $0""}' | $yad --list \
		--window-icon=idiomind --scroll --quoted-output \
		--skip-taskbar --center --title=" " --borders=10 \
		--text="<big><big>$trg</big></big> <a href='$lnk'>More</a>\\n\\n<i>$srce</i>\\n\\n\\n" \
		--width="$wth" --height="$eht" --center --no-headers \
		--column=$lgtl:TEXT --column=$lgsl:TEXT \
		--expand-column=0 --limit=20 --text-align=center \
		--button=gtk-save:"$DS_pf/add n_i '$nme'" \
		--button=$listen:"$DS_pf/audio/ply '$nme'" \
		--button=gtk-go-up:3 --button=gtk-go-down:2 \
		--dclick-action="$DS_pf/audio/ply.sh '$nme'"
		
	else
		ff=$(($nuw + 1))
		$vwr V1 "$nll" "$ff" & exit 1
	fi

		ret=$?
		if [[ $ret -eq 2 ]]; then
			ff=$(($nuw + 1))
			$vwr V1 "$nll" "$ff" &
		elif [[ $ret -eq 3 ]]; then
			ff=$(($nuw - 1))
			$vwr V1 "$nll" "$ff" &
		else
			rm -f $DT/.*.x &
		exit 1
		fi
		
elif [[ $1 = V2 ]]; then
	
	DM_tlfk="$DM_tl/Feeds/kept"
	DS_pf="$DS/addons/Learning_with_news"
	trgt="$DS_pf/trgt1"
	wth=$(sed -n 5p $DC_s/cnfg18)
	eht=$(sed -n 6p $DC_s/cnfg18)
	c=$(echo $(($RANDOM%100)))
	re='^[0-9]+$'
	now="$2"
	nuw="$3"
	
	if ! [[ $nuw =~ $re ]]; then
		nuw=$(cat "$DC_tl/Feeds/cnfg0" | grep -Fxon "$now" \
		| sed -n 's/^\([0-9]*\)[:].*/\1/p')
		nll=" "
	fi

	nme=$(sed -n "$nuw"p "$DC_tl/Feeds/cnfg0")
	if [ -z "$nme" ]; then
		nme=$(sed -n 1p "$DC_tl/Feeds/cnfg0")
		nuw=1
	fi

	lnk=$(cat "$DM_tlfk/$nme.lnk")
	echo "$nme" > $DT/.dzmx.x
	if [ "$ap" = TRUE ]; then
		(killall play & sleep 0.3 && play "$DM_tlfk/words/$nme.mp3") &
	fi

	if [[ -f "$DM_tlfk/words/$nme.mp3" ]]; then
		tgs=$(eyeD3 "$DM_tlfk/words/$nme.mp3")
		trg=$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
		srce=$(echo "$tgs" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
		lswd=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
		exm=$(echo "$lswd" | sed -n 1p)
		exmp=$(echo "$exm" | sed "s/"$trg"/<span background='#CFFF8B'>"$trg"<\/\span>/g")
		
		echo "$lwrd" | awk '{print $0""}' | yad --form \
		--window-icon=idiomind --scroll --text-align=center \
		--skip-taskbar --center --title="$MPG " --borders=10 \
		--quoted-output --selectable-labels \
		--text="<big><big>$trg</big></big>\\n\\n<i>$srce</i>\\n\\n" \
		--field="":lbl \
		--field="<i>$exmp</i>\\n:lbl" \
		--width="$wth" --height="$eht" --center \
		--button="$delete":"$DS_pf/del dlti '$nme'" \
		--button="$listen":"play '$DM_tlfk/words/$nme.mp3'" \
		--button=gtk-go-up:3 --button=gtk-go-down:2

	elif [[ -f "$DM_tlfk/$nme.mp3" ]]; then
		if [ "$ap" = TRUE ]; then
			(killall play & sleep 0.3 && play "$DM_tlfk/$nme.mp3") &
		fi
		tgs=$(eyeD3 "$DM_tlfk/$nme.mp3")
		trg=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
		srce=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
		lwrd=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' | tr '_' '\n')
		
		echo "$lwrd" | awk '{print $0""}' | yad --list \
		--window-icon=idiomind --scroll --text-align=center \
		--skip-taskbar --center --title=" " --borders=10 \
		--quoted-output --selectable-labels --no-headers \
		--text="<big><big>$trg</big></big> <a href='$lnk'>More</a>\\n\\n<i>$srce</i>\\n\\n\\n" \
		--width="$wth" --height="$eht" --center \
		--column=$lgtl:TEXT --column=$lgsl:TEXT \
		--expand-column=0 --limit=20 \
		--button="$delete":"$DS_pf/del dlti '$nme'" \
		--button=$listen:"$DS_pf/audio/ply '$nme'" \
		--button=gtk-go-up:3 --button=gtk-go-down:2 \
		--dclick-action="$DS_pf/audio/ply.sh '.audio'"
		
	else
		ff=$(($nuw + 1))
		$vwr V2 "$nll" "$ff" & exit 1
	fi
	
		ret=$?
		if [[ $ret -eq 2 ]]; then
			ff=$(($nuw + 1))
			$vwr V2 "$nll" "$ff" &
		elif [[ $ret -eq 3 ]]; then
			ff=$(($nuw - 1))
			$vwr V2 "$nll" "$ff" &
		else
			rm -f $DT/.*.x & exit 1
		fi
fi
