#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/edit.conf

if [ $1 = edit ]; then
	ttl=$(sed -n 2p $DC_s/cnfg6)
	plg1=$(sed -n 1p $DC_s/cnfg3)
	cnfg1="$DC_s/cnfg1"
	ti=$(cat "$DC_tl/$tpc/cnfg0" | wc -l)
	ni="$DC_tl/$tpc/cnfg1"
	bi=$(cat "$DC_tl/$tpc/cnfg2" | wc -l)
	nstll=$(grep -Fxo "$tpc" "$DC_tl"/.cnfg3)
	eht=$(sed -n 7p $DC_s/cnfg18)
	wth=$(sed -n 8p $DC_s/cnfg18)
	slct=$(mktemp $DT/slct.XXXX)
	img1=$DS/images/ok.png
	img2=$DS/images/rw.png
	img3=$DS/images/rn.png
	img4=$DS/images/dlt.png
	img5=$DS/images/upd.png
	img6=$DS/images/pdf.png
	st1=FALSE
	st2=FALSE
	st3=FALSE
	st4=FALSE
	st5=FALSE
	st6=FALSE
	
	if [ -z "$nstll" ]; then
		if [ "$ti" -ge 15 ]; then
			dd="$img1 $learned $img2 $review $img3 $rename $img4 $delete $img5 $share $img6 $topdf"
		else
			dd="$img3 $rename $img4 $delete $img5 $share $img6 $topdf"
		fi
	else
		if [ "$ti" -ge 15 ]; then
			dd="$img1 $learned $img2 $review $img3 $rename $img4 $delete $img6 $topdf"
		else
			dd="$img3 $rename $img4 $delete $img6 $topdf"
		fi
	fi
	$yad --list --on-top --expand-column=2 --center \
	--width=160 --name=idiomind --class=idmnd \
	--height=220 --title=" " --window-icon=idiomind --no-headers \
	--buttons-layout=end --skip-taskbar \
	--borders=0 --button=Ok:0 --column=icon:IMG \
	--column=Action:TEXT $dd > "$slct"
	ret=$?
	slt=$(cat "$slct")
	if  [[ "$ret" -eq 0 ]]; then
		if echo "$slt" | grep -o $learned; then
			/usr/share/idiomind/mngr.sh mkok-
		elif echo "$slt" | grep -o $review; then
			/usr/share/idiomind/mngr.sh mklg-
		elif echo "$slt" | grep -o $rename; then
			/usr/share/idiomind/add.sh n_t name 2
		elif echo "$slt" | grep -o $delete; then
			/usr/share/idiomind/mngr.sh dlt
		elif echo "$slt" | grep -o $share; then
			/usr/share/idiomind/ifs/upld.sh
		elif echo "$slt" | grep -o $topdf; then
			/usr/share/idiomind/ifs/tls.sh pdf
		fi
		rm -f "$slct"

	elif [[ "$ret" -eq 1 ]]; then
		exit 1
	fi
#--------------------------------
elif [ $1 = inx ]; then
	[ $lgt = ja ] || [ $lgt = zh-cn ] && c=c || c=w
	itm="$3"
	fns="$5"
	DC_tlt="$DC_tl/$4"

	if [ -z "$itm" ]; then
		exit 1
	fi
	
	if [ "$2" = W ]; then
		if [[ "$(cat "$DC_tlt/cnfg0" | grep "$fns")" ]] && [ -n "$fns" ]; then
			sed -i "s/${fns}/${fns}\n$itm/" "$DC_tlt/cnfg11"
			sed -i "s/${fns}/${fns}\n$itm/" "$DC_tlt/cnfg0"
			sed -i "s/${fns}/${fns}\n$itm/" "$DC_tlt/cnfg1"
		else
			echo "$itm" >> "$DC_tlt/cnfg11"
			echo "$itm" >> "$DC_tlt/cnfg0"
			echo "$itm" >> "$DC_tlt/cnfg1"
		fi
		echo "$itm" >> "$DC_tlt/cnfg3"
	elif [ "$2" = S ]; then
		echo "$itm" >> "$DC_tlt"/cnfg11
		echo "$itm" >> "$DC_tlt"/cnfg0
		echo "$itm" >> "$DC_tlt"/cnfg1
		echo "$itm" >> "$DC_tlt"/cnfg4
	fi
	
	lss="$DC_tlt/cnfg11"
	if [ -n "$(cat "$lss" | sort -n | uniq -dc)" ]; then
		cat "$lss" | awk '!array_temp[$0]++' > lss_inx
		sed '/^$/d' lss_inx > "$lss"
	fi
	ls0="$DC_tlt/cnfg0"
	if [ -n "$(cat "$ls0" | sort -n | uniq -dc)" ]; then
		cat "$ls0" | awk '!array_temp[$0]++' > ls0_inx
		sed '/^$/d' ls0_inx > "$ls0"
	fi
	ls1="$DC_tlt/cnfg1"
	if [ -n "$(cat "$ls1" | sort -n | uniq -dc)" ]; then
		cat "$ls1" | awk '!array_temp[$0]++' > ls1_inx
		sed '/^$/d' ls1_inx > "$ls1"
	fi
	ls2="$DC_tlt/cnfg3"
	if [ -n "$(cat "$ls2" | sort -n | uniq -dc)" ]; then
		cat "$ls2" | awk '!array_temp[$0]++' > ls2_inx
		sed '/^$/d' ls2_inx > "$ls2"
	fi
	ls3="$DC_tlt/cnfg4"
	if [ -n "$(cat "$ls3" | sort -n | uniq -dc)" ]; then
		cat "$ls3" | awk '!array_temp[$0]++' > ls3_inx
		sed '/^$/d' ls3_inx > "$ls3"
	fi

	exit 1
