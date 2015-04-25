#!/bin/bash
# -*- ENCODING: UTF-8 -*-


function mksure() {
    
    e=0
    if [ ! -f "${1}" ] || \
    [ `stat --printf="%s" "${1}" | cut -c -3` -lt 100 ]; then
    e=1; fi
    for str in "${@}"; do
        shopt -s extglob
        if [ -z "${str##+([[:space:]])}" ]; then
        e=1; break; fi
    done
    return $e
}


function index() {

    DC_tlt="$DM_tl/$3/.conf"
    item="${2}"
    
    if [ ! -z "${item}" ] && ! grep -Fxo "${item}" < "$DC_tlt/0.cfg"; then
    
        if [ "$1" = word ]; then
        
            if [ "$(grep "$4" < "$DC_tlt/0.cfg")" ] && [ -n "$4" ]; then
            sed -i "s/${4}/${4}\n${item}/" "$DC_tlt/0.cfg"
            sed -i "s/${4}/${4}\n${item}/" "$DC_tlt/1.cfg"
            sed -i "s/${4}/${4}\n${item}/" "$DC_tlt/.11.cfg"
            else
            echo "${item}" >> "$DC_tlt/0.cfg"
            echo "${item}" >> "$DC_tlt/1.cfg"
            echo "${item}" >> "$DC_tlt/.11.cfg"; fi
            echo "${item}" >> "$DC_tlt/3.cfg"
            
        elif [ "$1" = sentence ]; then
        
            echo "${item}" >> "$DC_tlt/0.cfg"
            echo "${item}" >> "$DC_tlt/1.cfg"
            echo "${item}" >> "$DC_tlt/4.cfg"
            echo "${item}" >> "$DC_tlt/.11.cfg"
        fi
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
    
    if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
    echo "$1" | sed ':a;N;$!ba;s/\n/ /g' \
    | sed 's/"//; s/“//;s/&//; s/”//;s/://'g | sed "s/’/'/g" \
    | sed "s/|//g" \
    | sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/ -//;s/- //g' \
    | sed 's/^ *//; s/ *$//g'| sed 's/^\s*./\U&\E/g'
    else
    echo "$1" | sed ':a;N;$!ba;s/\n/ /g' \
    | sed 's/"//; s/“//;s/&//; s/”//;s/://'g | sed "s/’/'/g" \
    | iconv -c -f utf8 -t ascii | sed "s/|//g" \
    | sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/ -//;s/- //g' \
    | sed 's/^ *//; s/ *$//g'| sed 's/^\s*./\U&\E/g'
    fi
}


function clean_2() {
    
    echo "$1" | cut -d "|" -f1 | sed 's/!//; s/&//; s/\://; s/\&//g' \
    | sed "s/'//;s/-//g" | sed 's/^[ \t]*//;s/[ \t]*$//' \
    | sed 's|/||; s/^\s*./\U&\E/g' | sed 's/\：//g' | iconv -c -t UTF-8
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
    /usr/bin/convert img.jpg -interlace Plane -thumbnail 110x90^ \
    -gravity center -extent 110x90 -quality 90% ico.jpg
}


function set_image_2() {
    
    /usr/bin/convert img.jpg -interlace Plane -thumbnail 400x270^ \
    -gravity center -extent 400x270 -quality 90% imgs.jpg
    eyeD3 --add-image imgs.jpg:ILLUSTRATION "$1"
    mv -f imgs.jpg "$2"
} >/dev/null 2>&1


function set_image_3() {
    
    /usr/bin/convert img.jpg -interlace Plane -thumbnail 400x270^ \
    -gravity center -extent 400x270 -quality 90% imgw.jpg
    eyeD3 --add-image imgw.jpg:ILLUSTRATION "$1"
    mv -f imgw.jpg "$2"
} >/dev/null 2>&1


function list_words() {
    
    sed -i 's/\. /\n/g' "$bw"
    sed -i 's/\. /\n/g' "$aw"
    cd "$1"; touch "A.$2" "B.$2" "g.$2"; n=1
    
    if [ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]; then
        while [ $n -le "$(wc -l < "$aw")" ]; do
        s=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
        t=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
        echo ISTI"$n"I0I"$t"ISTI"$fetch_audion"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> "A.$2"
        echo "$t"_"$s""" >> "B.$2"
        let n++
        done
    else
        while [ $n -le "$(wc -l < "$aw")" ]; do
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
    
    synth="$(sed -n 12p < "$DC_s/1.cfg" \
    | grep -o synth=\"[^\"]* | grep -o '[^"]*$')"

    cd "$2"
    if [ -n "$synth" ]; then
    
        if [ "$synth" = 'festival' ] || [ "$synth" = 'text2wave' ]; then
            lg="${lgtl,,}"

            if ([ $lg = "english" ] \
            || [ $lg = "spanish" ] \
            || [ $lg = "russian" ]); then
            echo "$1" | text2wave -o ./s.wav
            sox ./s.wav "$3"
            else
            msg "$(gettext "Sorry, <b><i>festival</i></b> can not process this language.")\n" error
            [ "$DT_r" ] && rm -fr "$DT_r"; exit 1; fi
        else
            echo "$1" | "$synth"
            [ -f *.mp3 ] && mv -f *.mp3 "$3"
            [ -f *.wav ] && sox *.wav "$3"
        fi
    else
    
        lg="${lgtl,,}"
        
        [ $lg = chinese ] && lg=Mandarin
        [ $lg = portuguese ] && lg=brazil
        [ $lg = vietnamese ] && lg=vietnam
        if [ $lg = japanese ]; then msg "$(gettext "Sorry, <b><i>espeak</i></b> can not process Japanese language.")\n" error
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
                voice "$word" "$3" "$4/${word,,}.mp3"
            fi
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
    
    yad --form --title="$(gettext "New Topic")" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --center --on-top \
    --width=450 --height=100 --borders=5 \
    --field="$(gettext "Name")" "$1" \
    --button=gtk-ok:0
}


