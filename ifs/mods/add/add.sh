#!/bin/bash
# -*- ENCODING: UTF-8 -*-


function index() {

	DC_tlt="$DC_tl/$3"

	if [ ! -z "$2" ]; then
	
		if [ "$1" = word ]; then
		
			if [[ "$(cat "$DC_tlt/cfg.0" | grep "$4")" ]] && [ -n "$4" ]; then
				sed -i "s/${4}/${4}\n$2/" "$DC_tlt/cfg.0"
				sed -i "s/${4}/${4}\n$2/" "$DC_tlt/cfg.1"
				sed -i "s/${4}/${4}\n$2/" "$DC_tlt/.cfg.11"
			else
				echo "$2" >> "$DC_tlt/cfg.0"
				echo "$2" >> "$DC_tlt/cfg.1"
				echo "$2" >> "$DC_tlt/.cfg.11"; fi
			echo "$2" >> "$DC_tlt/cfg.3"
			
		elif [ "$1" = sentence ]; then
			echo "$2" >> "$DC_tlt/cfg.0"
			echo "$2" >> "$DC_tlt/cfg.1"
			echo "$2" >> "$DC_tlt/cfg.4"
			echo "$2" >> "$DC_tlt/.cfg.11"; fi
		
		tmp=$DT/tmp
		lss="$DC_tlt/.cfg.11"
		if [ -n "$(cat "$lss" | sort -n | uniq -dc)" ]; then
			cat "$lss" | awk '!array_temp[$0]++' > $tmp
			sed '/^$/d' $tmp > "$lss"; fi
		ls0="$DC_tlt/cfg.0"
		if [ -n "$(cat "$ls0" | sort -n | uniq -dc)" ]; then
			cat "$ls0" | awk '!array_temp[$0]++' > $tmp
			sed '/^$/d' $tmp > "$ls0"; fi
		ls1="$DC_tlt/cfg.1"
		if [ -n "$(cat "$ls1" | sort -n | uniq -dc)" ]; then
			cat "$ls1" | awk '!array_temp[$0]++' > $tmp
			sed '/^$/d' $tmp > "$ls1"; fi
		ls2="$DC_tlt/cfg.3"
		if [ -n "$(cat "$ls2" | sort -n | uniq -dc)" ]; then
			cat "$ls2" | awk '!array_temp[$0]++' > $tmp
			sed '/^$/d' $tmp > "$ls2"; fi
		ls3="$DC_tlt/cfg.4"
		if [ -n "$(cat "$ls3" | sort -n | uniq -dc)" ]; then
			cat "$ls3" | awk '!array_temp[$0]++' > $tmp
			sed '/^$/d' $tmp > "$ls3"; fi
		rm -f $tmp
	fi
}



