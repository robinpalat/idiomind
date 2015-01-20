#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source /usr/share/idiomind/ifs/trans/$lgs/rss.conf

if [[ $1 = n_i ]]; then
	trgt=$(cat $DT/.dzmxx.x | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
	nm=$(cat $DT/.dzmxx.x)
	info2=$(cat $DT/list | wc -l)
	c=$(echo $(($RANDOM%100)))
	var="$2"

	if [ $info2 -ge 50 ]; then
		$yad --center --fixed --image=info \
		--image-on-top --on-top --fixed --sticky \
		--width=220 --height=120 \
		--skip-taskbar --window-icon=idiomind --title=" " \
		--button=Ok:1 && exit 1
	fi

	if [[ ! -d "$DM_tl/Feeds"/kept ]]; then
		mkdir "$DM_tl/Feeds"/kept
		mkdir "$DM_tl/Feeds"/kept/words
	fi

	if [[ -f $DT/.dzmxx.x ]]; then
		bttn="--button=$save_word:0"
		txt="<b>$word </b>"
	fi

	$yad --width=480 --height=200 --window-icon=idiomind \
	--title="$save" --center --on-top --borders=10 \
	--image=dialog-question --skip-taskbar \
	--text="  <b>$sentence </b>\\n  <i>$var</i>\\n\\n  $txt\\n  <i>$trgt\\n</i>" \
	--button="$save_sentence":2 "$bttn" \
	--button="$cancel":1
		ret=$?
		
		if [[ $ret -eq 0 ]]; then
			if [ $(cat "$DC_tl/Feeds/cnfg3" | wc -l) -ge 50 ]; then
				$yad --name=idiomind --center --on-top --image=info \
				--text=" <b>$tpe    </b>\\n\\n $words_max  \\n" \
				--image-on-top --fixed --sticky --title="$tpe" \
				--width=230 --height=120 --borders=3 --button=gtk-ok:0 \
				--skip-taskbar --window-icon=idiomind && exit 1
			fi
		
			curl -v www.google.com 2>&1 | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
			$yad --window-icon=idiomind --on-top \
			--image="info" --name=idiomind \
			--text="<b> $connection_err  \\n  </b>" \
			--image-on-top --center --sticky \
			--width=300 --height=120 --borders=3 \
			--skip-taskbar --title="Idiomind" \
			--button="  Ok  ":0 & exit 1
			 >&2; exit 1;}
			
			mkdir $DT/rss_$c
			cd $DT/rss_$c
			result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lgs" --data-urlencode text="$trgt" https://translate.google.com)
			encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
			srce=$(iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8)
			nme=$(echo "$trgt" | sed 's/[ \t]*$//' | sed "s/'/ /g")
			
			[[ ! -d "$DM_tl/Feeds/kept/words" ]] && mkdir "$DM_tl/Feeds/kept/words"
			cp "$DM_tl/Feeds/conten/$var/$nm.mp3" "$DM_tl/Feeds/kept/words/$nme.mp3"
			
			eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt}IWI1I0I" -a "IWI2I0I${srce}IWI2I0I" -A IWI3I0I"$var"IWI3I0I \
			"$DM_tl/Feeds/kept/words/$nme.mp3"
			echo "$nme" >> "$DC_tl/Feeds/cnfg0"
			echo "$nme" >> "$DC_tl/Feeds/.cnfg11"
			echo "$nme" >> "$DC_tl/Feeds/cnfg3"
			
			if [ -n "$(cat "$DC_tl/Feeds/cnfg0" | sort -n | uniq -dc)" ]; then
				cat "$DC_tl/Feeds/cnfg0" | awk '!array_temp[$0]++' > $DT/.ls.x
				sed '/^$/d' $DT/.ls.x > "$DC_tl/Feeds/cnfg0"
			fi
			rm -rf $DT/rss_$c
			
		elif [[ $ret -eq 2 ]]; then
			if [ $(cat "$DC_tl/Feeds/cnfg4" | wc -l) -ge 50 ]; then
				$yad --name=idiomind --center --on-top --image=info \
				--text=" <b>$tpe    </b>\\n\\n $sentences_max \\n" \
				--image-on-top --fixed --sticky --title="$tpe" \
				--width=230 --height=120 --borders=3 --button=gtk-ok:0 \
				--skip-taskbar --window-icon=idiomind && exit 1
			fi
			
			curl -v www.google.com 2>&1 | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
			$yad --window-icon=idiomind --on-top \
			--image="info" --name=idiomind \
			--text="<b> $connection_err  \\n  </b>" \
			--image-on-top --center --sticky \
			--width=300 --height=120 --borders=3 \
			--skip-taskbar --title="Idiomind" \
			--button="  Ok  ":0 & exit 1
			 >&2; exit 1;}
			
			if [[ $(echo "$var" | wc -c) -ge 73 ]]; then
				nme="$(echo "$var" | cut -c 1-70 | sed 's/[ \t]*$//' | \
				sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')..."
			else
				nme=$(echo "$var" | sed 's/[ \t]*$//' | \
				sed "s/'/ /g" | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
			fi
			
			cp "$DM_tl/Feeds/conten/$var.mp3" "$DM_tl/Feeds/kept/$nme.mp3"
			cp "$DM_tl/Feeds/conten/$var.lnk" "$DM_tl/Feeds/kept/$nme.lnk"
			cp $DM_tl/Feeds/conten/"$var"/*.mp3 "$DM_tl/Feeds/kept/.audio/"
			
			if [ -n "$(cat "$DC_tl/Feeds/cnfg0" | sort -n | uniq -dc)" ]; then
				cat "$DC_tl/Feeds/cnfg0" | awk '!array_temp[$0]++' > $DT/.ls.x
				sed '/^$/d' $DT/.ls.x > "$DC_tl/Feeds/cnfg0"
			fi
				echo "$nme" >> "$DC_tl/Feeds/cnfg0"
				echo "$nme" >> "$DC_tl/Feeds/.cnfg11"
				echo "$nme" >> "$DC_tl/Feeds/cnfg4"
				rm -f -r $DT/.dzmxx.x $DT/rss_$ & exit 1
		else
			rm -f -r $DT/.dzmxx.x $DT/rss_$ & exit 1
		fi
		
elif [[ $1 = n_t ]]; then

	dte=$(date "+%a %d %B")
	if [ $(cat "$DC_tl/.cnfg1" | wc -l) -ge 50 ]; then
		$yad --fixed --image=info --title=Idiomind \
		--name=idiomind --center --skip-taskbar \
		--text=" <b>$topics_max  </b>" \
		--image-on-top --fixed --sticky --on-top \
		--width=230 --height=120 --borders=3 \
		--window-icon=idiomind \
		--button=gtk-ok:0
		exit 1
	fi

	jlbi=$($yad --form \
	--window-icon=idiomind --borders=10 \
	--fixed --width=400 --height=120 \
	--on-top --center --skip-taskbar \
	--field=" : " "News - $dte" \
	--button=$create:0 --title="$new_topic" )
		
		if [ -z "$jlbi" ];then
			exit 0
		else
			
			jlb=$(echo "$jlbi" | cut -d "|" -f1 | sed s'/!//'g)
			mkdir "$DM_tl/$jlb"
			mkdir "$DC_tl/$jlb"
			mkdir $DC_tl/"$jlb"/practice
			
			cd $DS/practice/default/
			cp -f ./.* "$DC_tl/$jlb/practice/"
			
			[[ -f "$DC_tl/Feeds/cnfg0" ]] && mv -f "$DC_tl/Feeds/cnfg0" "$DC_tl/$jlb/cnfg0" || "touch $DC_tl/$jlb/cnfg0"
			[[ -f "$DC_tl/Feeds/cnfg3" ]] && mv -f "$DC_tl/Feeds/cnfg3" "$DC_tl/$jlb/cnfg3" || "touch $DC_tl/$jlb/cnfg3"
			[[ -f "$DC_tl/Feeds/cnfg4" ]] && mv -f "$DC_tl/Feeds/cnfg4" "$DC_tl/$jlb/cnfg4" || "touch $DC_tl/$jlb/cnfg4"
			[[ -f "$DC_tl/Feeds/.cnfg11" ]] && mv -f "$DC_tl/Feeds/.cnfg11" "$DC_tl/$jlb/.cnfg11" || "touch $DC_tl/$jlb/.cnfg11"
			
			cd "$DM_tl/Feeds/kept"
			cp -f *.mp3 "$DM_tl/$jlb/" && rm *.mp3
			cp -f *.lnk "$DM_tl/$jlb/" && rm *.lnk
			
			cd "$DM_tl/Feeds/kept/.audio"
			ls *.mp3 > "$DC_tl/$jlb/cnfg5"
			mv *.mp3 "$DM_tl/.share/"
			
			mkdir "$DM_tl/$jlb/words"
			cd "$DM_tl/Feeds/kept/words"
			cp -f *.mp3 "$DM_tl/$jlb/words" && rm *.mp3
			
			mkdir "$DM_tl/$jlb/words/images"
			
			touch "$DC_tl/Feeds/cnfg0"
			touch "$DC_tl/Feeds/cnfg3"
			touch "$DC_tl/Feeds/cnfg4"
			touch "$DC_tl/$jlb/cnfg2"
			
			cnt=$(cat "$DC_tl/$jlb/cnfg0" | wc -l)
			echo "aitm.$cnt.aitm" >> \
			$DC/addons/stats/.log &
			
			[[ -f $DT/ntpc ]] && rm -f $DT/ntpc
			
			cp -f "$DC_tl/$jlb/cnfg0" "$DC_tl/$jlb/cnfg1"
			cp -f $DS/default/tpc.sh "$DC_tl/$jlb/tpc.sh"
			chmod +x "$DC_tl/$jlb/tpc.sh"
			echo "$(date +%F)" > "$DC_tl/$jlb/cnfg12"
			echo "1" > "$DC_tl/$jlb/cnfg8"
			echo "$jlb" >> $DC_tl/.cnfg2
			
			"$DC_tl/$jlb/tpc.sh"
			$DS/mngr.sh mkmn
		fi
fi
