#!/bin/bash
# -*- ENCODING: UTF-8 -*-


function check_grammar_1() {
	
	g=$(echo "$trgt"  | sed 's/ /\n/g')
	cd $1; touch A.$r B.$r g.$r; n=1
	while [ $n -le $(echo "$g" | wc -l) ]; do
		grmrk=$(echo "$g" | sed -n "$n"p)
		chck=$(echo "$g" | sed -n "$n"p | awk '{print tolower($0)}' \
		| sed 's/,//g' | sed 's/\.//g')
		if echo "$pronouns" | grep -Fxq $chck; then
			echo "<span color='#35559C'>$grmrk</span>" >> g.$2
		elif echo "$nouns_verbs" | grep -Fxq $chck; then
			echo "<span color='#896E7A'>$grmrk</span>" >> g.$2
		elif echo "$conjunctions" | grep -Fxq $chck; then
			echo "<span color='#90B33B'>$grmrk</span>" >> g.$2
		elif echo "$verbs" | grep -Fxq $chck; then
			echo "<span color='#CF387F'>$grmrk</span>" >> g.$2
		elif echo "$prepositions" | grep -Fxq $chck; then
			echo "<span color='#D67B2D'>$grmrk</span>" >> g.$2
		elif echo "$adverbs" | grep -Fxq $chck; then
			echo "<span color='#9C68BD'>$grmrk</span>" >> g.$2
		elif echo "$nouns_adjetives" | grep -Fxq $chck; then
			echo "<span color='#496E60'>$grmrk</span>" >> g.$2
		elif echo "$adjetives" | grep -Fxq $chck; then
			echo "<span color='#3E8A3B'>$grmrk</span>" >> g.$2
		else
			echo "$grmrk" >> g.$2
		fi
		let n++
	done
}


function check_grammar_2() {

	if echo "$pronouns" | grep -Fxq "${1,,}"; then echo 'Pron. ';
	elif echo "$conjunctions" | grep -Fxq "${1,,}"; then echo 'Conj. ';
	elif echo "$prepositions" | grep -Fxq "${1,,}"; then echo 'Prep. ';
	elif echo "$adverbs" | grep -Fxq "${1,,}"; then echo 'adv. ';
	elif echo "$nouns_adjetives" | grep -Fxq "${1,,}"; then echo 'Noun, Adj. ';
	elif echo "$nouns_verbs" | grep -Fxq "${1,,}"; then echo 'Noun, Verb ';
	elif echo "$verbs" | grep -Fxq "${1,,}"; then echo 'verb. ';
	elif echo "$adjetives" | grep -Fxq "${1,,}"; then echo 'adj. '; fi
}


function clean_1() {
	
	echo "$(echo "$1" | sed ':a;N;$!ba;s/\n/ /g' \
	| sed 's/"//g' | sed 's/“//g' | sed s'/&//'g \
	| sed 's/”//g' | sed s'/://'g | sed "s/’/'/g" \
	| sed 's/ \+/ /g' | sed 's/^[ \t]*//;s/[ \t]*$//'\
	| sed 's/^ *//; s/ *$//g'| sed 's/^\s*./\U&\E/g')"
}


function clean_2() { # name topic
    
    echo "$(echo "$1" | cut -d "|" -f1 | sed s'/!//'g \
    | sed s'/&//'g | sed s'/\://'g | sed s'/\&//'g \
    | sed s"/'//"g | sed 's/^[ \t]*//;s/[ \t]*$//' \
    | sed s'|/||'g | sed 's/^\s*./\U&\E/g')"
}    


function clean_3() {
	
	cd $1; touch swrd.$2 twrd.$2
	if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
		vrbl="$srce"; lg=$lgt; aw=swrd.$2; bw=twrd.$2
	else
		vrbl="$trgt"; lg=$lgs; aw=twrd.$2; bw=swrd.$2
	fi
	echo "$vrbl" | sed 's/ /\n/g' | grep -v '^.$' \
	| grep -v '^..$' | sed -n 1,40p | sed s'/&//'g \
	| sed 's/,//g' | sed 's/\?//g' | sed 's/\¿//g' \
	| sed 's/;//g' | sed 's/\!//g' | sed 's/\¡//g' \
	| tr -d ')' | tr -d '(' | sed 's/\]//g' | sed 's/\[//g' \
	| sed 's/\.//g' | sed 's/  / /g' | sed 's/ /\. /g' > $aw
}


function add_tags_1() {
	
	eyeD3 --set-encoding=utf8 \
	-t I$1I1I0I"$2"I$1I1I0I \
	-a I$1I2I0I"$3"I$1I2I0I "$4"
}


function add_tags_2() {
	
	eyeD3 --set-encoding=utf8 \
	-t IWI1I0I"$2"IWI1I0I \
	-a IWI2I0I"$3"IWI2I0I \
	-A IWI3I0I"$4"IWI3I0I "$5"
}


function add_tags_3() {
	
	eyeD3 --set-encoding=utf8 \
	-A IWI3I0I"$2"IWI3I0IIPWI3I0I"$3"IPWI3I0IIGMI3I0I"$4"IGMI3I0I "$5"
}


function add_tags_4() {
	
	eyeD3 --set-encoding=utf8 \
	-t ISI1I0I"$2"ISI1I0I \
	-a ISI2I0I"$3"ISI2I0I \
	-A IWI3I0I"$4"IWI3I0IIPWI3I0I"$5"IPWI3I0IIGMI3I0I"$6"IGMI3I0I "$7"
}


function add_tags_5() {
	
	eyeD3 --set-encoding=utf8 \
	-a I$1I2I0I"$2"I$1I2I0I "$3"
}


