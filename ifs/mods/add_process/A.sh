#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf


function dlg_checklist_5() {
    
        slt=$(mktemp $DT/slt.XXXX.x)
        cat "$1" | awk '{print "FALSE\n"$0}' | \
        yad --center --sticky --name=idiomind --class=idiomind \
        --dclick-action='/usr/share/idiomind/ifs/mods/add_process/A.sh show_item_for_edit' \
        --list --checklist --window-icon=idiomind \
        --width=$wth --text="<small>$info</small>" \
        --height=$eht --borders=3 --button="$cancel":1 \
        --button="$to_new_topic":'/usr/share/idiomind/add.sh new_topic' \
        --button=gtk-save:0 --title="$Title_sentences" \
        --column="$(cat "$1" | wc -l)" --column="Items" > "$slt"
}


function dlg_text_info_5() {
    
        echo "$1" | yad --text-info --center --wrap \
        --name=idiomind --class=idiomind --window-icon=idiomind \
        --sticky --width=520 --height=110 --editable \
        --margins=8 --borders=0 --button=Ok:0 \
        --title="$edit_item" > "$1".txt
}


function audio_recognizer() {
	
	echo "$(wget -q -U "Mozilla/5.0" --post-file "$1" --header="Content-Type: audio/x-flac; rate=16000" \
	-O - "https://www.google.com/speech-api/v2/recognize?&lang="$2"-"$3"&key=$4")"
}


# load
function dlg_file_1() {
    
        echo "$(yad --borders=0 --name=idiomind --file-filter="*.mp3 *.tar *.zip" \
        --skip-taskbar --on-top --title="Speech recognize" --center \
        --window-icon=idiomind --file --width=600 --height=450)"
}


# save
function dlg_file_2() {
    
        yad --save --center --borders=10 \
        --on-top --filename="$(date +%m-%d-%Y)"_audio.tar.gz \
        --window-icon=idiomind --skip-taskbar --title="Save" \
        --file --width=600 --height=500 --button=gtk-ok:0
}


