#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/add.conf

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
	--text=" $connection_err  \\n  " \
	--image-on-top --center --sticky \
	--width=420 --height=150 --borders=3 \
	--skip-taskbar --title=Idiomind \
	--button="  Ok  ":0 >&2; exit 1;}
}

function grammar_1() {
	
	cd $2; n=1
	while [ $n -le $(echo "$1" | wc -l) ]; do
		grmrk=$(echo "$1" | sed -n "$n"p)
		chck=$(echo "$1" | sed -n "$n"p | awk '{print tolower($0)}' \
		| sed 's/,//g' | sed 's/\.//g')
		if echo "$pronouns" | grep -Fxq $chck; then
			echo "<span color='#35559C'>$grmrk</span>" >> g_$3
		elif echo "$nouns_verbs" | grep -Fxq $chck; then
			echo "<span color='#896E7A'>$grmrk</span>" >> g_$3
		elif echo "$conjunctions" | grep -Fxq $chck; then
			echo "<span color='#90B33B'>$grmrk</span>" >> g_$3
		elif echo "$verbs" | grep -Fxq $chck; then
			echo "<span color='#CF387F'>$grmrk</span>" >> g_$3
		elif echo "$prepositions" | grep -Fxq $chck; then
			echo "<span color='#D67B2D'>$grmrk</span>" >> g_$3
		elif echo "$adverbs" | grep -Fxq $chck; then
			echo "<span color='#9C68BD'>$grmrk</span>" >> g_$3
		elif echo "$nouns_adjetives" | grep -Fxq $chck; then
			echo "<span color='#496E60'>$grmrk</span>" >> g_$3
		elif echo "$adjetives" | grep -Fxq $chck; then
			echo "<span color='#3E8A3B'>$grmrk</span>" >> g_$3
		else
			echo "$grmrk" >> g_$3
		fi
		let n++
	done
}

function grammar_2() {

	if echo "$pronouns" | grep -Fxq "${1,,}"; then echo 'Pron. ';
	elif echo "$conjunctions" | grep -Fxq "${1,,}"; then echo 'Conj. ';
	elif echo "$prepositions" | grep -Fxq "${1,,}"; then echo 'Prep. ';
	elif echo "$adverbs" | grep -Fxq "${1,,}"; then echo 'adv. ';
	elif echo "$nouns_adjetives" | grep -Fxq "${1,,}"; then echo 'Noun, Adj. ';
	elif echo "$nouns_verbs" | grep -Fxq "${1,,}"; then echo 'Noun, Verb ';
	elif echo "$verbs" | grep -Fxq "${1,,}"; then echo 'verb. ';
	elif echo "$adjetives" | grep -Fxq "${1,,}"; then echo 'adj. '; fi
}

function tts() {
	
	cd $3; xargs -n10 < "$1" > ./temp
	[[ -n "$(sed -n 1p ./temp)" ]] && wget -q -U Mozilla -O $DT_r/tmp01.mp3 \
	"https://translate.google.com/translate_tts?ie=UTF-8&tl=$2&q=$(sed -n 1p ./temp)"
	[[ -n "$(sed -n 2p ./temp)" ]] && wget -q -U Mozilla -O $DT_r/tmp02.mp3 \
	"https://translate.google.com/translate_tts?ie=UTF-8&tl=$2&q=$(sed -n 2p ./temp)"
	[[ -n "$(sed -n 3p ./temp)" ]] && wget -q -U Mozilla -O $DT_r/tmp03.mp3 \
	"https://translate.google.com/translate_tts?ie=UTF-8&tl=$2&q=$(sed -n 3p ./temp)"
	[[ -n "$(sed -n 4p ./temp)" ]] && wget -q -U Mozilla -O $DT_r/tmp04.mp3 \
	"https://translate.google.com/translate_tts?ie=UTF-8&tl=$2&q=$(sed -n 4p ./temp)"
	cat tmp01.mp3 tmp02.mp3 tmp03.mp3 tmp04.mp3 > "$DM_tlt/$4.mp3"
}

function nmfile() {
	
	echo "$(echo "$1" | cut -c 1-100 | sed 's/[ \t]*$//' \
	| sed s'/&//'g | sed s'/://'g | sed "s/'/ /g" | sed "s/’/ /g")"
}

function clean_1() {
	
	echo "$(echo "$1" | sed ':a;N;$!ba;s/\n/ /g' \
	| sed 's/"//g' | sed 's/“//g' | sed s'/&//'g \
	| sed 's/”//g' | sed s'/://'g | sed "s/’/'/g" \
	| sed 's/^[ \t]*//;s/[ \t]*$//')"
}

function clean_word_list() {
	
	echo "$(echo "$1" | sed 's/ /\n/g' | grep -v '^.$' \
	| grep -v '^..$' | sed -n 1,40p | sed s'/&//'g \
	| sed 's/,//g' | sed 's/\?//g' | sed 's/\¿//g' \
	| sed 's/;//g' | sed 's/\!//g' | sed 's/\¡//g' \
	| tr -d ')' | tr -d '(' | sed 's/\]//g' | sed 's/\[//g' \
	| sed 's/\.//g' | sed 's/  / /g' | sed 's/ /\. /g')"
}

function tags_1() {
	
	eyeD3 --set-encoding=utf8 \
	-t I$1I1I0I"$2"I$1I1I0I \
	-a I$1I2I0I"$3"I$1I2I0I "$4"
}

function tags_2() {
	
	eyeD3 --set-encoding=utf8 \
	-t IWI1I0I"$2"IWI1I0I \
	-a IWI2I0I"$3"IWI2I0I \
	-A IWI3I0I"$4"IWI3I0I "$5"
}

function tags_3() {
	
	eyeD3 --set-encoding=utf8 \
	-A IWI3I0I"$2"IWI3I0IIPWI3I0I"$3"IPWI3I0IIGMI3I0I"$4"IGMI3I0I "$5"
}

function tags_4() {
	
	eyeD3 --set-encoding=utf8 \
	-t ISI1I0I"$2"ISI1I0I \
	-a ISI2I0I"$3"ISI2I0I \
	-A IWI3I0I"$4"IWI3I0IIPWI3I0I"$5"IPWI3I0IIGMI3I0I"$6"IGMI3I0I "$7"
}

function voice() {
	
	cd $DT_r; vs=$(sed -n 7p $DC_s/cfg.1)
	if [ -n "$vs" ]; then
	
		if [ "$vs" = 'festival' ] || [ "$vs" = 'text2wave' ]; then
			lg=$(echo $lgtl | awk '{print tolower($0)}')

			if ([ $lg = "english" ] \
			|| [ $lg = "spanish" ] \
			|| [ $lg = "russian" ]); then
			echo "$1" | text2wave -o $DT_r/s.wav
			sox $DT_r/s.wav "$2"
			else
				msg "$festival_err $lgtl" error
				exit 1
			fi
		else
			echo "$1" | "$vs"
			if [ -f *.mp3 ]; then
				mv -f *.mp3 "$2"
			elif [ -f *.wav ]; then
				sox *.wav "$2"
			fi
		fi
	else
		lg=$(echo $lgtl | awk '{print tolower($0)}')
		if [ $lg = chinese ]; then
			lg=Mandarin
		elif [ $lg = japanese ]; then
			msg "$espeak_err $lgtl" error
			exit 1
		fi
		espeak "$1" -v $lg -k 1 -p 40 -a 80 -s 110 -w $DT_r/s.wav
		sox $DT_r/s.wav "$2"
	fi
}

function audio_recognize() {
	
	echo "$(wget -q -U "Mozilla/5.0" --post-file "$1" --header="Content-Type: audio/x-flac; rate=16000" \
	-O - "https://www.google.com/speech-api/v2/recognize?&lang="$2"-"$3"&key=$4")"
}