function add_tags_6() {
	
	eyeD3 --set-encoding=utf8 \
	-A IWI3I0I"$2"IWI3I0I "$3"
}


function add_tags_7() {
	
	eyeD3 --set-encoding=utf8 \
	-t ISI1I0I"$2"ISI1I0I "$3"
}


function add_tags_8() {
	
	eyeD3 -p I$1I4I0I"$2"I$1I4I0I "$3"
}


function add_tags_9() {
	
	eyeD3 --set-encoding=utf8 -A IWI3I0I"$2"IWI3I0IIPWI3I0I"$3"IPWI3I0I "$4"
}


function voice() {
	
	cd "$2"; vs=$(sed -n 8p $DC_s/cfg.1)
	if [ -n "$vs" ]; then
	
		if [ "$vs" = 'festival' ] || [ "$vs" = 'text2wave' ]; then
			lg=$(echo $lgtl | awk '{print tolower($0)}')

			if ([ $lg = "english" ] \
			|| [ $lg = "spanish" ] \
			|| [ $lg = "russian" ]); then
			echo "$1" | text2wave -o ./s.wav
			sox ./s.wav "$3"
			else
				msg "$festival_err $lgtl" error
				exit 1
			fi
		else
			echo "$1" | "$vs"
			[[ -f *.mp3 ]] && mv -f *.mp3 "$3"
			[[ -f *.wav ]] && sox *.wav "$3"
		fi
	else
	
		lg=$(echo $lgtl | awk '{print tolower($0)}')
		[[ $lg = chinese ]] && lg=Mandarin
		[[ $lg = japanese ]] && (msg "$espeak_err $lgtl" error)
		espeak "$1" -v $lg -k 1 -p 40 -a 80 -s 110 -w ./s.wav
		sox ./s.wav "$3"
	fi
}


function set_image_1() {
	
	scrot -s --quality 70 img.jpg
	/usr/bin/convert -scale 110x90! img.jpg ico.jpg
}


function set_image_2() {
	
	/usr/bin/convert -scale 450x270! img.jpg imgs.jpg
	eyeD3 --add-image imgs.jpg:ILLUSTRATION "$1"
}


function set_image_3() {
	
	/usr/bin/convert -scale 100x90! img.jpg imgs.jpg
	/usr/bin/convert -scale 360x240! img.jpg imgt.jpg
	eyeD3 --set-encoding=utf8 --add-image imgs.jpg:ILLUSTRATION "$1"
	mv -f imgt.jpg "$2"
}


function set_image_4() {

	scrot -s --quality 70 "$1.temp.jpeg"
	/usr/bin/convert -scale 100x90! "$1.temp.jpeg" "$1"_temp.jpeg
	/usr/bin/convert -scale 360x240! "$1.temp.jpeg" "$3.jpg"
	eyeD3 --remove-images "$2" >/dev/null 2>&1
	eyeD3 --add-image "$1"_temp.jpeg:ILLUSTRATION "$2"
}


function set_image_5() {
	
	scrot -s --quality 70 "$1.temp.jpeg"
	/usr/bin/convert -scale 450x270! "$1.temp.jpeg" "$1"_temp.jpeg
	eyeD3 --remove-image "$2" >/dev/null 2>&1
	eyeD3 --add-image "$1"_temp.jpeg:ILLUSTRATION "$2"
}


function list_words() {
	
	sed -i 's/\. /\n/g' $bw
	sed -i 's/\. /\n/g' $aw
	cd $1; touch A.$2 B.$2 g.$2; n=1
	if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
		while [ $n -le "$(cat $aw | wc -l)" ]; do
			s=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
			t=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
			echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A.$2
			echo "$t"_"$s""" >> B.$2
			let n++
		done
	else
		while [ $n -le "$(cat $aw | wc -l)" ]; do
			t=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
			s=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
			echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> A.$2
			echo "$t"_"$s""" >> B.$2
			let n++
		done
	fi
}


function fetch_audio() {
	
	n=1
	if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
		while [ $n -le $(cat $2 | wc -l) ]; do
			$dct $(sed -n "$n"p "$2") $DT_r
			let n++
		done
	else
		while [ $n -le $(cat $1 | wc -l) ]; do
			$dct $(sed -n "$n"p "$1") $DT_r
			let n++
		done
	fi
}


function fetch_audio_2() {
	
	n=1
	if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
		while [ $n -le $(cat $2 | wc -l) ]; do
			fl=$(sed -n "$n"p "$2")
			$dct "$fl" $DT_r swrd
			mv "${fl^}.mp3" "./$nme/${fl^}.mp3"
			let n++
		done
	else
		while [ $n -le $(cat $1 | wc -l) ]; do
			fl=$(sed -n "$n"p "$1")
			$dct "$fl" $DT_r swrd
			mv "${fl^}.mp3" "./$nme/${fl^}.mp3"
			let n++
		done
	fi

}


function list_words_2() {

	    if [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
			eyeD3 "$2" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' \
			| tr '_' '\n' | sed -n 1~2p | sed '/^$/d' > idlst
	    else
			echo "$1" | tr -c "[:alnum:]" '\n' | sed '/^$/d' | sed '/"("/d' \
			| sed '/")"/d' | sed '/":"/d' | sort -u \
			| head -n40 > idlst
	    fi
}


function list_words_3() {

	if [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
		echo "$2" | tr '_' '\n' | sed -n 1~2p | sed '/^$/d' > lst
	else
		cat "$1" | tr -c "[:alnum:]" '\n' | sed '/^$/d' | sed '/"("/d' \
		| sed '/")"/d' | sed '/":"/d' | sort -u \
		| head -n40 | egrep -v "FALSE" | egrep -v "TRUE" > lst
	fi
}
