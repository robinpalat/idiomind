#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf

if [[ "$1" = chngi ]]; then
	saw=$(sed -n 1p $DC_s/cnfg5) # words
	sas=$(sed -n 2p $DC_s/cnfg5) # sentences
	sam=$(sed -n 3p $DC_s/cnfg5) # marks
	sap=$(sed -n 4p $DC_s/cnfg5) # practice
	saf=$(sed -n 5p $DC_s/cnfg5) # feeds conten
	nta=$(sed -n 6p $DC_s/cnfg5) # osd
	sna=$(sed -n 7p $DC_s/cnfg5) # audio
	user=$(echo "$(whoami)")
	cnfg1="$DC_s/cnfg5"
	indx="$DT/.$user/indx"
	tlck="$DS/images/chng.mp3"
	imgt="/$DT/FRONT_COVER.jpeg"
	rm -f "$DT/FRONT_COVER.jpeg"
	wth=$(sed -n 10p $DC_s/cnfg18)
	eht=$(sed -n 9p $DC_s/cnfg18)
	nim=$(sed -n 11p $DC_s/cnfg18)
	indp="$DT/.$user/indp"
	br="$DS/images/br.png"
	br2="$DS/images/br2.png"
	br3="$DS/images/br3.png"
	
	if [[ -z $(sed -n 1p $DC_s/cnfg2) ]]; then
	pst=$(sed -n 1p $DC_s/cnfg17)
		echo 8 > $DC_s/cnfg2
		echo $pst >> $DC_s/cnfg2
		bcl=$(sed -n 1p $DC_s/cnfg2)
		pst=$(sed -n 2p $DC_s/cnfg2)
	else
		bcl=$(sed -n 1p $DC_s/cnfg2)
		pst=$(sed -n 2p $DC_s/cnfg2)
	fi
	if echo "$sna" | grep "TRUE"; then
		aud=play
	else
		aud='#'
	fi
	if echo "$nta" | grep "TRUE"; then
		osd=notify-send
		bcl=$(sed -n 1p $DC_s/cnfg2)
	else
		osd="#"
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
		$osd -i "$osdi" "$trgt" "$srce\\n" -t 8000  &
		sleep 1
		$aud "$DM_tlt/$itm".mp3 &
		
		if [ $bcl -ge 30 ]; then
			(sleep 15 && $aud "$DM_tlt/$itm".mp3) &
		fi
		if [ $bcl -ge 45 ]; then
			(sleep 30 && $aud "$DM_tlt/$itm".mp3) &
		fi
		if [ $bcl -ge 65 ]; then
			(sleep 50 && $aud "$DM_tlt/$itm".mp3) &
		fi
		
		sleep $wmm
	
	elif ( [ $saw = TRUE ] || [ $sap = TRUE ] || [ $sam = TRUE ] ) && \
	( [ $(echo "$itm" | wc -w) = 1 ] && \
	[ -f "$DM_tlt/words/$itm.mp3" ] || [ -f "$DM_tlt/words/$itm.mp3" ] ); then
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

		$osd -i "$osdi" "$trgt" "$srce\n" -t 7000 &
		sleep 1
		$aud "$DM_tlt/words/$itm".mp3 &
		if [ $bcl -ge 5 ]; then
			(sleep 2.5 && $aud "$DM_tlt/words/$itm.mp3") &
		fi
		if [ $bcl -ge 30 ]; then
			(sleep 10 && $aud "$DM_tlt/words/$itm.mp3"
			sleep 10
			$aud "$DM_tlt/words/$itm.mp3") &
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

			$osd -i idiomind "$trgt" "$srce" -t 8000 -i idiomind &
			sleep 1
			$aud "$DM_tl/Feeds/kept/$itm".mp3 &
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

			$osd -i idiomind "$trgt" "$srce\\n\\n[ $exm ]" -t 7000 &
			sleep 1
			$aud "$DM_tl/Feeds/kept/words/$itm".mp3 &
			if [ $bcl -ge 5 ]; then
				(sleep 4 && $aud "$DM_tl/Feeds/kept/words/$itm.mp3") &
			fi
			if [ $bcl -ge 30 ]; then
				(sleep 10 && $aud "$DM_tl/Feeds/kept/words/$itm.mp3"
				sleep 10
				$aud "$DM_tl/Feeds/kept/words/$itm.mp3") &
			fi
			rm -f $DT/*.jpeg
			sleep $wmm
		else
			exit 1
		fi
	else
		exit 1
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
		img1=$DS/images/img1.png
		img2=$DS/images/img2.png
		img3=$DS/images/img3.png
		img4=$DS/images/img4.png
		img5=$DS/images/img5.png
		img6=$DS/images/img6.png
		img7=$DS/images/img7.png
		img8=$DS/images/img8.png
		img9=$DS/images/img9.png
		img10=$DS/images/img10.png
		img11=$DS/images/img11.png
		img12=$DS/images/img12.png
		text=--class=idm
		if [ -n "$1" ]; then
			text="--text=$(cat "$1")"
		fi
		info2=$(cat $DC_tl/.cnfg1 | wc -l)
		cd $DC_s

		VAR=$(cat $DC_s/cnfg0 | $yad --name=idiomind --ellipsize=END \
		--class=idiomind --center --separator="" \
		"$text" --width=$wth --height=$eht \
		--no-headers --list --window-icon=idiomind \
		--button="gtk-preferences":$DS/cnfg.sh \
		--button="gtk-add":3 --button="gtk-ok":0 --button="gtk-close":1 \
		--borders=5 --title "Topics" --column=img:img --column=File:TEXT)
			ret=$?

			if [ $ret -eq 3 ]; then
				$DS/add.sh n_t
				exit 1
			elif [ $ret -eq 1 ]; then
				exit 1
			elif [ $ret -eq 0 ]; then
				if [ -n "$1" ]; then
					$DC_tl/"$VAR/tpc.sh" && $DS/add.sh n_i & exit 1
				else
					$DC_tl/"$VAR/tpc.sh" & exit 1
				fi
			else
				exit 1
			fi
fi

