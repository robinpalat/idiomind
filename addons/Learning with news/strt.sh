#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source /usr/share/idiomind/ifs/trans/$lgs/rss.conf

DSF="$DS/addons/Learning with news"
DCF="$DC/addons/Learning with news"

function msg() {
	
	yad --window-icon=idiomind --name=idiomind \
	--image=$2 --on-top --text=" $1 " \
	--image-on-top --center --sticky --button="Ok":0 \
	--width=420 --height=150 --borders=5 \
	--skip-taskbar --title="Idiomind"
}

[[ -f $DT/.uptf ]] && STT=$(cat $DT/.uptf) || STT=""

[[ ! -f $DC/addons/dict/.dicts ]] && touch $DC/addons/dict/.dicts


if [[ -z "$(cat $DC/addons/dict/.dicts)" ]]; then
	source $DS/ifs/trans/$lgs/topics_lists.conf
	$DS/addons/Dics/cnfg.sh "" f "$no_dictionary"
	if  [[ -z "$(cat $DC/addons/dict/.dicts)" ]]; then
		exit 1
	fi
fi


if echo "$STT" | grep "Actualizando..."; then
	yad --image=info --width=420 --height=150 \
	--window-icon=idiomind \
	--title=Info --center --borders=5 \
	--on-top --skip-taskbar --button="$cancel":2 \
	--button=Ok:1 --text=" $updating"
	ret=$?
		if [ $ret -eq 1 ]; then
			exit 1
		elif [ $ret -eq 2 ]; then
			"$DSF/tls.sh stop"
		fi
	exit 1
fi
sleep 1

dct="$DS/addons/Dics/cnfg.sh"
feed=$(sed -n 1p "$DCF/$lgtl/link")
rsrc=$(cat "$DCF/$lgtl/.rss")

icon=$DS/images/cnn.png
date=$(date "+%a %d %B")
c=$(echo $(($RANDOM%1000)))

if [ ! -d $DM_tl/Feeds ]; then

	mkdir $DM_tl/Feeds
	mkdir $DM_tl/Feeds/conten
	mkdir $DM_tl/Feeds/kept
	mkdir $DM_tl/Feeds/kept/.audio
	mkdir $DM_tl/Feeds/kept/words
	mkdir $DC_tl/Feeds/
	
	if [ ! -d "$DCF/$lgtl" ]; then
		mkdir "$DCF/$lgtl"
		mkdir "$DCF/$lgtl/subscripts"
		cp $DSF/examples/$lgtl \
		"$DCF/$lgtl/subscripts/Example"
		cp $DSF/examples/$lgtl.txt \
		"$DCF/$lgtl/subscripts/Example.txt"
	fi
	
	echo '#!/bin/bash
source /usr/share/idiomind/ifs/c.conf
uid=$(sed -n 1p $DC_s/cfg.4)
FEED=$(cat "$DC/addons/Learning with news/$lgtl/.rss")
[ ! -f $DC_tl/Feeds/cfg.8 ] && echo "11" > $DC_tl/Feeds/cfg.8
[ ! -f $DC_tl/Feeds/cfg.0 ] && touch $DC_tl/Feeds/cfg.0
[ ! -f $DC_tl/Feeds/cfg.1 ] && touch $DC_tl/Feeds/cfg.1
[ ! -f $DC_tl/Feeds/cfg.3 ] && touch $DC_tl/Feeds/cfg.3
[ ! -f $DC_tl/Feeds/cfg.4 ] && touch $DC_tl/Feeds/cfg.4
sleep 1
echo "$tpc" > $DC_s/cfg.8
echo fd >> $DC_s/cfg.8
notify-send -i idiomind "Feed Mode" " $FEED" -t 3000
exit 1' > $DC_tl/Feeds/tpc.sh
	chmod +x $DC_tl/Feeds/tpc.sh
	echo "11" > $DC_tl/Feeds/cfg.8
	cd $DC_tl/Feeds
	touch cfg.0 cfg.1 cfg.3 cfg.4 .updt.lst
	$DS/mngr.sh mkmn
fi