# --------------------------------------
if [[ "$prdt" = A ]]; then

	cd $DT_r
	left=$((50 - $(cat "$DC_tlt/cfg.4" | wc -l)))
	key=$(sed -n 2p $DC_s/cfg.3)
	test="$DS/addons/Google translation service/test.flac"
	
	if [ -z "$key" ]; then
		
		msg "$no_key <a href='$LNK'>Web</a>\n" dialog-warning
		[[ -d $DT_r ]] && rm -fr $DT_r
		rm -f ls $lckpr & exit 1
	fi
	
	cd $HOME

	FL="$(dlg_file_1)"
	
	if [ -z "$FL" ];then
		[[ -d $DT_r ]] && rm -fr $DT_r
		rm -f $lckpr & exit 1
		
	else
		if [ -z "$tpe" ]; then
			[[ -d $DT_r ]] && rm -fr $DT_r
			source $DS/ifs/trans/$lgs/topics_lists.conf
			$DS/chng.sh "$no_edit" & exit 1
		fi
		
		
		(
		echo "2"
		echo "# $file_pros" ; sleep 1
		cd $DT_r
		
		if echo "$FL" | grep '.mp3'; then
		
			cp -f "$FL" $DT_r/rv.mp3
			#eyeD3 -P itunes-podcast --remove "$DT_r"/rv.mp3
			eyeD3 --remove-all "$DT_r"/rv.mp3
			sox "$DT_r"/rv.mp3 "$DT_r"/c_rv.mp3 remix - highpass 100 norm \
			compand 0.05,0.2 6:-54,-90,-36,-36,-24,-24,0,-12 0 -90 0.1 \
			vad -T 0.6 -p 0.2 -t 5 fade 0.1 reverse \
			vad -T 0.6 -p 0.2 -t 5 fade 0.1 reverse norm -0.5
			rm -f "$DT_r"/rv.mp3
			mp3splt -s -o @n *.mp3
			rename 's/^0*//' *.mp3
			rm -f "$DT_r"/c_rv.mp3
			
		elif echo "$FL" | grep '.tar'; then
		
			cp -f "$FL" $DT_r/rv.tar
			tar -xvf $DT_r/rv.tar
			
		elif echo "$FL" | grep '.zip'; then
		
			cp -f "$FL" $DT_r/rv.zip
			unzip $DT_r/rv.zip
		fi

		ls *.mp3 > lst
		lns=$(cat ./lst | head -50 | wc -l)
		# --------------------------------------
		internet
		 
		echo "3"
		echo "# $check_key... " ; sleep 1
		data="$(audio_recognizer "$test" $lgt $lgt $key)"
		if [ -z "$data" ]; then
			key=$(sed -n 3p $DC_s/cfg.3)
			data="$(audio_recognizer "$test" $lgt $lgt $key)"
		fi
		if [ -z "$data" ]; then
			key=$(sed -n 4p $DC_s/cfg.3)
			data="$(audio_recognizer "$test" $lgt $lgt $key)"
		fi
		if [ -z "$data" ]; then
		    msg "$key_err <a href='$LNK'>Google. </a>" error
			[[ -d $DT_r ]] && rm -fr $DT_r
			rm -f ls $lckpr & exit 1
		fi
		
		echo "# $file_pros" ; sleep 0.2

		n=1
		while [ $n -le "$lns" ]; do

			sox "$n".mp3 info.flac rate 16k
			data="$(audio_recognizer info.flac $lgt $lgt $key)"
			if [ -z "$data" ]; then
			
				msg "$key_err <a href='$LNK'>Google</a>" error
				[[ -d $DT_r ]] && rm -fr $DT_r
				rm -f ls $lckpr & break & exit 1
			fi

			trgt="$(echo "$data" | sed '1d' | sed 's/.*transcript":"//' \
			| sed 's/"}],"final":true}],"result_index":0}//g')"
			
			if [ $(echo "$trgt" | wc -c) -ge 180 ]; then
				printf "\n- $trgt" >> log
			
			else
				#fname="$(nmfile "$trgt")"
				mv -f "./$n.mp3" "./$trgt.mp3"
				echo "$trgt" > "./$trgt.txt"
				echo "$trgt" >> ./ls
				rm -f info.flac info.ret
			fi
			prg=$((100*$n/$lns))
			echo "$prg"
			echo "# ${trgt:0:35} ... " ;
			
			let n++
		done
		
		) | dlg_progress_2
		# --------------------------------------
		cd $DT_r
		sed -i '/^$/d' ./ls
		[[ $(echo "$tpe" | wc -c) -gt 40 ]] && tcnm="${tpe:0:40}..." || tcnm="$tpe"

		left=$((50 - $(cat "$DC_tlt"/cfg.4 | wc -l)))
		info=$(printf "$remain$left$sentences. ")
		[ $ns -ge 45 ] && info=$(printf "$remain$left$sentences. ")
		[ $ns -ge 49 ] && info=$(printf "$remain$left$sentence. ")
		
		if [ -z "$(cat $DT_r/ls)" ]; then
		
			dlg_text_info_4 "$gettext_err"
			[[ -d $DT_r ]] && rm -fr $DT_r
			rm -f $lckpr & exit 1
			
		else
			dlg_checklist_5 $DT_r/ls
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
				
				internet
				
				# --------------------------------------
				(
				echo "1"
				echo "# $pros... " ;
				[ $lgt = ja ] || [ $lgt = "zh-cn" ] || [ $lgt = ru ] && c=c || c=w
				lns=$(cat ./slts ./wrds | wc -l)

				n=1
				while [ $n -le $(cat ./slts | head -50 | wc -l) ]; do
					
					sntc=$(sed -n "$n"p ./slts)
					trgt=$(cat "./$sntc.txt" | sed 's/^\s*./\U&\E/g')
					fname="$(nmfile "$trgt")"
					
					if [ $(sed -n 1p "$sntc.txt" | wc -$c) -eq 1 ]; then
					
						if [ $(cat "$DC_tlt"/cfg.3 | wc -l) -ge 50 ]; then
							printf "\n- $sntc" >> ./wlog
					
						else
							srce="$(translate "$trgt" $lgt $lgs)"
							mv -f "$sntc".mp3 "$DM_tlt/words/$fname".mp3
							
							if ( [ -n $(file -ib "$DM_tlt/words/$fname".mp3 | grep -o 'binary') ] \
							&& [ -n "$trgt" ] && [ -n "$srce" ] ); then
							
								add_tags_1 W "$trgt" "$srce" "$DM_tlt/words/$fname".mp3
								$DS/mngr.sh index word "$fname" "$tpe"
								echo "$sntc" >> addw
							else
								[ -f "$DM_tlt/words/$fname".mp3 ] && rm "$DM_tlt/words/$fname".mp3
								printf "\n- $sntc" >> ./wlog
							fi
						fi
					
					elif [ $(sed -n 1p "$sntc.txt" | wc -$c) -ge 1 ]; then
					
						if [ $(cat "$DC_tlt"/cfg.4 | wc -l) -ge 50 ]; then
							printf "\n- $sntc" >> ./slog
					
						else
							srce="$(translate "$trgt" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')"
							
							mv -f "$sntc.mp3" "$DM_tlt/$fname.mp3"
							
							if ( [ -f "$DM_tlt/$fname.mp3" ] && [ -n "$trgt" ] && [ -n "$srce" ] ); then
							    add_tags_1 S "$trgt" "$srce" "$DM_tlt/$fname.mp3"
							fi

							(
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
							&& [ -n "$lwrds" ] && [ -n "$pwrds" ] && [ -n "$grmrk" ] ); then
								
								echo "$sntc" >> adds
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
					
							rm -f "$sntc.mp3"
						fi
					fi
				
					prg=$((100*$n/$lns-1))
					echo "$prg"
					echo "# ${sntc:0:35} ... " ;
					
					let n++
				done
				
				# --------------------------------------
				#-words
				if [ -n "$(cat wrds)" ]; then
					nwrds=" $(cat wrds | head -50 | wc -l) Palabras"
				fi
				
				n=1
				while [ $n -le "$(cat wrds | head -50 | wc -l)" ]; do
					trgt=$(sed -n "$n"p wrds | sed ':a;N;$!ba;s/\n/ /g' | sed 's/^\s*./\U&\E/g')
					sname=$(sed -n "$n"p wrdsls)
					fname="$(nmfile "$trgt")"

					if [ $(cat "$DC_tlt"/cfg.3 | wc -l) -ge 50 ]; then
						printf "\n- $trgt" >> ./wlog
				
					else
						srce="$(translate "$trgt" auto $lgs)"
						$dct "$trgt" $DT_r swrd
						
						if [ -f "$trgt".mp3 ]; then
						
							mv -f "$DT_r/$trgt.mp3" "$DM_tlt/words/$fname.mp3"
							
						else
							voice "$trgt" $DT_r "$DM_tlt/words/$fname.mp3"
						fi
						if ( [ -n $(file -ib "$DM_tlt/words/$fname.mp3" | grep -o 'binary') ] \
						&& [ -n "$trgt" ] && [ -n "$srce" ] ); then
						
							add_tags_2 W "$trgt" "$srce" "$exmp" "$DM_tlt/words/$fname.mp3" >/dev/null 2>&1
							$DS/mngr.sh index word "$trgt" "$tpe" "$sname"
							echo "$trgt" >> addw
						else
							[ -f "$DM_tlt/words/$fname.mp3" ] && rm "$DM_tlt/words/$fname.mp3"
							printf "\n- $trgt" >> ./wlog
						fi
					fi
					
					
					nn=$(($n+$(cat ./slts | wc -l)-1))
					prg=$((100*$nn/$lns))
					echo "$prg"
					echo "# ${trgt:0:35} ... " ;
					
					let n++
				done
				) | dlg_progress_2
				
				# --------------------------------------
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
				
				logs=$(cat ./slog ./wlog ./log)
				adds=$(cat ./adds ./addw | wc -l)
				
				if [ $adds -ge 1 ]; then
					notify-send -i idiomind "$tpe" "$is_added\n$sadds$S$wadds$W" -t 2000 &
					echo "aitm.$adds.aitm" >> \
					$DC/addons/stats/.log
				fi
				
				if ( [ -n "$logs" ] || [ $(ls [0-9]* | wc -l) -ge 1 ] ); then
				
					if [ -n "$logs" ]; then
						text_r1="$items_rest\n\n$logs"
					fi
					
					if [ $(ls [0-9]* | wc -l) -ge 1 ]; then
						btn="--button=$btn_save_audio:0"
						text_r2="$audio_rest\n"
					fi
					
					dlg_text_info_3 "$text_r2$text_r1" "$btn" >/dev/null 2>&1
					ret=$(echo "$?")
					
						if  [ "$ret" -eq 0 ]; then
							aud=$(dlg_file_2)
							ret=$(echo "$?")
								if [ "$ret" -eq 0 ]; then
									mkdir rest
									mv -f [0-9]*.mp3 ./rest/
									cd ./rest
									cat $(ls [0-9]*.mp3 | sort -n | tr '\n' ' ') > audio.mp3
									rm -f $(ls [0-9]*.mp3)
									tar cvzf audio.tar.gz *
									mv -f audio.tar.gz "$aud"
								fi
						fi
				fi
				# --------------------------------------
				cd $DT_r
				if  [ -f ./log ]; then
					rm=$(($(cat ./adds) - $(cat ./log | sed '/^$/d' | wc -l)))
				else
					rm=$(cat ./adds)
				fi
				
				n=1
				while [ $n -le 20 ]; do
					 sleep 5
					 if ( [ "$(cat ./x | wc -l)" = "$rm" ] || [ "$n" = 20 ] ); then
						[[ -d "$DT_r" ]] && rm -fr $DT_r
						cp -f "$DC_tlt/cfg.0" "$DC_tlt/.cfg.11"
						rm -f $lckpr & break & exit 1
					 fi
					let n++
				done
				exit 1
			else
				[ -d "$DT_r" ] && rm -fr $DT_r
				cp -f "$DC_tlt/cfg.0" "$DC_tlt/.cfg.11"
				rm -f $lckpr $slt & exit 1
			fi
		fi
	exit 1
	
elif [ $1 = show_item_for_edit ]; then

	DT_r=$(cat $DT/.n_s_pr)
	cd $DT_r
	dlg_text_info_5 "$3"
	$? >/dev/null 2>&1
	
fi
