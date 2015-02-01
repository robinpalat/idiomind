#!/bin/bash
# -*- ENCODING: UTF-8 -*-


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
	cat tmp01.mp3 tmp02.mp3 tmp03.mp3 tmp04.mp3 > "$4"
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


function clean_2() { # name topic
    
    echo "$(echo "$1" | cut -d "|" -f1 | sed s'/!//'g \
    | sed s'/&//'g | sed s'/\://'g | sed s'/\&//'g \
    | sed s"/'//"g | sed 's/^[ \t]*//;s/[ \t]*$//' \
    | sed 's/^\s*./\U&\E/g')"
}    


function clean_3() {
	
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


function tags_5() {
	
	eyeD3 --set-encoding=utf8 \
	-a I$1I2I0I"$2"I$I2I0I "$3"
}


function tags_6() {
	
	eyeD3 --set-encoding=utf8 \
	-A IWI3I0I"$2"IWI3I0I "$3"
}


function tags_7() {
	
	eyeD3 --set-encoding=utf8 \
	-t ISI1I0I"$2"ISI1I0I "$3"
}


function tags_8() {
	
	eyeD3 -p I$1I4I0I"$2"I$1I4I0I "$3"
}


function tags_9() {
	
	eyeD3 --set-encoding=utf8 -A IWI3I0I"$2"IWI3I0IIPWI3I0I"$3"IPWI3I0I "$4"
}


function voice() {
	
	cd $DT_r; vs=$(sed -n 10p $DC_s/cfg.1)
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


function scrot_1() {
	
	scrot -s --quality 70 img.jpg
	/usr/bin/convert -scale 110x90! img.jpg ico.jpg
}


function scrot_2() {
	
	/usr/bin/convert -scale 450x270! img.jpg imgs.jpg
	eyeD3 --add-image imgs.jpg:ILLUSTRATION "$1"
}


function scrot_3() {
	
	/usr/bin/convert -scale 100x90! img.jpg imgs.jpg
	/usr/bin/convert -scale 360x240! img.jpg imgt.jpg
	eyeD3 --set-encoding=utf8 --add-image imgs.jpg:ILLUSTRATION "$1"
	mv -f imgt.jpg "$2"
}


function scrot_4() {

	scrot -s --quality 70 "$1.temp.jpeg"
	/usr/bin/convert -scale 100x90! "$1.temp.jpeg" "$1"_temp.jpeg
	/usr/bin/convert -scale 360x240! "$1.temp.jpeg" "$3.jpg"
	eyeD3 --remove-images "$2" >/dev/null 2>&1
	eyeD3 --add-image "$1"_temp.jpeg:ILLUSTRATION "$2"
}


function scrot_5() {
	
	scrot -s --quality 70 "$1.temp.jpeg"
	/usr/bin/convert -scale 450x270! "$1.temp.jpeg" "$1"_temp.jpeg
	eyeD3 --remove-image "$2" >/dev/null 2>&1
	eyeD3 --add-image "$1"_temp.jpeg:ILLUSTRATION "$2"
}


function list_words() {
    
	cd $3
	if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
		n=1
		while [ $n -le "$(cat $1 | wc -l)" ]; do
			s=$(sed -n "$n"p $1 | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
			t=$(sed -n "$n"p $2 | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
			echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A_$4
			echo "$t"_"$s""" >> B_$4
			let n++
		done
	else
		n=1
		while [ $n -le "$(cat $1 | wc -l)" ]; do
			t=$(sed -n "$n"p $1 | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
			s=$(sed -n "$n"p $2 | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
			echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A_$4
			echo "$t"_"$s""" >> B_$4
			let n++
		done
	fi
}


function get_words() {
    
	if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
		n=1
		while [ $n -le $(cat $2 | wc -l) ]; do
			$dct $(sed -n "$n"p $2) $DT_r
			let n++
		done
	else
		n=1
		while [ $n -le $(cat $1 | wc -l) ]; do
			$dct $(sed -n "$n"p $1) $DT_r
			let n++
		done
	fi
}


function get_words_2() {
	
	if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
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

}


function list_words_2() {

	    if [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
			eyeD3 "$1" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' \
			| tr '_' '\n' | sed -n 1~2p | sed '/^$/d' > idlst
	    else
			list=$(eyeD3 "$1" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
			echo "$list" | tr -c "[:alnum:]" '\n' | sed '/^$/d' | sed '/"("/d' \
			| sed '/")"/d' | sed '/":"/d' | sort -u \
			| head -n40 > idlst
	    fi
}


function list_words_3() {

	if [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
		cat "$1" | tr ' ' '\n' | sed -n 1~2p | sed '/^$/d' > lst
	else
		cat "$1" | tr -c "[:alnum:]" '\n' | sed '/^$/d' | sed '/"("/d' \
		| sed '/")"/d' | sed '/":"/d' | sort -u \
		| head -n40 | egrep -v "FALSE" | egrep -v "TRUE" > lst
	fi
}

