#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/topics_lists.conf
if [[ "$1" = chngi ]]; then
	saw=$(sed -n 1p $DC_s/cnfg5)
	sas=$(sed -n 2p $DC_s/cnfg5)
	sam=$(sed -n 3p $DC_s/cnfg5)
	sap=$(sed -n 4p $DC_s/cnfg5)
	saf=$(sed -n 5p $DC_s/cnfg5)
	nta=$(sed -n 6p $DC_s/cnfg5)
	sna=$(sed -n 7p $DC_s/cnfg5)
	cnfg1="$DC_s/cnfg5"
	indx="$DT/.$user/indx"
	tlck="$DS/images/chng.mp3"
	imgt="/$DT/FRONT_COVER.jpeg"
	rm -f "$DT/FRONT_COVER.jpeg"
	wth=$(sed -n 10p $DC_s/cnfg18)
	eht=$(sed -n 9p $DC_s/cnfg18)
	nim=$(sed -n 11p $DC_s/cnfg18)
	indp="$DT/.$user/indp"
	
	if [[ -z $(cat $DC_s/cnfg2) ]]; then
		echo 8 > $DC_s/cnfg2
		bcl=$(cat $DC_s/cnfg2)
	else
		bcl=$(cat $DC_s/cnfg2)
	fi

	itm=$(sed -n "$2"p $indx)
	
	if ( [ $sas = TRUE ] ) && \
	( [ $(echo "$itm" | wc -w) != 1 ] && \
	[ -f "$DM_tlt/$itm.mp3" ] || [ -f "$DM_tlt/$itm.omd" ] ); then

		if [ -f "$DM_tlt/$itm.mp3" ]; then
			file="$DM_tlt/$itm.mp3"
		else
			file="$DM_tlt/$itm.omd"
		fi
		
		tgs=$(eyeD3 "$file")
		srce=$(echo "$tgs" | \
		grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
		gmmk=$(echo "$tgs" | \
		grep -o -P '(?<=IGMI3I0I).*(?=IGMI3I0I)')
		
		if [ -z "$trgt" ]; then
			trgt="$itm"
		fi
		
		if [ -z "$srce" ]; then
			srce=" 
			- - - - "
		fi
		
		cnt=$(echo "$trgt" | wc -w)
		
		if echo "$nta" | grep "TRUE"; then
			cnt=10
		fi
		
		wmm=$(($bcl + $cnt / 2 ))
		wmt=$(($wmm + 5))
		rm -f $imgt
		eyeD3 --write-images=$DT "$file"
		imgt=$DT/FRONT_COVER.jpeg
		if [ -f $imgt ]; then
			img=$imgt
			osdi=$imgt
		else
			if [[ -n "$(cat "$indp" | grep "$itm")" ]] \
			&& [[ $sap = TRUE ]]; then
				img=$br2
			else
				img=$br
			fi
			osdi=idiomind
		fi
		if echo "$nta" | grep "TRUE"; then
			notify-send -i "$osdi" "$trgt" "$srce\\n" -t 12000  &
		fi
		sleep 1
		
		if echo "$sna" | grep "TRUE"; then
			play "$DM_tlt/$itm".mp3 &
			if [ $bcl -ge 30 ]; then
				(sleep 15 && play "$DM_tlt/$itm".mp3) &
			fi
		fi
		
		sleep $wmm
	
	elif ( [ $saw = TRUE ] || [ $sap = TRUE ] || [ $sam = TRUE ] ) && \
	( [ $(echo "$itm" | wc -w) = 1 ] && \
	[ -f "$DM_tlt/words/$itm.mp3" ] ); then
	
		file="$DM_tlt/words/$itm.mp3"
		if echo "$nta" | grep "TRUE"; then
			cnt=10
		else
			cnt=1
		fi
		wmm=$(($bcl + $cnt))
		wmt=$(($wmm + 5))
		rm -f $imgt
		eyeD3 --write-images=$DT "$file"
		imgt=$DT/FRONT_COVER.jpeg
		if [ -f $imgt ]; then
			img=$imgt
			osdi=$imgt
		else
			if [[ -n "$(cat "$indp" | grep "$itm")" ]] \
			&& [[ $sap = TRUE ]]; then
				img=$br2
			else
				img=$br
			fi
			osdi=idiomind
		fi
		tgs=$(eyeD3 "$file")
		tgt=$(echo "$tgs" | \
		grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
		srce=$(echo "$tgs" | \
		grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
		mrk=$(echo "$tgs" | \
		grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)')
		if [ -z "$tgt" ]; then
			tgt="$itm"
		fi
		if [ -z "$srce" ]; then
			srce=" - - - "
		fi
		if [ "$mrk" = TRUE ]; then
			trgt="$tgt"
		else
			trgt="$tgt"
		fi
		if echo "$nta" | grep "TRUE"; then
			notify-send -i "$osdi" "$trgt" "$srce\n" -t 7000 &
		fi
		sleep 1
		if echo "$sna" | grep "TRUE"; then
			play "$DM_tlt/words/$itm".mp3 &
			if [ $bcl -ge 5 ]; then
				(sleep 2.5 && play "$DM_tlt/words/$itm.mp3") &
			fi
			if [ $bcl -ge 30 ]; then
				(sleep 10 && play "$DM_tlt/words/$itm.mp3"
				sleep 10
				play "$DM_tlt/words/$itm.mp3") &
			fi
		fi
		rm -f $DT/*.jpeg ./.id.tmp
		sleep $wmm
				
	elif ([ $saf = TRUE ]) && \
	([ -f "$DM_tl/Feeds/kept/words/$itm.mp3" ] || [ -f "$DM_tl/Feeds/kept/$itm.mp3" ]); then
	
		if [ -f "$DM_tl/Feeds/kept/$itm.mp3" ]; then
			file="$DM_tl/Feeds/kept/$itm.mp3"
			tgs=$(eyeD3 "$file")
			trgt=$(echo "$tgs" | \
			grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
			srce=$(echo "$tgs" | \
			grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
			cnt=$(echo "$trgt" | wc -w)
			if [ -z "$trgt" ]; then
				trgt="$itm"
			fi
			if echo "$nta" | grep "TRUE"; then
				cnt=10
			fi
			wmm=$(($bcl + $cnt))
			wmt=$(($wmm + 5))
			if echo "$nta" | grep "TRUE"; then
				notify-send -i idiomind "$trgt" "$srce" -t 8000 -i idiomind &
			fi
			sleep 1
			if echo "$sna" | grep "TRUE"; then
				play "$DM_tl/Feeds/kept/$itm".mp3 &
			fi
			sleep $wmm
					
		elif [ -f "$DM_tl/Feeds/kept/words/$itm.mp3" ]; then
			
			file="$DM_tl/Feeds/kept/words/$itm.mp3"
			if echo "$nta" | grep "TRUE"; then
				cnt=10
			else
				cnt=1
			fi
			wmm=$(($bcl + $cnt))
			wmt=$(($wmm + 5))
			tgs=$(eyeD3 "$file")
			tgt=$(echo "$tgs" | \
			grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
			srce=$(echo "$tgs" | \
			grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
			mrk=$(echo "$tgs" | \
			grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)')
			exm=$(echo "$tgs" | \
			grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)')
			exmm=$(echo "$exm" | \
			sed "s/"$tgt"/<b>"$tgt"<\/\b>/g")
			if [ -z "$tgt" ]; then
				tgt="$itm"
			fi
			if [ -n "$exm" ]; then
				exmp=$(echo "<i><small>"$exmm"\\n</small></i>")
			else
				exmp=$(echo " ")
			fi
			if [ "$mrk" = TRUE ]; then
				trgt="* $tgt"
			else
				trgt="$tgt"
			fi
			if echo "$nta" | grep "TRUE"; then
				notify-send -i idiomind "$trgt" "$srce\\n\\n[ $exm ]" -t 7000 &
			fi
			sleep 1
			if echo "$sna" | grep "TRUE"; then
				play "$DM_tl/Feeds/kept/words/$itm".mp3 &
				if [ $bcl -ge 5 ]; then
					(sleep 4 && play "$DM_tl/Feeds/kept/words/$itm.mp3") &
				fi
			fi
			rm -f $DT/*.jpeg
			sleep $wmm
		else
			exit 1
		fi
		[[ -f $DT/.bcle ]] && rm -f $DT/.bcle
	else
		echo "$itm" >> $DT/.bcle
		echo "-- no file found"
		if [ $(cat $DT/.p__$use | wc -l) -gt 5 ]; then
			int="$(sed -n 16p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
			T="$(echo "$int" | sed -n 1p)"
			D="$(echo "$int" | sed -n 2p)" #interrupt
			notify-send -i idiomind "$T" "$D" -t 9000 &
			rm -fr $DT/.p__$user &
			$DS/stop.sh S & exit 1
		fi
	fi

elif [ "$1" != chngi ]; then
	
	if [ ! -d $DC_s ]; then
		/usr/share/idiomind/ifs/1u &
		exit 1
	fi
	if [ ! -f $DC_s/cnfg0 ]; then
		> $DC_s/cnfg0
		fi
		eht=$(sed -n 3p $DC_s/cnfg18)
		wth=$(sed -n 4p $DC_s/cnfg18)
		if [ -n "$1" ]; then
			text="--text=<small>$1\n</small>"
			align="--text-align=left"
		else
			host="http://tmp.site50.net"
			lgtl=$(echo "$lgtl" | awk '{print tolower($0)}')
			text="--text=<small><small><a href='$host/$lgs/$lgtl'>$find_topics</a>\t</small></small>"
			align="--text-align=right"
		fi
		[[ -f $DC_tl/.cnfg1 ]] && info2=$(cat $DC_tl/.cnfg1 | wc -l) || info2=""
		cd $DC_s

		VAR=$(cat $DC_s/cnfg0 | $yad --name=idiomind --ellipsize=END \
		--class=idiomind --center --separator="" $align\
		"$text" --width=$wth --height=$eht \
		--no-headers --list --window-icon=idiomind \
		--button="gtk-preferences":$DS/cnfg.sh \
		--button="gtk-add":3 --button="$ok":0 --button="$close":1 \
		--borders=5 --title="$topics" --column=img:img --column=File:TEXT)
			ret=$?
			if [ $ret -eq 3 ]; then
				$DS/add.sh n_t
				exit 1
			elif [ $ret -eq 1 ]; then
				exit 1
			elif [ $ret -eq 0 ]; then
				if [ -n "$1" ]; then
					if [ "$2" = 3 ]; then
						$DC_tl/"$VAR"/tpc.sh
						$DS/add.sh n_i  & exit
					else
						$DC_tl/"$VAR"/tpc.sh 2 & exit
					fi
				else
					$DC_tl/"$VAR"/tpc.sh & exit
				fi
			else
				exit 0
			fi
fi
