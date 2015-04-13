#!/usr/bin/env


function index() {

    DC_tlt="$DM_tl/$3/.conf"

    if [ ! -z "$2" ]; then
    
        item="$2"
    
        if [ "$1" = word ]; then
        
            if [ "$(grep "$4" < "$DC_tlt/0.cfg")" ] && [ -n "$4" ]; then
                sed -i "s/${4}/${4}\n$item/" "$DC_tlt/0.cfg"
                sed -i "s/${4}/${4}\n$item/" "$DC_tlt/1.cfg"
                sed -i "s/${4}/${4}\n$item/" "$DC_tlt/.11.cfg"
            else
                echo "$item" >> "$DC_tlt/0.cfg"
                echo "$item" >> "$DC_tlt/1.cfg"
                echo "$item" >> "$DC_tlt/.11.cfg"; fi
                
            echo "$item" >> "$DC_tlt/3.cfg"
            
        elif [ "$1" = sentence ]; then
            echo "$item" >> "$DC_tlt/0.cfg"
            echo "$item" >> "$DC_tlt/1.cfg"
            echo "$item" >> "$DC_tlt/4.cfg"
            echo "$item" >> "$DC_tlt/.11.cfg"; fi

        z=0; tmp="$DT/tmp"
        while [[ $z -le 4 ]]; do
        
            inx="$DC_tlt/$z.cfg"
            if [ -n "$(uniq -dc < "$inx" | sort -n)" ]; then
                cat "$inx" | awk '!array_temp[$0]++' > "$tmp"
                sed '/^$/d' "$tmp" > "$inx"; fi
            if grep '^$' "$inx"; then
                sed -i '/^$/d' "$inx"; fi
            let z++
        done
        
        rm -f "$tmp"
    fi
}


function check_grammar_1() {
    
    g=$(echo "$trgt"  | sed 's/ /\n/g')
    cd "$1"; touch "A.$r" "B.$r" "g.$r"; n=1
    while [ $n -le $(echo "$g" | wc -l) ]; do
        grmrk=$(echo "$g" | sed -n "$n"p)
        chck=$(echo "$g,," | sed -n "$n"p | sed 's/,//;s/\.//g')
        if echo "$pronouns" | grep -Fxq "$chck"; then
            echo "<span color='#35559C'>$grmrk</span>" >> "g.$2"
        elif echo "$nouns_verbs" | grep -Fxq "$chck"; then
            echo "<span color='#896E7A'>$grmrk</span>" >> "g.$2"
        elif echo "$conjunctions" | grep -Fxq "$chck"; then
            echo "<span color='#90B33B'>$grmrk</span>" >> "g.$2"
        elif echo "$verbs" | grep -Fxq "$chck"; then
            echo "<span color='#CF387F'>$grmrk</span>" >> "g.$2"
        elif echo "$prepositions" | grep -Fxq "$chck"; then
            echo "<span color='#D67B2D'>$grmrk</span>" >> "g.$2"
        elif echo "$adverbs" | grep -Fxq "$chck"; then
            echo "<span color='#9C68BD'>$grmrk</span>" >> "g.$2"
        elif echo "$nouns_adjetives" | grep -Fxq "$chck"; then
            echo "<span color='#496E60'>$grmrk</span>" >> "g.$2"
        elif echo "$adjetives" | grep -Fxq "$chck"; then
            echo "<span color='#3E8A3B'>$grmrk</span>" >> "g.$2"
        else
            echo "$grmrk" >> "g.$2"
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
    
    echo "$1" | sed ':a;N;$!ba;s/\n/ /g' \
    | sed 's/"//; s/“//;s/&//; s/”//;s/://'g | sed "s/’/'/g" \
    | iconv -c -f utf8 -t ascii | sed "s/|//g" \
    | sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/ -//;s/- //g' \
    | sed 's/^ *//; s/ *$//g'| sed 's/^\s*./\U&\E/g'
}


function clean_2() {
    
    echo "$1" | cut -d "|" -f1 | sed 's/!//; s/&//; s/\://; s/\&//g' \
    | sed "s/'//;s/-//g" | sed 's/^[ \t]*//;s/[ \t]*$//' \
    | sed 's|/||; s/^\s*./\U&\E/g'
}    