if [ -n "$feed" ]; then
	curl -v www.google.com 2>&1 | \
	grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
	yad --window-icon=idiomind --on-top \
	--image=info --name=idiomind \
	--text=" $connection_err  \\n" \
	--image-on-top --center --sticky \
	--width=420 --height=150 --borders=3 \
	--skip-taskbar --title=Idiomind \
	--button=Ok:0 >&2; exit 1;}
	
	echo "- Feeds Mode ( Actualizando... 5% )" > $DT/.uptf
	
	if [ "$1" != A ]; then
		echo "$tpc" > $DC_s/cfg.8
		echo fd >> $DC_s/cfg.8
		echo "11" > $DC_tl/Feeds/cfg.8
		notify-send -i idiomind "$rsrc" "$updating" -t 3000 &
	fi
	
	DT_r=$(mktemp -d $DT/XXXXXX)
	cd $DT_r
	echo "$rsrc" > $DT/.rss
	rsstail -NHPl -n 8 -1 -u "$feed" > rss.txt
	cat rss.txt | sed -n 2~2p | sed 's/^ *//g' | sed 's/\&/\\/g' > lnk
	cat rss.txt | sed -n 1~2p | sed 's/://g' | sed 's/\&//g' | sed 's/"//g' \
	| sed "s/'//g" | sed 's/^ *//g' | sed 's/-/ /g' \
	| sed 's/^[ \t]*//;s/[ \t]*$//g' > rss
	
	if [ $(cat rss | wc -l) = 0 ]; then
		$yad --window-icon=idiomind --on-top \
		--image=info --name=idiomind \
		--text="<b>$link_err</b>" \
		--image-on-top --center --sticky \
		--width=420 --height=150 --borders=3 \
		--skip-taskbar --title=Idiomind \
		--button=Ok:0 &
		rm -fr $DT_r .rss & exit 1
	fi
	
	n=1
	while [ $n -le $(cat rss | wc -l) ]; do
			f="5"
			if [[ "$(cat $DT/.uptf \
			| grep -o "Actualizando...")" = "Actualizando..." ]]; then
				echo "- feeds Mode ( Actualizando... $n$f% )" > $DT/.uptf
			fi
		trgt=$(sed -n "$n"p rss)
		lnk=$(sed -n "$n"p lnk)
		
		if [[ "$trgt" != "$(grep "$trgt" $DC_tl/Feeds/.updt.lst)" ]]; then

			nme="$(echo "$trgt" | cut -c 1-100 | sed 's/[ \t]*$//' | sed s'/&//'g | sed s'/://'g | sed "s/'/ /g")"

			mkdir "$nme"
			result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lgs" --data-urlencode text="$trgt" https://translate.google.com)
			encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
			iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 | sed 's/\n/ /g' > srce
			srce=$(cat srce | sed ':a;N;$!ba;s/\n/ /g')
			
			if [[ $(sed -n 1p $DC_s/cfg.3) != TRUE ]]; then
				vs=$(sed -n 7p $DC_s/cfg.1)
				if [ -n "$vs" ]; then
					if [ "$vs" = 'festival' ] || [ "$vs" = 'text2wave' ]; then
						lg=$(echo $lgtl | awk '{print tolower($0)}')
						
						if ([ $lg = "english" ] || [ $lg = "spanish" ] || [ $lg = "russian" ]); then

							echo "$trgt" | text2wave -o $DT_r/s.wav
							sox $DT_r/s.wav "$nme.mp3"
						else
							rm -fr $DT_r $DT/.uptf $DT/.rss
							msg "$festival_err $lgtl" error
							break && exit
						fi
					else
						cd $DT_r
						echo "$trgt" | $vs
						if [ -f *.mp3 ]; then
							mv -f *.mp3 "$nme.mp3"
						elif [ -f *.wav ]; then
							sox *.wav "$nme.mp3"
						fi
					fi
				else
					lg=$(echo $lgtl | awk '{print tolower($0)}')
					if [ $lg = chinese ]; then
						lg=Mandarin
					elif [ $lg = japanese ]; then

						rm -fr $DT_r $DT/.uptf $DT/.rss
						msg "$espeak_err $lgtl" error
						break && exit
					fi
					espeak "$trgt" -v $lg -k 1 -p 65 -a 80 -s 120 -w $DT_r/s.wav
					sox $DT_r/s.wav "$nme.mp3"
				fi
			else
				wget -q -U Mozilla -O ./"$nme.mp3" "https://translate.google.com/translate_tts?ie=UTF-8&tl=$lgt&q=$trgt"
			fi
			
			eyeD3 --set-encoding=utf8 -t ISI1I0I"$trgt"ISI1I0I -a ISI2I0I"$srce"ISI2I0I "$nme.mp3"
			echo "$trgt" >> "$DC_tl/Feeds/cfg.1"
			
			> swrd
			> twrd
			if [[ $lgt = ja ]] || [[ $lgt = 'zh-cn' ]]; then
				vrbl="$srce"; lg=$lgt; aw=$DT/swrd; bw=$DT/twrd
			else
				vrbl="$trgt"; lg=$lgs; aw=$DT/twrd; bw=$DT/swrd
			fi
			echo  "$vrbl" | sed 's/ /\n/g' | grep -v '^.$' | grep -v '^..$' \
			| sed -n 1,20p | sed s'/&//'g | sed 's/\.//g' | sed 's/,//g' \
			| sed 's/ /\. /g'  | awk '{print tolower($0)}' > $aw
			twrd=$(cat $aw | sed '/^$/d')
			result=$(curl -s -i --user-agent "" -d "sl=auto" -d "tl=$lg" --data-urlencode text="$twrd" https://translate.google.com)
			encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
			iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8 > $bw
			sed -i 's/\. /\n/g' $bw
			sed -i 's/\. /\n/g' $aw

			if [[ $lgt = ja ]] || [[ $lgt = 'zh-cn' ]]; then
				(
				n=1
				while [ $n -le "$(cat $aw | wc -l)" ]; do
					s=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
					t=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
					echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A
					echo "$t"_"$s""" >> B
					let n++
				done
				)
			else
				(
				n=1
				while [ $n -le "$(cat $aw | wc -l)" ]; do
					t=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
					s=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
					echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A
					echo "$t"_"$s""" >> B
					let n++
				done
				)
			fi
			lwrds=$(cat A)
			pwrds=$(cat B | tr '\n' '_')
			eyeD3 --set-encoding=utf8 -A IWI3I0I"$lwrds"IWI3I0IIPWI3I0I"$pwrds"IPWI3I0I "$nme".mp3
			(
			if [[ $lgt = ja ]] || [[ $lgt = 'zh-cn' ]]; then
				n=1
				while [ $n -le $(cat $bw | wc -l) ]; do
					t=$(sed -n "$n"p $bw)
					$dct "$t" $DT_r swrd
					mv "$t.mp3" "$nme/$t.mp3"
					let n++
				done
			else
				n=1
				while [ $n -le $(cat $aw | wc -l) ]; do
					t=$(sed -n "$n"p $aw)
					$dct "$t" $DT_r swrd
					mv "$t.mp3" "$nme/$t.mp3"
					let n++
				done
			fi
			)
			cp -fr "./$nme" "$DM_tl/Feeds/conten/$nme"
			mv -f "$nme.mp3" "$DM_tl/Feeds/conten/$nme.mp3"
			echo "$lnk" > "$DM_tl/Feeds/conten/$nme.lnk"
			rm -f A B twrd swrd srce
			notify-send -i idiomind "$trgt" "$srce" -t 12000 &
			echo "$date" > $DC_tl/Feeds/.dt
		fi
		
		let n++
	done

	mv -f $DT_r/rss "$DC_tl/Feeds/.updt.lst"
	rm -fr $DT_r $DT/.uptf $DT/.rss
	cd "$DM_tl/Feeds/conten"
	find *.mp3 -mtime +5 -exec ls > ls {} \;
	
	n=1
	while [ $n -le $(cat ls | wc -l) ]; do
		nmfile=$(sed -n "$n"p ls)
		tgs=$(eyeD3 "$DM_tl/Feeds/conten/$nmfile")
		trg=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
		grep -v -x -v "$trg" "$DC_tl/Feeds/cfg.1" > "$DC_tl/Feeds/cfg.1._"
		sed '/^$/d' "$DC_tl/Feeds/cfg.1._" > "$DC_tl/Feeds/cfg.1"
		let n++
	done
	rm "$DC_tl/Feeds/cfg.1._"
	
	if [[ -d "$DM_tl/Feeds/conten" ]]; then
	cd "$DM_tl/Feeds/conten"
	find ./* -mtime +5 -exec rm -r {} \; &
	fi

	if [ "$1" != A ]; then
		notify-send -i idiomind "$rsrc" " $updateok" -t 3000
	fi
	
	exit
else
	exit
fi