function check_grammar_1() {
	
	g=$(echo "$trgt"  | sed 's/ /\n/g')
	cd $1; touch A.$r B.$r g.$r; n=1
	while [ $n -le $(echo "$g" | wc -l) ]; do
		grmrk=$(echo "$g" | sed -n "$n"p)
		chck=$(echo "$g,," | sed -n "$n"p \
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
	elif echo "$adjetives" | grep -Fxq "${1,,}"; then echo 'adj. ';
	elif echo "$verbs" | grep -Fxq "${1,,}"; then echo 'verb. '; fi
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


#function add_tags_7() {
	
	#eyeD3 --set-encoding=utf8 \
	#-t ISI1I0I"$2"ISI1I0I "$3"
#}


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
			lg="${lgtl,,}"

			if ([ $lg = "english" ] \
			|| [ $lg = "spanish" ] \
			|| [ $lg = "russian" ]); then
			echo "$1" | text2wave -o ./s.wav
			sox ./s.wav "$3"
			else
				msg "$festival_err $lgtl" error
				[[ -d $DT_r ]] && rm -fr $DT_r
				exit 1
			fi
		else
			echo "$1" | "$vs"
			[[ -f *.mp3 ]] && mv -f *.mp3 "$3"
			[[ -f *.wav ]] && sox *.wav "$3"
		fi
	else
	
		lg="${lgtl,,}"
		[[ $lg = chinese ]] && lg=Mandarin
		[[ $lg = japanese ]] && (msg "$espeak_err $lgtl" error \
		&& exit 1 && [[ -d $DT_r ]] && rm -fr $DT_r)
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


#ARGS 2 and 2 words list to process, 3 dir work, 4 dir target
function fetch_audio() { 
	
	if ([ $lgt = ja ] || [ $lgt = "zh-cn" ] || [ $lgt = ru ]); then
	words_list="$2"; else words_list="$1"; fi
	
	while read word; do
		
		if [ ! -f "$DM_tls/${word,,}.mp3" ]; then
		
			dictt "${word,,}" $3
			
			if [ -f "$3/${word,,}.mp3" ]; then
					mv -f "$3/${word,,}.mp3" "$4/${word,,}.mp3"
			else
				voice "$word" "$3" "$4/${word,,}.mp3"; fi
			
			[ "$4" = "$DM_tl/.share" ] \
			&& echo "${word,,}.mp3" >> "$DC_tlt/cfg.5"

		fi
		
	done < "$words_list"
}


function list_words_2() {

	    if [ $lgt = ja ] || [ $lgt = 'zh-cn' ] || [ $lgt = ru ]; then
			eyeD3 "$1" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' \
			| tr '_' '\n' | sed -n 1~2p | sed '/^$/d' > idlst
	    else
			eyeD3 "$1" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' \
			| tr '_' '\n' | sed -n 1~2p | sed '/^$/d' > idlst
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


# current process
function dlg_msg_3() {
    
        yad --fixed --center --on-top \
        --image=info --name=idiomind \
        --text=" $current_pros  " \
        --fixed --sticky --buttons-layout=edge \
        --width=360 --height=120 --borders=5 \
        --skip-taskbar --window-icon=idiomind \
        --title=Idiomind --button=gtk-cancel:3 --button=Ok:1
}


# s
function dlg_msg_2() {
    
        yad --name=idiomind --center --on-top --image=info \
        --text="$item_err\n" \
        --image-on-top --width=360 --height=120 --borders=3 \
        --skip-taskbar --window-icon=idiomind --sticky \
        --title=Idiomind --button="$delete":1 --button="$fix_item":0 
}


# same name - topic 
function dlg_msg_6() {
    
        yad --name=idiomind --center --on-top --image=info \
        --text=" $1" \
        --image-on-top --width=420 --height=120 --borders=3 \
        --skip-taskbar --window-icon=idiomind --sticky \
        --title=Idiomind --button="$cancel":1 --button=Ok:0
}


# new topic
function dlg_form_0() {
    
        yad --window-icon=idiomind --form --center \
        --field="$name_for_new_topic" "$2" --title="$1" \
        --width=440 --height=100 --name=idiomind --on-top \
        --skip-taskbar --borders=5 --button=gtk-ok:0
}


# imput text 
function dlg_form_1() {
    
        yad --form --center --always-print-result \
        --on-top --window-icon=idiomind --skip-taskbar \
        --separator="\n" --align=right $img \
        --name=idiomind --class=idiomind \
        --borders=0 --title=" " --width=420 --height=140 \
        --field=" <small><small>$lgtl</small></small>: " "$txt" \
        --field=" <small><small>$topic</small></small>:CB" \
        "$ttle!$new *$e$tpcs" \
        --button="<small>$image</small>":3 \
        --button="<small>Audio</small>":2 --button=gtk-ok:0
}


# imput text 
function dlg_form_2() {
    
        yad --form --center --always-print-result \
        --on-top --window-icon=idiomind --skip-taskbar \
        --separator="\n" --align=right $img \
        --name=idiomind --class=idiomind \
        --borders=0 --title=" " --width=420 --height=170 \
        --field=" <small><small>$lgtl</small></small>: " "$txt" \
        --field=" <small><small>${lgsl^}</small></small>: " "$srce" \
        --field=" <small><small>$topic</small></small>:CB" \
        "$ttle!$new *$e$tpcs" \
        --button="<small>$image</small>":3 \
        --button="<small>Audio</small>":2 --button=gtk-ok:0
}


# check_tpe
function dlg_radiolist_1() {
    
        echo "$1" | awk '{print "FALSE\n"$0}' | \
        yad --name=idiomind --class=idiomind --center \
        --list --radiolist --on-top --fixed --no-headers \
        --text="<b>$te</b> <small><small> --window-icon=idiomind \
        $info</small></small>" --sticky --skip-taskbar \
        --height=420 --width=150 --separator="\\n" \
        --button=Save:0 --title="selector" --borders=3 \
        --column=" " --column="Sentences"
}


#edit_word_list
function dlg_checklist_1() {
    
        cat "$1" | awk '{print "FALSE\n"$0}' | \
        yad --list --checklist --title="$word_selector" \
        --on-top --text="<small>$2</small>" \
        --center --sticky --no-headers \
        --buttons-layout=end --skip-taskbar --width=400 \
        --height=280 --borders=10 --window-icon=idiomind \
        --button=gtk-close:1 --button="$add":0 \
        --column="" --column="Select" > "$slt"
}


# process no audio
function dlg_checklist_3() {

        slt=$(mktemp $DT/slt.XXXX.x)
        cat "$1" | awk '{print "FALSE\n"$0}' | \
        yad --name=idiomind --window-icon=idiomind \
        --dclick-action='/usr/share/idiomind/add.sh dclik_list_words' \
        --list --checklist --class=idiomind --center --sticky \
        --text="<small>$info</small>" --title="$tpe" \
        --width=$wth --print-all --height=$eht --borders=3 \
        --button="$cancel":1 --button="$arrange":2 \
        --button="$to_new_topic":'/usr/share/idiomind/add.sh new_topic' \
        --button=gtk-save:0 \
        --column="$(cat "$1" | wc -l)" --column="$sentences" > $slt
}


# sort
function dlg_text_info_1() {
    
        cat "$1" | awk '{print "\n\n\n"$0}' | \
        yad --text-info --editable --window-icon=idiomind \
        --name=idiomind --wrap --margins=60 --class=idiomind \
        --sticky --fontname=vendana --on-top --center \
        --skip-taskbar --width=$wth \
        --height=$eht --borders=3 \
        --button=gtk-ok:0 --title="$tpe" > ./sort
}


# for log
function dlg_text_info_3() {

        printf "$1" | yad --text-info --center --wrap \
        --center --skip-taskbar --on-top --title=Idiomind \
        --width=420 --height=150 --on-top --margins=4 \
        --window-icon=idiomind --borders=0 --name=idiomind \
        "$2" --button=Ok:1
}


# no get text
function dlg_text_info_4() {
    
        echo "$1" | yad --text-info --center --wrap \
        --name=idiomind --class=idiomind --window-icon=idiomind \
        --text=" " --sticky --width=$wth --height=$eht \
        --margins=8 --borders=3 --button=Ok:0 \
        --title=Idiomind
}


function dlg_progress_1() {
    
        yad --progress --progress-text=" " \
        --width=200 --height=20 --geometry=200x20-2-2 \
        --pulsate --percentage="5" --on-top \
        --undecorated --auto-close \
        --skip-taskbar --no-buttons
}


function dlg_progress_2() {

        yad --progress --progress-text=" " \
        --width=200 --height=20 --geometry=200x20-2-2 \
        --undecorated --auto-close --on-top \
        --skip-taskbar --no-buttons
}