function clean_3() {
    
    cd "$1"; touch "swrd.$2" "twrd.$2"
    if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
    vrbl="$srce"; lg=$lgt; aw="swrd.$2"; bw="twrd.$2"
    else vrbl="$trgt"; lg=$lgs; aw="twrd.$2"; bw="swrd.$2"; fi
    
    echo "$vrbl" | sed 's/ /\n/g' | grep -v '^.$' \
    | grep -v '^..$' | sed -n 1,50p | sed s'/&//'g \
    | sed 's/,//;s/\?//;s/\¿//;s/;//g;s/\!//;s/\¡//g' \
    | tr -d ')' | tr -d '(' | sed 's/\]//;s/\[//g' \
    | sed 's/\.//;s/  / /;s/ /\. /;s/ -//;s/- //g' > "$aw"
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


function add_tags_8() {
    
    eyeD3 -p I$1I4I0I"$2"I$1I4I0I "$3"
}


function add_tags_9() {
    
    eyeD3 --set-encoding=utf8 -A IWI3I0I"$2"IWI3I0IIPWI3I0I"$3"IPWI3I0I "$4"
}


function set_image_1() {
    
    scrot -s --quality 80 img.jpg
    /usr/bin/convert -scale 110x90! img.jpg ico.jpg
}


function set_image_2() {
    
    /usr/bin/convert -scale 450x260! img.jpg imgs.jpg
    eyeD3 --add-image imgs.jpg:ILLUSTRATION "$1"
    mv -f imgs.jpg "$2"
} >/dev/null 2>&1


function set_image_3() {
    
    /usr/bin/convert -scale 360x240! img.jpg imgw.jpg
    eyeD3 --add-image imgw.jpg:ILLUSTRATION "$1"
    mv -f imgw.jpg "$2"
} >/dev/null 2>&1


function list_words() {
    
    sed -i 's/\. /\n/g' "$bw"
    sed -i 's/\. /\n/g' "$aw"
    cd "$1"; touch "A.$2" "B.$2" "g.$2"; n=1
    
    if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
        while [ $n -le "$(cat $aw | wc -l)" ]; do
        s=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
        t=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
        echo ISTI"$n"I0I"$t"ISTI"$fetch_audion"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> "A.$2"
        echo "$t"_"$s""" >> "B.$2"
        let n++
        done
    else
        while [ $n -le "$(cat $aw | wc -l)" ]; do
        t=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
        s=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
        echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> "A.$2"
        echo "$t"_"$s""" >> "B.$2"
        let n++
        done
    fi
}


function translate() {
    
    for trans in "$DS/ifs/mods/trans"/*.trad; do
    "$trans" "$@"; done
}


function tts() {
    
    for convert in "$DS/ifs/mods/trans"/*.tts; do
    "$convert" "$@"; done
}


function voice() {
    
    source "$DC_s/1.cfg"
    cd "$2"; vs="$synth"
    if [ -n "$vs" ]; then
    
        if [ "$vs" = 'festival' ] || [ "$vs" = 'text2wave' ]; then
            lg="${lgtl,,}"

            if ([ $lg = "english" ] \
            || [ $lg = "spanish" ] \
            || [ $lg = "russian" ]); then
            echo "$1" | text2wave -o ./s.wav
            sox ./s.wav "$3"
            else
            msg "$(gettext "Sorry, festival can not process this language.")\n" error
            [ "$DT_r" ] && rm -fr "$DT_r"; exit 1; fi
        else
            echo "$1" | "$vs"
            [ -f *.mp3 ] && mv -f *.mp3 "$3"
            [ -f *.wav ] && sox *.wav "$3"
        fi
    else
    
        lg="${lgtl,,}"
        [ $lg = chinese ] && lg=Mandarin
        if [ $lg = japanese ]; then msg "$(gettext "Sorry, espeak can not process Japanese text.")\n" error
        [ "$DT_r" ] && rm -fr "$DT_r"; exit 1; fi
        espeak "$1" -v $lg -k 1 -p 40 -a 80 -s 110 -w ./s.wav
        sox ./s.wav "$3"
    fi
}


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


function dlg_form_0() {
    
    yad --window-icon="$DS/images/icon.png" --form --center --on-top \
    --field="$(gettext "Name")" "$2" --title="$1" \
    --width=470 --height=100 --name=Idiomind --class=Idiomind \
    --skip-taskbar --borders=5 --button=gtk-ok:0
}


function dlg_form_1() {

    yad --form --title="$(gettext "New Note")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --separator="\n" \
    --skip-taskbar --center --on-top \
    --align=right --image="$img" \
    --window-icon="$DS/images/icon.png" \
    --width=420 --height=150 --borders=0 \
    --field=" <small>$lgtl</small>" "$txt" \
    --field=" $atopic:CB" \
    "$ltopic!$(gettext "New topic") *$e$tpcs" \
    --button="$(gettext "Image")":3 \
    --button="$(gettext "Audio")":2 \
    --button=gtk-add:0
}


function dlg_form_2() {
    
    yad --form --title="$(gettext "New Note")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --separator="\n" \
    --skip-taskbar --center --on-top \
    --align=right --image="$img" \
    --window-icon="$DS/images/icon.png" \
    --width=420 --height=180 --borders=0 \
    --field=" <small>$lgtl</small>" "$txt" \
    --field=" <small>${lgsl^}</small>" "$srce" \
    --field=" $atopic:CB" \
    "$ltopic!$(gettext "New topic") *$e$tpcs" \
    --button="$(gettext "Image")":3 \
    --button="$(gettext "Audio")":2 \
    --button=gtk-add:0
}


function dlg_radiolist_1() {
    
    echo "$1" | awk '{print "FALSE\n"$0}' | \
    yad --name=Idiomind --class=Idiomind --center \
    --list --radiolist --on-top --fixed --no-headers \
    --text="<b>$te</b> <small> $info</small>" \
    --sticky --skip-taskbar --window-icon="$DS/images/icon.png" \
    --height=420 --width=150 --separator="\\n" \
    --button=gtk-add:0 --title="$(gettext "Listing words")" \
    --borders=5 --column=" " --column="$(gettext "Sentences")"
}


function dlg_checklist_1() {
    
    cat "$1" | awk '{print "FALSE\n"$0}' | \
    yad --list --checklist --title="$(gettext "Listing words")" \
    --on-top --text="<small>$2</small>" --class=Idiomind \
    --center --sticky --no-headers --name=Idiomind \
    --buttons-layout=end --width=400 \
    --height=280 --borders=5 --window-icon="$DS/images/icon.png" \
    --button="$(gettext "Close")":1 \
    --button="$(gettext "Add")":0 \
    --column="" --column="Select" > "$slt"
}


function dlg_checklist_3() {

    slt=$(mktemp $DT/slt.XXXX.x)
    cat "$1" | awk '{print "FALSE\n"$0}' | \
    yad --name=Idiomind --window-icon="$DS/images/icon.png" --ellipsize=END \
    --dclick-action='/usr/share/idiomind/add.sh dclik_list_words' \
    --list --checklist --class=Idiomind --center --sticky \
    --text="<small>$info</small>" --title="$2" --no-headers \
    --width=$wth --height=$eht --borders=5 \
    --button="$(gettext "Cancel")":1 --button=$(gettext "Reorder"):2 \
    --button="$(gettext "To New Topic")":"$DS/add.sh 'new_topic'" \
    --button=gtk-add:0 \
    --column="$(cat "$1" | wc -l)" \
    --column="$(gettext "sentences")" > "$slt"
}


function dlg_text_info_1() {
    
    cat "$1" | awk '{print "\n\n\n"$0}' | \
    yad --text-info --editable --window-icon="$DS/images/icon.png" \
    --name=Idiomind --wrap --margins=60 --class=Idiomind \
    --sticky --fontname=vendana --on-top --center \
    --skip-taskbar --width=$wth --height=$eht --borders=5 \
    --button=gtk-ok:0 --title="$2" > ./sort
}


function dlg_text_info_3() {

    printf "$2" | yad --text="$1" --text-info --center --wrap \
    --center --on-top --title=Idiomind --class=Idiomind \
    --width=420 --height=150 --on-top --margins=4 \
    --window-icon="$DS/images/icon.png" --borders=5 --name=Idiomind \
    "$3" --button="$(gettext "OK")":1
}


function dlg_progress_1() {
    
    yad --progress --progress-text=" " --on-top \
    --width=240 --height=20 --geometry=240x20-4-4 \
    --pulsate --percentage="5" \
    --undecorated --auto-close --skip-taskbar --no-buttons
}


function dlg_progress_2() {

    yad --progress --progress-text=" " --on-top \
    --width=240 --height=20 --geometry=240x20-4-4 \
    --undecorated --auto-close --skip-taskbar --no-buttons
}
