#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source /usr/share/idiomind/ifs/trans/$lgs/rss.conf

function msg() {
	
	yad --window-icon=idiomind --name=idiomind \
	--image=$2 --on-top --text=" $1 " \
	--image-on-top --center --sticky --button="Ok":0 \
	--width=420 --height=150 --borders=5 \
	--skip-taskbar --title="Idiomind"
}

function internet() {

	curl -v www.google.com 2>&1 \
	| grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
	yad --window-icon=idiomind --on-top \
	--image=info --name=idiomind \
	--text=" $connection_err  \n" \
	--image-on-top --center --sticky \
	--width=420 --height=150 --borders=3 \
	--skip-taskbar --title=Idiomind \
	--button="  Ok  ":0 >&2; exit 1;}
}

if [[ $1 = n_i ]]; then

	trgt=$(cat $DT/word.x)
	nm=$(cat $DT/word.x)
	c=$(echo $(($RANDOM%100)))
	var="$2"

	if [[ ! -d "$DM_tl/Feeds"/kept ]]; then
		mkdir "$DM_tl/Feeds"/kept
		mkdir "$DM_tl/Feeds"/kept/words
	fi

	if [[ -f $DT/word.x ]]; then
		bttn="--button=$save_word:0"
		txt="<b>$word </b>"
	fi

	$yad --width=480 --height=210 --window-icon=idiomind \
	--title="$save" --center --on-top --borders=10 \
	--image=dialog-question --skip-taskbar \
	--text="  <b>$sentence </b>\n  $var\n\n  $txt\n  $trgt\n" \
	--button="$save_sentence":2 "$bttn" 
		ret=$?
		
		if [[ $ret -eq 0 ]]; then
			if [ $(cat "$DC_tl/Feeds/cfg.3" | wc -l) -ge 50 ]; then
				msg "$tpe  \n$words_max " info & exit
			fi
		
			internet
			
			mkdir $DT/rss_$c
			cd $DT/rss_$c
			result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lgs" --data-urlencode text="$trgt" https://translate.google.com)
			encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
			srce=$(iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8)
			nme="$(echo "$trgt" | cut -c 1-100 | sed 's/[ \t]*$//' | sed s'/&//'g | sed s'/://'g | sed "s/'/ /g")"
			
			[[ ! -d "$DM_tl/Feeds/kept/words" ]] && mkdir "$DM_tl/Feeds/kept/words"
			cp "$DM_tl/Feeds/conten/$var/$nm.mp3" "$DM_tl/Feeds/kept/words/${nm^}.mp3"
			
			eyeD3 --set-encoding=utf8 -t "IWI1I0I${trgt^}IWI1I0I" -a "IWI2I0I${srce^}IWI2I0I" -A IWI3I0I"$var"IWI3I0I \
			"$DM_tl/Feeds/kept/words/${nm^}.mp3"
			echo "${trgt^}" >> "$DC_tl/Feeds/cfg.0"
			echo "${trgt^}" >> "$DC_tl/Feeds/.cfg.11"
			echo "${trgt^}" >> "$DC_tl/Feeds/cfg.3"
			
			if [ -n "$(cat "$DC_tl/Feeds/cfg.0" | sort -n | uniq -dc)" ]; then
				cat "$DC_tl/Feeds/cfg.0" | awk '!array_temp[$0]++' > $DT/.ls.x
				sed '/^$/d' $DT/.ls.x > "$DC_tl/Feeds/cfg.0"
			fi
			rm -rf $DT/rss_$c
			
		elif [[ $ret -eq 2 ]]; then
			if [ $(cat "$DC_tl/Feeds/cfg.4" | wc -l) -ge 50 ]; then
				msg "$tpe  \n$sentences_max" info & exit
			fi
			
			internet
			
			nme="$(echo "$var" | cut -c 1-100 | sed 's/[ \t]*$//' | sed s'/&//'g | sed s'/://'g | sed "s/'/ /g")"
			
			tgs=$(eyeD3 "$DM_tl/Feeds/conten/$nme.mp3")
			trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')

			
			cp "$DM_tl/Feeds/conten/$nme.mp3" "$DM_tl/Feeds/kept/$nme.mp3"
			cp "$DM_tl/Feeds/conten/$nme.lnk" "$DM_tl/Feeds/kept/$nme.lnk"
			cp $DM_tl/Feeds/conten/"$nme"/*.mp3 "$DM_tl/Feeds/kept/.audio/"
			
			if [ -n "$(cat "$DC_tl/Feeds/cfg.0" | sort -n | uniq -dc)" ]; then
				cat "$DC_tl/Feeds/cfg.0" | awk '!array_temp[$0]++' > $DT/.ls.x
				sed '/^$/d' $DT/.ls.x > "$DC_tl/Feeds/cfg.0"
			fi
				echo "$trgt" >> "$DC_tl/Feeds/cfg.0"
				echo "$trgt" >> "$DC_tl/Feeds/.cfg.11"
				echo "$trgt" >> "$DC_tl/Feeds/cfg.4"
				rm -f -r $DT/word.x $DT/rss_$ & exit
		else
			rm -fr $DT/word.x $DT/rss_$c & exit
		fi
		
elif [[ $1 = n_t ]]; then

	dte=$(date "+%a %d %B")
	if [ $(cat "$DC_tl/.cfg.1" | wc -l) -ge 50 ]; then
		msg "$topics_max " info & exit
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
			
			[[ -f "$DC_tl/Feeds/cfg.0" ]] && mv -f "$DC_tl/Feeds/cfg.0" "$DC_tl/$jlb/cfg.0" || "touch $DC_tl/$jlb/cfg.0"
			[[ -f "$DC_tl/Feeds/cfg.3" ]] && mv -f "$DC_tl/Feeds/cfg.3" "$DC_tl/$jlb/cfg.3" || "touch $DC_tl/$jlb/cfg.3"
			[[ -f "$DC_tl/Feeds/cfg.4" ]] && mv -f "$DC_tl/Feeds/cfg.4" "$DC_tl/$jlb/cfg.4" || "touch $DC_tl/$jlb/cfg.4"
			[[ -f "$DC_tl/Feeds/.cfg.11" ]] && mv -f "$DC_tl/Feeds/.cfg.11" "$DC_tl/$jlb/.cfg.11" || "touch $DC_tl/$jlb/.cfg.11"
			
			cd "$DM_tl/Feeds/kept"
			cp -f *.mp3 "$DM_tl/$jlb/" && rm *.mp3
			cp -f *.lnk "$DM_tl/$jlb/" && rm *.lnk
			
			cd "$DM_tl/Feeds/kept/.audio"
			ls *.mp3 > "$DC_tl/$jlb/cfg.5"
			mv *.mp3 "$DM_tl/.share/"
			
			mkdir "$DM_tl/$jlb/words"
			cd "$DM_tl/Feeds/kept/words"
			cp -f *.mp3 "$DM_tl/$jlb/words" && rm *.mp3
			
			mkdir "$DM_tl/$jlb/words/images"
			
			touch "$DC_tl/Feeds/cfg.0"
			touch "$DC_tl/Feeds/cfg.3"
			touch "$DC_tl/Feeds/cfg.4"
			touch "$DC_tl/$jlb/cfg.2"
			
			cnt=$(cat "$DC_tl/$jlb/cfg.0" | wc -l)
			echo "aitm.$cnt.aitm" >> \
			$DC/addons/stats/.log &
			
			[[ -f $DT/ntpc ]] && rm -f $DT/ntpc
			
			cp -f "$DC_tl/$jlb/cfg.0" "$DC_tl/$jlb/cfg.1"
			cp -f $DS/default/tpc.sh "$DC_tl/$jlb/tpc.sh"
			chmod +x "$DC_tl/$jlb/tpc.sh"
			echo "$(date +%F)" > "$DC_tl/$jlb/cfg.12"
			echo "1" > "$DC_tl/$jlb/cfg.8"
			echo "$jlb" >> $DC_tl/.cfg.2
			
			"$DC_tl/$jlb/tpc.sh"
			$DS/mngr.sh mkmn
		fi
fi