#--------------------------------
elif [ "$1" = mklg- ]; then
	kill -9 $(pgrep -f "$yad --icons")
	(
	echo "# " ;
	nstll=$(grep -Fxo "$tpc" "$DC_tl/.cnfg3")
	if [ -n "$nstll" ]; then
		if [ $(cat "$DC_tlt/cnfg8") = 7 ]; then
			dts=$(cat "$DC_tlt/cnfg9" | wc -l)
			if [ $dts = 1 ]; then
				dte=$(sed -n 1p "$DC_tlt/cnfg9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/10))
			elif [ $dts = 2 ]; then
				dte=$(sed -n 2p "$DC_tlt/cnfg9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/15))
			elif [ $dts = 3 ]; then
				dte=$(sed -n 3p "$DC_tlt/cnfg9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/30))
			elif [ $dts = 4 ]; then
				dte=$(sed -n 4p "$DC_tlt/cnfg9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/60))
			fi
			if [ "$RM" -ge 50 ]; then
				echo "8" > "$DC_tlt/cnfg8"
			else
				echo "6" > "$DC_tlt/cnfg8"
			fi
		else
			echo "6" > "$DC_tlt/cnfg8"
		fi
		rm -f "$DC_tlt/cnfg7"
	else
		if [ $(cat "$DC_tlt/cnfg8") = 2 ]; then
			dts=$(cat "$DC_tlt/cnfg9" | wc -l)
			if [ $dts = 1 ]; then
				dte=$(sed -n 1p "$DC_tlt/cnfg9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/10))
			elif [ $dts = 2 ]; then
				dte=$(sed -n 2p "$DC_tlt/cnfg9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/15))
			elif [ $dts = 3 ]; then
				dte=$(sed -n 3p "$DC_tlt/cnfg9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/30))
			elif [ $dts = 4 ]; then
				dte=$(sed -n 4p "$DC_tlt/cnfg9")
				TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
				RM=$((100*$TM/60))
			fi
			if [ "$RM" -ge 50 ]; then
				echo "3" > "$DC_tlt/cnfg8"
			else
				echo "1" > "$DC_tlt/cnfg8"
			fi
		else
			echo "1" > "$DC_tlt/cnfg8"
		fi
		rm -f "$DC_tlt/cnfg7"
	fi
	cat "$DC_tlt/cnfg0" | awk '!array_temp[$0]++' > $DT/cnfg0.t
	sed '/^$/d' $DT/cnfg0.t > "$DC_tlt/cnfg0"
	rm -f $DT/*.t
	rm "$DC_tlt/cnfg2" "$DC_tlt/cnfg1" "$DC_tl/.cnfg6" "$DC_tl/ok"
	cp -f "$DC_tlt/cnfg0" "$DC_tlt/cnfg1"

	$DS/mngr.sh mkmn &

	) | $yad --progress \
	--width=50 --height= 35 \
	--pulsate --auto-close \
	--sticky --undecorated \
	--skip-taskbar --center --no-buttons

	idiomind topic & exit 1
	
#--------------------------------
elif [ "$1" = mkok- ]; then
	kill -9 $(pgrep -f "yad --icons")

	if [ -f "$DC_tlt/cnfg9" ]; then
		dts=$(cat "$DC_tlt/cnfg9" | wc -l)
		if [ $dts = 1 ]; then
			dte=$(sed -n 1p "$DC_tlt/cnfg9")
			TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
			RM=$((100*$TM/10))
		elif [ $dts = 2 ]; then
			dte=$(sed -n 2p "$DC_tlt/cnfg9")
			TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
			RM=$((100*$TM/15))
		elif [ $dts = 3 ]; then
			dte=$(sed -n 3p "$DC_tlt/cnfg9")
			TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
			RM=$((100*$TM/30))
		elif [ $dts = 4 ]; then
			dte=$(sed -n 4p "$DC_tlt/cnfg9")
			TM=$(echo $(( ( $(date +%s) - $(date -d "$dte" +%s) ) /(24 * 60 * 60 ) )))
			RM=$((100*$TM/60))
		fi
		if [ "$RM" -ge 50 ]; then # tiempo aceptado para  establecer la marca de repaso
			if [ $(cat "$DC_tlt/cnfg9" | wc -l) = 4 ]; then # falso ciclo para despues del cuarto
				echo "_
				_
				_
				$(date +%m/%d/%Y)" > "$DC_tlt/cnfg9"
			else
				echo "$(date +%m/%d/%Y)" >> "$DC_tlt/cnfg9"
			fi
		fi
	else
		echo "$(date +%m/%d/%Y)" > "$DC_tlt/cnfg9"
	fi
	> "$DC_tlt/cnfg7"
	nstll=$(grep -Fxo "$tpc" "$DC_tl/.cnfg3")
	if [ -n "$nstll" ]; then
		echo "7" > "$DC_tlt/cnfg8"
	else
		echo "2" > "$DC_tlt/cnfg8"
	fi
	rm "$DC_tlt/cnfg2" "$DC_tlt/cnfg1"
	cp -f "$DC_tlt/cnfg0" "$DC_tlt/cnfg2"
	$DS/mngr.sh mkmn &

	idiomind topic & exit 1
	
#--------------------------------
elif [ "$1" = edt ]; then
	dct="$DS/addons/Dics/dict"
	cnf=$(mktemp $DT/cnf.XXXX)
	edta=$(sed -n 17p ~/.config/idiomind/s/cnfg1)
	tpcs=$(cat "$DC_tl/.cnfg2" | egrep -v "$tpc" | cut -c 1-40 \
	| tr "\\n" '!' | sed 's/!\+$//g')
	topc=$(echo "$tpc" | cut -c 1-40)
	c=$(echo $(($RANDOM%10000)))
	re='^[0-9]+$'
	v="$2"
	nme="$3"
	ff="$4"

	if [ "$v" = v1 ]; then
		ind="$DC_tlt/cnfg1"
		inp="$DC_tlt/cnfg2"
		chk="$mark_as_learned"
	elif [ "$v" = v2 ]; then
		ind="$DC_tlt/cnfg2"
		inp="$DC_tlt/cnfg1"
		chk="$review"
	fi

	file="$DM_tlt/words/$nme.mp3"
	AUD="$DM_tlt/words/$nme.mp3"

	if [ -f "$file" ]; then
		TGT="$nme"
		tgs=$(eyeD3 "$file")
		SRC=$(echo "$tgs" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
		inf=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
		echo "$inf"
		mrk=$(echo "$tgs" | grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)')
		src=$(echo "$SRC")
		ok=$(echo "FALSE")
		exm1=$(echo "$inf" | sed -n 1p)
		dftn=$(echo "$inf" | sed -n 2p)
		ntes=$(echo "$inf" | sed -n 3p)
		dlte="$DS/mngr.sh dli '$nme'"
		imge="$DS/add.sh img '$nme' w"

		$yad --form --wrap --center --name=idiomind --class=idmnd \
		--width=600 --height=450 --always-print-result \
		--borders=15 --columns=2 --align=center \
		--buttons-layout=end --title=" $nme" --separator="\\n" \
		--fontname="Arial" --scroll --window-icon=idiomind \
		--text-align=center --selectable-labels \
		--field="<small>$lgtl</small>":RO "$TGT" \
		--field="<small>$lgsl</small>" "$src" \
		--field="<small>$topic </small>":CB "$topc!$tpcs" \
		--field="<small>$audio </small>":FL "$AUD" \
		--field="<small>$example </small>":TXT "$exm1" \
		--field="<small>$definition </small>":TXT "$dftn" \
		--field="<small>$notes </small>":TXT "$ntes" \
		--field="$mark "":CHK" "$mrk" \
		--field="$chk"":CHK" "$mrok" \
		--field=" :LBL" " " \
		--field="<a href='http://www.google.com/search?q=$TGT'>$search_google</a>\\n\\n<a href='http://glosbe.com/en/es/$TGT'>$search_def </a>":lbl \
		--button="$image":"$imge" \
		--button="$delete":"$dlte" \
		--button=gtk-close:0 > $cnf
			ret=$?
			
			srce=$(cat $cnf | tail -12 | sed -n 2p)
			tp=$(cat $cnf | tail -12 | sed -n 3p)
			tpc=$(cat "$DC_tl/.cnfg1" | grep "$tp")
			audo=$(cat $cnf | tail -12 | sed -n 4p)
			exm1=$(cat $cnf | tail -12 | sed -n 5p)
			dftn=$(cat $cnf | tail -12 | sed -n 6p)
			ntes=$(cat $cnf | tail -12 | sed -n 7p)
			mrok=$(cat $cnf | tail -12 | sed -n 9p)
			mrk2=$(cat $cnf | tail -12 | sed -n 8p)
			rm -f $cnf
			
			if [[ $ret -eq 0 ]]; then
				if [ "$mrk" != "$mrk2" ]; then
					if [ "$mrk2" = "TRUE" ]; then
						echo "$TGT" >> "$DC_tlt/cnfg6"
					else
						grep -v -x -v "$TGT" "$DC_tlt/cnfg6" > "$DC_tlt/cnfg6_"
						sed '/^$/d' "$DC_tlt/cnfg6_" > "$DC_tlt/cnfg6"
						rm "$DC_tlt/cnfg6_"
					fi
					eyeD3 -p IWI4I0I"$mrk2"IWI4I0I "$DM_tlt/words/$nme".mp3 >/dev/null 2>&1
				fi
				
				if [ "$audo" != "$file" ]; then
					eyeD3 --write-images=$DT "$file"
					cp -f "$audo" "$DM_tlt/words/$nme.mp3"
					eyeD3 --set-encoding=utf8 -t "IWI1I0I${TGT}IWI1I0I" -a "IWI2I0I${srce}IWI2I0I" -A "IWI3I0I${exm1}IWI3I0I" \
					"$DM_tlt/words/$nme.mp3" >/dev/null 2>&1
					
					eyeD3 --add-image $DT/FRONT_COVER.jpeg:FRONT_COVER \
					"$DM_tlt/words/$nme.mp3" >/dev/null 2>&1
					rm -fr $DT/idadtmptts
				fi
				
				if [ "$srce" != "$SRC" ]; then
					eyeD3 --set-encoding=utf8 -a IWI2I0I"$srce"IWI2I0I "$file" >/dev/null 2>&1
				fi
				
				infm="$(echo $exm1 && echo $dftn && echo $ntes)"
				if [ "$infm" != "$inf" ]; then
					impr=$(echo "$infm" | tr '\n' '_')
					eyeD3 --set-encoding=utf8 -A IWI3I0I"$impr"IWI3I0I "$file" >/dev/null 2>&1
					echo "eitm.$tpc.eitm" >> \
					$DC/addons/stats/.log &
				fi

				mv -f "$DT/$nme.mp3" "$file"

				if [ "$(echo $tpc | cut -c 1-40)" != "$topc" ]; then
					cp -f "$audo" "$DM_tl/$tpc/words/$nme.mp3"
					$DS/mngr.sh inx W "$nme" "$tpc" &
					if [ -n "$(cat "$DC_tl/.cnfg2" | grep "$tpc")" ]; then
						$DS/mngr.sh dli "$nme" C
					fi
				fi
				
				if [ "$mrok" = "TRUE" ]; then
					grep -v -x -v "$nme" "$ind" > $DT/tx
					sed '/^$/d' $DT/tx > "$ind"
					rm $DT/tx
					echo "$nme" >> "$inp"
					echo "okim.1.okim" >> \
					$DC/addons/stats/.log &
					./vwr.sh "$v" "nll" $ff & exit 1
				fi
				./vwr.sh "$v" "$nme" $ff & exit 1
			fi
			
	else 
		file="$DM_tlt/$nme.mp3"
		tgs=$(eyeD3 "$file")
		tgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
		src=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
		lwrd=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IPWI3I0I)')
		pwrds=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)')
		wrds="$DS/add.sh edt '$nme' F $c"
		
		edau="--button=Edit Audio:/usr/share/idiomind/audio/auds edt '$DM_tlt/$nme.mp3' '$DM_tlt'"
		dlte="$DS/mngr.sh dli '$nme'"
		imge="$DS/add.sh img '$nme' s"
		
		$yad --form --wrap --center --name=idiomind --class=idmnd \
		--width=600 --height=450 --always-print-result \
		--separator="\\n" --borders=15 --align=center --align=center \
		--buttons-layout=end --title=" $nme" --fontname="Arial" \
		--selectable-labels --window-icon=idiomind \
		--field="$chk:CHK" "$ok" \
		--field="<small>$lgtl</small>":TXT "$tgt" \
		--field="<small>$lgsl</small>":TXT "$src" \
		--field="<small>$topic </small>":CB "$topc!$tpcs" \
		--field="<small>$audio </small>":FL "$DM_tlt/$nme.mp3" \
		--field="$list_words":BTN "$wrds" \
		--button="$image":"$imge" \
		--button="$delete":"$dlte" "$edau" \
		--button=gtk-close:1 > $cnf
			
			mrok=$(cat $cnf | tail -7 | sed -n 1p)
			trgt=$(cat $cnf | tail -7 | sed -n 2p)
			srce=$(cat $cnf | tail -7 | sed -n 3p)
			tp=$(cat $cnf | tail -7 | sed -n 4p)
			tpc=$(cat "$DC_tl/.cnfg1" | grep "$tp")
			audo=$(cat $cnf | tail -7 | sed -n 5p)
			rm -f $cnf
			
			if [ -n "$audo" ]; then
			
				if [ "$audo" != "$file" ]; then
				
					cp -f "$audo" "$DM_tlt/$nme.mp3"
					eyeD3 --remove-all "$DM_tlt/$nme.mp3"
					eyeD3 --set-encoding=utf8 -t ISI1I0I"$trgt"ISI1I0I -a ISI2I0I"$srce"ISI2I0I \
					"$DM_tlt/$nme.mp3" >/dev/null 2>&1
					
					(
					DT_r=$(mktemp -d $DT/XXXXXX)
					cd $DT_r
					> swrd
					> twrd
					if [ $lgt = ja ] || [ $lgt = zh-cn ]; then
						vrbl="$srce"; lg=$lgt; aw=$DT/swrd; bw=$DT/twrd
					else
						vrbl="$trgt"; lg=$lgs; aw=$DT/twrd; bw=$DT/swrd
					fi
					
					echo "$vrbl" | sed 's/ /\n/g' | grep -v '^.$' | grep -v '^..$' \
					| sed -n 1,40p | sed s'/&//'g | sed 's/,//g' | sed 's/\?//g' \
					| sed 's/\¿//g' | sed 's/;//g' | sed 's/\!//g' | sed 's/\¡//g' \
					| tr -d ')' | tr -d '(' | sed 's/\]//g' | sed 's/\[//g' \
					| sed 's/\.//g' | sed 's/  / /g' | sed 's/ /\. /g' > $aw
					twrd=$(cat $aw | sed '/^$/d')
					result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lg" --data-urlencode text="$twrd" https://translate.google.com)
					encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
					iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 | sed 's/,//g' | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw
					sed -i 's/\. /\n/g' $bw
					sed -i 's/\. /\n/g' $aw
					snmk=$(echo "$trgt"  | sed 's/ /\n/g')
					n=1
					while [ $n -le $(echo "$snmk" | wc -l) ]; do
						grmrk=$(echo "$snmk" | sed -n "$n"p)
						chck=$(echo "$snmk" | sed -n "$n"p | awk '{print tolower($0)}' \
						| sed 's/,//g' | sed 's/\.//g')
						if echo "$lnns" | grep -Fxq $chck; then
							echo "$grmrk" >> grmrk
						elif echo "$lvbr" | grep -Fxq $chck; then
							echo "<span color='#D14D8B'>$grmrk</span>" >> grmrk
						elif echo "$lpre" | grep -Fxq $chck; then
							echo "<span color='#E08434'>$grmrk</span>" >> grmrk
						elif echo "$ladv" | grep -Fxq $chck; then
							echo "<span color='#9C68BD'>$grmrk</span>" >> grmrk
						elif echo "$lprn" | grep -Fxq $chck; then
							echo "<span color='#5473B8'>$grmrk</span>" >> grmrk
						elif echo "$ladj" | grep -Fxq $chck; then
							echo "<span color='#368F68'>$grmrk</span>" >> grmrk
						else
							echo "$grmrk" >> grmrk
						fi
						let n++
					done
					
					if [ $lgt = ja ] || [ $lgt = zh-cn ]; then
						n=1
						while [ $n -le "$(cat $aw | wc -l)" ]; do
							s=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
							t=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
							echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A
							echo "$t"_"$s""" >> B
							let n++
						done
					else
						n=1
						while [ $n -le "$(cat $aw | wc -l)" ]; do
							t=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
							s=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
							echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A
							echo "$t"_"$s""" >> B
							let n++
						done
					fi
					
					eyeD3 --set-encoding=utf8 -A IWI3I0I"$lwrds"IWI3I0IIPWI3I0I"$pwrds"IPWI3I0IIGMI3I0I"$grmrk"IGMI3I0I \
					"$DM_tlt/$nme.mp3" >/dev/null 2>&1
					rm -f grmrk
					
					n=1
					while [ $n -le $(cat $bw | wc -l) ]; do
						$dct $(sed -n "$n"p $bw | awk '{print tolower($0)}') $DT_r
						let n++
					done
					
					rm -fr $DT_r
					) &
				fi
			fi
			
			if [ -f $DT/tmpau.mp3 ]; then
				cp -f $DT/tmpau.mp3 "$DM_tlt/$nme.mp3"
				eyeD3 --set-encoding=utf8 -t ISI1I0I"$trgt"ISI1I0I -a ISI2I0I"$srce"ISI2I0I \
				"$DM_tlt/$nme.mp3" >/dev/null 2>&1
				rm -f $DT/tmpau.mp3
			fi

			if [ "$trgt" != "$tgt" ]; then
			
				if [[ "$(echo "$trgt" | wc -c)" -ge 73 ]]; then
					fl=$(echo "$trgt" | cut -c 1-70 | sed 's/[ \t]*$//' | \
					sed "s/'/ /g" | sed "s/\n/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
					n="..."
					fln="$fl$n"
				else
					fln=$(echo "$trgt" | sed 's/[ \t]*$//' | \
					sed "s/'/ /g" | sed "s/\n/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
				fi

				sed -i "s/${nme}/${fln}/" "$DC_tlt/cnfg4"
				sed -i "s/${nme}/${fln}/" "$DC_tlt/cnfg1"
				sed -i "s/${nme}/${fln}/" "$DC_tlt/cnfg0"
				sed -i "s/${nme}/${fln}/" "$DC_tlt/cnfg2"
				sed -i "s/${nme}/${fln}/" "$DC_tlt/Practice/lsin.tmp"

				mv -f "$DM_tlt/$nme".mp3 "$DM_tlt/$fln".mp3
				eyeD3 --set-encoding=utf8 -t ISI1I0I"$trgt"ISI1I0I "$DM_tlt/$fln".mp3 >/dev/null 2>&1

				(
					DT_r=$(mktemp -d $DT/XXXXXX)
					cd $DT_r
					echo "$trgt" | sed 's/ /\n/g' | grep -v '^.$' | grep -v '^..$' \
					| sed -n 1,40p | sed s'/&//'g \
					| sed 's/\.//g' | sed 's/  / /g' | sed 's/ /\. /g' > twrd
					sed -i '/^$/d' twrd
					twrd=$(cat twrd)
					result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lgs" --data-urlencode text="$twrd" https://translate.google.com)
					encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
					iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 > swrd
				
					sed -i 's/\. /\n/g' swrd
					lines=$(cat twrd | wc -l)
					lvbr=$(cat $DS/default/$lgt/verbs)
					lnns=$(cat $DS/default/$lgt/nouns)
					ladv=$(cat $DS/default/$lgt/adverbs)
					lprn=$(cat $DS/default/$lgt/pronouns)
					lpre=$(cat $DS/default/$lgt/prepositions)
					ladj=$(cat $DS/default/$lgt/adjetives)
					snmk=$(echo "$trgt" | sed 's/ /\n/g')
					
					n=1
					while [ $n -le $(echo "$snmk" | wc -l) ]; do
						grmrk=$(echo "$snmk" | sed -n "$n"p)
						chck=$(echo "$snmk" | sed -n "$n"p | awk '{print tolower($0)}' \
						| sed 's/,//g' | sed 's/\.//g')
						if echo "$lnns" | grep -Fxq $chck; then
							echo "$grmrk" >> grmrk
						elif echo "$lvbr" | grep -Fxq $chck; then
							echo "<span color='#D14D8B'>$grmrk</span>" >> grmrk
						elif echo "$lpre" | grep -Fxq $chck; then
							echo "<span color='#E08434'>$grmrk</span>" >> grmrk
						elif echo "$ladv" | grep -Fxq $chck; then
							echo "<span color='#9C68BD'>$grmrk</span>" >> grmrk
						elif echo "$lprn" | grep -Fxq $chck; then
							echo "<span color='#5473B8'>$grmrk</span>" >> grmrk
						elif echo "$ladj" | grep -Fxq $chck; then
							echo "<span color='#368F68'>$grmrk</span>" >> grmrk
						else
							echo "$grmrk" >> grmrk
						fi
						let n++
					done
					
					> A
					n=1
					while [ $n -le "$lines" ]; do
						t=$(sed -n "$n"p twrd | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
						s=$(sed -n "$n"p swrd | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
						echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A
						echo "$t"_"$s""" >> B
						let n++
					done
					
					grmrk=$(cat grmrk | sed ':a;N;$!ba;s/\n/ /g')
					lwrds=$(cat A)
					pwrds=$(cat B | tr '\n' '_')
					eyeD3 --set-encoding=utf8 -A IWI3I0I"$lwrds"IWI3I0IIPWI3I0I"$pwrds"IPWI3I0IIGMI3I0I"$grmrk"IGMI3I0I \
					"$DM_tlt/$fln.mp3" >/dev/null 2>&1
					
					n=1
					while [ $n -le $(cat twrd | wc -l) ]; do
						t=$(sed -n "$n"p twrd | awk '{print tolower($0)}')
						$dct "$t" $DT_r
						let n++
					done
				
					rm -fr $DT_r
				) &
				
				nme="$fln"
			fi
			
			if [ "$srce" != "$src" ]; then
				file="$DM_tlt/$nme.mp3"
				eyeD3 --set-encoding=utf8 -a ISI2I0I"$srce"ISI2I0I "$file" >/dev/null 2>&1
			fi
			
			if [ "$(echo $tpc | cut -c 1-40)" != "$topc" ]; then
				cp -f "$audo" "$DM_tl/$tpc/$nme.mp3"
				tgt=$(eyeD3 "$DM_tl/$tpc/$nme.mp3" \
				| grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' \
				| sed 's/ /\n/g' | grep -v '^.$' | grep -v '^..$' \
				| sed -n 1,40p | sed s'/&//'g | sed 's/,//g' | sed 's/\?//g' \
				| sed 's/\¿//g' | sed 's/;//g' | sed 's/\!//g' | sed 's/\¡//g' \
				| tr -d ')' | tr -d '(' | sed 's/\]//g' | sed 's/\[//g' \
				| sed 's/\.//g' | sed 's/  / /g' | sed 's/ /\. /g')
				n=1
				while [ $n -le "$(echo "$tgt" | wc -l)" ]; do
					echo "$(echo "$tgt" | sed -n "$n"p).mp3" >> "$DC_tl/$tpc/cnfg5"
					let n++
				done
				$DS/mngr.sh inx S "$nme" "$tpc" &
				if [ -n "$(cat "$DC_tl/.cnfg2" | grep "$tpc")" ]; then
					$DS/mngr.sh dli "$nme" C
				fi
			fi
			
			if [ "$mrok" = "TRUE" ]; then
				grep -v -x -v "$nme" "$ind" > $DT/tx
				sed '/^$/d' $DT/tx > "$ind"
				rm $DT/tx
				echo "$nme" >> "$inp"
				echo "okim.1.okim" >> \
				$DC/addons/stats/.log &
				./vwr.sh "$v" "nll" $ff & exit 1
			fi
			
			[ -d "$DT/$c" ] && $DS/add.sh edt "$nme" S $c "$trgt" &
			./vwr.sh "$v" "$nme" $ff & exit 1
	fi
	
#--------------------------------
elif [ $1 = dli ]; then
	itdl=$(echo "$2")
	if [ "$3" = "C" ]; then
		# delete word
		file="$DM_tlt/words/$itdl.mp3"
		if [ -f "$file" ]; then
			rm "$file"
			cd "$DC_tlt/Practice"
			sed -i 's/'"$itdl"'//g' ./lsin.tmp
			cd ..
			grep -v -x -v "$itdl" ./cnfg11 > ./cnfg11_
			sed '/^$/d' ./cnfg11_ > ./cnfg11
			rm ./cnfg11_
			grep -v -x -v "$itdl" ./cnfg0 > ./cnfg0_
			sed '/^$/d' ./cnfg0_ > ./cnfg0
			rm ./cnfg0_
			grep -v -x -v "$itdl" ./cnfg2 > ./cnfg2_
			sed '/^$/d' ./cnfg2_ > ./cnfg2
			rm ./cnfg2_
			grep -v -x -v "$itdl" ./cnfg1 > ./cnfg1_
			sed '/^$/d' ./cnfg1_ > ./cnfg1
			rm ./cnfg1_
			grep -v -x -v "$itdl" cnfg3 > cnfg3_
			sed '/^$/d' cnfg3_ > cnfg3
			rm ./cnfg3_
		fi
		# delete sentence
		file="$DM_tlt/$itdl.mp3"
		if [ -f "$file" ]; then
			rm "$file"
			cd "$DC_tlt/Practice"
			sed -i 's/'"$itdl"'//g' ./lsin.tmp
			cd ..
			grep -v -x -v "$itdl" ./cnfg11 > ./cnfg11_
			sed '/^$/d' ./cnfg11_ > ./cnfg11
			rm ./cnfg11_
			grep -v -x -v "$itdl" ./cnfg0 > ./cnfg0_
			sed '/^$/d' ./cnfg0_ > ./cnfg0
			rm ./cnfg0_
			grep -v -x -v "$itdl" ./cnfg2 > ./cnfg2_
			sed '/^$/d' ./cnfg2_ > ./cnfg2
			rm ./cnfg2_
			grep -v -x -v "$itdl" ./cnfg1 > ./cnfg1_
			sed '/^$/d' ./cnfg1_ > ./cnfg1
			rm ./cnfg1_
			grep -v -x -v "$itdl" cnfg4 > cnfg4_
			sed '/^$/d' cnfg4_ > cnfg4
			rm ./cnfg4_
		fi
		exit 1
	fi
	
	# delete word
	if [ -f "$DM_tlt/words/$itdl.mp3" ]; then
		flw="$DM_tlt/words/$itdl.mp3"
	elif [ -f "$DM_tlt/$itdl.mp3" ]; then
		fls="$DM_tlt/$itdl.mp3"
	fi

	if [ -f "$flw" ]; then

		$yad --fixed --scroll --center \
		--title="$confirm" --width=400 --height=140 \
		--on-top --image=dialog-question \
		--skip-taskbar --window-icon=idiomind \
		--text="  <b>$delete_word</b> " \
		--window-icon=idiomind \
		--button=gtk-delete:0 --button="$cancel":1
			ret=$?
			
			if [ $ret -eq 0 ]; then
			
				(sleep 1 && kill -9 $(pgrep -f "$yad --form "))
				killall edt1 edt2
				rm -f "$flw"
				cd "$DC_tlt/Practice"
				sed -i 's/'"$itdl"'//g' ./fin.tmp
				sed -i 's/'"$itdl"'//g' ./lwin.tmp
				sed -i 's/'"$itdl"'//g' ./mcin.tmp
				cd ..
				grep -v -x -v "$itdl" ./cnfg11 > ./cnfg11_
				sed '/^$/d' ./cnfg11_ > ./cnfg11
				rm ./cnfg11_
				grep -v -x -v "$itdl" ./cnfg0 > ./cnfg0_
				sed '/^$/d' ./cnfg0_ > ./cnfg0
				rm ./cnfg0_
				grep -v -x -v "$itdl" ./cnfg2 > ./cnfg2_
				sed '/^$/d' ./cnfg2_ > ./cnfg2
				rm ./cnfg2_
				grep -v -x -v "$itdl" ./cnfg1 > ./cnfg1_
				sed '/^$/d' ./cnfg1_ > ./cnfg1
				rm ./cnfg1_
				grep -v -x -v "$itdl" cnfg3 > cnfg3_
				sed '/^$/d' cnfg3_ > cnfg3
				rm ./cnfg3_
			else
				exit 1
			fi
			
	elif [ -f "$fls" ]; then
		$yad --fixed --center --scroll \
		--title="$confirm" --width=400 --height=140 \
		--on-top --image=dialog-question --skip-taskbar \
		--text="  <b>$delete_sentence</b> " \
		--window-icon=idiomind \
		--button=gtk-delete:0 --button="$cancel":1
			ret=$?
			
			if [ $ret -eq 0 ]; then
				(sleep 1 && kill -9 $(pgrep -f "$yad --form "))
				rm -f "$fls"
				cd "$DC_tlt/Practice"
				sed -i 's/'"$itdl"'//g' ./lsin.tmp
				cd ..
				grep -v -x -v "$itdl" ./cnfg11 > ./cnfg11_
				sed '/^$/d' ./cnfg11_ > ./cnfg11
				rm ./cnfg11_
				grep -v -x -v "$itdl" ./cnfg0 > ./cnfg0_
				sed '/^$/d' ./cnfg0_ > ./cnfg0
				rm ./cnfg0_
				grep -v -x -v "$itdl" ./cnfg2 > ./cnfg2_
				sed '/^$/d' ./cnfg2_ > ./cnfg2
				rm ./cnfg2_
				grep -v -x -v "$itdl" ./cnfg1 > ./cnfg1_
				sed '/^$/d' ./cnfg1_ > ./cnfg1
				rm ./cnfg1_
				grep -v -x -v "$itdl" cnfg4 > cnfg4_
				sed '/^$/d' cnfg4_ > cnfg4
				rm ./cnfg4_
			else
				exit 1
			fi
			
	elif [ ! -f "$flw" ] || [ ! -f "$flw" ]; then
		$yad --fixed --center --scroll \
		--title="$confirm" --width=400 --height=140 \
		--on-top --image=dialog-question --skip-taskbar \
		--text="  <b>$delete_item</b> " \
		--window-icon=idiomind \
		--button=gtk-delete:0 --button="$cancel":1
			ret=$?
	
			cd "$DC_tlt/Practice"
			sed -i 's/'"$itdl"'//g' ./fin.tmp
			sed -i 's/'"$itdl"'//g' ./lwin.tmp
			sed -i 's/'"$itdl"'//g' ./mcin.tmp
			sed -i 's/'"$itdl"'//g' ./lsin.tmp
			cd ..
			grep -v -x -v "$itdl" ./cnfg11 > ./cnfg11_
			sed '/^$/d' ./cnfg11_ > ./cnfg11
			rm ./cnfg11_
			grep -v -x -v "$itdl" ./cnfg0 > ./cnfg0_
			sed '/^$/d' ./cnfg0_ > ./cnfg0
			rm ./cnfg0_
			grep -v -x -v "$itdl" ./cnfg2 > ./cnfg2_
			sed '/^$/d' ./cnfg2_ > ./cnfg2
			rm ./cnfg2_
			grep -v -x -v "$itdl" ./cnfg1 > ./cnfg1_
			sed '/^$/d' ./cnfg1_ > ./cnfg1
			rm ./cnfg1_
			grep -v -x -v "$itdl" cnfg4 > cnfg4_
			sed '/^$/d' cnfg4_ > cnfg4
			rm ./cnfg4_
			grep -v -x -v "$itdl" cnfg3 > cnfg3_
			sed '/^$/d' cnfg3_ > cnfg3
			rm ./cnfg3_
	fi
	
#--------------------------------
elif [ $1 = dlt ]; then
	$yad --name=idiomind --center \
	--image=dialog-question --sticky --on-top \
	--text="  <b>$delete_topic</b> \n\n\t$tpc \n" --buttons-layout=end \
	--width=400 --height=140 --borders=5 \
	--skip-taskbar --window-icon=idiomind \
	--title="$confirm" --button=gtk-delete:0 --button="$cancel":1

		ret=$?

		if [ $ret -eq 0 ]; then
			rm -r "$DM_tl/$tpc"
			rm -r "$DC_tl/$tpc"
			$ > $DC_s/topic_m
			$ > $DC_s/cnfg6
			rm $DC_s/cnfg8
			$ > $DC_tl/.cnfg8
			grep -v -x -v "$tpc" $DC_tl/.cnfg2 > $DC_tl/.cnfg2_
			sed '/^$/d' $DC_tl/.cnfg2_ > $DC_tl/.cnfg2
			grep -v -x -v "$tpc" $DC_tl/.cnfg1 > $DC_tl/.cnfg1_
			sed '/^$/d' $DC_tl/.cnfg1_ > $DC_tl/.cnfg1
			grep -v -x -v "$tpc" $DC_tl/.cnfg3 > $DC_tl/.cnfg3_
			sed '/^$/d' $DC_tl/.cnfg3_ > $DC_tl/.cnfg3
			grep -v -x -v "$tpc" $DC_tl/.cnfg7 > $DC_tl/.cnfg7_
			sed '/^$/d' $DC_tl/.cnfg7_ > $DC_tl/.cnfg7
			grep -v -x -v "$tpc" $DC_tl/.cnfg6 > $DC_tl/.cnfg6_
			sed '/^$/d' $DC_tl/.cnfg6_ > $DC_tl/.cnfg6
			grep -v -x -v "$tpc" $DC_tl/.cnfg5 > $DC_tl/.cnfg5_
			sed '/^$/d' $DC_tl/.cnfg5_ > $DC_tl/.cnfg5
			rm $DC_tl/.cnfg1_ $DC_tl/.cnfg2_ $DC_tl/.cnfg3_ DC_tl/.cnfg5_ DC_tl/.cnfg6_ DC_tl/.cnfg7_
			
			kill -9 $(pgrep -f "$yad --list ")
			D="$(sed -n 4p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g' | sed -n 2p)"
			notify-send  -i idiomind "$tpc" "$D"  -t 1000
			
			$DS/mngr.sh mkmn
			
		elif [ $ret -eq 1 ]; then
			exit
		else
			exit
		fi
		
elif [ $1 = mkmn ]; then
	[[ ! -f $DC_tl/.cnfg1 ]] && exit 1
	cd "$DC_tl"
	[[ -d ./images ]] && rm -r ./images
	[[ -d ./words ]] && rm -r ./words
	[[ -f ./*.mp3 ]] && rm -r ./*.mp3
	[[ -f ./cnfg0 ]] && rm ./cnfg0
	[[ -f ./cnfg1 ]] && rm ./cnfg1
	[[ -f ./cnfg2 ]] && rm ./cnfg2
	[[ -f ./cnfg3 ]] && rm ./cnfg3
	[[ -f ./cnfg11 ]] && rm ./cnfg11
	ls -t -d -N * > $DC_tl/.cnfg1
	[[ -f $DC_s/cnfg0 ]] && mv -f $DC_s/cnfg0 $DC_s/cnfg16
	n=1
	while [ $n -le $(cat $DC_tl/.cnfg1 | head -30 | wc -l) ]; do
		tp=$(sed -n "$n"p $DC_tl/.cnfg1)
		i=$(cat "$DC_tl/$tp/cnfg8")
		if [ ! -f "$DC_tl/$tp/cnfg8" ] || \
		[ ! -f "$DC_tl/$tp/tpc.sh" ] || \
		[ ! -f "$DC_tl/$tp/cnfg0" ] || \
		[ ! -f "$DC_tl/$tp/cnfg3" ] || \
		[ ! -f "$DC_tl/$tp/cnfg4" ] || \
		[ ! -d "$DM_tl/$tp" ]; then
			i=13
		fi
		echo "/usr/share/idiomind/images/img$i.png" >> $DC_s/cnfg0
		echo "$tp" >> $DC_s/cnfg0
		let n++
	done
	n=1
	while [ $n -le $(cat $DC_tl/.cnfg1 | tail -n+31 | wc -l) ]; do
		ff=$(cat $DC_tl/.cnfg1 | tail -n+31)
		tp=$(echo "$ff" | sed -n "$n"p)
		if [ ! -f "$DC_tl/$tp/cnfg8" ] || \
		[ ! -f "$DC_tl/$tp/tpc.sh" ] || \
		[ ! -f "$DC_tl/$tp/cnfg0" ] || \
		[ ! -f "$DC_tl/$tp/cnfg3" ] || \
		[ ! -f "$DC_tl/$tp/cnfg4" ] || \
		[ ! -d "$DM_tl/$tp" ]; then
			echo '/usr/share/idiomind/images/img13.png' >> $DC_s/cnfg0
		else
			echo '/usr/share/idiomind/images/img12.png' >> $DC_s/cnfg0
		fi
		echo "$tp" >> $DC_s/cnfg0
		let n++
	done
fi