function translate() {
	
	result=$(curl -s -i --user-agent "" -d "sl=$2" -d "tl=$3" --data-urlencode text="$1" https://translate.google.com)
	encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
	t=$(iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8)
	echo "$t"
}

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
		jlbi=$(yad --window-icon=idiomind --form --center \
		--field="$name_for_new_topic" "$nmt" --title="$tle" \
		--width=440 --height=100 --name=idiomind --on-top \
		--skip-taskbar --borders=5 --button=gtk-ok:0)
		
		jlb=$(echo "$jlbi" | cut -d "|" -f1 | sed s'/!//'g \
		| sed s'/&//'g | sed s'/\://'g | sed s'/\&//'g \
		| sed s"/'//"g | sed 's/^[ \t]*//;s/[ \t]*$//' \
		| sed 's/^\s*./\U&\E/g')
		
		snm=$(cat $DC_tl/.cfg.1 | grep -Fxo "$jlb" | wc -l)
		if [ $snm -ge 1 ]; then
			jlb=$(echo ""$jlb" $snm")
			yad --name=idiomind --center --on-top --image=info \
			--text=" <b>$name_eq   </b>\\n $name_eq2  <b>$jlb</b>   \\n" \
			--image-on-top --width=420 --height=150 --borders=3 \
			--skip-taskbar --window-icon=idiomind --sticky \
			--title=Idiomind --button="$cancel":1 --button=gtk-ok:0
			ret=$?
				
				if [ "$ret" -eq 1 ]; then
					exit 1
				fi
		else
			jlb=$(echo "$jlb")
		fi
		
		if [ -z "$jlb" ]; then
			exit 1
		else
			mkdir $DM_tl/"$jlb"
			mkdir $DM_tl/"$jlb"/words
			mkdir $DM_tl/"$jlb"/words/images
			mkdir $DC_tl/"$jlb"
			mkdir $DC_tl/"$jlb"/practice
			
			cd "$DM_tl/$tpc"
			cp -fr ./* "$DM_tl/$jlb"

			cd "$DC_tl/$tpc"
			cp -fr ./.* "$DC_tl/$jlb"/
			
			echo "$jlb" >> $DC_tl/.cfg.2
			grep -v -x -F "$tpc" $DC_tl/.cfg.2 > $DC_tl/.cfg.2_
			sed '/^$/d' $DC_tl/.cfg.2_ > $DC_tl/.cfg.2
			grep -v -x -F "$tpc" $DC_tl/.cfg.1 > $DC_tl/.cfg.1_
			sed '/^$/d' $DC_tl/.cfg.1_ > $DC_tl/.cfg.1
			grep -v -x -F "$tpc" $DC_tl/.cfg.3 > $DC_tl/.cfg.3_
			sed '/^$/d' $DC_tl/.cfg.3_ > $DC_tl/.cfg.3

			[[ -d "$DC_tl/$tpc" ]] && rm -r "$DC_tl/$tpc"
			[[ -d "$DM_tl/$tpc" ]] && rm -r "$DM_tl/$tpc"
			
			$DS/mngr.sh mkmn
			"$DC_tl/$jlb/tpc.sh" & exit 1
		fi
		
		[ "$?" -eq 1 ] && exit
	else
		
		[[ -z "$2" ]] && nmt="" || nmt="$2"
		
		if [ $info2 -ge 50 ]; then
			rm "$DM_tl/.rn"
			msg "$topics_max" info &&
			killall add.sh & exit 1
		fi
		
		jlbi=$(yad --window-icon=idiomind \
		--form --center --title="$new_topic"  --separator="\n" \
		--width=440 --height=100 --name=idiomind --on-top \
		--skip-taskbar --borders=5 --button=gtk-ok:0 \
		--field=" $name_for_new_topic: " "$nmt")
			
			jlb=$(echo "$jlbi" | sed -n 1p | cut -d "|" -f1 | sed s'/!//'g \
			| sed s'/&//'g | sed s'/://'g | sed s'/\&//'g \
			| sed s"/'//"g | sed 's/^[ \t]*//;s/[ \t]*$//' \
			| sed 's/^\s*./\U&\E/g')
			ABC=$(echo "$jlbi" | sed -n 2p)
			
			snme=$(cat $DC_tl/.cfg.1 | grep -Fxo "$jlb" | wc -l)
			if [ "$snme" -ge 1 ]; then
				jlb="$jlb $snme"
				yad --name=idiomind --center --on-top --image=info \
				--text=" <b>$name_eq   </b>\\n $name_eq2  <b>$jlb</b>   \\n" \
				--image-on-top --width=420 --height=150 --borders=3 \
				--skip-taskbar --window-icon=idiomind --sticky \
				--title=Idiomind --button="$cancel":1 --button=gtk-ok:0
				ret=$?
				
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
	
