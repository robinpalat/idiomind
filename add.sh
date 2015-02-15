#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/add.conf
source $DS/ifs/mods/cmns.sh
include $DS/ifs/mods/add

if [ $1 = new_topic ]; then

	info2=$(cat $DC_tl/.cfg.1 | wc -l)
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
		
		jlbi=$(dlg_form_0 "$rename" "$nmt")
		ret=$(echo "$?")
		jlb="$(clean_2 "$jlbi")"
		snm=$(cat $DC_tl/.cfg.1 | grep -Fxo "$jlb" | wc -l)
		
		if [ $snm -ge 1 ]; then
		
			jlb=$(echo ""$jlb" $snm")
			dlg_msg_6 " <b>$name_eq   </b>\\n $name_eq2  <b>$jlb</b>   \\n"
			ret=$(echo "$?")

				if [ "$ret" -eq 1 ]; then
					exit 1
				fi
		else
			jlb=$(echo "$jlb")
		fi
		
		if [ -z "$jlb" ]; then
			exit 1
		else
			mv -f "$DC_tl/$tpc/.cfg.11" "$DT/.cfg.11"
			mv -f "$DM_tl/$tpc" "$DM_tl/$jlb"
			mv -f "$DC_tl/$tpc" "$DC_tl/$jlb"
			mv -f "$DT/.cfg.11" "$DC_tl/$jlb/.cfg.11"
			
			if grep -Fxo "$tpc" $DC_tl/.cfg.3; then
				echo "$jlb" >> $DC_tl/.cfg.3
			else
				echo "$jlb" >> $DC_tl/.cfg.2
			fi
			
			grep -v -x -F "$tpc" $DC_tl/.cfg.2 > $DC_tl/.cfg.2.tmp
			sed '/^$/d' $DC_tl/.cfg.2.tmp > $DC_tl/.cfg.2
			grep -v -x -F "$tpc" $DC_tl/.cfg.1 > $DC_tl/.cfg.1.tmp
			sed '/^$/d' $DC_tl/.cfg.1.tmp > $DC_tl/.cfg.1
			grep -v -x -F "$tpc" $DC_tl/.cfg.3 > $DC_tl/.cfg.3.tmp
			sed '/^$/d' $DC_tl/.cfg.3.tmp > $DC_tl/.cfg.3
			rm $DC_tl/.*.tmp

			[[ -d "$DC_tl/$tpc" ]] && rm -r "$DC_tl/$tpc"
			[[ -d "$DM_tl/$tpc" ]] && rm -r "$DM_tl/$tpc"
			
			$DS/mngr.sh mkmn
			"$DC_tl/$jlb/tpc.sh" & exit 1
		fi
		
	else
		
		[[ -z "$2" ]] && nmt="" || nmt="$2"
		
		if [ $info2 -ge 80 ]; then
			rm "$DM_tl/.rn"
			msg "$topics_max" info &&
			killall add.sh & exit 1
		fi
		jlbi=$(dlg_form_0 "$new_topic" "$nmt")
		ret=$(echo "$?")

			jlb="$(clean_2 "$jlbi")"
			sfname=$(cat $DC_tl/.cfg.1 | grep -Fxo "$jlb" | wc -l)
			
			if [ "$sfname" -ge 1 ]; then
			
				jlb="$jlb $sfname"
				dlg_msg_6 " <b>$name_eq   </b>\\n $name_eq2  <b>$jlb</b>   \\n"
				ret=$(echo "$?")
				
				[[ "$ret" -eq 1 ]] && rm "$DM_tl"/.rn && exit 1
				
			else
				jlb="$jlb"
			fi
			
			if [[ -z "$jlb" ]]; then
				rm "$DM_tl/.rn" && exit 1
				
			else
				mkdir "$DC_tl/$jlb"
				cp -f "$DS/default/tpc.sh" "$DC_tl/$jlb/tpc.sh"
				chmod +x "$DC_tl/$jlb/tpc.sh"
				[[ -f $DT/ntpc ]] && rm -f $DT/ntpc
				
				echo "$jlb" >> $DC_tl/.cfg.2
				"$DC_tl/$jlb/tpc.sh"
				$DS/mngr.sh mkmn
			fi
	fi
	exit 1
	