function dlg_form_1() {

    yad --form --title="$(gettext "New note")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --separator="\n" \
    --skip-taskbar --center --on-top \
    --align=right --image="$img" \
    --window-icon="$DS/images/icon.png" \
    --width=450 --height=140 --borders=0 \
    --field="" "$txt" \
    --field=":CB" "$ltopic!$(gettext "New") *$e$tpcs" \
    --button="$(gettext "Image")":3 \
    --button="$(gettext "Audio")":2 \
    --button=gtk-add:0
}


function dlg_form_2() {
    
    yad --form --title="$(gettext "New note")" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --separator="\n" \
    --skip-taskbar --center --on-top \
    --align=right --image="$img" \
    --window-icon="$DS/images/icon.png" \
    --width=450 --height=170 --borders=0 \
    --field="" "$txt" \
    --field="" "$srce" \
    --field=":CB" "$ltopic!$(gettext "New") *$e$tpcs" \
    --button="$(gettext "Image")":3 \
    --button="$(gettext "Audio")":2 \
    --button=gtk-add:0
}

#<small>$lgtl</small>
#<small>${lgsl^}</small>
#$atopic
 
function dlg_radiolist_1() {
    
    echo "$1" | awk '{print "FALSE\n"$0}' | \
    yad --list --radiolist --title="$(gettext "Listing words")" \
    --text="<b>$te</b> <small> $info</small>" \
    --name=Idiomind --class=Idiomind \
    --separator="\n" \
    --window-icon="$DS/images/icon.png" \
    --sticky --skip-taskbar --center --on-top --fixed --no-headers \
    --width=150 --height=420 --borders=5 \
    --column=" " --column=" " \
    --button=gtk-add:0
}


function dlg_checklist_1() {
    
    cat "$1" | awk '{print "FALSE\n"$0}' | \
    yad --list --checklist --title="$(gettext "Listing words")" \
    --text="<small> $2 </small>" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --center --on-top --sticky --no-headers \
    --text-align=right --buttons-layout=end \
    --width=400 --height=280 --borders=5  \
    --column=" " --column="Select" \
    --button="$(gettext "Close")":1 \
    --button="$(gettext "Add")":0 > "$slt"
}


function dlg_checklist_3() {

    slt=$(mktemp $DT/slt.XXXX.x)
    cat "$1" | awk '{print "FALSE\n"$0}' | \
    yad --list --checklist --title="$2" \
    --text="<small>$info</small> " \
    --name=Idiomind --class=Idiomind \
    --dclick-action="'/usr/share/idiomind/add.sh' 'dclik_list_words'" \
    --window-icon="$DS/images/icon.png" \
    --ellipsize=END --text-align=right --center --sticky --no-headers \
    --width=600 --height=550 --borders=5 \
    --column="$(cat "$1" | wc -l)" \
    --column="$(gettext "sentences")" \
    --button="$(gettext "Cancel")":1 \
    --button=$(gettext "Reorder"):2 \
    --button="$(gettext "New topic")":"$DS/add.sh 'new_topic'" \
    --button=gtk-add:0 > "$slt"
}


function dlg_text_info_1() {
    
    cat "$1" | awk '{print "\n\n\n"$0}' | \
    yad --text-info --title="$2" \
    --name=Idiomind --class=Idiomind \
    --editable \
    --window-icon="$DS/images/icon.png" \
    --wrap --margins=30 --fontname=vendana \
    --sticky --skip-taskbar --center --on-top \
    --width=600 --height=550 --borders=5 \
    --button=gtk-ok:0 > ./sort
}


function dlg_text_info_3() {

    printf "$2" | yad --text-info --title="Idiomind" \
    --text="$1" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --wrap --margins=4 \
    --center --on-top \
    --width=420 --height=150 --borders=5 \
    "$3" --button="$(gettext "OK")":1
}


function dlg_progress_1() {
    
    yad --progress --title="$(gettext "Progress")" \
    --progress-text=" " --pulsate --percentage="5" --auto-close \
    --skip-taskbar --no-buttons --on-top --fixed \
    --width=200 --height=50 --borders=4 --geometry=240x20-4-4
}


function dlg_progress_2() {

    yad --progress --title="$(gettext "Progress")" \
    --progress-text=" " --auto-close \
    --skip-taskbar --no-buttons --on-top --fixed \
    --width=200 --height=50 --borders=4 --geometry=240x20-4-4
}