elif [ $1 = new_items ]; then

	[[ ! -f $DC/addons/dict/.dicts ]] && touch $DC/addons/dict/.dicts
	if  [ -z "$(cat $DC/addons/dict/.dicts)" ]; then
		source $DS/ifs/trans/$lgs/topics_lists.conf
		$DS/addons/Dics/cnfg.sh "" f "$no_dictionary"
		[[ -z "$(cat $DC/addons/dict/.dicts)" ]] && exit 1
	fi
	c=$(echo $(($RANDOM%1000)))
	txt="$4"; [[ -z "$txt" ]] && txt="$(xclip -selection primary -o)"

	if [ "$3" = 2 ]; then
		DT_r="$2"
		cd $DT_r
		[[ ! $(sed -n 1p $DC_s/cfg.3 | grep TRUE) ]] && srce="$5"
	else
		DT_r=$(mktemp -d $DT/XXXXXX)
		cd $DT_r
	fi
	
	[[ -f $DT_r/ico.jpg ]] && img="--image=$DT_r/ico.jpg" \
	|| img="--image=$DS/images/nw.png"
	
	
	if [ "$(cat $DC_tl/.cfg.1 | grep -v 'Feeds' | wc -l)" -lt 1 ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		source $DS/ifs/trans/$lgs/topics_lists.conf
		$DS/chng.sh "$no_topic" & exit 1
	fi
	
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

	
	if sed -n 1p $DC_s/cfg.3 | grep TRUE; then
	lzgpr=$(yad --form --center --always-print-result \
	--on-top --window-icon=idiomind --skip-taskbar \
	--separator="\n" --align=right $img \
	--name=idiomind --class=idiomind \
	--borders=0 --title=" " --width=440 --height=140 \
	--field=" <small><small>$lgtl</small></small>: " "$txt" \
	--field=" <small><small>$topic</small></small>:CB" \
	"$ttle!$new *$e$tpcs" "$field" \
	--button="$image":3 --button=Audio:2 --button=gtk-ok:0)
	elif sed -n 1p $DC_s/cfg.3 | grep FALSE; then
	lzgpr=$(yad --form --center --always-print-result \
	--on-top --window-icon=idiomind --skip-taskbar \
	--separator="\n" --align=right $img \
	--name=idiomind --class=idiomind \
	--borders=0 --title=" " --width=440 --height=170 \
	--field=" <small><small>$lgtl</small></small>: " "$txt" \
	--field=" <small><small>${lgsl^}</small></small>: " "$srce" \
	--field=" <small><small>$topic</small></small>:CB" \
	"$ttle!$new *$e$tpcs" "$field" \
	--button="$image":3 --button=Audio:2 --button=gtk-ok:0)
	fi
	ret=$?

	trgt=$(echo "$lzgpr" | head -n -1 | sed -n 1p | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
	srce=$(echo "$lzgpr" | sed -n 2p | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
	chk=$(echo "$lzgpr" | tail -1)
	tpe=$(cat "$DC_tl/.cfg.1" | grep "$chk")
	echo "$chk"
		
		if [ $ret -eq 3 ]; then
		
			cd $DT_r
			scrot -s --quality 70 img.jpg
			/usr/bin/convert -scale 110x90! img.jpg ico.jpg
			$DS/add.sh new_items $DT_r 2 "$trgt" "$srce" && exit 1
		
		elif [ $ret -eq 2 ]; then
		
			$DS/ifs/tls.sh add_audio $DT_r
			$DS/add.sh new_items $DT_r 2 "$trgt" "$srce" && exit 1
		
		elif [ $ret -eq 0 ]; then
		
			if [ -z "$trgt" ]; then
				[[ -d $DT_r ]] && rm -fr $DT_r
				exit
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
					slt=`echo "$tpe" | awk '{print "FALSE\n"$0}' | \
					yad --name=idiomind --class=idiomind --center \
					--list --radiolist --on-top --fixed --no-headers \
					--text="<b>  $te </b> <small><small> --window-icon=idiomind \
					$info</small></small>" --sticky --skip-taskbar \
					--height="420" --width="150" --separator="\\n" \
					--button=Save:0 --title="selector" --borders=3 \
					--column=" " --column="Sentences"`
					if [ -z "$(echo "$slt" | sed -n 2p)" ]; then
						killall add.sh & exit
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
			
			if [ "$(echo "$trgt" | sed -n 1p | awk '{print tolower($0)}')" = i ]; then
				$DS/add.sh other_ways image $DT_r & exit 1
			elif [ "$(echo "$trgt" | sed -n 1p | awk '{print tolower($0)}')" = a ]; then
				$DS/add.sh other_ways audio $DT_r & exit 1
			elif [ $(echo ${trgt:0:4}) = 'Http' ]; then
				$DS/add.sh other_ways "$trgt" $DT_r & exit 1
			elif [ $(echo "$trgt" | wc -c) -gt 180 ]; then
				$DS/add.sh other_ways "$trgt" $DT_r & exit 1
			elif ([ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]); then
				if sed -n 1p $DC_s/cfg.3 | grep FALSE; then
					if [ -z "$4" ]; then
						[[ -d $DT_r ]] && rm -fr $DT_r
						msg "$no_text$lgsl." info & exit
					elif [ -z "$2" ]; then
						[[ -d $DT_r ]] && rm -fr $DT_r
						msg "$no_text$lgtl." info & exit
					fi
				fi

				srce=$(translate "$trgt" auto $lgs)
				
				if [ $(echo "$srce" | wc -w) = 1 ]; then
					$DS/add.sh new_word "$trgt" $DT_r "$srce" & exit
				elif [ $(echo "$srce" | wc -w) -ge 1 -a $(echo "$srce" | wc -c) -le 180 ]; then
					$DS/add.sh new_sentence "$trgt" $DT_r "$srce" & exit
				fi
			elif ([ $lgt != ja ] || [ $lgt != 'zh-cn' ] || [ $lgt != ru ]); then
				if [ $(echo "$trgt" | wc -w) = 1 ]; then
					$DS/add.sh new_word "$trgt" $DT_r "$srce" & exit
				elif [ $(echo "$trgt" | wc -w) -ge 1 -a $(echo "$trgt" | wc -c) -le 180 ]; then
					$DS/add.sh new_sentence "$trgt" $DT_r "$srce" & exit
				fi
			fi
		else
			[[ -d $DT_r ]] && rm -fr $DT_r
			exit
		fi
		
elif [ $1 = new_sentence ]; then

	if [ -z "$tpe" ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$no_topic_msg." info & exit
	fi
		
	DT_r="$3"
	source $DS/default/dicts/$lgt


	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	icnn=idiomind
	
	dct=$DS/addons/Dics/cnfg.sh
			
	if [ $(cat "$DC_tlt/cfg.4" | wc -l) -ge 50 ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$tpe    \\n$sentences_max" info & exit
	fi
	
	if sed -n 1p $DC_s/cfg.3 | grep TRUE; then
	
		internet
	
		cd $DT_r
		
		txt="$(clean_1 "$2")"

		translate "$txt" auto $lgt > ./.en
		
		sed -i ':a;N;$!ba;s/\n/ /g' ./.en
		sed -i 's/  / /g' ./.en
		sed -i 's/  / /g' ./.en
		
		trgt=$(cat ./.en | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
		
		nme="$(nmfile "$trgt")"

		translate "$trgt" $lgt $lgs > ./.es
		
		sed -i ':a;N;$!ba;s/\n/ /g' ./.es
		srce=$(cat ./.es)
		
		sed -i 's/,/ /g' .en
		sed -i "s/'/ /g" .en
		sed -i 's/’/ /g' .en
		
		if [ ! -f $DT_r/audtm.mp3 ]; then
		
			tts .en $lgt $DT_r "$nme"
		else
			cp -f $DT_r/audtm.mp3 "$DM_tlt/$nme.mp3"
		fi
		tags_1 S "$trgt" "$srce" "$DM_tlt/$nme.mp3"

		if [ -f img.jpg ]; then
			/usr/bin/convert -scale 450x270! img.jpg imgs.jpg
			eyeD3 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/$nme".mp3
			icnn=img.jpg
		fi
		
		notify-send -i "$icnn" "$trgt" "$srce \\n($tpe)" -t 10000
		$DS/mngr.sh inx S "$trgt" "$tpe"
		
		cd $DT_r
		> swrd
		> twrd
		if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
			vrbl="$srce"; lg=$lgt; aw=$DT/swrd; bw=$DT/twrd
		else
			vrbl="$trgt"; lg=$lgs; aw=$DT/twrd; bw=$DT/swrd
		fi
		
		clean_word_list "$vrbl" > $aw

		twrd=$(cat $aw | sed '/^$/d')

		src=$(translate "$twrd" auto $lg)
		
		echo "$src" | sed 's/,//g' | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw
		sed -i 's/\. /\n/g' $bw
		sed -i 's/\. /\n/g' $aw

		snmk=$(echo "$trgt"  | sed 's/ /\n/g')
		
		grammar_1 "$snmk" $DT_r
		
		if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
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

		grmrk=$(cat g_ | sed ':a;N;$!ba;s/\n/ /g')
		lwrds=$(cat A)
		pwrds=$(cat B | tr '\n' '_')
		tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$nme.mp3"
		
		(
		if [ $(sed -n 4p $DC_s/cfg.1) = TRUE ]; then
		$DS/add.sh selecting_words "$nme" "$tpe"
		fi
		) &
		
		if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
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
		[[ -d $DT_r ]] && rm -fr $DT_r
		rm -f $DT/twrd $DT/swrd &
		echo "aitm.1.aitm" >> \
		$DC/addons/stats/.log
		exit 1
		
	else
		if [ -z "$4" ]; then
			[[ -d $DT_r ]] && rm -fr $DT_r
			msg "$no_text$lgsl." info & exit
		elif [ -z "$2" ]; then
			[[ -d $DT_r ]] && rm -fr $DT_r
			msg "$no_text$lgtl." info & exit
		fi
		
		cd $DT_r
		echo "$2" | sed ':a;N;$!ba;s/\n/ /g' \
		| sed 's/  / /g' | sed 's/   / /g' \
		| sed 's/"//g' | sed 's/^[ \t]*//;s/[ \t]*$//' > trgt
		
		trgt="$(cat trgt)"
		nme="$(nmfile "$(cat ./trgt)")"
		srce="$4"
		> swrd
		> twrd
		if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
			vrbl="$srce"; lg=$lgt; aw=$DT/swrd; bw=$DT/twrd
		else
			vrbl="$trgt"; lg=$lgs; aw=$DT/twrd; bw=$DT/swrd
		fi

		clean_word_list "$vrbl" > $aw
		
		twrd=$(cat $aw | sed '/^$/d')
		
		src=$(translate "$twrd" auto $lg)
		echo "$src" | sed 's/,//g' | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw

		sed -i 's/\. /\n/g' $bw
		sed -i 's/\. /\n/g' $aw

		snmk=$(echo "$trgt"  | sed 's/ /\n/g')
		
		grammar_1 "$snmk" $DT_r
		
		if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
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

		grmrk=$(cat g_ | sed ':a;N;$!ba;s/\n/ /g')
		lwrds=$(cat A)
		pwrds=$(cat B | tr '\n' '_')
		
		if [ -f $DT_r/audtm.mp3 ]; then
		
			mv -f $DT_r/audtm.mp3 "$DM_tlt/$nme.mp3"

				if [ -f img.jpg ]; then
					/usr/bin/convert -scale 450x270! img.jpg imgs.jpg
					eyeD3 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/$nme.mp3"
				fi
				
		else
			voice "$trgt" "$DM_tlt/$nme.mp3"
			
				if [ -f img.jpg ]; then
					/usr/bin/convert -scale 450x270! img.jpg imgs.jpg
					eyeD3 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/$nme.mp3"
					icnn=img.jpg
				fi
		fi
		
		tags_4 S "$trgt" "$srce" "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$nme.mp3"
		
		notify-send -i "$icnn" "$trgt" "$srce \\n($tpe)" -t 10000
		$DS/mngr.sh inx S "$trgt" "$tpe"
		
		if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
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
		[[ -d $DT_r ]] && rm -fr $DT_r
		rm -f $DT/twrd $DT/swrd & exit 1
	fi

elif [ $1 = new_word ]; then

	trgt="$2"
	srce="$4"
	dct="$DS/addons/Dics/cnfg.sh"
	source $DS/default/dicts/$lgt
	icnn=idiomind
	tpcs=$(cat "$DC_tl/.cfg.2" | cut -c 1-30 | egrep -v "$tpe" \
	| tr "\\n" '!' | sed 's/!\+$//g')
	ttle="${tpe:0:30}"
	DT_r="$3"
	cd $DT_r
	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	
	if [ $(cat "$DC_tlt/cfg.3" | wc -l) -ge 50 ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$tpe    \\n$words_max" info & exit 1
	fi
	
	internet
	
	if sed -n 1p $DC_s/cfg.3 | grep TRUE; then

		trgt="$(translate "$trgt" auto $lgt)"
		srce="$(translate "$trgt" $lgt $lgs)"
		$dct "$trgt" $DT_r swrd
		nme=$(echo "$trgt" | sed "s/'//g")
		
		if [ -f "$DT_r/$trgt.mp3" ]; then

			cp -f "$DT_r/$trgt.mp3" "$DM_tlt/words/$nme.mp3"
			tags_1 W "$trgt" "$srce" "$DM_tlt/words/$nme.mp3"
			
			nt="$(echo "_$(grammar_2 $trgt)" | tr '\n' '_')"
			eyeD3 --set-encoding=utf8 -A IWI3I0I"$nt"IWI3I0I "$DM_tlt/words/$nme.mp3"
			
		else exit 1; fi
		
		if [ -f img.jpg ]; then
			/usr/bin/convert -scale 100x90! img.jpg imgs.jpg
			/usr/bin/convert -scale 360x240! img.jpg imgt.jpg
			eyeD3 --set-encoding=utf8 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/words/$nme.mp3"
			mv -f imgt.jpg "$DM_tlt/words/images/$nme.jpg"
			icnn=img.jpg
		fi
		
		
		
		notify-send -i "$icnn" "$trgt" "$srce\\n  ($tpe)" -t 5000
		$DS/mngr.sh inx W "$nme" "$tpe"
		
		echo "aitm.1.aitm" >> \
		$DC/addons/stats/.log
		[[ -d $DT_r ]] && rm -fr $DT_r
		rm -f *.jpg
		
	else
		if [ -z "$4" ]; then
			[[ -d $DT_r ]] && rm -fr $DT_r
			msg "$no_text$lgsl." info & exit
		elif [ -z "$2" ]; then
			[[ -d $DT_r ]] && rm -fr $DT_r
			msg "$no_text$lgtl." info & exit 1
		fi
		
		if [ -f audtm.mp3 ]; then
			mv -f audtm.mp3 "$DM_tlt/words/$trgt.mp3"
			
			tags_1 W "$trgt" "$srce" "$DM_tlt/words/$trgt.mp3"

			if [ -f img.jpg ]; then
				/usr/bin/convert -scale 100x90! img.jpg imgs.jpg
				/usr/bin/convert -scale 360x240! img.jpg imgt.jpg
				eyeD3 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/words/$trgt.mp3"
				mv -f imgt.jpg "$DM_tlt/words/images/$trgt.jpg"
			fi
			
		else
			cd $DT_r
			$dct "$trgt" $DT_r swrd
			
			if [ -f "$DT_r/$trgt.mp3" ]; then
			
				mv -f "$DT_r/$trgt.mp3" "$DM_tlt/words/$trgt.mp3"

				if [ -f img.jpg ]; then
					/usr/bin/convert -scale 100x90! img.jpg imgs.jpg
					/usr/bin/convert -scale 360x240! img.jpg imgt.jpg
					eyeD3 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/words/$trgt.mp3"
					mv -f imgt.jpg "$DM_tlt/words/images/$trgt.jpg"
				fi
				
			else
				voice "$trgt" "$DM_tlt/words/$trgt.mp3"
				
				if [ -f img.jpg ]; then
					/usr/bin/convert -scale 100x90! -border 0.5 \
					-bordercolor '#9A9A9A' img.jpg imgs.jpg
					/usr/bin/convert -scale 360x240! img.jpg imgt.jpg
					eyeD3 --add-image imgs.jpg:ILLUSTRATION "$DM_tlt/words/$trgt.mp3"
					mv -f imgt.jpg "$DM_tlt/words/images/$trgt.jpg"
				fi
			fi
		fi
		tags_1 W "$trgt" "$srce" "$DM_tlt/words/$trgt.mp3"
		
		nt="$(echo "_$(grammar_2 $trgt)" | tr '\n' '_')"
		eyeD3 --set-encoding=utf8 -A IWI3I0I"$nt"IWI3I0I "$DM_tlt/words/$trgt.mp3"
			
		icnn="$DM_tlt/words/images/$trgt.jpg"
		notify-send -i "$icnn" "$trgt" "$srce\\n ($tpe)" -t 3000
		$DS/mngr.sh inx W "$trgt" "$tpe"
		
		echo "aitm.1.aitm" >> \
		$DC/addons/stats/.log
		[[ -d $DT_r ]] && rm -fr $DT_r
		exit
	fi
	
elif [ $1 = selecting_words_edit ]; then

	c="$4"
	DIC=$DS/addons/Dics/cnfg.sh

	if [ "$3" = "F" ]; then

		tpe="$tpc"
		if [ $(cat "$DC_tlt/cfg.3" | wc -l) -ge 50 ]; then
			[[ -d $DT_r ]] && rm -fr $DT_r
			msg "$tpe    \\n$words_max" info & exit
		fi
		
		nw=$(cat "$DC_tlt/cfg.3" | wc -l)
		left=$((50 - $nw))
		info=$(echo " $remain"$left"$words")
		if [ $nw -ge 45 ]; then
			info=$(echo " $remain"$left"$words")
		elif [ $nw -ge 49 ]; then
			info=$(echo " $remain"$left"$word")
		fi

		mkdir $DT/$c
		DT_r=$DT/$c
		cd $DT_r
		file="$DM_tlt/$2.mp3"
		
		if [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
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
		yad --list --checklist \
		--on-top --text="<small> $info </small>" \
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
			if [ $(cat "$DC_tlt/cfg.3" | wc -l) -ge 50 ]; then
				echo "$trgt
" > logw
				
			else
				translate "$trgt" auto $lgs > tr."$c"
				
				UNI=$(cat tr."$c")
				
				$DIC "$trgt" $DT_r swrd
				
				if [ -f "$trgt.mp3" ]; then
				
					mv -f $DT_r/"$trgt.mp3" "$DM_tlt/words/$trgt.mp3"
				else
				
					voice "$trgt" "$DM_tlt/words/$trgt.mp3"
				fi
				
				tags_2 W "$trgt" "$UNI" "$5" "$DM_tlt/words/$trgt.mp3" >/dev/null 2>&1
				
				$DS/mngr.sh inx W "$trgt" "$tpc" "$nme"
			fi
			
			let n++
		done

		echo "aitm.$lns.aitm" >> \
		$DC/addons/stats/.log &

			if [ -f $DT_r/logw ]; then
				yad --name=idiomind --class=idiomind \
				--center --wrap --text-info --skip-taskbar \
				--width=400 --height=280 --on-top --margins=4 \
				--fontname=vendana --window-icon=idiomind \
				--button=Ok:0 --borders=0 --filename=logw --title="$ttl" \
				--text=" <b>  ! </b><small><small> $items_rest </small></small>" \
				--field=":lbl" "" >/dev/null 2>&1
			fi
			[[ -d $DT_r ]] && rm -fr $DT_r
			rm -f logw $DT/*.$c & exit 1
	fi
	
elif [ $1 = selecting_words_dclik ]; then

	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	DT_r=$(cat $DT/.n_s_pr)
	cd $DT_r
	echo "$3" > ./lstws
	
	if [ -z "$tpe" ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		source $DS/ifs/trans/$lgs/topics_lists.conf
		$DS/chng.sh "$no_edit" & exit 1
	fi
	
	nw=$(cat "$DC_tlt/cfg.3" | wc -l)
	
	if [ $(cat "$DC_tlt/cfg.3" | wc -l) -ge 50 ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		msg "$tpe    \\n$words_max" info & exit
	fi

	left=$((50 - $nw))
	info=$(echo " $remain"$left"$words")
	if [ $nw -ge 45 ]; then
		info=$(echo " $remain"$left"$words")
	elif [ $nw -ge 49 ]; then
		info=$(echo " $remain"$left"$word ")
	fi

	if [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
	    cat ./lstws | tr ' ' '\n' | sed -n 1~2p | sed '/^$/d' > lst
	else
	    cat ./lstws | tr -c "[:alnum:]" '\n' | sed '/^$/d' | sed '/"("/d' \
	    | sed '/")"/d' | sed '/":"/d' | sort -u \
	    | head -n40 | egrep -v "FALSE" | egrep -v "TRUE" > lst
	fi
	
	nme="$(nmfile "$(cat ./lstws)")"

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
		yad --list --checklist --window-icon=idiomind \
		--on-top --text="<small> $info </small>" \
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

elif [ $1 = selecting_words ]; then

	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	DIC=$DS/addons/Dics/cnfg.sh
	c=$(echo $(($RANDOM%100)))
	DT_r=$(mktemp -d $DT/XXXXXX)
	cd $DT_r
	if [ -z "$tpe" ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		source $DS/ifs/trans/$lgs/topics_lists.conf
		$DS/chng.sh "$no_edit" & exit 1
	fi
	nw=$(cat "$DC_tlt/words/cfg.3" | wc -l)
	left=$((50 - $nw))
	if [ "$left" = 0 ]; then
		exit 1
		info=$(echo " $remain"$left"$words")
	elif [ $nw -ge 45 ]; then
		info=$(echo " $remain"$left"$words")
	elif [ $nw -ge 49 ]; then
		info=$(echo " $remain"$left"$word)")
	fi

	if [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
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
	yad --list --checklist \
	--on-top --text="<small> $info </small>" \
	--fixed --sticky --no-headers --center \
	--buttons-layout=end --skip-taskbar --width=400 \
	--height=280 --borders=10 --window-icon=idiomind \
	--button=gtk-close:1 --button="$add":0 \
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
			[[ -d $DT_r ]] && rm -fr $DT_r
			exit
		fi
			
	EX=$(echo "$2")
	ADD=$(wc -l ./slts)
	n=1
	while [ $n -le $(cat ./slts | head -50 | wc -l) ]; do
		trgt=$(sed -n "$n"p ./slts | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
		if [ $(cat "$DC_tlt/cfg.3" | wc -l) -ge 50 ]; then
			echo "$trgt" >> logw
		else
			translate "$trgt" auto $lgs > tr."$c"
			
			UNI=$(cat ./tr."$c")
			$DIC "$trgt" $DT_r swrd
			
			if [ -f "$trgt.mp3" ]; then
			
				mv -f "$DT_r/$trgt.mp3" "$DM_tlt/words/$trgt.mp3"
				
			else
				voice "$trgt" "$DM_tlt/words/$trgt.mp3"
			fi
			
			tags_2 W "$trgt" "$UNI" "$2" "$DM_tlt/words/$trgt.mp3" >/dev/null 2>&1
			
			$DS/mngr.sh inx W "$trgt" "$3"
		fi
		let n++
	done

	echo "aitm.$lns.aitm" >> \
	$DC/addons/stats/.log &

	if [ -f $DT_r/logw ]; then
		yad --name=idiomind --class=idiomind \
		--center --wrap --text-info --skip-taskbar \
		--width=400 --height=280 --on-top --margins=4 \
		--fontname=vendana --window-icon=idiomind \
		--button="Ok:0" --borders=0 --filename=logw --title="$ttl" \
		--text=" <b>  ! </b><small><small> $items_rest</small></small>" \
		--field=":lbl" "" >/dev/null 2>&1
	fi
	rm -f $DT/*."$c" 
	[[ -d $DT_r ]] && rm -fr $DT_r
	exit
	
elif [ $1 = other_ways ]; then

	source $DS/ifs/trans/$lgs/add.conf
	wth=$(sed -n 3p $DC_s/cfg.18)
	eht=$(sed -n 4p $DC_s/cfg.18)
	ns=$(cat "$DC_tlt"/cfg.4 | wc -l)
	source $DS/default/dicts/$lgt
	nspr='/usr/share/idiomind/add.sh other_ways'
	LNK='http://www.chromium.org/developers/how-tos/api-keys'
	dct=$DS/addons/Dics/cnfg.sh
	lckpr=$DT/.n_s_pr
	DM_tlt="$DM_tl/$tpe"
	DC_tlt="$DC_tl/$tpe"
	DT_r="$3"
	cd "$DT_r"

	if [ -z "$tpe" ]; then
		[[ -d $DT_r ]] && rm -fr $DT_r
		source $DS/ifs/trans/$lgs/topics_lists.conf
		$DS/chng.sh "$no_edit" & exit 1
	fi

	if [ $ns -ge 50 ]; then
		msg "$tpe    \\n$sentences_max" info
		[[ -d $DT_r ]] && rm -fr $DT_r
		rm -f ls $lckpr & exit
	fi

	if [ -f $lckpr ]; then
		yad --fixed --center --on-top \
		--image=info --name=idiomind \
		--text=" $current_pros  " \
		--fixed --sticky --buttons-layout=edge \
		--width=420 --height=150  --borders=5 \
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

	if [ "$(echo "$prdt")" = "audio" ]; then

		left=$((50 - $(cat "$DC_tlt/cfg.4" | wc -l)))
		key=$(sed -n 2p $DC_s/cfg.3)
		
		if [ -z "$key" ]; then
			yad --name=idiomind --center --on-top --image=error \
			--text="$no_key <a href='$LNK'> Google.</a>" \
			--image-on-top --sticky --title="Idiomind" \
			--width=420 --height=150 --button=gtk-ok:0 \
			--skip-taskbar --window-icon=idiomind && \
			[[ -d $DT_r ]] && rm -fr $DT_r
			rm -f ls $lckpr & exit 1
		fi
		
		cd $HOME
		FL=$(yad --borders=0 --name=idiomind --file-filter="*.mp3" \
		--skip-taskbar --on-top --title="Speech recognize" --center \
		--window-icon=idiomind --file --width=600 --height=450)
		
		if [ -z "$FL" ];then
			[[ -d $DT_r ]] && rm -fr $DT_r
			rm -f $lckpr & exit 1
			
		else
			if [ -z "$tpe" ]; then
				[[ -d $DT_r ]] && rm -fr $DT_r
				source $DS/ifs/trans/$lgs/topics_lists.conf
				$DS/chng.sh "$no_edit" & exit 1
			fi
			cd $DT_r
			
			(
			echo "2"
			echo "# $file_pros" ; sleep 1
			cp -f "$FL" $DT_r/rv.mp3
			cd $DT_r
			eyeD3 -P itunes-podcast --remove "$DT_r"/rv.mp3
			eyeD3 --remove-all "$DT_r"/rv.mp3
			sox "$DT_r"/rv.mp3 "$DT_r"/c_rv.mp3 remix - highpass 100 norm \
			compand 0.05,0.2 6:-54,-90,-36,-36,-24,-24,0,-12 0 -90 0.1 \
			vad -T 0.6 -p 0.2 -t 5 fade 0.1 reverse \
			vad -T 0.6 -p 0.2 -t 5 fade 0.1 reverse norm -0.5
			rm -f "$DT_r"/rv.mp3
			mp3splt -s -o @n *.mp3
			rename 's/^0*//' *.mp3
			rm -f "$DT_r"/c_rv.mp3
			ls *.mp3 > lst
			lns=$(cat ./lst | head -50 | wc -l)
			
			internet
			 
			echo "3"
			echo "# $check_key... " ; sleep 1
			
			data="$(audio_recognize "$DS/addons/Google translation service/test.flac" $lgt $lgt $key)"
			
			if [ -z "$data" ]; then
				key=$(sed -n 3p $DC_s/cfg.3)
				data="$(audio_recognize "$DS/addons/Google translation service/test.flac" $lgt $lgt $key)"
			fi
			
			if [ -z "$data" ]; then
				key=$(sed -n 4p $DC_s/cfg.3)
				data="$(audio_recognize "$DS/addons/Google translation service/test.flac" $lgt $lgt $key)"
			fi
			
			if [ -z "$data" ]; then
				yad --name=idiomind --center --on-top --image=error \
				--text="$key_err <a href='$LNK'>Google. </a>" \
				--image-on-top --sticky --title="Idiomind" \
				--width=420 --height=150 --borders=3 --button=gtk-ok:0 \
				--skip-taskbar --window-icon=idiomind && \
				[[ -d $DT_r ]] && rm -fr $DT_r
				rm -f ls $lckpr & exit 1
			fi
			
			echo "# $file_pros" ; sleep 0.2
			#----------------------
			n=1
			while [ $n -le "$lns" ]; do

				sox "$n".mp3 info.flac rate 16k
				
				data="$(audio_recognize info.flac $lgt $lgt $key)"

				if [ -z "$data" ]; then
					yad --name=idiomind --center --on-top --image=error \
					--text="$key_err <a href='$LNK'>Google</a>" \
					--image-on-top --sticky --title="Idiomind" \
					--width=420 --height=150 --button=gtk-ok:0 \
					--skip-taskbar --window-icon=idiomind &
					[[ -d $DT_r ]] && rm -fr $DT_r
					rm -f ls $lckpr & break & exit 1
				fi

				trgt="$(echo "$data" | sed '1d' | sed 's/.*transcript":"//' \
				| sed 's/"}],"final":true}],"result_index":0}//g')"
				
				if [ $(echo "$trgt" | wc -c) -gt 180 ]; then
					echo "
$trgt" >> log
				
				else
					nme="$(nmfile "$trgt")"
					
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
			
			) | yad --progress --progress-text=" " \
			--width=200 --height=20 --geometry=200x20-2-2 \
			--undecorated --auto-close --on-top \
			--skip-taskbar --no-buttons
			
			sed -i '/^$/d' ./ls
			[[ $(echo "$tpe" | wc -c) -gt 40 ]] && tcnm="${tpe:0:40}..." || tcnm="$tpe"

			left=$((50 - $(cat "$DC_tlt"/cfg.4 | wc -l)))
			info=$(echo "$remain"$left"$sentences")
			if [ $ns -ge 45 ]; then
				info=$(echo "$remain"$left"$sentences")
			elif [ $ns -ge 49 ]; then
				info=$(echo "$remain"$left"$sentence")
			fi
			
			if [ -z "$(cat ls)" ]; then
				echo "$gettext_err" | yad --text-info --center --wrap \
				--name=idiomind --class=idiomind --window-icon=idiomind \
				--text=" " --sticky --width=$wth --height=$eht \
				--margins=8 --borders=3 --button=gtk-ok:0 \
				--title="$Title_sentences" && \
				[[ -d $DT_r ]] && rm -fr $DT_r
				rm -f $lckpr & exit 1
				
			else
				slt=$(mktemp $DT/slt.XXXX.x)
				cat ls | awk '{print "FALSE\n"$0}' | \
				yad --center --sticky \
				--name=idiomind --class=idiomind \
				--dclick-action='/usr/share/idiomind/add.sh selecting_words_dclik' \
				--list --checklist --window-icon=idiomind \
				--width=$wth --text="<small>$info</small>" \
				--height=$eht --borders=3 --button=gtk-cancel:1 \
				--button="$to_new_topic":'/usr/share/idiomind/add.sh new_topic' \
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
					
					internet
					
					#---------------
					(
					echo "1"
					echo "# $pros... " ;
					[ $lgt = ja ] || [ $lgt = "zh-cn" ] || [ $lgt = ru ] && c=c || c=w
					lns=$(cat ./slts ./wrds | wc -l)
					n=1
					while [ $n -le $(cat ./slts | head -50 | wc -l) ]; do
						
						sntc=$(sed -n "$n"p ./slts)
						trgt=$(cat "./$sntc.txt")
						nme="$(nmfile "$sntc")"
						
						if [ $(sed -n 1p "$sntc.txt" | wc -$c) -eq 1 ]; then
						
							if [ $(cat "$DC_tlt"/cfg.3 | wc -l) -ge 50 ]; then
								echo "
$sntc" >> ./slog
						
							else
								srce="$(translate "$trgt" $lgt $lgs)"

								tags_1 W "$trgt" "$srce" "$DT_r/$sntc.mp3"
								
								mv -f "$sntc".mp3 "$DM_tlt/words/$nme".mp3
								$DS/mngr.sh inx W "$nme" "$tpe"
								echo "$nme" >> addw
							fi
						
						elif [ $(sed -n 1p "$sntc.txt" | wc -$c) -ge 1 ]; then
						
							if [ $(cat "$DC_tlt"/cfg.4 | wc -l) -ge 50 ]; then
								echo "
$sntc" >> ./wlog
						
							else
								srce="$(translate "$trgt" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')"
								
								tags_1 S "$trgt" "$srce" "$DT_r/$sntc.mp3"

								mv -f "$sntc.mp3" "$DM_tlt/$nme.mp3"
								$DS/mngr.sh inx S "$trgt" "$tpe"
								echo "$nme" >> adds
								
								(
								r=$(echo $(($RANDOM%1000)))
								> twrd_$r
								> swrd_$r
								if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
									vrbl="$srce"; lg=$lgt; aw=$DT/swrd_$r; bw=$DT/twrd_$r
								else
									vrbl="$trgt"; lg=$lgs; aw=$DT/twrd_$r; bw=$DT/swrd_$r
								fi

								clean_word_list "$vrbl" > $aw
								
								twrd=$(cat $aw | sed '/^$/d')

								srce="$(translate "$twrd" auto $lg)"
								
								echo "$srce" | sed 's/,//g' | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw
								
								> A_$r
								> B_$r
								> g_$r
								sed -i 's/\. /\n/g' $bw
								sed -i 's/\. /\n/g' $aw
								snmk=$(echo "$trgt"  | sed 's/ /\n/g')
								grammar_1 "$snmk" $DT_r $r
								
								if ([ "$lgt" = ja ] || [ "$lgt" = 'zh-cn' ] || [ "$lgt" = ru ]); then
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
								grmrk=$(cat g_$r | sed ':a;N;$!ba;s/\n/ /g')
								lwrds=$(cat A_$r)
								pwrds=$(cat B_$r | tr '\n' '_')

								tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$nme.mp3"

								if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
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
					
					#-words
					if [ -n "$(cat wrds)" ]; then
						nwrds=" y $(cat wrds | head -50 | wc -l) Palabras"
					fi
					
					n=1
					while [ $n -le "$(cat wrds | head -50 | wc -l)" ]; do
						trgt=$(sed -n "$n"p wrds | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
						exmp=$(sed -n "$n"p wrdsls)

						nme="$(nmfile "$exmp")"

						if [ $(cat "$DC_tlt"/cfg.3 | wc -l) -ge 50 ]; then
							echo "
$trgt" >> ./wlog
					
						else
							srce="$(translate "$trgt" auto $lgs)"

							$dct "$trgt" $DT_r swrd
							
							if [ -f "$trgt".mp3 ]; then
							
								mv -f "$DT_r/$trgt.mp3" "$DM_tlt/words/$trgt.mp3"
							else
								voice "$trgt" "$DM_tlt/words/$trgt.mp3"
								
							fi
							tags_2 W "$trgt" "$srce" "$exmp" "$DM_tlt/words/$trgt.mp3" >/dev/null 2>&1
							
							echo "$trgt" >> addw
							$DS/mngr.sh inx W "$trgt" "$tpe" "$nme"
						fi
						nn=$(($n+$(cat ./slts | wc -l)-1))
						prg=$((100*$nn/$lns))
						echo "$prg"
						echo "# ${trgt:0:35} ... " ;
						
						let n++
					done
					) | yad --progress --progress-text=" " \
					--width=200 --height=20 --geometry=200x20-2-2 \
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
						sadds=" $(cat ./adds | wc -l)"
						S=" $sentences"
						if [ $(echo $sadds) = 1 ]; then
							S=" $sentence"
						fi
					fi
					
					logs=$(cat ./slog ./wlog)
					adds=$(cat ./adds ./addw | wc -l)
					
					if [ $adds -ge 1 ]; then
						notify-send -i idiomind "$tpe" "$is_added\n$sadds$S$wadds$W" -t 2000 &
						echo "aitm.$adds.aitm" >> \
						$DC/addons/stats/.log
					fi
					
					if [ -f ./log ]; then
						if [ $(ls ./*.mp3 | wc -l) -ge 1 ]; then
							btn="--button=$save:0"
						fi
						yad --form --name=idiomind --class=idiomind \
						--center --skip-taskbar --on-top \
						--width=420 --height=150 --on-top --margins=4 \
						--window-icon=idiomind \
						--borders=0 --title="Idiomind" \
						--field="<small><small> $items_rest $logn</small></small>":txt "$log" \
						--field=":lbl"\
						"$btn" --button=Ok:1 >/dev/null 2>&1
							ret=$?
						
							if  [ "$ret" -eq 0 ]; then
								aud=$(yad --save --center --borders=10 \
								--on-top --filename="$(date +%m/%d/%Y)"_audio.tar.gz \
								--window-icon=idiomind --skip-taskbar --title="Save" \
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
					while [[ $n -le 20 ]]; do
						 sleep 5
						 if ([ $(cat ./x | wc -l) = $rm ] || [ $n = 20 ]); then
							[[ -d $DT_r ]] && rm -fr $DT_r
							rm -f $lckpr & break & exit 1
						 fi
						let n++
					done
					exit 1
				else
					[[ -d $DT_r ]] && rm -fr $DT_r
					rm -f $lckpr $slt & exit 1
				fi
		fi
	fi

	if [ $(echo ${2:0:4}) = 'Http' ]; then
	
		internet
		
		(
		echo "1"
		echo "# $pros..." ;
		lynx -dump -nolist $2  | sed -n -e '1x;1!H;${x;s-\n- -gp}' \
		| sed 's/\./\.\n/g' | sed 's/<[^>]*>//g' | sed 's/ \+/ /g' \
		| sed '/^$/d' | sed 's/  / /g' | sed 's/^[ \t]*//;s/[ \t]*$//g' \
		| sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
		| sed 's/<[^>]\+>//g' | sed 's/\://g' >> ./sntsls_
		
		) | yad --progress --progress-text=" " \
		--width=200 --height=20 --geometry=200x20-2-2 \
		--pulsate --percentage="5" --on-top \
		--undecorated --auto-close \
		--skip-taskbar --no-buttons

	elif [[ "$(echo "$2" | grep -o "i")" = i ]]; then
		
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
		| sed 's/  / /g' | sed 's/\://g' > ./sntsls_
		
		) | yad --progress --progress-text=" " \
		--width=200 --height=20 --geometry=200x20-2-2 \
		--pulsate --percentage="5" --on-top \
		--undecorated --auto-close \
		--skip-taskbar --no-buttons
	else
		(
		echo "1"
		echo "# $pros..." ;
		echo "$prdt" | sed 's/\\n/./g' | sed 's/\./\n/g' \
		| sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//' \
		| sed 's/  / /g' | sed 's/\://g' > ./sntsls_
		
		) | yad --progress --progress-text=" " \
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

		sed -i '/^$/d' ./sntsls
		[[ $(echo "$tpe" | wc -c) -gt 40 ]] && tcnm="${tpe:0:40}..." || tcnm="$tpe"
		
		left=$((50 - $ns))
		info=$(echo "$remain$left$sentences")

		if [ $ns -ge 45 ]; then
			info=$(echo "$remain$left$sentences")
		elif [ $ns -ge 49 ]; then
			info=$(echo "$remain$left$sentence")
		fi
		
		if [ -z "$(cat ./sntsls)" ]; then
			echo "  $gettext_err1. " | \
			yad --text-info --center --wrap \
			--name=idiomind --class=idiomind --window-icon=idiomind \
			--text=" " --sticky --width=$wth --height=$eht \
			--borders=3 --button=Ok:0 --title="$selector"
			[[ -d $DT_r ]] && rm -fr $DT_r
			rm -f $lckpr $slt & exit 1
		
		else
			slt=$(mktemp $DT/slt.XXXX.x)
			cat ./sntsls | awk '{print "FALSE\n"$0}' | \
			yad --name=idiomind --window-icon=idiomind \
			--dclick-action='/usr/share/idiomind/add.sh selecting_words_dclik' \
			--list --checklist --class=idiomind --center --sticky \
			--text="<small> $info</small>" \
			--width=$wth --print-all --height=$eht --borders=3 \
			--button="$cancel":1 \
			--button="$arrange":2 \
			--button="$to_new_topic":'/usr/share/idiomind/add.sh new_topic' \
			--button=gtk-save:0 --title="$tpe" \
			--column="$(cat ./sntsls | wc -l)" --column="$sentences" > $slt
				ret=$?
		fi
				if [ $ret -eq 2 ]; then
					rm -f $lckpr "$slt" &
					w=`cat ./sntsls | awk '{print "\n\n\n"$0}' | \
					yad --text-info --editable --window-icon=idiomind \
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
					> ./wlog
					> ./slog
					
					#words
					{
					echo "5"
					echo "# $pros... " ;
					[ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ] && c=c || c=w
					lns=$(cat ./slts ./wrds | wc -l)
					n=1
					while [ $n -le $(cat slts | head -50 | wc -l) ]; do
						sntc=$(sed -n "$n"p slts)
						if [ $(echo "$sntc" | wc -$c) = 1 ]; then
							if [ $(cat "$DC_tlt"/cfg.3 | wc -l) -ge 50 ]; then
								echo "
$sntc" >> ./wlog
						
							else
								trgt="$(translate "$sntc" auto $lgt)"

								srce="$(translate "$trgt" $lgt $lgs)"
								
								wget -q -U Mozilla -O $DT_r/$trgt.mp3 "https://translate.google.com/translate_tts?ie=UTF-8&tl=$lgt&q=$trgt"
								
								tags_1 W "$trgt" "$srce" "$DT_r/$trgt.mp3"

								mv -f "$trgt".mp3 "$DM_tlt/words/$trgt".mp3
								echo "$trgt" >> addw
								
								$DS/mngr.sh inx W "$trgt" "$tpe"
							fi
						#words
						elif [ $(echo "$sntc" | wc -$c) -ge 1 ]; then
							
							if [ $(cat "$DC_tlt"/cfg.4 | wc -l) -ge 50 ]; then
								echo "
$sntc" >> ./slog
						
							else
								if [ $(echo "$sntc" | wc -c) -ge 180 ]; then
									echo "
$sntc" >> ./slog
							
								else
									txt="$(clean_1 "$sntc")"
									
									translate "$txt" auto $lgt > ./trgt

									sed -i ':a;N;$!ba;s/\n/ /g' ./trgt
									trgt=$(cat ./trgt | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
									
									nme="$(nmfile "$trgt")" #sed -i 's/,/ /g' ./trgt
									
									srce="$(translate "$trgt" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')"
									
									if sed -n 1p $DC_s/cfg.3 | grep TRUE; then
									
										tts ./trgt $lgt $DT_r "$nme"
										
									else
										voice "$trgt" "$DM_tlt/$nme.mp3"
										
									fi

									tags_1 S "$trgt" "$srce" "$DM_tlt/$nme.mp3"
									
									echo "$nme" >> adds
									$DS/mngr.sh inx S "$trgt" "$tpe"
									(	
										r=$(echo $(($RANDOM%1000)))
										> twrd_$r
										> swrd_$r
										if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
											vrbl="$srce"; lg=$lgt; aw=$DT/swrd_$r; bw=$DT/twrd_$r
										else
											vrbl="$trgt"; lg=$lgs; aw=$DT/twrd_$r; bw=$DT/swrd_$r
										fi

										clean_word_list "$vrbl" > $aw
										twrd=$(cat $aw | sed '/^$/d')
										
										translate "$twrd" auto $lg | sed 's/,//g' | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw
										
										> A_$r
										> B_$r
										> g_$r
										sed -i 's/\. /\n/g' $bw
										sed -i 's/\. /\n/g' $aw
										snmk=$(echo "$trgt"  | sed 's/ /\n/g')
										
										grammar_1 "$snmk" $DT_r $r
										
										if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
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
										
										grmrk=$(cat g_$r | sed ':a;N;$!ba;s/\n/ /g')
										lwrds=$(cat A_$r)
										pwrds=$(cat B_$r | tr '\n' '_')
										tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$nme.mp3"
										
										if ([ "$lgt" = ja ] || [ "$lgt" = 'zh-cn' ] || [ "$lgt" = ru ]); then
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
										rm -f $aw $bw 
										
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
					
					#words
					n=1
					while [ $n -le $(cat wrds | head -50 | wc -l) ]; do
					
						exmp=$(sed -n "$n"p wrdsls)
						itm=$(sed -n "$n"p wrds | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
						nme="$(nmfile "$exmp")"

						if [ $(cat "$DC_tlt"/cfg.3 | wc -l) -ge 50 ]; then
							echo "
$itm" >> ./wlog
					
						else
							
							srce="$(translate "$itm" auto $lgs)"
							
							$dct "$itm" $DT_r swrd
							
							if [ -f "$itm".mp3 ]; then
								mv -f "$DT_r/$itm.mp3" "$DM_tlt/words/$itm.mp3"
								
								tags_2 W "$itm" "$srce" "$exmp" "$DM_tlt/words/$itm.mp3"

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
					} | yad --progress --progress-text=" " \
					--width=200 --height=20 --geometry=200x20-2-2 \
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
						echo "aitm.$adds.aitm" >> \
						$DC/addons/stats/.log
					fi
					
					if [ $(cat ./slog ./wlog | wc -l) -ge 1 ]; then
						echo "$logs" | yad --name=idiomind --class=idiomind \
						--center --wrap --text-info --editable --skip-taskbar \
						--width=420 --height=150 --on-top --margins=4 \
						--fontname=vendana --window-icon=idiomind \
						--button=Ok:0 --borders=0 --title="Idiomind" \
						--text=" <small><small> $items_rest</small></small>" \
						--field=":lbl" "" >/dev/null 2>&1
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
							rm -f $lckpr & break & exit 1
						 fi
						let n++
					done
					
				else
					[[ -d $DT_r ]] && rm -fr $DT_r
					 rm -f $lckpr $slt & exit 1
				fi
				
elif [ $1 = add_image ]; then
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
	
	if [ "$3" = word ]; then
		
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
		
		yad --form --align=center --center \
		--width=340 --text-align=center --height=280 \
		--on-top --skip-taskbar --image-on-top "$txt">/dev/null 2>&1 \
		"$btnn" --window-icon=idiomind --borders=0 \
		--title=Image "$ICON" "$btn2" \
		--button=gtk-close:1
			ret=$? >/dev/null 2>&1
			
			if [ $ret -eq 3 ]; then
			
				rm -f *.l
				scrot -s --quality 70 "$wrd.temp.jpeg"
				/usr/bin/convert -scale 100x90! "$wrd.temp.jpeg" "$wrd"_temp.jpeg
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
			
	elif [ "$3" = sentence ]; then
	
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
		
		yad --form --text-align=center \
		--center --width=470 --height=280 \
		--on-top --skip-taskbar --image-on-top \
		"$txt" "$btnn" --window-icon=idiomind --borders=0 \
		--title="Image" "$ICON" "$btn2" --button=gtk-close:1
			ret=$? >/dev/null 2>&1
				
			if [ $ret -eq 3 ]; then
			
				rm -f $DT/*.l
				scrot -s --quality 70 "$wrd.temp.jpeg"
				/usr/bin/convert -scale 450x270! "$wrd.temp.jpeg" "$wrd"_temp.jpeg
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