elif [ $1 = new_items ]; then


	if [ "$(cat $DC_tl/.cfg.1 | grep -v 'Feeds' | wc -l)" -lt 1 ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		source $DS/ifs/trans/$lgs/topics_lists.conf
		$DS/chng.sh "$no_topic" & exit 1
	fi
	
	#c=$(echo $(($RANDOM%1000)))
	[[ -z "$4" ]] && txt="$(xclip -selection primary -o \
	| sed ':a;N;$!ba;s/\n/ /g' | sed '/^$/d')" || txt="$4"

	if [[ "$3" = 2 ]]; then
		DT_r="$2"; cd $DT_r
		[[ -n "$5" ]] && srce="$5" || srce=""
	else
		DT_r=$(mktemp -d $DT/XXXXXX); cd $DT_r
	fi
	
	[[ -f $DT_r/ico.jpg ]] && img="--image=$DT_r/ico.jpg" \
	|| img="--image=$DS/images/nw.png"
	
	if [[ -z "$tpe" ]]; then
		tpcs=$(cat "$DC_tl/.cfg.2" | cut -c 1-40 \
		| tr "\\n" '!' | sed 's/\!*$//g')
	else
		tpcs=$(cat "$DC_tl/.cfg.2" | egrep -v "$tpe" | cut -c 1-40 \
		| tr "\\n" '!' | sed 's/\!*$//g')
	fi
	[ -n "$tpcs" ] && e='!'
	ttle="${tpe:0:50}"
	[[ "$tpe" != "$tpc" ]] && topic="$topic <b>*</b>" || topic="$topic"
	
	[[ ! -f $DC_s/cfg.3 ]] && echo 'FALSE' > $DC_s/cfg.3
	
	if sed -n 1p $DC_s/cfg.3 | grep 'TRUE'; then
	
		lzgpr="$(dlg_form_1)"
		
	elif sed -n 1p $DC_s/cfg.3 | grep 'FALSE'; then
	
		lzgpr="$(dlg_form_2)"
	fi
	
	ret=$(echo "$?")
	trgt=$(echo "$lzgpr" | head -n -1 | sed -n 1p | sed 's/^\s*./\U&\E/g')
	srce=$(echo "$lzgpr" | sed -n 2p | sed 's/^\s*./\U&\E/g')
	chk=$(echo "$lzgpr" | tail -1)
	tpe=$(cat "$DC_tl/.cfg.1" | grep "$chk")
	
		if [[ $ret -eq 3 ]]; then
		
			cd $DT_r; set_image_1
			$DS/add.sh new_items $DT_r 2 "$trgt" "$srce" && exit
		
		elif [[ $ret -eq 2 ]]; then
		
			$DS/ifs/tls.sh add_audio $DT_r
			$DS/add.sh new_items $DT_r 2 "$trgt" "$srce" && exit
		
		elif [[ $ret -eq 0 ]]; then
		
			if [ -z "$chk" ]; then
				[[ -d $DT_r ]] && rm -fr $DT_r
				msg "$topic_err\n" info & exit 1
			fi
		
			if [ -z "$trgt" ]; then
				[[ -d $DT_r ]] && rm -fr $DT_r
				exit 1
			fi

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
					slt=`dlg_radiolist_1 "$tpe"`
					
					if [ -z "$(echo "$slt" | sed -n 2p)" ]; then
						killall add.sh & exit 1
					fi
					tpe=$(echo "$slt" | sed -n 2p)
				fi
			fi
			if [[ "$chk" = "$new *" ]]; then
				$DS/add.sh new_topic
			else
				echo "$tpe" > $DC_s/cfg.7
				echo "$tpe" > $DC_s/cfg.6
			fi
			
			if [ "$(echo "$trgt")" = I ]; then
				$DS/add.sh process image $DT_r & exit 1

			elif [[ $(printf "$trgt" | wc -c) = 1 ]]; then
				$DS/add.sh process ${trgt:0:2} $DT_r & exit 1

			elif [[ "$(echo ${trgt:0:4})" = 'Http' ]]; then
				$DS/add.sh process "$trgt" $DT_r & exit 1
			
			elif [ $(echo "$trgt" | wc -c) -gt 150 ]; then
				$DS/add.sh process "$trgt" $DT_r & exit 1

			elif ([ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]); then
			
				if sed -n 1p $DC_s/cfg.3 | grep FALSE; then
					if [ -z "$srce" ]; then
						[[ -d $DT_r ]] && rm -fr $DT_r
						msg "$no_text $lgsl." info & exit 1
					elif [ -z "$trgt" ]; then
						[[ -d $DT_r ]] && rm -fr $DT_r
						msg "$no_text $lgtl." info & exit 1
					fi
				fi

				srce=$(translate "$trgt" auto $lgs)
				
				if [ $(echo "$srce" | wc -w) = 1 ]; then
					$DS/add.sh new_word "$trgt" $DT_r "$srce" & exit 1
					
				elif [ $(echo "$srce" | wc -w) -ge 1 -a $(echo "$srce" | wc -c) -le 180 ]; then
					$DS/add.sh new_sentence "$trgt" $DT_r "$srce" & exit 1
				fi
			elif ([ $lgt != ja ] || [ $lgt != 'zh-cn' ] || [ $lgt != ru ]); then
			
				if sed -n 1p $DC_s/cfg.3 | grep FALSE; then
					if [ -z "$srce" ]; then
						[[ -d $DT_r ]] && rm -fr $DT_r
						msg "$no_text $lgsl." info & exit 1
						
					elif [ -z "$trgt" ]; then
						[[ -d $DT_r ]] && rm -fr $DT_r
						msg "$no_text $lgtl." info & exit 1
					fi
				fi
		    
				if [ $(echo "$trgt" | wc -w) = 1 ]; then
					$DS/add.sh new_word "$trgt" $DT_r "$srce" & exit 1
					
				elif [ $(echo "$trgt" | wc -w) -ge 1 -a $(echo "$trgt" | wc -c) -le 180 ]; then
					$DS/add.sh new_sentence "$trgt" $DT_r "$srce" & exit 1
					
				fi
			fi
		else
			[[ -d $DT_r ]] && rm -fr $DT_r
			exit 1
		fi
		
elif [ $1 = new_sentence ]; then
		
	DT_r="$3"
	source $DS/default/dicts/$lgt
	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	icnn=idiomind

	if [ $(cat "$DC_tlt/cfg.4" | wc -l) -ge 50 ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$tpe  \\n$sentences_max" info & exit
	fi
	if [ -z "$tpe" ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$topic_err\n" info & exit 1
	fi
	
	# --------------------------------------------------------------
	if sed -n 1p $DC_s/cfg.3 | grep TRUE; then
	
		internet
	
		cd $DT_r
		trgt=$(translate "$(clean_1 "$2")" auto $lgt | sed ':a;N;$!ba;s/\n/ /g')
		srce=$(translate "$trgt" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')
		echo "$trgt" > trgt
		fname="$(nmfile "$trgt")"
		
		if [ ! -f $DT_r/audtm.mp3 ]; then
		
			tts ./trgt $lgt $DT_r "$DM_tlt/$fname.mp3"
			
		else
			cp -f $DT_r/audtm.mp3 "$DM_tlt/$fname.mp3"
		fi
		
	else # ---------------------
		if [ -z "$4" ]; then
			[[ -d $DT_r ]] && rm -fr $DT_r
			msg "$no_text$lgsl." info & exit
		elif [ -z "$2" ]; then
			[[ -d $DT_r ]] && rm -fr $DT_r
			msg "$no_text$lgtl." info & exit
		fi
		
		trgt=$(echo "$(clean_1 "$2")" | sed ':a;N;$!ba;s/\n/ /g')
		srce=$(echo "$(clean_1 "$4")" | sed ':a;N;$!ba;s/\n/ /g')
		fname="$(nmfile "$trgt")"
		
		if [ -f $DT_r/audtm.mp3 ]; then
		
			mv -f $DT_r/audtm.mp3 "$DM_tlt/$fname.mp3"
			
		else
			voice "$trgt" $DT_r "$DM_tlt/$fname.mp3"
		fi
	fi
	# --------------------------------------------------------------
	
	if ( [ -z $(file -ib "$DM_tlt/$fname.mp3" | grep -o 'binary') ] \
	|| [ ! -f "$DM_tlt/$fname.mp3" ] || [ -z "$trgt" ] || [ -z "$srce" ] ); then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$error1" dialog-warning & exit 1
	fi
	
	add_tags_1 S "$trgt" "$srce" "$DM_tlt/$fname.mp3"

	if [ -f img.jpg ]; then
		set_image_2 "$DM_tlt/$fname.mp3"
		icnn=img.jpg
	fi
	
	cd $DT_r
	r=$(echo $(($RANDOM%1000)))
	clean_3 $DT_r $r
	translate "$(cat $aw | sed '/^$/d')" auto $lg | sed 's/,//g' \
	| sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw
	check_grammar_1 $DT_r $r
	list_words $DT_r $r
	grmrk=$(cat g.$r | sed ':a;N;$!ba;s/\n/ /g')
	lwrds=$(cat A.$r)
	pwrds=$(cat B.$r | tr '\n' '_')
	
	if ([ -z "$grmrk" ] || [ -z "$lwrds" ] || [ -z "$pwrds" ]); then
	    rm "$DM_tlt/$fname.mp3"
	    msg "$error1" dialog-warning 
	    [[ -d $DT_r ]] && rm -fr $DT_r & exit 1
	    
	fi
	
	add_tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$fname.mp3"
	notify-send -i "$icnn" "$trgt" "$srce\\n($tpe)" -t 10000
	$DS/mngr.sh index sentence "$trgt" "$tpe"
	
	(
	if [ $(sed -n 4p $DC_s/cfg.1) = TRUE ]; then
	$DS/add.sh sentence_list_words "$DM_tlt/$fname.mp3" "$trgt" "$tpe"
	fi
	) &

	fetch_audio $aw $bw $DT_r $DM_tls
	
	[[ -d $DT_r ]] && rm -fr $DT_r
	printf "aitm.1.aitm\n" >> \
	$DC/addons/stats/.log
	exit 1
	

elif [ $1 = new_word ]; then

	trgt="$2"
	srce="$4"
	source $DS/default/dicts/$lgt
	icnn=idiomind
	DT_r="$3"
	cd $DT_r
	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	
	if [ $(cat "$DC_tlt/cfg.3" | wc -l) -ge 50 ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$tpe    \\n$words_max" info & exit 0
	fi
	if [ -z "$tpe" ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$topic_err\n" info & exit 1
	fi
	
	internet
	# --------------------------------------------------------------
	if sed -n 1p $DC_s/cfg.3 | grep TRUE; then

		trgt="$(translate "$trgt" auto $lgt)"
		srce="$(translate "$trgt" $lgt $lgs)"
		fname="$(nmfile "${trgt^}")"
		
		if [ -f "$DM_tls/${trgt,,}.mp3" ]; then
		
			cp -f "$DM_tls/${trgt,,}.mp3" "$DT_r/${trgt,,}.mp3"
			
		else
			dictt "${trgt,,}" $DT_r
		fi
		
		if [ -f "$DT_r/${trgt,,}.mp3" ]; then

			cp -f "$DT_r/${trgt,,}.mp3" "$DM_tlt/words/$fname.mp3"
			
		else
			voice "$trgt" $DT_r "$DM_tlt/words/$fname.mp3"
		fi
		
	else # -------------------
		if [ -z "$4" ]; then
			[[ -d $DT_r ]] && rm -fr $DT_r
			msg "$no_text$lgsl." info & exit 1
		elif [ -z "$2" ]; then
			[[ -d $DT_r ]] && rm -fr $DT_r
			msg "$no_text$lgtl." info & exit 1
		fi
		
		if [ -f audtm.mp3 ]; then
		
			mv -f audtm.mp3 "$DM_tlt/words/$fname.mp3"
			
		else
			if [ -f "$DM_tls/${trgt,,}.mp3" ]; then
			
				cp -f "$DM_tls/${trgt,,}.mp3" "$DT_r/${trgt,,}.mp3"
				
			else
				dictt "${trgt,,}" $DT_r
			fi
			
			if [ -f "$DT_r/${trgt,,}.mp3" ]; then

				cp -f "$DT_r/${trgt,,}.mp3" "$DM_tlt/words/$fname.mp3"
				
			else
				voice "$trgt" $DT_r "$DM_tlt/words/$fname.mp3"
			fi

		fi
	fi
	# --------------------
	if [ -f img.jpg ]; then
		set_image_3 "$DM_tlt/words/$fname.mp3" "$DM_tlt/words/images/$fname.jpg"
		icnn=img.jpg
	fi
	
	if ( [ -n $(file -ib "$DM_tlt/words/$fname.mp3" | grep -o 'binary') ] \
	&& [ -f "$DM_tlt/words/$fname.mp3" ] && [ -n "$trgt" ] && [ -n "$srce" ] ); then
	
		add_tags_1 W "$trgt" "$srce" "$DM_tlt/words/$fname.mp3"
		nt="$(echo "_$(check_grammar_2 $trgt)" | tr '\n' '_')"
		eyeD3 --set-encoding=utf8 -A IWI3I0I"$nt"IWI3I0I "$DM_tlt/words/$fname.mp3"
		notify-send -i "$icnn" "$trgt" "$srce\\n($tpe)" -t 5000
		$DS/mngr.sh index word "$trgt" "$tpe"
		printf "aitm.1.aitm\n" >> \
		$DC/addons/stats/.log
	
	else
		[ -f "$DM_tlt/words/$fname.mp3" ] && rm "$DM_tlt/words/$fname.mp3"
		msg "$error1" dialog-warning & exit 1
	fi

	#[[ -d $DT_r ]] && rm -fr $DT_r
	rm -f *.jpg
	exit 1
	
elif [ $1 = edit_list_words ]; then

	c="$4"

	if [ "$3" = "F" ]; then

		tpe="$tpc"
		if [ $(cat "$DC_tlt/cfg.3" | wc -l) -ge 50 ]; then
			[[ -d $DT_r ]] && rm -fr $DT_r
			msg "$tpe    \\n$words_max" info & exit
		fi
		if [ -z "$tpe" ]; then
			[[ -d $DT_r ]] && rm -fr $DT_r
			msg "$topic_err\n" info & exit 1
		fi
		
		nw=$(cat "$DC_tlt/cfg.3" | wc -l)
		left=$((50 - $nw))
		info=$(echo " $remain$left$words")
		if [ $nw -ge 45 ]; then
			info=$(echo " $remain$left$words")
		elif [ $nw -ge 49 ]; then
			info=$(echo " $remain$left$word")
		fi

		mkdir $DT/$c; DT_r=$DT/$c; cd $DT_r

		list_words_2 "$2"
		slt=$(mktemp $DT/slt.XXXX.x)
		
		dlg_checklist_1 ./idlst "$info" "$slt"
		ret=$(echo "$?")

			if [ $ret -eq 0 ]; then
				list=$(cat "$slt" | sed 's/|//g')
				n=1
				while [ $n -le "$(cat "$slt" | head -50 | wc -l)" ]; do
					chkst=$(echo "$list" | sed -n "$n"p)
					echo "$chkst" | sed 's/TRUE//g' >> ./slts
					let n++
				done
				rm -f "$slt"
			fi
		
	elif [ "$3" = "S" ]; then
	
		sname="$5"
		DT_r="$DT/$c"
		cd $DT_r
		
		n=1
		while [ $n -le "$(cat ./slts | head -50 | wc -l)" ]; do

				trgt=$(sed -n "$n"p ./slts | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
				fname="$(nmfile "$trgt")"
				
			if [ $(cat "$DC_tlt/cfg.3" | wc -l) -ge 50 ]; then
				echo "$trgt
" > logw
			
			else
				translate "$trgt" auto $lgs > tr."$c"
				srce=$(cat tr."$c")
				
				if [ -f "$DM_tls/${trgt,,}.mp3" ]; then
				
					cp -f "$DM_tls/${trgt,,}.mp3" "$DT_r/${trgt,,}.mp3"
				
				else
					dictt "${trgt,,}" $DT_r
				fi
				
				if [ -f "$DT_r/${trgt,,}.mp3" ]; then

					cp -f "$DT_r/${trgt,,}.mp3" "$DM_tlt/words/$fname.mp3"
				
				else
					voice "$trgt" $DT_r "$DM_tlt/words/$fname.mp3"
				fi
				
				if ( [ -n $(file -ib "$DM_tlt/words/$fname.mp3" | grep -o 'binary') ] \
				&& [ -f "$DM_tlt/words/$fname.mp3" ] && [ -n "$trgt" ] && [ -n "$srce" ] ); then
				
					add_tags_2 W "$trgt" "$srce" "$5" "$DM_tlt/words/$fname.mp3" >/dev/null 2>&1
					$DS/mngr.sh index word "$trgt" "$tpc" "$sname"
				
				else
					printf "\n- $sntc" >> ./logw
					[ -f "$DM_tlt/words/$fname.mp3" ] && rm "$DM_tlt/words/$fname.mp3"
				fi
			fi
			let n++
		done

		printf "aitm.$lns.aitm\n" >> \
		$DC_a/stats/.log &

			if [ -f $DT_r/logw ]; then
				dlg_info_1 "$items_rest"
			fi
			[[ -d $DT_r ]] && rm -fr $DT_r
			rm -f logw $DT/*.$c & exit 1
	fi
	
elif [ $1 = dclik_list_words ]; then

	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	DT_r=$(cat $DT/.n_s_pr)
	cd $DT_r
	echo "$3" > ./lstws
	
	if [ -z "$tpe" ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$topic_err\n" info & exit 1
	fi
	
	nw=$(cat "$DC_tlt/cfg.3" | wc -l)
	
	if [ $(cat "$DC_tlt/cfg.3" | wc -l) -ge 50 ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$tpe    \\n$words_max" info & exit
	fi

	left=$((50 - $nw))
	info=$(echo " $remain$left$words")
	if [ $nw -ge 45 ]; then
		info=$(echo " $remain$left$words")
	elif [ $nw -ge 49 ]; then
		info=$(echo " $remain$left$word")
	fi
	
	if [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
		(
			echo "1"
			echo "# $pros..." ;
			srce="$(translate "$(cat lstws)" $lgtl $lgsl)"
			cd $DT_r
			r=$(echo $(($RANDOM%1000)))
			clean_3 $DT_r $r
			translate "$(cat $aw | sed '/^$/d')" auto $lg | sed 's/,//g' \
			| sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw
			list_words $DT_r $r
			pwrds=$(cat B.$r | tr '\n' '_')
			echo "$pwrds"
			list_words_3 ./lstws "$pwrds"
		) | dlg_progress_1
	
	else
		list_words_3 ./lstws
	fi

	sname="$(cat lstws)"
	slt=$(mktemp $DT/slt.XXXX.x)
	dlg_checklist_1 ./lst " " "$slt"
	ret=$(echo "$?")
	
	if [ $? -eq 0 ]; then
	
			list=$(cat "$slt" | sed 's/|//g')
			n=1
		    while [ $n -le $(cat "$slt" | head -50 | wc -l) ]; do
				chkst=$(echo "$list" |sed -n "$n"p)
				echo "$chkst" | sed 's/TRUE//g' >> ./wrds
				echo "$sname" >> wrdsls
				let n++
		    done
		    rm -f "$slt"
		    
	    elif [ "$ret" -eq 1 ]; then
	    
		rm -f $DT/*."$c"
		[[ -d $DT_r ]] && rm -fr $DT_r
		exit
	    fi
		
	$? >/dev/null 2>&1
	exit 1


elif [ $1 = show_item_for_edit ]; then

	DT_r=$(cat $DT/.n_s_pr)
	cd $DT_r
	dlg_text_info_5 "$3" "$(nmfile "$3")"
	$? >/dev/null 2>&1


elif [ $1 = sentence_list_words ]; then

	DM_tlt="$DM_tl/$4"
	DC_tlt="$DC_tl/$4"
	c=$(echo $(($RANDOM%100)))
	DT_r=$(mktemp -d $DT/XXXXXX)
	cd $DT_r
	
	if [ -z "$4" ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$topic_err\n" info & exit 1
	fi
	
	nw=$(cat "$DC_tlt/cfg.3" | wc -l)
	left=$((50 - $nw))
	if [ "$left" = 0 ]; then
		exit 1
	elif [ $nw -ge 45 ]; then
		info=$(echo " $remain$left$words")
	elif [ $nw -ge 49 ]; then
		info=$(echo " $remain$left$word")
	fi
	
	#fname="$(nmfile "$2")"
	list_words_2 "$2"

	slt=$(mktemp $DT/slt.XXXX.x)
	dlg_checklist_1 ./idlst "$info" "$slt"
	ret=$(echo "$?")
		
		if [ $ret -eq 0 ]; then
		
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
			[[ -d $DT_r ]] && rm -fr $DT_r
			exit 1
		fi

	n=1
	while [ $n -le $(cat ./slts | head -50 | wc -l) ]; do
	
		trgt=$(sed -n "$n"p ./slts | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
		fname="$(nmfile "$trgt")"
		
		if [ $(cat "$DC_tlt/cfg.3" | wc -l) -ge 50 ]; then
			echo "$trgt" >> logw
		else
			translate "$trgt" auto $lgs > tr."$c"
			srce=$(cat ./tr."$c")

			if [ -f "$DM_tls/${trgt,,}.mp3" ]; then
			
				cp -f "$DM_tls/${trgt,,}.mp3" "$DT_r/${trgt,,}.mp3"
				
			else
				dictt "${trgt,,}" $DT_r
			fi
			
			if [ -f "$DT_r/${trgt,,}.mp3" ]; then

				cp -f "$DT_r/${trgt,,}.mp3" "$DM_tlt/words/$fname.mp3"
				
			else
				voice "$trgt" $DT_r "$DM_tlt/words/$fname.mp3"
			fi
			
			if ( [ -n $(file -ib "$DM_tlt/words/$fname.mp3" | grep -o 'binary') ] \
			&& [ -f "$DM_tlt/words/$fname.mp3" ] && [ -n "$trgt" ] && [ -n "$srce" ] ); then
				
				add_tags_2 W "$trgt" "$srce" "$3" "$DM_tlt/words/$fname.mp3" >/dev/null 2>&1
				$DS/mngr.sh index word "$trgt" "$4"
			
			else
				printf "\n- $sntc" >> ./logw
				[ -f "$DM_tlt/words/$fname.mp3" ] && rm "$DM_tlt/words/$fname.mp3"
			fi
		fi
		let n++
	done

	printf "aitm.$lns.aitm\n" >> \
	$DC_a/stats/.log &

	if [ -f  $DT_r/logw ]; then
		logs="$(cat $DT_r/logw)"
		text_r1="$items_rest\n\n$logs"
		dlg_text_info_3 "$text_r1"
	fi
	
	rm -f $DT/*."$c" 
	[[ -d $DT_r ]] && rm -fr $DT_r
	exit 1
	
	
elif [ $1 = process ]; then
	
	source $DS/ifs/trans/$lgs/add.conf
	wth=$(sed -n 3p $DC_s/cfg.18)
	eht=$(sed -n 4p $DC_s/cfg.18)
	ns=$(cat "$DC_tlt"/cfg.4 | wc -l)
	source $DS/default/dicts/$lgt
	nspr='/usr/share/idiomind/add.sh process'
	LNK='http://www.chromium.org/developers/how-tos/api-keys'
	lckpr=$DT/.n_s_pr
	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	DT_r="$3"
	cd "$DT_r"

	if [ -z "$tpe" ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$topic_err\n" info & exit 1
	fi
	if [ $ns -ge 50 ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$tpe    \\n$sentences_max" info
		rm -f ls $lckpr & exit 1
	fi

	if [ -f $lckpr ]; then
	
		dlg_msg_3
		ret=$(echo "$?")

		if [ $ret -eq "3" ]; then
			rm=$(cat $lckpr)
			rm fr $rm $lckpr
			$DS/mngr.sh index R && killall add.sh
		fi
		exit 1
	fi
	
	if [ -n "$2" ]; then
		echo $DT_r > $DT/.n_s_pr
		lckpr=$DT/.n_s_pr
		prdt="$2"
	fi
	include $DS/ifs/mods/add
	include $DS/ifs/mods/add_process
	
	
	if [ $(echo ${2:0:4}) = 'Http' ]; then
	
		internet
		
		(
		echo "1"
		echo "# $pros..." ;
		lynx -dump -nolist $2  | sed -n -e '1x;1!H;${x;s-\n- -gp}' \
		| sed 's/\./\.\n/g' | sed 's/<[^>]*>//g' | sed 's/ \+/ /g' \
		| sed '/^$/d' |  sed 's/ \+/ /g' | sed 's/\://; s/"//g' \
		| sed 's/^[ \t]*//;s/[ \t]*$//g' | sed 's/^ *//; s/ *$//g' \
		| sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' | grep -v '^..$' \
		| grep -v '^.$' | sed 's/<[^>]\+>//g' | sed 's/\://g' \
		| sed '/\*/d' | sed '/\+/d' >> ./sntsls_
		
		) | dlg_progress_1

	elif echo "$2" | grep -o "image"; then
		
		SCR_IMG=`mktemp`
		trap "rm $SCR_IMG*" EXIT
		scrot -s $SCR_IMG.png
		
		(
		echo "1"
		echo "# $pros..." ;
		mogrify -modulate 100,0 -resize 400% $SCR_IMG.png
		tesseract $SCR_IMG.png $SCR_IMG &> /dev/null
		cat $SCR_IMG.txt | sed 's/\\n/./g' | sed 's/\./\n/g' \
		| sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//' \
		| sed 's/ \+/ /g' | sed 's/\://; s/"//g' \
		| sed 's/^ *//; s/ *$//g' > ./sntsls_
		
		) | dlg_progress_1

	else
		(
		echo "1"
		echo "# $pros..." ;
		echo "$prdt" | sed 's/\\n/./g' | sed 's/\./\n/g' \
		| sed 's/^ *//; s/ *$//g' | sed 's/^[ \t]*//;s/[ \t]*$//' \
		| sed 's/ \+/ /g' | sed 's/\://; s/"//g' \
		| sed '/^$/d' > ./sntsls_
		
		) | dlg_progress_1
	fi
	
		[[ -f ./sntsls ]] && rm -f ./sntsls
	
		#while read sntnc
		#do
			#if [ $(echo "$sntnc" | wc -c) -ge 150 ]; then
				#less="$(echo "$sntnc" | sed 's/\,/\n/g')"
				#n=1
				#while [ $n -le $(echo "$less" | wc -l) ]; do
					#sn=$(echo "$less" | sed -n "$n"p)
					#echo "$sn" >> ./sntsls
					#let n++
				#done
			#else
				#echo "$sntnc" >> ./sntsls
			#fi
		#done < ./sntsls_

		sed -i '/^$/d' ./sntsls_
		[[ $(echo "$tpe" | wc -c) -gt 60 ]] \
		&& tcnm="${tpe:0:60}..." || tcnm="$tpe"
		
		left=$((50 - $ns))
		info=$(echo "$remain$left$sentences.")

		if [ $ns -ge 45 ]; then
			info=$(echo "$remain$left$sentences.")
		elif [ $ns -ge 49 ]; then
			info=$(echo "$remain$left$sentence.")
		fi
		
		if [ -z "$(cat ./sntsls_)" ]; then
		
			dlg_text_info_4 " $gettext_err1."

			[[ -d $DT_r ]] && rm -fr $DT_r
			rm -f $lckpr $slt & exit 1
		
		else
		
			dlg_checklist_3 ./sntsls_
			ret=$(echo "$?")
			
		fi
				if [ $ret -eq 2 ]; then
					rm -f $lckpr "$slt" &
					
					dlg_text_info_1 ./sntsls_
					ret=$(echo "$?")
						
						if [ $ret -eq 0 ]; then
							$nspr "$(cat ./sort)" $DT_r "$tpe" &
							exit 1
						else
							[[ -d $DT_r ]] && rm -fr $DT_r
							rm -f $lckpr $slt & exit 1
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
					
					internet
					
					cd $DT_r
					touch ./wlog ./slog
					
					{
					echo "5"
					echo "# $pros... " ;
					[ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ] && c=c || c=w
					
					lns=$(cat ./slts ./wrds | wc -l)

					n=1
					while [ $n -le $(cat slts | head -50 | wc -l) ]; do
					
						sntc=$(sed -n "$n"p slts)
						trgt=$(translate "$(clean_1 "$sntc")" auto $lgt | sed ':a;N;$!ba;s/\n/ /g')
						srce=$(translate "$trgt" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')
						echo "$trgt" > ./trgt
						fname="$(nmfile "$trgt")"
					
						# words
						if [ $(echo "$sntc" | wc -$c) = 1 ]; then
							if [ $(cat "$DC_tlt"/cfg.3 | wc -l) -ge 50 ]; then
								printf "\n- $sntc" >> ./wlog
						
							else
								if sed -n 1p $DC_s/cfg.3 | grep TRUE; then
			
									tts ./trgt $lgt $DT_r "$DM_tlt/words/$fname.mp3"
									
								else
									voice "$trgt" $DT_r "$DM_tlt/words/$fname.mp3"
								fi

								if ( [ -n $(file -ib "$DM_tlt/words/$fname.mp3" | grep -o 'binary') ] \
								&& [ -f "$DM_tlt/words/$fname.mp3" ] && [ -n "$trgt" ] && [ -n "$srce" ] ); then
								
									add_tags_1 W "$trgt" "$srce" "$DM_tlt/words/$fname.mp3"
									echo "$trgt" >> addw
									$DS/mngr.sh index word "$trgt" "$tpe"

								else
									printf "\n- $sntc" >> ./wlog
									[ -f "$DM_tlt/words/$fname.mp3" ] && rm "$DM_tlt/words/$fname.mp3"
									
								fi
							fi
						
						#sentences 
						elif [ $(echo "$sntc" | wc -$c) -ge 1 ]; then
							
							if [ $(cat "$DC_tlt"/cfg.4 | wc -l) -ge 50 ]; then
								printf "\n- $sntc" >> ./slog
						
							else
								if [ $(echo "$sntc" | wc -c) -ge 150 ]; then
									printf "\n- $sntc" >> ./slog
							
								else
									if sed -n 1p $DC_s/cfg.3 | grep TRUE; then
									
										tts ./trgt $lgt $DT_r "$DM_tlt/$fname.mp3"
										
									else
										voice "$trgt" $DT_r "$DM_tlt/$fname.mp3"
										
									fi
									
									add_tags_1 S "$trgt" "$srce" "$DM_tlt/$fname.mp3"
									
									(
									cd $DT_r
									r=$(echo $(($RANDOM%1000)))
									clean_3 $DT_r $r
									translate "$(cat $aw | sed '/^$/d')" auto $lg | sed 's/,//g' \
									| sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw
									check_grammar_1 $DT_r $r
									list_words $DT_r $r
									grmrk=$(cat g.$r | sed ':a;N;$!ba;s/\n/ /g')
									lwrds=$(cat A.$r)
									pwrds=$(cat B.$r | tr '\n' '_')
									
									if ( [ -n $(file -ib "$DM_tlt/$fname.mp3" | grep -o 'binary') ] \
									&& [ -f "$DM_tlt/$fname.mp3" ] && [ -n "$lwrds" ] && [ -n "$pwrds" ] && [ -n "$grmrk" ] ); then
									
										echo "$fname" >> adds
										$DS/mngr.sh index sentence "$trgt" "$tpe"
										add_tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$fname.mp3"
										fetch_audio $aw $bw $DT_r $DM_tls

									else
										printf "\n- $sntc" >> ./slog
										[ -f "$DM_tlt/$fname.mp3" ] && rm "$DM_tlt/$fname.mp3"
										
									fi
									
									echo "__" >> x
									rm -f $DT/*.$r
									rm -f $aw $bw
									
									) &
									
									rm -f "$fname.mp3"
								fi
							fi
						fi
						
						prg=$((100*$n/$lns-1))
						echo "$prg"
						echo "# ${sntc:0:35}... " ;
						
						let n++
					done
					
					#words
					n=1
					while [ $n -le $(cat wrds | head -50 | wc -l) ]; do
					
						sname=$(sed -n "$n"p wrdsls)
						trgt=$(sed -n "$n"p wrds | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
						fname="$(nmfile "$trgt")"

						if [ $(cat "$DC_tlt"/cfg.3 | wc -l) -ge 50 ]; then
							printf "\n- $trgt" >> ./wlog
					
						else
							srce="$(translate "$trgt" auto $lgs)"
							
							if [ -f "$DM_tls/${trgt,,}.mp3" ]; then
	
								cp -f "$DM_tls/${trgt,,}.mp3" "$DT_r/${trgt,,}.mp3"
								
							else
								dictt "${trgt,,}" $DT_r
							fi
							
							if [ -f "$DT_r/${trgt,,}.mp3" ]; then

								cp -f "$DT_r/${trgt,,}.mp3" "$DM_tlt/words/$fname.mp3"
								
							else
								voice "$trgt" $DT_r "$DM_tlt/words/$fname.mp3"
							fi


							if ( [ -n $(file -ib "$DM_tlt/words/$fname.mp3" | grep -o 'binary') ] \
							&& [ -f "$DM_tlt/words/$fname.mp3" ] && [ -n "$trgt" ] && [ -n "$srce" ] ); then
								add_tags_2 W "$trgt" "$srce" "$sname" "$DM_tlt/words/$fname.mp3"
								$DS/mngr.sh index word "$trgt" "$tpe" "$sname"
								echo "$trgt" >> addw
							else
								printf "\n- $sntc" >> ./wlog
								[ -f "$DM_tlt/words/$fname.mp3" ] && rm "$DM_tlt/words/$fname.mp3"
							fi
						fi
						
						
						nn=$(($n+$(cat ./slts | wc -l)-1))
						prg=$((100*$nn/$lns))
						echo "$prg"
						echo "# ${itm:0:35}... " ;
						
						let n++
					done
					} | dlg_progress_2

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
						sadds=" $(cat ./adds | wc -l)"
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
						printf "aitm.$adds.aitm\n" >> \
						$DC/addons/stats/.log
					fi
					
					if [ $(cat ./slog ./wlog | wc -l) -ge 1 ]; then
						
						dlg_text_info_3 "$items_rest\n\n$logs" >/dev/null 2>&1
					fi
					if  [ $(cat ./slog ./wlog | wc -l) -ge 1 ]; then
						rm=$(($(cat ./addw ./adds | wc -l) - $(cat ./slog ./wlog | sed '/^$/d' | wc -l)))
					else
						rm=$(cat ./addw ./adds | wc -l)
					fi
					
					n=1
					while [[ $n -le 20 ]]; do
						 sleep 5
						 if ([ $(cat ./x | wc -l) = $rm ] || [ $n = 20 ]); then
							[[ -d $DT_r ]] && rm -fr $DT_r
							cp -f "$DC_tlt/cfg.0" "$DC_tlt/.cfg.11"
							rm -f $lckpr & break & exit 1
						 fi
						let n++
					done
					
				else
					cp -f "$DC_tlt/cfg.0" "$DC_tlt/.cfg.11"
					[[ -d $DT_r ]] && rm -fr $DT_r
					 rm -f $lckpr $slt & exit 1
				fi
			
elif [ $1 = set_image ]; then
	cd $DT
	wrd="$2"
	fname="$(nmfile "$wrd")"
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
	
	if [ "$3" = word ]; then
		
		if [ ! -f "$DT/$fname.*" ]; then
			file="$DM_tlt/words/$fname.mp3"
		fi
		
		if [ -f "$DM_tlt/words/images/$fname.jpg" ]; then
			ICON="--image=$DM_tlt/words/images/$fname.jpg"
			btnn=$(echo --button=$change:3)
			btn2=$(echo --button=$delete:2)
		else
			txt="--text=<small>$images_for  <a href='file://$DT/s.html'>$wrd</a></small>"
		fi
		
		yad --form --align=center --center \
		--width=340 --text-align=center --height=280 \
		--on-top --skip-taskbar --image-on-top "$txt" >/dev/null 2>&1 \
		"$btnn" --window-icon=idiomind --borders=0 \
		--title=Image "$ICON" "$btn2" \
		--button=gtk-close:1
			ret=$? >/dev/null 2>&1
			
			if [ $ret -eq 3 ]; then
			
				rm -f *.l
				scrot -s --quality 70 "$fname.temp.jpeg"
				/usr/bin/convert -scale 100x90! "$fname.temp.jpeg" "$wrd"_temp.jpeg
				/usr/bin/convert -scale 360x240! "$fname.temp.jpeg" "$DM_tlt/words/images/$fname.jpg"
				eyeD3 --remove-images "$file" >/dev/null 2>&1
				eyeD3 --add-image "$fname"_temp.jpeg:ILLUSTRATION "$file" >/dev/null 2>&1
				rm -f *.jpeg
				$DS/add.sh set_image "$wrd" word
				
			elif [ $ret -eq 2 ]; then
			
				eyeD3 --remove-image "$file" >/dev/null 2>&1
				rm -f "$DM_tlt/words/images/$fname.jpg"
				rm -f *.jpeg s.html
				
			else
				rm -f *.jpeg s.html
			fi
			
	elif [ "$3" = sentence ]; then
	
		if [ ! -f "$DT/$wrd.*" ]; then
			file="$DM_tlt/$fname.mp3"
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
		
		yad --form --text-align=center \
		--center --width=470 --height=280 \
		--on-top --skip-taskbar --image-on-top \
		"$txt" "$btnn" --window-icon=idiomind --borders=0 \
		--title="Image" "$ICON" "$btn2" --button=gtk-close:1
			ret=$? >/dev/null 2>&1
				
			if [ $ret -eq 3 ]; then
			
				rm -f $DT/*.l
				scrot -s --quality 70 "$fname.temp.jpeg"
				/usr/bin/convert -scale 450x270! "$fname.temp.jpeg" "$fname"_temp.jpeg
				eyeD3 --remove-image "$file" >/dev/null 2>&1
				eyeD3 --add-image "$fname"_temp.jpeg:ILLUSTRATION "$file" >/dev/null 2>&1 &&
				rm -f *.jpeg
				printf "aimg.$tpc.aimg\n" >> \
				$DC_a/stats/.log &
				$DS/add.sh set_image "$wrd" sentence
				
			elif [ $ret -eq 2 ]; then
				eyeD3 --remove-images "$file" >/dev/null 2>&1
				rm -f s.html *.jpeg
			else
				rm -f s.html *.jpeg
			fi
	fi


elif [[ "$1" = fix_item ]]; then

	kill -9 $(pgrep -f "$yad --form ")
	trgt="$2"
	DT_r=$(mktemp -d $DT/XXXXXX)
	cd $DT_r
	

	if ([ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]); then

		srce=$(translate "$trgt" auto $lgs)
		
		if [ $(echo "$srce" | wc -w) = 1 ]; then
			$DS/add.sh new_word "$trgt" $DT_r "$srce" & exit 1
			
		elif [ $(echo "$srce" | wc -w) -ge 1 -a $(echo "$srce" | wc -c) -le 180 ]; then
			$DS/add.sh new_sentence "$trgt" $DT_r "$srce" & exit 1
		fi
		
	elif ([ $lgt != ja ] || [ $lgt != 'zh-cn' ] || [ $lgt != ru ]); then
	
    
		if [ $(echo "$trgt" | wc -w) = 1 ]; then
			$DS/add.sh new_word "$trgt" $DT_r "$srce" & exit 1
			
		elif [ $(echo "$trgt" | wc -w) -ge 1 -a $(echo "$trgt" | wc -c) -le 180 ]; then
			$DS/add.sh new_sentence "$trgt" $DT_r "$srce" & exit 1
			
		fi
	fi
	
	$DS/vwr.sh "$trgt" "v1"
	
fi
