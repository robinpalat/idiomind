#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/add.conf
if [ $1 = n_t ]; then
	info2=$(cat $DC_tl/.cnfg1 | wc -l)
	int="$(sed -n 22p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	btn="$(sed -n 21p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	c=$(echo $(($RANDOM%100)))

	if [ "$3" = 2 ]; then
		nmt="$tpc"
		tle="$tpc"
		if [ -n "$nmt" ];then
			nmt="$nmt"
		else
			tle=$(echo "$new_topic")
			nmt=""
		fi
		#--------------normal
		jlbi=$($yad --window-icon=idiomind \
		--form --center --field="$name_for_new_topic" "$nmt" --title="$tle" \
		--width=440 --height=100 --name=idiomind --on-top \
		--skip-taskbar --borders=5 --button=gtk-ok:0)
		
		jlb=$(echo "$jlbi" | cut -d "|" -f1 | sed s'/!//'g \
		| sed s'/&//'g | sed s'/\://'g | sed s'/\&//'g \
		| sed s"/'//"g | sed 's/^[ \t]*//;s/[ \t]*$//' \
		| sed 's/^\s*./\U&\E/g')
		
		snm=$(cat $DC_tl/.cnfg1 | grep -Fxo "$jlb" | wc -l)
		if [ $snm -ge 1 ]; then
			jlb=$(echo ""$jlb" $snm")
			$yad --name=idiomind --center --on-top \
			--image=info --sticky \
			--text=" <b>$name_eq   </b>\\n $name_eq2  <b>$jlb</b>   \\n" \
			--image-on-top --width=400 --height=120 --borders=3 \
			--skip-taskbar --window-icon=idiomind \
			--title=Idiomind --button="$cancel":1 --button=gtk-ok:0
				ret=$?
				
				if [ "$ret" -eq 1 ]; then
					exit 1
				fi
		else
			jlb=$(echo "$jlb")
		fi
		#--------------
		if [ -z "$jlb" ]; then
			exit 1
		else		
			mkdir $DM_tl/"$jlb"
			mkdir $DM_tl/"$jlb"/words
			mkdir $DM_tl/"$jlb"/words/images
			mkdir $DC_tl/"$jlb"
			> $DC_tl/"$jlb"/cnfg3
			> $DC_tl/"$jlb"/cnfg4
			mkdir $DC_tl/"$jlb"/Practice
			cp $DS/addons/Practice/default/.* $DC_tl/"$jlb"/Practice
			cd $DC_tl/"$jlb"
			echo "$jlb" >> $DC_tl/.cnfg2
			cd "$DM_tl/$tpc"
			cp -f *.mp3 "$DM_tl/$jlb"
			cp -f -r ./words "$DM_tl/$jlb/"
			cd "$DC_tl/$tpc"
			cp -f cnfg5 "$DC_tl/$jlb"/cnfg5
			cp -f cnfg4 "$DC_tl/$jlb"/cnfg4
			cp -f tpc.sh "$DC_tl/$jlb"/tpc.sh
			cp -f cnfg3 "$DC_tl/$jlb"/cnfg3
			cp -f cnfg8 "$DC_tl/$jlb"/cnfg8
			cp -f cnfg0 "$DC_tl/$jlb"/cnfg0
			cp -f cnfg1 "$DC_tl/$jlb"/cnfg1
			cp -f cnfg2 "$DC_tl/$jlb"/cnfg2
			cp -f nt "$DC_tl/$jlb"/nt
			cp -f ./Practice/.* $DC_tl/"$jlb"/Practice
			grep -v -x -v "$tpc" $DC_tl/.cnfg2 > $DC_tl/.cnfg2_
			sed '/^$/d' $DC_tl/.cnfg2_ > $DC_tl/.cnfg2
			grep -v -x -v "$tpc" $DC_tl/.cnfg1 > $DC_tl/.cnfg1_
			sed '/^$/d' $DC_tl/.cnfg1_ > $DC_tl/.cnfg1
			grep -v -x -v "$tpc" $DC_tl/.cnfg3 > $DC_tl/.cnfg3_
			sed '/^$/d' $DC_tl/.cnfg3_ > $DC_tl/.cnfg3
			rm $DC_tl/in_s $DC_tl/in $DC_tl/nstll
			rm -r "$DM_tl/$tpc" "$DC_tl/$tpc"
			if [ -f $DT/ntpc ]; then
				rm -f $DT/ntpc
			fi
			$DS/mngr.sh mkmn
			"$DC_tl/$jlb"/tpc.sh & exit 1
		fi
		[ "$?" -eq 1 ] && exit

	else
		nmt="$2"
		if [ -z "$2" ]; then
			nmt=""
		fi
		
		if [ $info2 -ge 50 ]; then
			yad --name=idiomind --center --image=info \
			--text=" <b>$topics_max </b>" \
			--image-on-top --sticky --on-top \
			--width=430 --height=120 --borders=3 \
			--skip-taskbar --window-icon=idiomind --title=Idiomind \
			--button=Ok:0 && rm "$DM_tl/.rn" & exit 1
		fi
		
		jlbi=$($yad --window-icon=idiomind \
		--form --center --title="$new_topic"  --separator="\n" \
		--width=440 --height=100 --name=idiomind --on-top \
		--skip-taskbar --borders=5 --button=gtk-ok:0 \
		--field=" $name_for_new_topic: " "$nmt")
			
		jlb=$(echo "$jlbi" | sed -n 1p | cut -d "|" -f1 | sed s'/!//'g \
		| sed s'/&//'g | sed s'/://'g | sed s'/\&//'g \
		| sed s"/'//"g | sed 's/^[ \t]*//;s/[ \t]*$//' \
		| sed 's/^\s*./\U&\E/g')
		ABC=$(echo "$jlbi" | sed -n 2p)
		
		snme=$(cat $DC_tl/.cnfg1 | grep -Fxo "$jlb" | wc -l)
		if [ "$snme" -ge 1 ]; then
			jlb="$jlb $snme"
			$yad --name=idiomind --center --on-top \
			--image=info --sticky \
			--text=" <b>$name_eq   </b>\\n $name_eq2  <b>$jlb</b>   \\n" \
			--image-on-top --width=400 --height=120 --borders=3 \
			--skip-taskbar --window-icon=idiomind \
			--title=Idiomind --button="$cancel":1 --button=gtk-ok:0
			ret=$?
			
			if [ "$ret" -eq 1 ]; then
				rm "$DM_tl"/.rn & exit 1
			fi
		else
			jlb="$jlb"
		fi
		
		if [ -z "$jlb" ]; then
			rm "$DM_tl"/.rn & exit 1
			
		else
			mkdir $DM_tl/"$jlb"
			mkdir $DM_tl/"$jlb"/words
			mkdir $DM_tl/"$jlb"/words/images
			mkdir $DC_tl/"$jlb"
			> $DC_tl/"$jlb"/cnfg5
			> $DC_tl/"$jlb"/cnfg4
			> $DC_tl/"$jlb"/cnfg3
			> $DC_tl/"$jlb"/cnfg0
			> $DC_tl/"$jlb"/cnfg1
			echo "1" > $DC_tl/"$jlb"/cnfg8
			mkdir $DC_tl/"$jlb"/Practice
			cp $DS/addons/Practice/default/.* $DC_tl/"$jlb"/Practice
			cp -f $DS/default/tpc.sh $DC_tl/"$jlb"/tpc.sh
			cd $DC_tl/"$jlb"
			echo "$jlb" >> $DC_tl/.cnfg2
			chmod +x $DC_tl/"$jlb"/tpc.sh
			if [ -f $DT/ntpc ]; then
				rm -f $DT/ntpc
			fi
			$DC_tl/"$jlb"/tpc.sh
			$DS/mngr.sh mkmn
		fi
		
		[ "$?" -eq 1 ] && exit
	fi
	exit 1
	
elif [ $1 = n_i ]; then
	[[ ! -f $DC/addons/dict/.dicts ]] && touch $DC/addons/dict/.dicts
	if  [ -z "$(cat $DC/addons/dict/.dicts)" ]; then
		source $DS/ifs/trans/$lgs/topics_lists.conf
		$DS/addons/Dics/dict "$no_dictionary" f cnf
		if  [ -z "$(cat $DC/addons/dict/.dicts)" ]; then
			exit 1
		fi
	fi
	c=$(echo $(($RANDOM%1000)))
	txt="$4"
	if [ -z "$txt" ]; then
		txt="$(xclip -selection primary -o)"
	fi

	if [ "$3" = 2 ]; then
		DT_r="$2"
		cd $DT_r
		if ! [ sed -n 1p $DC_s/cnfg3 | grep TRUE ]; then
			srce="$5"
		fi
	else
		DT_r=$(mktemp -d $DT/XXXXXX)
		cd $DT_r
	fi
	
	if [ -f $DT_r/ico.jpg ]; then
		img="--image=$DT_r/ico.jpg"
	else
		img="--on-top"
	fi
	
	if [ -f $DT/ntpc ]; then
		rm -fr $DT_r
		source $DS/ifs/trans/$lgs/topics_lists.conf
		$DS/chng.sh "$no_topic" fnew & exit 1
	fi
	
	if [ -z "$tpc" ]; then
		rm -fr $DT_r
		source $DS/ifs/trans/$lgs/topics_lists.conf
		$DS/chng.sh "$no_topic" fnew & exit 1
	fi

	if [ -z "$tpe" ]; then
		rm -fr $DT_r
		source $DS/ifs/trans/$lgs/topics_lists.conf
		$DS/chng.sh "$no_edit" fnew & exit 1
	fi
	
	ls=$((50 - $(cat "$DC_tlt/cnfg4" | wc -l)))
	lw=$((50 - $(cat "$DC_tlt/cnfg3" | wc -l)))
	dct="$DS_p/Dics/dict"
	tpcs=$(cat "$DC_tl/.cnfg2" | egrep -v "$tpe" | cut -c 1-50 \
	| tr "\\n" '!' | sed 's/!\+$//g')
	ttle="${tpe:0:50}"
	s=$(cat "$DC_tlt/cnfg4" | wc -l)
	w=$(cat "$DC_tlt/cnfg3" | wc -l)
	if [ $s -ge 45 -a $s -lt 50 ]; then
		is="S <b>$ls</b>"
	elif [ $s -ge 50 ]; then
		is="S <b>0</b>"
	fi
	if [ $w -ge 45 -a $w -lt 50 ]; then
		iw="W <b>$lw</b>"
	elif [ $w -ge 50 ]; then
		iw="W <b>0</b>"
	fi
	if [ -n "$is" ] || [ -n "$iw" ]; then
		info="\\n$is $iw"
	fi
	if [ "$tpe" != "$tpc" ]; then
		topic="<span color='#CE6F1C'>$topic</span>$info"
	else
		topic="$topic $info"
	fi
	
	if sed -n 1p $DC_s/cnfg3 | grep TRUE; then
	sx='120x100'
		lzgpr=$($yad --form --center --always-print-result \
		--text-info --on-top --window-icon=idiomind --skip-taskbar \
		--separator="\n" --align=right "$img" \
		--name=idiomind --class=idiomind \
		--borders=0 --title="$tpe" --width=360 --height=160 \
		--field="  <small><small>$lgtl / $lgsl</small></small>":TXT "$txt" \
		--field="<small><small>$topic</small></small>:CB" "$ttle!$new*!$tpcs" "$field" \
		--button="$image":3 \
		--button=gtk-ok:0)
		ret=$?
		trgt=$(echo "$lzgpr"| head -n -1)
		chk=$(echo "$lzgpr" | tail -1)
		tpe=$(cat "$DC_tl/.cnfg2" | grep "$chk")
		echo "$chk"
	else
		cd $HOME
		txt2="$5"
		sx='180x160'
		auds="--button=Audio:$DS/audio/auds pnl '$DT_r' 10"
		rec="--button=gtk-media-record:$DS/audio/auds rec '$DT_r' '10'"
		ls="--button=Play:play $DT_r/audtm.mp3"
		lzgpr=$($yad --separator="\\n" --skip-taskbar \
		--width=400 --height=220 --form --on-top --name=idiomind \
		--class=idiomind --window-icon=idiomind "$img" --center "$ls" "$rec" \
		--button="$image":3 --always-print-result --align=right \
		--button=gtk-ok:0 --borders=2 --title="$tpe" \
		--field="  <small><small>$lgtl</small></small>":TXT "$txt" \
		--field=":lbl" "" \
		--field="  <small><small>$lgsl</small></small>":TXT "$srce" \
		--field=":lbl" "" \
		--field="<small><small>$topic</small></small>:CB" \
		"$ttle!$new*!$tpcs" "$field")
		ret=$?
		trgt=$(echo "$lzgpr" | tail -5 | sed -n 1p | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
		srce=$(echo "$lzgpr" | tail -5 | sed -n 3p | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
		tpe=$(cat "$DC_tl/.cnfg2" | grep "$(echo "$lzgpr" | tail -5 | sed -n 5p)")
		chk=$(echo "$lzgpr" | tail -1)
		echo "$chk"
	fi
		
		if [ $ret -eq 3 ]; then
			if sed -n 1p $DC_s/cnfg3 | grep TRUE; then
				trgt=$(echo "$lzgpr" | head -n -1)
			fi
			cd $DT_r
			scrot -s --quality 70 img.jpg
			/usr/bin/convert -scale $sx! -border 0.5 \
			-bordercolor '#9A9A9A' img.jpg ico.jpg
			$DS/add.sh n_i $DT_r 2 "$trgt" "$srce" && exit 1
		
		elif [ $ret -eq 0 ]; then
		
			if [ -z "$trgt" ]; then
				rm -fr $DT_r & exit 1
			fi
			# si coincide con otro nombre de topic
			if [ $(echo "$tpe" | wc -l) -ge 2 ]; then
				
				if [[ $(echo "$tpe" | sed -n 1p | wc -w) \
				= $(echo "$chk" | wc -w) ]]; then
					slt=$(echo "$tpe" | sed -n 1p)
					tpe="$slt"
				elif [[ $(echo "$tpe" | sed -n 2p | wc -w) \
				= $(echo "$chk" | wc -w) ]]; then
					slt=$(echo "$tpe" | sed -n 2p)
					tpe="$slt"
				else
					slt=`echo "$tpe" | awk '{print "FALSE\n"$0}' | \
					$yad --name=idiomind --class=idiomind --center \
					--list --radiolist --on-top --fixed --no-headers \
					--text="<b>  $te </b> <small><small> --window-icon=idiomind \
					$info</small></small>" --sticky --skip-taskbar \
					--height="300" --width="350" --separator="\\n" \
					--button=Save:0 --title="selector" --borders=3 \
					--column=" " --column="Sentences"`
					if [ -z "$(echo "$slt" | sed -n 2p)" ]; then
						killall add.sh & exit 1
					fi
					tpe=$(echo "$slt" | sed -n 2p)
				fi
			fi
			if [ "$chk" = "New*" ]; then
				$DS/add.sh n_t
			else
				echo "$tpe" > $DC_s/cnfg7
				echo "$tpe" > $DC_s/cnfg6
			fi
			[ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ] && c=c || c=w
			
			if [ "$(echo "$trgt" | sed -n 1p | awk '{print tolower($0)}')" = i ]; then
				$DS/add.sh prs image $DT_r & exit 1
			elif [ "$(echo "$trgt" | sed -n 1p | awk '{print tolower($0)}')" = a ]; then
				$DS/add.sh prs "$trgt" $DT_r & exit 1
			elif [ "$(echo "$trgt" | sed -n 1p | grep -o http)" = http ]; then
				$DS/add.sh prs "$trgt" $DT_r & exit 1
			elif [ $(echo "$trgt" | wc -$c) = 1 ]; then
				$DS/add.sh n_w "$trgt" $DT_r "$srce" & exit 1
			elif [ $(echo "$trgt" | wc -$c) -ge 1 -a $(echo "$trgt" | wc -c) -le 180 ]; then
				$DS/add.sh n_s "$trgt" $DT_r "$srce" & exit 1
			elif [ $(echo "$trgt" | wc -c) -gt 180 ]; then
				$DS/add.sh prs "$trgt" $DT_r & exit 1
			fi
		else
			rm -fr $DT_r & exit 1
		fi
		
elif [ $1 = n_s ]; then

	DT_r="$3"
	lvbr=$(cat $DS/default/$lgt/verbs)
	lnns=$(cat $DS/default/$lgt/nouns)
	ladv=$(cat $DS/default/$lgt/adverbs)
	lprn=$(cat $DS/default/$lgt/pronouns)
	lpre=$(cat $DS/default/$lgt/prepositions)
	ladj=$(cat $DS/default/$lgt/adjetives)
	btn="$(sed -n 21p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	int="$(sed -n 22p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	icnn=idiomind
	
	dct=$DS/addons/Dics/dict
			
	if [ $(cat "$DC_tlt/cnfg4" | wc -l) -ge 50 ]; then
		$yad --name=idiomind --center --on-top --image=info \
		--text=" <b>$tpe    </b>\\n\\n $sentences_max" \
		--image-on-top --fixed --sticky --title="$tpe" \
		--width=350 --height=140 --borders=3 --button=gtk-ok:0 \
		--skip-taskbar --window-icon=idiomind && exit 1
	fi
	
	if sed -n 1p $DC_s/cnfg3 | grep TRUE; then
	
		curl -v www.google.com 2>&1 | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
		$yad --window-icon=idiomind --on-top \
		--image=info --name=idiomind \
		--text="<b> $connection_err  \\n  </b>" \
		--image-on-top --center --sticky \
		--width=300 --height=50 --borders=3 \
		--skip-taskbar --title=Idiomind \
		--button="  Ok  ":0 >&2; exit 1;}
	
		cd $DT_r
		echo "$2" > ./txt2
		cat ./txt2 | sed ':a;N;$!ba;s/\n/ /g' | sed 's/"//g' | sed 's/“//g' | sed s'/&//'g \
		| sed 's/”//g' | sed s'/://'g | sed "s/’/'/g" | sed 's/^[ \t]*//;s/[ \t]*$//' > txt
		txt=$(cat ./txt)
		result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lgt" --data-urlencode text="$txt" https://translate.google.com)
		encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
		iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 > ./.en
		sed -i ':a;N;$!ba;s/\n/ /g' ./.en
		
		trgt=$(cat ./.en | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
		
		sed -i 's/  / /g' ./.en
		sed -i 's/  / /g' ./.en
		
		if [ $(cat ./.en | wc -c) -ge 73 ]; then
			nme="$(cat ./.en | cut -c 1-70 | sed 's/[ \t]*$//' | \
			sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')..."
		else
			nme=$(cat ./.en | sed 's/[ \t]*$//' | \
			sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
		fi
		result=$(curl -s -i --user-agent "" -d "sl=$lgt" -d "tl=$lgs" --data-urlencode text="$trgt" https://translate.google.com)
		encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
		iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 > ./.es
		sed -i ':a;N;$!ba;s/\n/ /g' ./.es
		srce=$(cat ./.es)
		
		sed -i 's/,/ /g' .en
		sed -i "s/'/ /g" .en
		sed -i 's/’/ /g' .en
		xargs -n10 < .en > ./temp
		srce1=$(sed -n 1p ./temp)
		srce2=$(sed -n 2p ./temp)
		srce3=$(sed -n 3p ./temp)
		srce4=$(sed -n 4p ./temp)
		srce5=$(sed -n 5p ./temp)
		
		wget -q -U Mozilla -O $DT_r/tmp01.mp3 "https://translate.google.com/translate_tts?ie=UTF-8&tl=$lgt&q=$srce1"
		if [ -n "$srce2" ]; then
			wget -q -U Mozilla -O $DT_r/tmp02.mp3 "https://translate.google.com/translate_tts?ie=UTF-8&tl=$lgt&q=$srce2"
		fi
		if [ -n "$srce3" ]; then
			wget -q -U Mozilla -O $DT_r/tmp03.mp3 "https://translate.google.com/translate_tts?ie=UTF-8&tl=$lgt&q=$srce3"
		fi
		if [ -n "$srce4" ]; then
			wget -q -U Mozilla -O $DT_r/tmp04.mp3 "https://translate.google.com/translate_tts?ie=UTF-8&tl=$lgt&q=$srce4"
		fi
		
		cat tmp01.mp3 tmp02.mp3 tmp03.mp3 tmp04.mp3 > "$DM_tlt/$nme.mp3"
		eyeD3 --set-encoding=utf8 -t ISI1I0I"$trgt"ISI1I0I -a ISI2I0I"$srce"ISI2I0I "$DM_tlt/$nme.mp3"

		if [ -f img.jpg ]; then
			/usr/bin/convert -scale 450x270! -border 0.5 \
			-bordercolor '#9A9A9A' img.jpg imgs.jpg
			eyeD3 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/$nme".mp3
			icnn=img.jpg
		fi
		
		notify-send -i "$icnn" "$trgt" "$srce \\n($tpe)" -t 10000
		$DS/mngr.sh inx S "$nme" "$tpe"
		
		cd $DT_r
		> swrd
		> twrd
		if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ]; then
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
		
		if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ]; then
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

		grmrk=$(cat grmrk | sed ':a;N;$!ba;s/\n/ /g')
		lwrds=$(cat A)
		pwrds=$(cat B | tr '\n' '_')
		eyeD3 --set-encoding=utf8 -A IWI3I0I"$lwrds"IWI3I0IIPWI3I0I"$pwrds"IPWI3I0IIGMI3I0I"$grmrk"IGMI3I0I "$DM_tlt/$nme.mp3"
		
		(
		if [ $(sed -n 4p $DC_s/cnfg1) = TRUE ]; then
		$DS/add.sh snt "$nme" "$tpe"
		fi
		) &
		
		if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ]; then
			n=1
			while [ $n -le $(cat $bw | wc -l) ]; do
				$dct $(sed -n "$n"p $bw) $DT_r
				let n++
			done
		else
			n=1
			while [ $n -le $(cat $aw | wc -l) ]; do
				$dct $(sed -n "$n"p $aw) $DT_r
				let n++
			done
		fi
		rm -fr $DT_r $DT/twrd $DT/swrd &
		echo "aitm.1.aitm" >> \
		$DC/addons/stats/.log
		exit 1
		
	else
		cd $DT_r
		echo "$2" > trgt_
		sed -i ':a;N;$!ba;s/\n/ /g' trgt_
		sed -i 's/  / /g' trgt_
		sed -i 's/   / /g' trgt_
		sed -i 's/"//g' trgt_
		sed 's/^[ \t]*//;s/[ \t]*$//' trgt_ > trgt
		
		if [ "$(cat ./trgt | wc -c)" -ge 73 ]; then
			nme="$(cat trgt | cut -c 1-70 | sed 's/[ \t]*$//' | sed s'/&//'g | sed s'/://'g \
			sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')..."
		else
			nme=$(cat trgt | sed 's/[ \t]*$//' | \
			sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
		fi
		
		#-----------------------------------------
		srce="$4"
		trgt="$(cat trgt)"
		> swrd
		> twrd
		if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ]; then
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
		
		if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ]; then
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

		grmrk=$(cat grmrk | sed ':a;N;$!ba;s/\n/ /g')
		lwrds=$(cat A)
		pwrds=$(cat B | tr '\n' '_')
		
		if [ -f $DT_r/audtm.mp3 ]; then
			mv -f $DT_r/audtm.mp3 "$DM_tlt/$nme.mp3"
			eyeD3 --set-encoding=utf8 -t ISI1I0I"$trgt"ISI1I0I -a ISI2I0I"$srce"ISI2I0I \
			-A IWI3I0I"$lwrds"IWI3I0IIPWI3I0I"$pwrds"IPWI3I0IIGMI3I0I"$grmrk"IGMI3I0I "$DM_tlt/$nme.mp3"
				if [ -f img.jpg ]; then
					/usr/bin/convert -scale 450x270! -border 0.5 \
					-bordercolor '#9A9A9A' img.jpg imgs.jpg
					eyeD3 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/$nme.mp3"
				fi
				
		else # si no hay audio
			vs=$(sed -n 7p $DC_s/cnfg1)
			if [ -n "$vs" ]; then
				if ([ $vs = "festival" ] || [ $vs = "text2wave" ]); then
					lg=$(echo $lgtl | awk '{print tolower($0)}')

					if ([ $lg = "english" ] || [ $lg = "spanish" ] || [ $lg = "russian" ]); then
					echo "$trgt" | text2wave -o $DT_r/s.wav
					sox $DT_r/s.wav "$DM_tlt/$nme.mp3"
					else
						$yad --image=error --button=gtk-ok:1 \
						--text=" <b>$festival_err $lgtl " \
						--on-top --skip-taskbar & exit 1
					fi
				else
					cd $DT_r
					echo "$trgt" | $vs
					if [ -f *.mp3 ]; then
						mv -f *.mp3 "$DM_tlt/$nme.mp3"
					elif [ -f *.wav ]; then
						sox *.wav "$DM_tlt/$nme.mp3"
					fi
				fi
			else
				lg=$(echo $lgtl | awk '{print tolower($0)}')
				if [ $lg = chinese ]; then
					lg=Mandarin
				elif [ $lg = japanese ]; then
					$yad --image=error --button=gtk-ok:1 \
					--text=" <b>$espeak_err " \
					--on-top --skip-taskbar & exit 1
				fi
				espeak "$trgt" -v $lg -k 1 -p 65 -a 80 -s 120 -w $DT_r/s.wav
				sox $DT_r/s.wav "$DM_tlt/$nme.mp3"
			fi
			eyeD3 --set-encoding=utf8 -t ISI1I0I"$trgt"ISI1I0I -a ISI2I0I"$srce"ISI2I0I \
			-A IWI3I0I"$lwrds"IWI3I0IIPWI3I0I"$pwrds"IPWI3I0IIGMI3I0I"$grmrk"IGMI3I0I "$DM_tlt/$nme.mp3"
				if [ -f img.jpg ]; then
					/usr/bin/convert -scale 450x270! -border 0.5 \
					-bordercolor '#9A9A9A' img.jpg imgs.jpg
					eyeD3 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/$nme.mp3"
					icnn=img.jpg
				fi
		fi
		sleep 1
		notify-send -i "$icnn" "$trgt" "$srce \\n($tpe)" -t 10000
		$DS/mngr.sh inx S "$nme" "$tpe"
		
		if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ]; then
			n=1
			while [ $n -le $(cat $bw | wc -l) ]; do
				$dct $(sed -n "$n"p $bw) $DT_r
				let n++
			done
		else
			n=1
			while [ $n -le $(cat $aw | wc -l) ]; do
				$dct $(sed -n "$n"p $aw) $DT_r
				let n++
			done
		fi
		echo "aitm.1.aitm" >> \
		$DC/addons/stats/.log
		rm -fr $DT_r $DT/twrd $DT/swrd & exit 1
	fi

elif [ $1 = n_w ]; then

	trgt="$2"
	srce="$4"
	dct="$DS/addons/Dics/dict"
	icnn=idiomind
	int="$(sed -n 22p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	btn="$(sed -n 21p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	tpcs=$(cat "$DC_tl/.cnfg2" | cut -c 1-30 | egrep -v "$tpe" \
	| tr "\\n" '!' | sed 's/!\+$//g')
	ttle="${tpe:0:30}"
	DT_r="$3"
	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"

	if [ $(cat "$DC_tlt/cnfg3" | wc -l) -ge 50 ]; then
		$yad --name=idiomind --center --on-top --image=info \
		--text=" <b>$tpe    </b>\\n\\n $words_max" \
		--image-on-top --fixed --sticky --title="$tpe" \
		--width=350 --height=1 --borders=3 --button=gtk-ok:0 \
		--skip-taskbar --window-icon=idiomind && exit 1
	fi
	
	curl -v www.google.com 2>&1 | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
	$yad --window-icon=idiomind --on-top \
	--image=info --name=idiomind \
	--text="<b>$connection_err  \\n  </b>" \
	--image-on-top --center --fixed --sticky \
	--width=220 --height=50 --borders=3 \
	--skip-taskbar --title=Idiomind \
	--button="  Ok  ":0 >&2; rm -f -r $DT_r & exit 1;}
			
	if sed -n 1p $DC_s/cnfg3 | grep TRUE; then
		result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lgt" --data-urlencode "text=$trgt" https://translate.google.com)
		encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); \
		sub(/[ "'\''].*$/,""); print}' <<<"$result")
		iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 > .tgt
		trgt=$(cat .tgt | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
		result=$(curl -s -i --user-agent "" -d "sl=$lgt" -d "tl=$lgs" --data-urlencode "text=$trgt" https://translate.google.com)
		encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); \
		sub(/[ "'\''].*$/,""); print}' <<<"$result")
		iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 > .src
		src=$(cat .src)
		$dct "$trgt" $DT_r swrd
		nme=$(echo "$trgt" | sed "s/'//g")

		if [ -f "$DT_r/$trgt.mp3" ]; then
			cp -f "$DT_r/$trgt.mp3" "$DM_tlt/words/$nme.mp3"
			eyeD3 --set-encoding=utf8 -t IWI1I0I"$trgt"IWI1I0I -a IWI2I0I"$src"IWI2I0I "$DM_tlt/words/$nme.mp3"
		fi
		
		if [ -f img.jpg ]; then
			/usr/bin/convert -scale 100x90! -border 0.5 \
			-bordercolor '#9A9A9A' img.jpg imgs.jpg
			/usr/bin/convert -scale 360x240! img.jpg imgt.jpg
			eyeD3 --set-encoding=utf8 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/words/$nme.mp3"
			mv -f imgt.jpg "$DM_tlt/words/images/$nme.jpg"
			icnn=img.jpg
		fi
		
		notify-send -i "$icnn" "$trgt" "$src\\n  ($tpe)" -t 5000
		$DS/mngr.sh inx W "$nme" "$tpe"
		echo "aitm.1.aitm" >> \
		$DC/addons/stats/.log
		rm -f -r *.jpg $DT_r
		
	else
		if [ -f audtm.mp3 ]; then
			mv -f audtm.mp3 "$DM_tlt/words/$trgt.mp3"
			eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt}IWI1I0I" -a "IWI2I0I${srce}IWI2I0I" \
			"$DM_tlt/words/$trgt.mp3"
			
			if [ -f img.jpg ]; then
				/usr/bin/convert -scale 100x90! -border 0.5 \
				-bordercolor '#9A9A9A' img.jpg imgs.jpg
				/usr/bin/convert -scale 360x240! img.jpg imgt.jpg
				eyeD3 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/words/$trgt.mp3"
				mv -f imgt.jpg "$DM_tlt/words/images/$trgt.jpg"
			fi
			
		else
			cd $DT_r
			$dct "$trgt" $DT_r swrd
			
			if [ -f "$DT_r/$trgt.mp3" ]; then
				mv -f "$DT_r/$trgt.mp3" "$DM_tlt/words/$trgt.mp3"
				eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt}IWI1I0I" -a "IWI2I0I${srce}IWI2I0I" \
				"$DM_tlt/words/$trgt.mp3"
			
				if [ -f img.jpg ]; then
					/usr/bin/convert -scale 100x90! -border 0.5 \
					-bordercolor '#9A9A9A' img.jpg imgs.jpg
					/usr/bin/convert -scale 360x240! img.jpg imgt.jpg
					eyeD3 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/words/$trgt.mp3"
					mv -f imgt.jpg "$DM_tlt/words/images/$trgt.jpg"
				fi
				
			else
				vs=$(sed -n 7p $DC_s/cnfg1)
				if [ -n "$vs" ]; then
					if [ "$vs" = 'festival' ] || [ "$vs" = 'text2wave' ]; then
						lg=$(echo $lgtl | awk '{print tolower($0)}')
						
						if ([ $lg = "english" ] || [ $lg = "spanish" ] || [ $lg = "russian" ]); then
							echo "$trgt" | text2wave -o $DT_r/s.wav
							sox $DT_r/s.wav "$DM_tlt/$nme.mp3"
						else
							$yad --image=error --button=gtk-ok:1 \
							--text=" <b>$festival_err $lgtl </b>" \
							--on-top --skip-taskbar & exit 1
						fi
					else
						cd $DT_r
						echo "$trgt" | "$vs"
						if [ -f *.mp3 ]; then
							mv -f *.mp3 "$DM_tlt/words/$trgt.mp3"
						elif [ -f *.wav ]; then
							sox *.wav "$DM_tlt/words/$trgt.mp3"
						fi
					fi
				else
					lg=$(echo $lgtl | awk '{print tolower($0)}')
					if [ $lg = chinese ]; then
						lg=Mandarin
					elif [ $lg = japanese ]; then
						$yad --image=error --button=gtk-ok:1 \
						--text=" <b>$espeak_err </b>" \
						--on-top --skip-taskbar & exit 1
					fi
					espeak "$trgt" -v $lg -k 1 -p 45 -a 80 -s 110 -w $DT_r/s.wav
					sox $DT_r/s.wav "$DM_tlt/words/$trgt.mp3"
				fi
				eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt}IWI1I0I" -a "IWI2I0I${srce}IWI2I0I" \
				"$DM_tlt/words/$trgt.mp3"
				
				if [ -f img.jpg ]; then
					/usr/bin/convert -scale 100x90! -border 0.5 \
					-bordercolor '#9A9A9A' img.jpg imgs.jpg
					/usr/bin/convert -scale 360x240! img.jpg imgt.jpg
					eyeD3 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/words/$trgt.mp3"
					mv -f imgt.jpg "$DM_tlt/words/images/$trgt.jpg"
					icnn="$DM_tlt/words/images/$trgt.jpg"
				fi
			fi
		fi
		
		sleep 2
		notify-send -i "$icnn" "$trgt" "$srce\\n ($tpe)" -t 3000
		$DS/mngr.sh inx W "$trgt" "$tpe"
		echo "aitm.1.aitm" >> \
		$DC/addons/stats/.log
		rm -fr $DT_r & exit 1
	fi
	
elif [ $1 = edt ]; then

	c="$4"
	DIC=$DS/addons/Dics/dict
	int="$(sed -n 22p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	btn="$(sed -n 21p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"

	if [ "$3" = "F" ]; then

		tpe="$tpc"
		if [ $(cat "$DC_tlt/cnfg3" | wc -l) -ge 50 ]; then
		$yad --name=idiomind --center --image=info --on-top \
		--text=" <b>$words_max   </b>" \
		--image-on-top --fixed --sticky --title="$tpc" \
		--width=350 --height=140 --borders=3 --button=gtk-ok:0 \
		--skip-taskbar --window-icon=idiomind && exit 1
		fi
		
		nw=$(cat "$DC_tlt/cnfg3" | wc -l)
		left=$((50 - $nw))
		info=$(echo " $remain  <b>"$left"</b> $words")
		if [ $nw -ge 45 ]; then
			info=$(echo " $remain  <span color='#EA355F'><b>"$left"</b></span>  $words")
		elif [ $nw -ge 49 ]; then
			info=$(echo " $remain  <span color='#EA355F'><b>"$left"</b></span>  $word")
		fi

		mkdir $DT/$c
		DT_r=$DT/$c
		cd $DT_r
		file="$DM_tlt/$2.mp3"
		
		if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ]; then
			eyeD3 "$file" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' \
			| tr '_' '\n' | sed -n 1~2p | sed '/^$/d' > idlst
		else
			list=$(eyeD3 "$file" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
			echo "$list" | tr -c "[:alnum:]" '\n' | sed '/^$/d' | sed '/"("/d' \
			| sed '/")"/d' | sed '/":"/d' | sort -u \
			| head -n40 > idlst
		fi

		slt=$(mktemp $DT/slt.XXXX.x)
		cat idlst | awk '{print "FALSE\n"$0}' | \
		$yad --list --checklist \
		--on-top --text="<small> $info </small>\\n" \
		--center --sticky --no-headers \
		--buttons-layout=end --skip-taskbar --width=400 \
		--height=280 --borders=10 --window-icon=idiomind \
		--button=gtk-close:1 \
		--button="$add":0 \
		--title="$selector" \
		--column="" --column="Select" > "$slt"

			if [ $? -eq 0 ]; then
				list=$(cat "$slt" | sed 's/|//g')
				n=1
				while [ $n -le "$(cat "$slt" | head -50 | wc -l)" ]; do
					chkst=$(echo "$list" |sed -n "$n"p)
					echo "$chkst" | sed 's/TRUE//g' >> ./slts
					let n++
				done
				rm -f "$slt"
			fi
		
	elif [ "$3" = "S" ]; then
	
		nme="$2"
		DT_r="$DT/$c"
		cd $DT_r
		
		n=1
		while [ $n -le "$(cat ./slts | head -50 | wc -l)" ]; do

				trgt=$(sed -n "$n"p ./slts | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
			if [ $(cat "$DC_tlt/cnfg3" | wc -l) -ge 50 ]; then
				echo "$trgt
" > logw
				
			else
				result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lgs" --data-urlencode text="$trgt" https://translate.google.com)
				encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
				iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 > tr."$c"
				UNI=$(cat tr."$c")
				
				trgt=$(echo "$trgt")
				$DIC "$trgt" $DT_r swrd
				
				if [ -f "$trgt.mp3" ]; then
					mv -f $DT_r/"$trgt.mp3" "$DM_tlt/words/$trgt.mp3"
					eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt}IWI1I0I" -a "IWI2I0I${UNI}IWI2I0I" -A IWI3I0I"$5"IWI3I0I \
					"$DM_tlt/words/$trgt.mp3" >/dev/null 2>&1
				#----------------------si no hay audio
				else
					vs=$(sed -n 7p $DC_s/cnfg1)
					if [ -n "$vs" ]; then
						if [ "$vs" = 'festival' ] || [ "$vs" = 'text2wave' ]; then
							lg=$(echo $lgtl | awk '{print tolower($0)}')
							
							if ([ $lg = "english" ] || [ $lg = "spanish" ] || [ $lg = "russian" ]); then
								echo "$trgt" | text2wave -o $DT_r/s.wav
								sox $DT_r/s.wav "$DM_tlt/words/$trgt.mp3"
							else
								$yad --image=error --button=gtk-ok:1 \
								--text=" <b> $festival_err $lgtl </b> " \
								--on-top --skip-taskbar & exit 1
							fi
						else
							cd $DT_r
							echo "$trgt" | "$vs"
							if [ -f *.mp3 ]; then
								mv -f *.mp3 "$DM_tlt/words/$trgt.mp3"
							elif [ -f *.wav ]; then
								sox *.wav "$DM_tlt/words/$trgt.mp3"
							fi
						fi
					else
						lg=$(echo $lgtl | awk '{print tolower($0)}')
						if [ $lg = chinese ]; then
							lg=Mandarin
						elif [ $lg = japanese ]; then
							$yad --image=error --button=gtk-ok:1 \
							--text=" <b>$espeak_err </b> " \
							--on-top --skip-taskbar & exit 1
						fi
						espeak "$trgt" -v $lg -k 1 -p 45 -a 80 -s 110 -w $DT_r/s.wav
						sox $DT_r/s.wav "$DM_tlt/words/$trgt.mp3"
					fi
					eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt}IWI1I0I" -a "IWI2I0I${UNI}IWI2I0I" -A IWI3I0I"$5"IWI3I0I \
					"$DM_tlt/words/$trgt.mp3" >/dev/null 2>&1
				fi
				$DS/mngr.sh inx W "$trgt" "$tpc" "$nme"
			fi
			
			let n++
		done

		echo "aitm.$lns.aitm" >> \
		$DC/addons/stats/.log &

			if [ -f $DT_r/logw ]; then
				$yad --name=idiomind --class=idiomind \
				--center --wrap --text-info --skip-taskbar \
				--width=400 --height=280 --on-top --margins=4 \
				--fontname=vendana --window-icon=idiomind \
				--button=Ok:0 --borders=0 --filename=logw --title="$ttl" \
				--text=" <b>  ! </b><small><small> $items_rest </small></small>" \
				--field=":lbl" "" >/dev/null 2>&1
			fi
			rm -fr logw $DT/*.$c $DT_r & exit 1
	fi
	
elif [ $1 = prc ]; then

	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	DT_r=$(cat $DT/.n_s_pr)
	int="$(sed -n 22p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	btn="$(sed -n 21p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	cd $DT_r
	echo "$3" > ./lstws

	if [ -z "$tpe" ]; then
		$DC_s/chng.sh $DS/ifs/info5 fnew & exit 1
	fi

	nw=$(cat "$DC_tlt/cnfg3" | wc -l)
	if [ $nw -ge 50 ]; then
		$yad --name=idiomind --center \
		--image=info --on-top \
		--text=" <b>$words_max  </b>" \
		--image-on-top --fixed --sticky --title="$tpe" \
		--width=230 --height=120 --borders=3 --button=gtk-ok:0 \
		--skip-taskbar --window-icon=idiomind && exit 1
	fi

	left=$((50 - $nw))
	info=$(echo " $remain  <b>"$left"</b> $words")
	if [ $nw -ge 45 ]; then
		info=$(echo " $remain  <span color='#EA355F'>\
		<b>"$left"</b></span>  $words")
	elif [ $nw -ge 49 ]; then
		info=$(echo " $remain  <span color='#EA355F'>\
		<b>"$left"</b></span>  $word ")
	fi

	cat ./lstws | tr -c "[:alnum:]" '\n' | sed '/^$/d' | sed '/"("/d' \
	| sed '/")"/d' | sed '/":"/d' | sort -u \
	| head -n40 | egrep -v "FALSE" | egrep -v "TRUE" > lst
	nme=$(cat ./lstws | sed 's/FALSE//g' | \
	sed 's/TRUE//g' | sed 's/^ *//' | sed 's/[ \t]*$//')

	ws1=$(sed -n 1p lst)
	ws2=$(sed -n 2p lst)
	ws3=$(sed -n 3p lst)
	ws4=$(sed -n 4p lst)
	ws5=$(sed -n 5p lst)  
	ws6=$(sed -n 6p lst)
	ws7=$(sed -n 7p lst)
	ws8=$(sed -n 8p lst)
	ws9=$(sed -n 9p lst)
	ws10=$(sed -n 10p lst)
	ws11=$(sed -n 11p lst)
	ws12=$(sed -n 12p lst)
	ws13=$(sed -n 13p lst)
	ws14=$(sed -n 14p lst)
	ws15=$(sed -n 15p lst)
	ws16=$(sed -n 16p lst)
	ws17=$(sed -n 17p lst)
	ws18=$(sed -n 18p lst)
	ws19=$(sed -n 19p lst)
	ws20=$(sed -n 20p lst)
	ws21=$(sed -n 21p lst)
	ws22=$(sed -n 22p lst)
	ws23=$(sed -n 23p lst)
	ws24=$(sed -n 24p lst)
	ws25=$(sed -n 25p lst)
	ws26=$(sed -n 26p lst)
	ws27=$(sed -n 27p lst)
	ws28=$(sed -n 28p lst)
	ws29=$(sed -n 29p lst)
	ws30=$(sed -n 30p lst)
	ws31=$(sed -n 31p lst)
	ws32=$(sed -n 32p lst)
	ws33=$(sed -n 33p lst)
	ws34=$(sed -n 34p lst)
	ws35=$(sed -n 35p lst)
	ws36=$(sed -n 36p lst)
	ws37=$(sed -n 37p lst)
	ws38=$(sed -n 38p lst)
	ws39=$(sed -n 39p lst)
	ws40=$(sed -n 40p lst)

	w=`cat ./lst | awk '{print "FALSE\n"$0}' | \
		$yad --list --checklist --window-icon=idiomind \
		--on-top --text="<small> $info </small>\\n" \
		--center --sticky --no-headers \
		--buttons-layout=end --skip-taskbar --width=400 \
		--height=280 --borders=10 \
		--button="gtk-close":1 \
		--button="$add":0 \
		--title="$title_selector" \
		--column="" --column="Select"`
		
		if [ $? -eq 0 ]
		then
			IFS="|"
			for w in $w
			do
				if [ "$w" = "$ws1" ];
					 then
					 echo "$ws1" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws2" ]
					 then
					 echo "$ws2" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws3" ]
					 then
					 echo "$ws3" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws4" ]
					 then
					 echo "$ws4" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws5" ]
					 then
					 echo "$ws5" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws6" ]
					 then
					 echo "$ws6" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws7" ]
					 then
					 echo "$ws7" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws8" ]
					 then
					 echo "$ws8" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws9" ]
					 then
					 echo "$ws9" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws10" ]
					 then
					 echo "$ws10" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws11" ]
					 then
					 echo "$ws11" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws12" ]
					 then
					 echo "$ws12" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws13" ]
					 then
					 echo "$ws13" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws14" ]
					 then
					 echo "$ws14" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws15" ]
					 then
					 echo "$ws15" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws16" ]
					 then
					 echo "$ws16" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws17" ]
					 then
					 echo "$ws17" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws18" ]
					 then
					 echo "$ws18" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws19" ]
					 then
					 echo "$ws19" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws20" ]
					 then
					 echo "$ws20" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws21" ]
					 then
					 echo "$ws21" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws22" ]
					 then
					 echo "$ws22" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws23" ]
					 then
					 echo "$ws23" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws24" ]
					 then
					 echo "$ws24" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws25" ]
					 then
					 echo "$ws25" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws26" ]
					 then
					 echo "$ws26" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws27" ]
					 then
					 echo "$ws27" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws28" ]
					 then
					 echo "$ws28" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws29" ]
					 then
					 echo "$ws29" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws30" ]
					 then
					 echo "$ws30" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws31" ]
					 then
					 echo "$ws31" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws32" ]
					 then
					 echo "$ws32" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws33" ]
					 then
					 echo "$ws33" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws34" ]
					 then
					 echo "$ws34" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws35" ]
					 then
					 echo "$ws35" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws36" ]
					 then
					 echo "$ws36" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws37" ]
					 then
					 echo "$ws37" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws38" ]
					 then
					 echo "$ws38" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws39" ]
					 then
					 echo "$ws39" >> wrds
					 echo "$nme" >> wrdsls
				elif [ "$w" = "$ws40" ]
					 then
					 echo "$ws40" >> wrds
					 echo "$nme" >> wrdsls
				fi
			done
		fi
	$? >/dev/null 2>&1
	exit 1

elif [ $1 = snt ]; then

	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	DIC=$DS/addons/Dics/dict
	int="$(sed -n 22p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	btn="$(sed -n 21p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	c=$(echo $(($RANDOM%100)))
	DT_r=$(mktemp -d $DT/XXXXXX)
	cd $DT_r

	if [ -z "$tpe" ]; then
		$DC_s/chng.sh $DS/ifs/info5 fnew & exit 1
	fi

	nw=$(cat "$DC_tlt/words/cnfg3" | wc -l)
	left=$((50 - $nw))
	if [ "$left" = 0 ]; then
		exit 1
		info=$(echo " $remain  <b>"$left"</b>  $words")
	elif [ $nw -ge 45 ]; then
		info=$(echo " $remain  <span color='#EA355F'><b>"$left"</b></span>  $words")
	elif [ $nw -ge 49 ]; then
		info=$(echo " $remain  <span color='#EA355F'><b>"$left"</b></span>  $word)")
	fi

	if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ]; then
		eyeD3 "$DM_tl/$3/$2.mp3" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' \
		| tr '_' '\n' | sed -n 1~2p | sed '/^$/d' > $DT_r/wrds
	else
		list=$(eyeD3 "$DM_tl/$3/$2.mp3" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
		echo "$list" | tr -c "[:alnum:]" '\n' | sed '/^$/d' | sed '/"("/d' \
		| sed '/")"/d' | sed '/":"/d' | sort -u \
		| head -n40 > $DT_r/wrds
	fi
	
	slt=$(mktemp $DT/slt.XXXX.x)
	sleep 0.5
	cat $DT_r/wrds | awk '{print "FALSE\n"$0}' | \
	$yad --list --checklist \
	--on-top --text="<small> $info </small>\\n" \
	--fixed --sticky --no-headers --center --window-icon=idiomind \
	--buttons-layout=end --skip-taskbar --width=400 \
	--height=280 --borders=10 \
	--button=gtk-close:1 \
	--button="$add":0 \
	--title="$title_selector - $tpe" \
	--column="" --column="Select" > "$slt"
		
		ret=$?
		
		if [ $? -eq 0 ]; then
			list=$(cat "$slt" | sed 's/|//g')
			n=1
			while [ $n -le $(cat "$slt" | head -50 | wc -l) ]; do
				chkst=$(echo "$list" |sed -n "$n"p)
				echo "$chkst" | sed 's/TRUE//g' >> ./slts
				let n++
			done
			rm -f "$slt"
		elif [ "$ret" -eq 1 ]; then
			rm -f $DT/*."$c"
			rm -fr $DT_r & exit 1
		fi
			
	EX=$(echo "$2")
	ADD=$(wc -l ./slts)
	n=1
	while [ $n -le $(cat ./slts | head -50 | wc -l) ]; do
		trgt=$(sed -n "$n"p ./slts | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
		if [ $(cat "$DC_tlt/cnfg3" | wc -l) -ge 50 ]; then
			echo "$trgt" >> logw
		else
			result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lgs" --data-urlencode text="$trgt" https://translate.google.com)
			encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
			iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 > tr."$c"
			UNI=$(cat ./tr."$c")
			$DIC "$trgt" $DT_r swrd
			if [ -f "$trgt.mp3" ]; then
				mv -f "$DT_r/$trgt.mp3" "$DM_tlt/words/$trgt.mp3"
				eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt}IWI1I0I" -a "IWI2I0I${UNI}IWI2I0I" -A IWI3I0I"$2"IWI3I0I \
				"$DM_tlt/words/$trgt.mp3"
				# si no hay audio
				else
					vs=$(sed -n 7p $DC_s/cnfg1)
					if [ -n "$vs" ]; then
						if [ "$vs" = 'festival' ] || [ "$vs" = 'text2wave' ]; then
							lg=$(echo $lgtl | awk '{print tolower($0)}')

							if ([ $lg = "english" ] || [ $lg = "spanish" ] || [ $lg = "russian" ]); then
								echo "$trgt" | text2wave -o $DT_r/s.wav
								sox $DT_r/s.wav "$DM_tlt/words/$trgt.mp3"
							else
								$yad --image=error --button=gtk-ok:1 \
								--text=" <b>$festival_err $lgtl</b> " \
								--on-top --skip-taskbar & exit 1
							fi
						else
							cd $DT_r
							echo "$trgt" | "$vs"
							if [ -f *.mp3 ]; then
								mv -f *.mp3 "$DM_tlt/words/$trgt.mp3"
							elif [ -f *.wav ]; then
								sox *.wav "$DM_tlt/words/$trgt.mp3"
							fi
						fi
					else
						lg=$(echo $lgtl | awk '{print tolower($0)}')
						if [ $lg = chinese ]; then
							lg=Mandarin
						elif [ $lg = japanese ]; then
							$yad --image=error --button=gtk-ok:1 \
							--text=" <b>$espeak_err</b> " \
							--on-top --skip-taskbar & exit 1
						fi
						espeak "$trgt" -v $lg -k 1 -p 45 -a 80 -s 110 -w $DT_r/s.wav
						sox $DT_r/s.wav "$DM_tlt/words/$trgt.mp3"
					fi

				eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt}IWI1I0I" -a "IWI2I0I${UNI}IWI2I0I" -A IWI3I0I"$2"IWI3I0I \
				"$DM_tlt/words/$trgt.mp3"
			fi
			$DS/mngr.sh inx W "$trgt" "$3"
			fi
		let n++
	done

	echo "aitm.$lns.aitm" >> \
	$DC/addons/stats/.log &

	if [ -f $DT_r/logw ]; then
		$yad --name=idiomind --class=idiomind \
		--center --wrap --text-info --skip-taskbar \
		--width=400 --height=280 --on-top --margins=4 \
		--fontname=vendana --window-icon=idiomind \
		--button="Ok:0" --borders=0 --filename=logw --title="$ttl" \
		--text=" <b>  ! </b><small><small> $items_rest</small></small>" \
		--field=":lbl" "" >/dev/null 2>&1
	fi
	rm -f $DT/*."$c" 
	rm -fr $DT_r & exit 1
	
elif [ $1 = prs ]; then
	source $DS/ifs/trans/$lgs/add.conf
	eht=$(sed -n 3p $DC_s/cnfg18)
	wth=$(sed -n 4p $DC_s/cnfg18)
	ns=$(cat "$DC_tlt"/cnfg4 | wc -l)
	lvbr=$(cat $DS/default/$lgt/verbs)
	lnns=$(cat $DS/default/$lgt/nouns)
	ladv=$(cat $DS/default/$lgt/adverbs)
	lprn=$(cat $DS/default/$lgt/pronouns)
	lpre=$(cat $DS/default/$lgt/prepositions)
	ladj=$(cat $DS/default/$lgt/adjetives)
	nspr='/usr/share/idiomind/add.sh prs'
	int="$(sed -n 22p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	btn="$(sed -n 21p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	LNK='http://www.chromium.org/developers/how-tos/api-keys'
	dct=$DS/addons/Dics/dict
	lckpr=$DT/.n_s_pr
	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	DT_r="$3"
	cd "$DT_r"

	if [ -z "$tpe" ]; then
		source $DS/ifs/trans/$lgs/topics_lists.conf
		$DC_s/chng.sh "$no_edit" fnew & exit 1
	fi

	if [ $ns -ge 50 ]; then
		$yad --name=idiomind --center --on-top --image=info \
		--text=" <b>$sentences_max </b>" \
		--image-on-top --fixed --sticky --title="$tpe" \
		--width=350 --height=150 --button=gtk-ok:0 \
		--skip-taskbar --window-icon=idiomind && \
		rm -fr ls $lckpr $DT_r & exit 1
	fi

	if [ -f $lckpr ]; then
		$yad --fixed --center --on-top \
		--image=info --name=idiomind \
		--text=" <i>$current_pros </i> " \
		--fixed --sticky --buttons-layout=edge \
		--width=350 --height=150  --borders=5 \
		--skip-taskbar --window-icon=idiomind \
		--title=Idiomind --button=gtk-cancel:3 --button=Ok:1
			ret=$?
			if [ $ret -eq "3" ]; then
				rm=$(cat $lckpr)
				rm fr $rm $lckpr
				$DS/mngr.sh inx R && killall add.sh
				exit 1
			else
				exit 1
			fi
	fi
	
	if [ -n "$2" ]; then
		echo $DT_r > $DT/.n_s_pr
		lckpr=$DT/.n_s_pr
		prdt="$2"
	fi

	if [ "$(echo "$prdt" | cut -d "|" -f1 | sed -n 1p)" = "a" ]; then

		left=$((50 - $(cat "$DC_tlt/cnfg4" | wc -l)))
		key=$(sed -n 2p $DC_s/cnfg3)
		
		if [ -z "$key" ]; then
			$yad --name=idiomind --center --on-top --image=error \
			--text="  $no_key <a href='$LNK'> Google.</a>" \
			--image-on-top --sticky --title="Idiomind" \
			--width=400 --height=150 --button=gtk-ok:0 \
			--skip-taskbar --window-icon=idiomind && \
			rm -fr ls $lckpr $DT_r & exit 1
		fi
		
		cd $HOME
		FL=$($yad --borders=0 --name=idiomind --file-filter="*.mp3" \
			--skip-taskbar --on-top --title="Speech recognize" --center \
			--window-icon=idiomind --file --width=600 --height=450)
		
		if [ -z "$FL" ];then
			rm -fr $lckpr $DT_r & exit 1
			
		else
			if [ -z "$tpe" ]; then
				$DS/chng.sh $DS/ifs/info5 fnew & exit 1
			fi
			cd $DT_r
			
			(
			echo "2"
			echo "# $file_pros" ; sleep 1
			cp -f "$FL" $DT_r/rv.mp3
			cd $DT_r
			eyeD3 -P itunes-podcast --remove "$DT_r"/rv.mp3
			eyeD3 --remove-all "$DT_r"/rv.mp3
			sox "$DT_r"/rv.mp3 "$DT_r"/c_rv.mp3 \
			remix - \
			highpass 100 \
			norm \
			compand 0.05,0.2 6:-54,-90,-36,-36,-24,-24,0,-12 0 -90 0.1 \
			vad -T 0.6 -p 0.2 -t 5 \
			fade 0.1 \
			reverse \
			vad -T 0.6 -p 0.2 -t 5 \
			fade 0.1 \
			reverse \
			norm -0.5
			rm -f "$DT_r"/rv.mp3
			mp3splt -s -o @n *.mp3
			rename 's/^0*//' *.mp3
			rm -f "$DT_r"/c_rv.mp3
			ls *.mp3 > lst
			lns=$(cat ./lst | head -50 | wc -l)
			
			curl -v www.google.com 2>&1 | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
			$yad --window-icon=idiomind --on-top \
			--image=info --name=idiomind \
			--text=" <b>$connection_err  \\n  </b>" \
			--image-on-top --center --fixed --sticky \
			--width=220 --height=150 \
			--skip-taskbar --title=Idiomind \
			--button="  Ok  ":0
			 >&2; exit 1;}
			 
			echo "3"
			echo "# $check_key... " ; sleep 1
			
			wget -q -U "Mozilla/5.0" --post-file $DS/addons/Google_translation_service/test.flac \
			--header="Content-Type: audio/x-flac; rate=16000" \
			-O - "https://www.google.com/speech-api/v2/recognize?&lang="$lgt"-"$lgt"&key=$key" > info.ret
			if [ -z "$(cat info.ret)" ]; then
				key=$(sed -n 3p $DC_s/cnfg3)
				wget -q -U "Mozilla/5.0" --post-file $DS/addons/Google_translation_service/test.flac \
				--header="Content-Type: audio/x-flac; rate=16000" \
				-O - "https://www.google.com/speech-api/v2/recognize?&lang="$lgt"-"$lgt"&key=$key" > info.ret
			fi
			if [ -z "$(cat info.ret)" ]; then
				key=$(sed -n 4p $DC_s/cnfg3)
				wget -q -U "Mozilla/5.0" --post-file $DS/addons/Google_translation_service/test.flac \
				--header="Content-Type: audio/x-flac; rate=16000" \
				-O - "https://www.google.com/speech-api/v2/recognize?&lang="$lgt"-"$lgt"&key=$key" > info.ret
			fi
			if [ -z "$(cat info.ret)" ]; then
				$yad --name=idiomind --center --on-top --image=error \
				--text="  $key_err <a href='$LNK'>Google. </a>" \
				--image-on-top --sticky --title="Idiomind" \
				--width=350 --height=140 --borders=3 --button=gtk-ok:0 \
				--skip-taskbar --window-icon=idiomind && \
				rm -fr ls $lckpr $DT_r & exit 1
			fi
			
			echo "# $file_pros" ; sleep 0.2
			#-----------------------------------------
			n=1
			while [ $n -le "$lns" ]; do

				sox "$n".mp3 info.flac rate 16k
				wget -q -U "Mozilla/5.0" \
				--post-file info.flac \
				--header="Content-Type: audio/x-flac; rate=16000" \
				-O - "https://www.google.com/speech-api/v2/recognize?&lang="$lgt"-"$lgt"&key=$key" | sed 's/","confidence.*//' > ./info.ret
				
				if [ -z "$(cat info.ret)" ]; then
					$yad --name=idiomind --center --on-top --image=error \
					--text="  $key_err <a href='$LNK'>Google. </a>" \
					--image-on-top --sticky --title="Idiomind" \
					--width=400 --height=150 --button=gtk-ok:0 \
					--skip-taskbar --window-icon=idiomind &
					rm -fr ls $lckpr $DT_r & break & exit 1
				fi
				
				cat ./info.ret | sed '1d' | sed 's/.*transcript":"//' | sed 's/"}],"final":true}],"result_index":0}//g' > ./tgt
				trgt=$(cat ./tgt)
				
				if [ $(echo "$trgt" | wc -c) -gt 180 ]; then
					echo "
$trgt" >> log
				
				else
					if [ $(cat ./tgt | wc -c) -ge 73 ]; then
						nme="$(cat ./tgt | cut -c 1-70 | sed 's/[ \t]*$//' | \
						sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')..."
					else
						nme=$(cat ./tgt | sed 's/[ \t]*$//' | \
						sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
					fi
					
					mv -f ./"$n".mp3 ./"$nme".mp3
					echo "$trgt" > ./"$nme".txt
					echo "$nme" >> ./ls
					rm -f info.flac info.ret
				fi
				
				prg=$((100*$n/$lns))
				echo "$prg"
				echo "# ${trgt:0:35} ... " ;
				
				let n++
			done
			) | $yad --progress --progress-text=" " \
			--width=250 --height=20 --geometry=250x20-2-2 \
			--undecorated --auto-close --on-top \
			--skip-taskbar --no-buttons
			
			[[ $(echo "$tpe" | wc -c) -gt 40 ]] && tcnm="${tpe:0:40}..." || tcnm="$tpe"

			left=$((50 - $(cat "$DC_tlt"/cnfg4 | wc -l)))
			info=$(echo "Puedes agregar  <b>"$left"</b>  oraciones")
			if [ $ns -ge 45 ]; then
				info=$(echo "Puedes agregar  <b>"$left"</b>  oraciones en $tcnm")
			elif [ $ns -ge 49 ]; then
				info=$(echo "Puedes agregar  <b>"$left"</b>  oración en $tcnm")
			fi
			
			if [ -z "$(cat ./ls)" ]; then
				echo "$gettext_err" | $yad --text-info --center --wrap \
				--name=idiomind --class=idiomind --window-icon=idiomind \
				--text=" " --sticky --width=$wth --height=$eht \
				--margins=8 --borders=3 --button=gtk-ok:0 --title="$Title_sentences" && \
				rm -fr $lckpr $DT_r & exit 1
				
			else
				slt=$(mktemp $DT/slt.XXXX.x)
				cat ./ls | awk '{print "FALSE\n"$0}' | \
				$yad --center --sticky --no-headers \
				--name=idiomind --class=idiomind \
				--dclick-action='/usr/share/idiomind/add.sh prc' \
				--list --checklist --window-icon=idiomind \
				--width=$wth --text="$info" \
				--height=$eht --borders=3 --button=gtk-cancel:1 \
				--button="$to_new_topic":'/usr/share/idiomind/add.sh n_t' \
				--button=gtk-save:0 --title="$Title_sentences" \
				--column="$(cat ./ls | wc -l)" --column="Items" > "$slt"
			fi
			
				if [ $? -eq 0 ]; then
				
					source /usr/share/idiomind/ifs/c.conf
					cd $DT_r
					list=$(cat "$slt" | sed 's/|//g')
					n=1
					while [ $n -le "$(cat "$slt" | head -50 | wc -l)" ]; do
						chkst=$(echo "$list" |sed -n "$n"p)
						echo "$chkst" | sed 's/TRUE//g' >> ./slts
						let n++
					done
					
					rm -f "$slt"
					sed -i 's/\://g' ./slts
					curl -v www.google.com 2>&1 | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
					$yad --window-icon=idiomind --on-top \
					--image=info --name=idiomind \
					--text="<b>$connection_err \\n  </b>" \
					--image-on-top --center --fixed --sticky \
					--width=220 --height=150 --borders=3 \
					--skip-taskbar --title=Idiomind \
					--button="  Ok  ":0 & exit 1
					>&2; exit 1;}
					
					#-----------------------------------------
					(
					echo "2"
					echo "# " ;
					[ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ] && c=c || c=w
					lns=$(cat ./slts ./wrds | wc -l)
					n=1
					while [ $n -le $(cat ./slts | head -50 | wc -l) ]; do
						
						sntc=$(sed -n "$n"p ./slts)
						trgt=$(cat "./$sntc.txt")
						
						if [ $(echo "$sntc" | wc -c) -ge 73 ]; then
							nme="$(echo "$sntc" | cut -c 1-70 | sed 's/[ \t]*$//' | \
							sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')..."
						else
							nme=$(echo "$sntc" | sed 's/[ \t]*$//' | \
							sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
						fi
						
						if [ $(sed -n 1p "$sntc.txt" | wc -$c) -eq 1 ]; then
						
							if [ $(cat "$DC_tlt"/cnfg3 | wc -l) -ge 50 ]; then
								echo "
$sntc" >> ./slog
						
							else
								result=$(curl -s -i --user-agent "" -d "sl=$lgt" -d "tl=$lgs" --data-urlencode text="$trgt" https://translate.google.com)
								encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
								srce=$(iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8)
								eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt}IWI1I0I" -a "IWI2I0I${srce}IWI2I0I" "$sntc".mp3
								
								mv -f "$sntc".mp3 "$DM_tlt/words/$nme".mp3
								$DS/mngr.sh inx W "$nme" "$tpe"
								echo "$nme" >> addw
							fi
						
						elif [ $(sed -n 1p "$sntc.txt" | wc -$c) -ge 1 ]; then
						
							if [ $(cat "$DC_tlt"/cnfg4 | wc -l) -ge 50 ]; then
								echo "
$sntc" >> ./wlog
						
							else
								result=$(curl -s -i --user-agent "" -d "sl=$lgt" -d "tl=$lgs" --data-urlencode text="$trgt" https://translate.google.com)
								encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
								srce=$(iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 | sed ':a;N;$!ba;s/\n/ /g')
								eyeD3 --set-encoding=utf8 -t ISI1I0I"$trgt"ISI1I0I -a ISI2I0I"$srce"ISI2I0I \
								"$sntc.mp3"

								mv -f "$sntc.mp3" "$DM_tlt/$nme.mp3"
								$DS/mngr.sh inx S "$nme" "$tpe"
								echo "$nme" >> adds
								
								(
								r=$(echo $(($RANDOM%1000)))
								> twrd_$r
								> swrd_$r
								if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt =ru ]; then
									vrbl="$srce"; lg=$lgt; aw=$DT/swrd_$r; bw=$DT/twrd_$r
								else
									vrbl="$trgt"; lg=$lgs; aw=$DT/twrd_$r; bw=$DT/swrd_$r
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
								> A_$r
								> B_$r
								> C_$r
								sed -i 's/\. /\n/g' $bw
								sed -i 's/\. /\n/g' $aw
								snmk=$(echo "$trgt"  | sed 's/ /\n/g')
								n=1
								while [ $n -le $(echo "$snmk" | wc -l) ]; do
									grmrk=$(echo "$snmk" | sed -n "$n"p)
									chck=$(echo "$snmk" | sed -n "$n"p | awk '{print tolower($0)}' \
									| sed 's/,//g' | sed 's/\.//g')
									if echo "$lnns" | grep -Fxq $chck; then
										echo "$grmrk" >> C_$r
									elif echo "$lvbr" | grep -Fxq $chck; then
										echo "<span color='#D14D8B'>$grmrk</span>" >> C_$r
									elif echo "$lpre" | grep -Fxq $chck; then
										echo "<span color='#E08434'>$grmrk</span>" >> C_$r
									elif echo "$ladv" | grep -Fxq $chck; then
										echo "<span color='#9C68BD'>$grmrk</span>" >> C_$r
									elif echo "$lprn" | grep -Fxq $chck; then
										echo "<span color='#5473B8'>$grmrk</span>" >> C_$r
									elif echo "$ladj" | grep -Fxq $chck; then
										echo "<span color='#368F68'>$grmrk</span>" >> C_$r
									else
										echo "$grmrk" >> C_$r
									fi
									let n++
								done
								
								if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ]; then
									n=1
									while [ $n -le "$(cat $aw | wc -l)" ]; do
										s=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
										t=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
										echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A_$r
										echo "$t"_"$s""" >> B_$r
										let n++
									done
								else
									n=1
									while [ $n -le "$(cat $aw | wc -l)" ]; do
										t=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
										s=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
										echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A_$r
										echo "$t"_"$s""" >> B_$r
										let n++
									done
								fi
								grmrk=$(cat C_$r | sed ':a;N;$!ba;s/\n/ /g')
								lwrds=$(cat A_$r)
								pwrds=$(cat B_$r | tr '\n' '_')
								eyeD3 --set-encoding=utf8 -A IWI3I0I"$lwrds"IWI3I0IIPWI3I0I"$pwrds"IPWI3I0IIGMI3I0I"$grmrk"IGMI3I0I "$DM_tlt/$nme.mp3"

								if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ]; then
									n=1
									while [ $n -le $(cat $bw | wc -l) ]; do
										$dct $(sed -n "$n"p $bw) $DT_r
										let n++
									done
								else
									n=1
									while [ $n -le $(cat $aw | wc -l) ]; do
										$dct $(sed -n "$n"p $aw) $DT_r
										let n++
									done
								fi

								echo "__" >> x
								) &
						
								rm -f "$nme".mp3 TMP1.mp3 TMP2.mp3 TMP3.mp3 TMP4.mp3 
							fi
						fi
					
						prg=$((100*$n/$lns-1))
						echo "$prg"
						echo "# ${sntc:0:35} ... " ;
						
						let n++
					done
					
					#-----------------------------------------palabras
					if [ -n "$(cat wrds)" ]; then
						nwrds=" y $(cat wrds | head -50 | wc -l) Palabras"
					fi
					
					n=1
					while [ $n -le "$(cat wrds | head -50 | wc -l)" ]; do
						trgt=$(sed -n "$n"p wrds | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
						exmp=$(sed -n "$n"p wrdsls)
						
						if [ $(echo "$exmp" | wc -c) -ge 73 ]; then # es para obtener el nobre de archivo
							nme="$(echo "$exmp" | sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g' | cut -c 1-70)..."
						else
							nme=$(echo "$exmp" | "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
						fi # es para obtener el nobre de archivo
					
						if [ $(cat "$DC_tlt"/cnfg3 | wc -l) -ge 50 ]; then
							echo "
$trgt" >> ./wlog
					
						else
							result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lgs" --data-urlencode text="$trgt" https://translate.google.com)
							encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
							srce=$(iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8)

							$dct "$trgt" $DT_r swrd
							
							if [ -f "$trgt".mp3 ]; then
								mv -f "$DT_r/$trgt.mp3" "$DM_tlt/words/$trgt.mp3"
								eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt}IWI1I0I" -a "IWI2I0I${srce}IWI2I0I" -A "IWI3I0I${exmp}IWI3I0I" \
								"$DM_tlt/words/$trgt.mp3"
							
							#-----------------if not audio
							else
								vs=$(sed -n 7p $DC_s/cnfg1)
								if [ -n "$vs" ]; then
									if [ "$vs" = 'festival' ] || [ "$vs" = 'text2wave' ]; then
										lg=$(echo $lgtl | awk '{print tolower($0)}')

										if ([ $lg = "english" ] || [ $lg = "spanish" ] || [ $lg = "russian" ]); then
										echo "$trgt" | text2wave -o $DT_r/s.wav
										sox $DT_r/s.wav "$DM_tlt/words/$trgt.mp3"
										else
											$yad --image=error --button=gtk-ok:1 \
											--text=" <b>$festival_err $lgtl</b> " \
											--on-top --skip-taskbar & exit 1
										fi
									else
										cd $DT_r
										echo "$trgt" | "$vs"
										if [ -f *.mp3 ]; then
											mv -f *.mp3 "$DM_tlt/words/$trgt.mp3"
										elif [ -f *.wav ]; then
											sox *.wav "$DM_tlt/words/$trgt.mp3"
										fi
									fi
								else
									lg=$(echo $lgtl | awk '{print tolower($0)}')
									if [ $lg = chinese ]; then
										lg=Mandarin
									elif [ $lg = japanese ]; then
										$yad --image=error --button=gtk-ok:1 \
										--text=" <b>$espeak_err </b> " \
										--on-top --skip-taskbar & exit 1
									fi
									espeak "$trgt" -v $lg -k 1 -p 45 -a 80 -s 110 -w $DT_r/s.wav
									sox $DT_r/s.wav "$DM_tlt/words/$trgt.mp3"
								fi
								eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt}IWI1I0I" -a "IWI2I0I${UNI}IWI2I0I" -A "IWI3I0I${exmp}IWI3I0I" \
								"$DM_tlt/words/$trgt.mp3"
							fi
							echo "$trgt" >> addw
							$DS/mngr.sh inx W "$trgt" "$tpe" "$nme"
						fi
						nn=$(($n+$(cat ./slts | wc -l)-1))
						prg=$((100*$nn/$lns))
						echo "$prg"
						echo "# ${trgt:0:35} ... " ;
						
						let n++
					done
					) | $yad --progress --progress-text=" " \
					--width=250 --height=20 --geometry=250x20-2-2 \
					--undecorated --auto-close --on-top \
					--skip-taskbar --no-buttons
					
					cd $DT_r
					
					if [ -f ./wlog ]; then
						wadds=" $(($(cat ./addw | wc -l) - $(cat ./wlog | sed '/^$/d' | wc -l)))"
						W=" $words"
						if [ $(echo $wadds) = 1 ]; then
							W=" $word"
						fi
					else
						wadds=" $(cat ./addw | wc -l)"
						W=" $words"
						if [ $(echo $wadds) = 1 ]; then
							wadds=" $(cat ./addw | wc -l)"
							W=" $word"
						fi
					fi
					if [ -f ./slog ]; then
						sadds=" $(($(cat ./adds | wc -l) - $(cat ./slog | sed '/^$/d' | wc -l)))"
						S=" $sentences"
						if [ $(echo $sadds) = 1 ]; then
							S=" $sentence"
						fi
					else
						sadds=" $(cat ./adds | wc -l) $sentences"
						S=" $sentences"
						if [ $(echo $sadds) = 1 ]; then
							S=" $sentence"
						fi
					fi
					
					logs=$(cat ./slog ./wlog)
					adds=$(cat ./adds ./addw | wc -l)
					
					if [ $adds -ge 1 ]; then
						notify-send -i idiomind "$tpe" "$added \\n$sadds$S$wadds$W" -t 2000 &
						echo "aitm.$adds.aitm" >> \
						$DC/addons/stats/.log
					fi
					
					if [ -f ./log ]; then
						if [ $(ls ./*.mp3 | wc -l) -ge 1 ]; then
							btn="--button=$save:0"
						fi
						$yad --form --name=idiomind --class=idiomind \
						--center --skip-taskbar --on-top \
						--width=350 --height=300 --on-top --margins=4 \
						--window-icon=idiomind \
						--borders=0 --title="$tpe" \
						--field="<b>  ! </b><small><small> $items_rest</small> </small><small><small>$logn</small></small>":txt "$log" \
						--field=":lbl"\
						"$btn" --button=Ok:1 >/dev/null 2>&1
							ret=$?
						
							if  [ "$ret" -eq 0 ]; then
								aud=$($yad --save --center --borders=10 \
								--on-top --filename="$(date +%m/%d/%Y)"_audio.tar.gz \
								--window-icon=idiomind --skip-taskbar --title="Save " \
								--file --width=600 --height=500 --button=gtk-ok:0 )
									ret=$?
									if [ "$ret" -eq 0 ]; then
										tar cvzf audio.tar.gz ./*.mp3, *.txt
										mv -f audio.tar.gz "$aud"
									fi
							fi
					fi
					
					if  [ -f ./log ]; then
						rm=$(($(cat ./adds) - $(cat ./log | sed '/^$/d' | wc -l)))
					else
						rm=$(cat ./adds)
					fi
					
					n=1
					while [ $n -le 20 ]; do
						 sleep 5
						 if ([ $(cat ./x | wc -l) = $rm ] || [ $n = 20 ]); then
							rm -fr $DT_r $lckpr & break & exit 1
						 fi
						let n++
					done
					exit 1
				else
					rm -fr $DT_r $lckpr $slt & exit 1
				fi
		fi
	fi

	if [ "$(echo "$prdt" | cut -d "|" -f1 \
	| sed -n 1p | grep -o "http")" = "http" ]; then
		
		curl -v www.google.com 2>&1 \
		| grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
		$yad --window-icon=idiomind --on-top \
		--image=info --name=idiomind \
		--text="<b> $connection_err  \\n  </b>" \
		--image-on-top --center --sticky \
		--width=300 --height=150 \
		--skip-taskbar --title=Idiomind \
		--button="  Ok  ":0
		>&2; exit 1;}
		
		(
		echo "3"
		echo "# " ;
		curl $prdt | grep -o -P '(?<=<title>).*(?=</title>)' > ./sntsls_
		lynx -dump -nolist $prdt  | sed -n -e '1x;1!H;${x;s-\n- -gp}' \
		| sed 's/\./\.\n/g' | sed 's/<[^>]*>//g' | sed 's/ \+/ /g' \
		| sed '/^$/d' | sed 's/  / /g' | sed 's/^[ \t]*//;s/[ \t]*$//g' \
		| sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
		| sed 's/<[^>]\+>//g' | sed 's/\://g' >> ./sntsls_
		
		) | $yad --progress --progress-text=" " \
		--width=200 --height=20 --geometry=200x20-2-2 \
		--pulsate --percentage="5" --on-top \
		--undecorated --auto-close \
		--skip-taskbar --no-buttons
		
		[[ $(sed -n 1p ./sntsls_ | wc -c) -gt 40 ]] \
		&& te="$(sed -n 1p ./sntsls_ | head -50)" \
		|| te="$(sed -n 1p ./sntsls_)"

	elif [[ "$(echo "$prdt" | cut -d "|" -f1 \
	| sed -n 1p | grep -o "i")" = i ]]; then
		
		SCR_IMG=`mktemp`
		trap "rm $SCR_IMG*" EXIT
		scrot -s $SCR_IMG.png
		
		(
		echo "3"
		echo "# " ;
		mogrify -modulate 100,0 -resize 400% $SCR_IMG.png
		tesseract $SCR_IMG.png $SCR_IMG &> /dev/null
		cat $SCR_IMG.txt | sed 's/\\n/./g' | sed 's/\./\n/g' \
		| sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//' \
		| sed 's/  / /g' | sed 's/\://g' > ./sntsls_
		
		) | $yad --progress --progress-text=" " \
		--width=200 --height=20 --geometry=200x20-2-2 \
		--pulsate --percentage="5" --on-top \
		--undecorated --auto-close \
		--skip-taskbar --no-buttons
	else
		(
		echo "3"
		echo "# " ;
		echo "$prdt" | sed 's/\\n/./g' | sed 's/\./\n/g' \
		| sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//' \
		| sed 's/  / /g' | sed 's/\://g' > ./sntsls_
		
		) | $yad --progress --progress-text=" " \
		--width=200 --height=20 --geometry=200x20-2-2 \
		--pulsate --percentage="5" --on-top \
		--undecorated --auto-close \
		--skip-taskbar --no-buttons
	fi
		while read sntnc
		do
			if [ $(echo "$sntnc" | wc -c) -ge 180 ]; then
				less="$(echo "$sntnc" | sed 's/\,/\n/g')"
				n=1
				while [ $n -le $(echo "$less" | wc -l) ]; do
					sn=$(echo "$less" | sed -n "$n"p)
					echo "$sn" >> ./sntsls
					let n++
				done
			else
				echo "$sntnc" >> ./sntsls
			fi
		done < ./sntsls_
		rm -f ./sntsls_
		
		[[ $(echo "$tpe" | wc -c) -gt 40 ]] && tcnm="${tpe:0:40}..." || tcnm="$tpe"
		
		left=$((50 - $ns))
		info=$(echo "$remain  <b>"$left"</b>  $sentences")

		if [ $ns -ge 45 ]; then
			info=$(echo "$remain  <b>"$left"</b>  $sentences $tcnm")
		elif [ $ns -ge 49 ]; then
			info=$(echo "$remain  <b>"$left"</b>  $sentence $tcnm")
		fi
		
		if [ -z "$(cat ./sntsls)" ]; then
			echo "  $gettext_err1 " | \
			$yad --text-info --center --wrap \
			--name=idiomind --class=idiomind --window-icon=idiomind \
			--text=" " --sticky --width=$wth --height=$eht \
			--borders=3 --button=Ok:0 --title="$selector"
			rm -fr $lckpr $DT_r $slt & exit 1
		
		else
			slt=$(mktemp $DT/slt.XXXX.x)
			cat ./sntsls | awk '{print "FALSE\n"$0}' | \
			$yad --name=idiomind --window-icon=idiomind \
			--dclick-action='/usr/share/idiomind/add.sh prc' --sticky \
			--list --checklist --class=idiomind --center \
			--text="<b>  $te</b>\\n<sub> $info</sub>" \
			--width=$wth --print-all --height=$eht --borders=3 \
			--button="$cancel":1 \
			--button="$arrange":2 \
			--button="$to_new_topic":'/usr/share/idiomind/add.sh n_t' \
			--button=gtk-save:0 --title="$tpe" \
			--column="$(cat ./sntsls | wc -l)" --column="$sentences" > $slt
				ret=$?
		fi
				if [ $ret -eq 2 ]; then
					rm -f $lckpr "$slt" &
					w=`cat ./sntsls | awk '{print "\n\n\n"$0}' | \
					$yad --text-info --editable --window-icon=idiomind \
					--name=idiomind --wrap --margins=60 --class=idiomind \
					--sticky --fontname=vendana --on-top --center \
					--skip-taskbar --width=$wth \
					--height=$eht --borders=3 \
					--button=gtk-ok:0 --title="$tpe"`
						ret=$?
						if [ $ret -eq 0 ]; then

							$nspr "$w" $DT_r "$tpe" &
							exit 1
						else
							rm -fr $lckpr $DT_r $slt & exit 1
						fi
				
				elif [ $ret -eq 0 ]; then
				
					source /usr/share/idiomind/ifs/c.conf
					list=$(cat "$slt" | sed 's/|//g')
					n=1
					while [ $n -le $(cat "$slt" | wc -l) ]; do
						chkst=$(echo "$list" |sed -n "$n"p)
						if echo "$chkst" | grep "TRUE"; then
							echo "$chkst" | sed 's/TRUE//g' >> slts
						fi
						let n++
					done
					
					rm -f $slt
					
					curl -v www.google.com 2>&1 | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
					$yad --window-icon=idiomind --on-top \
					--image=info --name=idiomind \
					--text="<b> $connection_err  \\n  </b>" \
					--image-on-top --center --fixed --sticky \
					--width=220 --height=150 \
					--skip-taskbar --title=Idiomind \
					--button="  Ok  ":0
					>&2; exit 1;}
					
					cd $DT_r
					> ./wlog
					> ./slog
					
					#-----------------------------------oraciones
					{
					echo "5"
					echo "# $pros... " ;
					[ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ] && c=c || c=w
					lns=$(cat ./slts ./wrds | wc -l)
					n=1
					while [ $n -le $(cat slts | head -50 | wc -l) ]; do
						sntc=$(sed -n "$n"p slts)
						if [ $(echo "$sntc" | wc -$c) = 1 ]; then
							if [ $(cat "$DC_tlt"/cnfg3 | wc -l) -ge 50 ]; then
								echo "
$sntc" >> ./wlog
						
							else
								result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lgt" --data-urlencode text="$sntc" https://translate.google.com)
								encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
								iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 > ./trgt
								trgt=$(cat ./trgt)
								result=$(curl -s -i --user-agent "" -d "sl=$lgt" -d "tl=$lgs" --data-urlencode text="$trgt" https://translate.google.com)
								encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
								srce=$(iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8)

								wget -q -U Mozilla -O $DT_r/$trgt.mp3 "https://translate.google.com/translate_tts?ie=UTF-8&tl=$lgt&q=$trgt"
								eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt}IWI1I0I" -a "IWI2I0I${srce}IWI2I0I" "$trgt".mp3

								mv -f "$trgt".mp3 "$DM_tlt/words/$trgt".mp3
								echo "$trgt" >> addw
								
								$DS/mngr.sh inx W "$trgt" "$tpe"
							fi
						
						elif [ $(echo "$sntc" | wc -$c) -ge 1 ]; then
							
							if [ $(cat "$DC_tlt"/cnfg4 | wc -l) -ge 50 ]; then
								echo "
$sntc" >> ./slog
						
							else
								if [ $(echo "$sntc" | wc -c) -ge 180 ]; then
									echo "
$sntc" >> ./slog
							
								else
									txt=$(echo "$sntc" | sed ':a;N;$!ba;s/\n/ /g' | sed 's/"//g' | sed 's/“//g' \
									| sed 's/”//g' | sed "s/’/'/g" | sed 's/^[ \t]*//;s/[ \t]*$//')
									result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lgt" --data-urlencode text="$txt" https://translate.google.com)
									encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
									iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 > ./trgt
									
									sed -i ':a;N;$!ba;s/\n/ /g' ./trgt
									trgt=$(cat ./trgt | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
									sed -i 's/  / /g' ./trgt
									sed -i 's/  / /g' ./trgt
									
									if [ $(cat ./trgt | wc -c) -ge 73 ]; then
										nme="$(cat ./trgt | cut -c 1-70 | sed 's/[ \t]*$//' | \
										sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')..."
									else
										nme=$(cat ./trgt | sed 's/[ \t]*$//' | \
										sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
									fi
								
									result=$(curl -s -i --user-agent "" -d "sl=$lgt" -d "tl=$lgs" --data-urlencode text="$trgt" https://translate.google.com)
									encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
									srce=$(iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 | sed ':a;N;$!ba;s/\n/ /g')
									
									if sed -n 1p $DC_s/cnfg3 | grep TRUE; then
										sed -i 's/,/ /g' ./trgt
										sed -i "s/'/ /g" ./trgt
										sed -i 's/’/ /g' ./trgt
										xargs -n10 < ./trgt > ./temp
										SRC1=$(sed -n 1p ./temp)
										SRC2=$(sed -n 2p ./temp)
										SRC3=$(sed -n 3p ./temp)
										SRC4=$(sed -n 4p ./temp)
										
										if [ -n "$SRC1" ]; then
											wget -q -U Mozilla -O $DT_r/TMP1.mp3 "https://translate.google.com/translate_tts?ie=UTF-8&tl=$lgt&q=$SRC1"
										fi
										if [ -n "$SRC2" ]; then
											wget -q -U Mozilla -O $DT_r/TMP2.mp3 "https://translate.google.com/translate_tts?ie=UTF-8&tl=$lgt&q=$SRC2"
										fi
										if [ -n "$SRC3" ]; then
											wget -q -U Mozilla -O $DT_r/TMP3.mp3 "https://translate.google.com/translate_tts?ie=UTF-8&tl=$lgt&q=$SRC3"
										fi
										if [ -n "$SRC4" ]; then
											wget -q -U Mozilla -O $DT_r/TMP4.mp3 "https://translate.google.com/translate_tts?ie=UTF-8&tl=$lgt&q=$SRC4"
										fi
										
										cat TMP1.mp3 TMP2.mp3 TMP3.mp3 TMP4.mp3 > "./$nme.mp3"
										mv -f "./$nme.mp3" "$DM_tlt/$nme.mp3"
										
									else
										vs=$(sed -n 7p $DC_s/cnfg1)
										if [ -n "$vs" ]; then
											if [ "$vs" = 'festival' ] || [ "$vs" = 'text2wave' ]; then
												lg=$(echo $lgtl | awk '{print tolower($0)}')

												if ([ $lg = "english" ] || [ $lg = "spanish" ] || [ $lg = "russian" ]); then
													echo "$trgt" | text2wave -o $DT_r/s.wav
													sox $DT_r/s.wav "$DM_tlt/$nme.mp3"
												else
													$yad --image=error --button=gtk-ok:1 \
													--text=" <b>$festival_err $lgtl</b> " \
													--on-top --skip-taskbar & exit 1
												fi
											else
												cd $DT_r
												echo "$trgt" | $vs
												if [ -f *.mp3 ]; then
													mv -f *.mp3 "$DM_tlt/$nme.mp3"
												elif [ -f *.wav ]; then
													sox *.wav "$DM_tlt/$nme.mp3"
												fi
											fi
										else
											lg=$(echo $lgtl | awk '{print tolower($0)}')
											if [ $lg = chinese ]; then
												lg=Mandarin
											elif [ $lg = japanese ]; then
												$yad --image=error --button=gtk-ok:1 \
												--text=" <b>$espeak_err</b> " \
												--on-top --skip-taskbar & exit 1
											fi
											espeak "$trgt" -v $lg -k 1 -p 65 -a 80 -s 120 -w $DT_r/s.wav
											sox $DT_r/s.wav "$DM_tlt/$nme.mp3"
										fi
									fi

									eyeD3 --set-encoding=utf8 -t ISI1I0I"$trgt"ISI1I0I -a ISI2I0I"$srce"ISI2I0I "$DM_tlt/$nme.mp3"
									
									echo "$nme" >> adds
									$DS/mngr.sh inx S "$nme" "$tpe"
									
									(
										r=$(echo $(($RANDOM%1000)))
										> twrd_$r
										> swrd_$r
										if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ]; then
											vrbl="$srce"; lg=$lgt; aw=$DT/swrd_$r; bw=$DT/twrd_$r
										else
											vrbl="$trgt"; lg=$lgs; aw=$DT/twrd_$r; bw=$DT/swrd_$r
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
										
										> A_$r
										> B_$r
										> C_$r
										sed -i 's/\. /\n/g' $bw
										sed -i 's/\. /\n/g' $aw
										snmk=$(echo "$trgt"  | sed 's/ /\n/g')
										n=1
										while [ $n -le $(echo "$snmk" | wc -l) ]; do
											grmrk=$(echo "$snmk" | sed -n "$n"p)
											chck=$(echo "$snmk" | sed -n "$n"p | awk '{print tolower($0)}' \
											| sed 's/,//g' | sed 's/\.//g')
											if echo "$lnns" | grep -Fxq $chck; then
												echo "$grmrk" >> C_$r
											elif echo "$lvbr" | grep -Fxq $chck; then
												echo "<span color='#D14D8B'>$grmrk</span>" >> C_$r
											elif echo "$lpre" | grep -Fxq $chck; then
												echo "<span color='#E08434'>$grmrk</span>" >> C_$r
											elif echo "$ladv" | grep -Fxq $chck; then
												echo "<span color='#9C68BD'>$grmrk</span>" >> C_$r
											elif echo "$lprn" | grep -Fxq $chck; then
												echo "<span color='#5473B8'>$grmrk</span>" >> C_$r
											elif echo "$ladj" | grep -Fxq $chck; then
												echo "<span color='#368F68'>$grmrk</span>" >> C_$r
											else
												echo "$grmrk" >> C_$r
											fi
											let n++
										done
										
										if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt = ru ]; then
											n=1
											while [ $n -le "$(cat $aw | wc -l)" ]; do
												s=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
												t=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
												echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A_$r
												echo "$t"_"$s""" >> B_$r
												let n++
											done
										else
											n=1
											while [ $n -le "$(cat $aw | wc -l)" ]; do
												t=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
												s=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
												echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A_$r
												echo "$t"_"$s""" >> B_$r
												let n++
											done
										fi
										
										grmrk=$(cat C_$r | sed ':a;N;$!ba;s/\n/ /g')
										lwrds=$(cat A_$r)
										pwrds=$(cat B_$r | tr '\n' '_')
										eyeD3 --set-encoding=utf8 -A IWI3I0I"$lwrds"IWI3I0IIPWI3I0I"$pwrds"IPWI3I0IIGMI3I0I"$grmrk"IGMI3I0I "$DM_tlt/$nme.mp3"
										
										if [ $lgt = ja ] || [ $lgt = zh-cn ] || [ $lgt =ru ]; then
											n=1
											while [ $n -le $(cat $bw | wc -l) ]; do
												$dct $(sed -n "$n"p $bw) $DT_r
												let n++
											done
										else
											n=1
											while [ $n -le $(cat $aw | wc -l) ]; do
												$dct $(sed -n "$n"p $aw) $DT_r
												let n++
											done
										fi
										
										echo "__" >> x
										
									) &
									
									rm -f "$nme".mp3 TMP1.mp3 TMP2.mp3 TMP3.mp3 TMP4.mp3 
								fi
							fi
						fi
						
						prg=$((100*$n/$lns-1))
						echo "$prg"
						echo "# ${sntc:0:35}... " ;
						
						let n++
					done
					
					#----------------------------------palabras
					n=1
					while [ $n -le $(cat wrds | head -50 | wc -l) ]; do
					
						exmp=$(sed -n "$n"p wrdsls)
						itm=$(sed -n "$n"p wrds | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
						
						if [ $(echo "$exmp" | wc -c) -ge 73 ]; then
							nme="$(echo "$exmp" | sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g' | cut -c 1-70)..."
						else
							nme=$(echo "$exmp" | "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
						fi
					
						if [ $(cat "$DC_tlt"/cnfg3 | wc -l) -ge 50 ]; then
							echo "
$itm" >> ./wlog
					
						else
							result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lgs" --data-urlencode text="$itm" https://translate.google.com)
							encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
							srce=$(iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8)

							$dct "$itm" $DT_r swrd
							
							if [ -f "$itm".mp3 ]; then
								mv -f "$DT_r/$itm.mp3" "$DM_tlt/words/$itm.mp3"
								eyeD3 --set-encoding=utf8 -t "IWI1I0I${itm}IWI1I0I" -a "IWI2I0I${srce}IWI2I0I" -A "IWI3I0I${exmp}IWI3I0I" \
								"$DM_tlt/words/$itm.mp3"
							else
								cp -f $DS/ifs/w "$DM_tlt/words/$itm.mp3"
								eyeD3 --set-encoding=utf8 -t "IWI1I0I${itm}IWI1I0I" -a "IWI2I0I${srce}IWI2I0I" -A "IWI3I0I${exmp}IWI3I0I" \
								"$DM_tlt/words/$itm.mp3"
							fi
							echo "$itm" >> addw
							$DS/mngr.sh inx  W "$itm" "$tpe" "$nme"
						fi
						
						nn=$(($n+$(cat ./slts | wc -l)-1))
						prg=$((100*$nn/$lns))
						echo "$prg"
						echo "# ${itm:0:35}... " ;
						
						let n++
					done
					} | $yad --progress --progress-text=" " \
					--width=250 --height=20 --geometry=250x20-2-2 \
					--undecorated --auto-close --on-top \
					--skip-taskbar --no-buttons
					
					cd $DT_r
					
					if [ -f ./wlog ]; then
						wadds=" $(($(cat ./addw | wc -l) - $(cat ./wlog | sed '/^$/d' | wc -l)))"
						W=" $words"
						if [ $(echo $wadds) = 1 ]; then
							W=" $word"
						fi
					else
						wadds=" $(cat ./addw | wc -l)"
						W=" $words"
						if [ $(echo $wadds) = 1 ]; then
							wadds=" $(cat ./addw | wc -l)"
							W=" $word"
						fi
					fi
					if [ -f ./slog ]; then
						sadds=" $(($(cat ./adds | wc -l) - $(cat ./slog | sed '/^$/d' | wc -l)))"
						S=" $sentences"
						if [ $(echo $sadds) = 1 ]; then
							S=" $sentence"
						fi
					else
						sadds=" $(cat ./adds | wc -l) $sentences"
						S=" $sentences"
						if [ $(echo $sadds) = 1 ]; then
							S=" $sentence"
						fi
					fi
					
					logs=$(cat ./slog ./wlog)
					adds=$(cat ./adds ./addw | wc -l)
					
					source $DS/ifs/trans/$lgs/add.conf
					
					if [ $adds -ge 1 ]; then
						notify-send -i idiomind "$tpe" "$is_added\n$sadds$S$wadds$W" -t 2000 &
						echo "aitm.$adds.aitm" >> \
						$DC/addons/stats/.log
					fi
					
					if [ $(cat ./slog ./wlog | wc -l) -ge 1 ]; then
						echo "$logs" | $yad --name=idiomind --class=idiomind \
						--center --wrap --text-info --editable --skip-taskbar \
						--width=350 --height=300 --on-top --margins=4 \
						--fontname=vendana --window-icon=idiomind \
						--button=Ok:0 --borders=0 --title="$tpe" \
						--text=" <b>  ! </b><small><small> $items_rest</small></small>" \
						--field=":lbl" "" >/dev/null 2>&1
					fi
					
					if  [ $(cat ./slog ./wlog | wc -l) -ge 1 ]; then
						rm=$(($(cat ./addw ./adds | wc -l) - $(cat ./slog ./wlog | sed '/^$/d' | wc -l)))
					else
						rm=$(cat ./addw ./adds | wc -l)
					fi
					
					n=1
					while [ $n -le 20 ]; do
						 sleep 5
						 if ([ $(cat ./x | wc -l) = $rm ] || [ $n = 20 ]); then
							rm -fr $DT_r $lckpr & break & exit 1
						 fi
						let n++
					done
					
				else
					rm -rf $lckpr $DT_r $slt & exit 1
				fi
				
elif [ $1 = img ]; then
	int="$(sed -n 22p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	btn="$(sed -n 21p $DS/ifs/trans/$lgs/$lgs | sed 's/|/\n/g')"
	cd $DT
	wrd="$2"
	echo '<html>
<head>
<meta http-equiv="Refresh" content="0;url=https://www.google.com/search?q=XxXx&tbm=isch">
</head>
<body>
<p>Search images for '"'XxXx'"'...</p>
</body>
</html>' > html

	sed -i 's/XxXx/'"$wrd"'/g' html
	mv -f html s.html
	chmod +x s.html
	ICON=$DS/icon/nw.png
	btnn=$(echo --button=$add_image:3)
	
	if [ "$3" = w ]; then
		
		if [ ! -f "$DT/$wrd.*" ]; then
			file="$DM_tlt/words/$wrd.mp3"
		fi
		
		if [ -f "$DM_tlt/words/images/$wrd.jpg" ]; then
			ICON="--image=$DM_tlt/words/images/$wrd.jpg"
			btnn=$(echo --button=$change:3)
			btn2=$(echo --button=$delete:2)
		else
			txt="--text=<small>$images_for  <a href='file://$DT/s.html'>$wrd</a></small>"
		fi
		
		$yad --form --align=center --center \
		--width=340 --text-align=center --height=280 \
		--on-top --skip-taskbar --image-on-top "$txt">/dev/null 2>&1 \
		"$btnn" --window-icon=idiomind --borders=0 \
		--title=Image "$ICON" "$btn2" \
		--button=gtk-close:1
			ret=$? >/dev/null 2>&1
			
			if [ $ret -eq 3 ]; then
			
				rm -f *.l
				scrot -s --quality 70 "$wrd.temp.jpeg"
				/usr/bin/convert -scale 100x90! -border 0.5 \
				-bordercolor '#9A9A9A' "$wrd.temp.jpeg" "$wrd"_temp.jpeg
				/usr/bin/convert -scale 360x240! "$wrd.temp.jpeg" "$DM_tlt/words/images/$wrd.jpg"
				eyeD3 --remove-images "$file" >/dev/null 2>&1
				eyeD3 --add-image "$wrd"_temp.jpeg:ILLUSTRATION "$file" >/dev/null 2>&1
				rm -f *.jpeg
				$DS/add.sh img "$wrd" w
				
			elif [ $ret -eq 2 ]; then
			
				eyeD3 --remove-image "$file" >/dev/null 2>&1
				rm -f "$DM_tlt/words/images/$wrd.jpg"
				rm -f *.jpeg s.html
				
			else
				rm -f *.jpeg s.html
			fi
			
	elif [ "$3" = s ]; then
	
		if [ ! -f "$DT/$wrd.*" ]; then
			file="$DM_tlt/$wrd.mp3"
		fi
		
		btnn=$(echo "--button=$add_image:3")
		eyeD3 --write-images=$DT "$file" >/dev/null 2>&1
		
		if [ -f "$DT/ILLUSTRATION".jpeg ]; then
			mv -f "$DT/ILLUSTRATION".jpeg "$DT/imgsw".jpeg
			ICON="--image=$DT/imgsw.jpeg"
			btnn=$(echo --button=$change:3)
			btn2=$(echo --button=$delete:2)
			
		else
			txt="--text=<small>$search_images \\n<a href='file://$DT/s.html'>$wrd</a></small>"
		fi
		
		$yad --form --text-align=center \
		--center --width=470 --height=280 \
		--on-top --skip-taskbar --image-on-top \
		"$txt" "$btnn" --window-icon=idiomind --borders=0 \
		--title="Image" "$ICON" "$btn2" --button=gtk-close:1
			ret=$? >/dev/null 2>&1
				
			if [ $ret -eq 3 ]; then
			
				rm -f $DT/*.l
				scrot -s --quality 70 "$wrd.temp.jpeg"
				/usr/bin/convert -scale 450x270! -border 0.5 \
				-bordercolor '#9A9A9A' "$wrd.temp.jpeg" "$wrd"_temp.jpeg
				eyeD3 --remove-image "$file" >/dev/null 2>&1
				eyeD3 --add-image "$wrd"_temp.jpeg:ILLUSTRATION "$file" >/dev/null 2>&1 &&
				rm -f *.jpeg
				echo "aimg.$tpc.aimg" >> \
				$DC/addons/stats/.log &
				$DS/add.sh img "$wrd" s
				
			elif [ $ret -eq 2 ]; then
				eyeD3 --remove-images "$file" >/dev/null 2>&1
				rm -f s.html *.jpeg
			else
				rm -f s.html *.jpeg
			fi
	fi
fi
