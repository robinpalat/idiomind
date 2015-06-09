#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if ([ -z "$lgtl" ] || [ -z "$lgsl" ]); then
msg "$(gettext "Please check the language settings in the preferences dialog.")\n" error & exit 1
fi

function mksure() {
    
    e=0
    if [[ ! -f "${1}" ]] || \
    [[ `stat --printf="%s" "${1}" | cut -c -3` -lt 100 ]]; then
    e=1; fi
    for str in "${@}"; do
        shopt -s extglob
        if [[ -z "${str##+([[:space:]])}" ]]; then
        e=1; break; fi
    done
    return $e
}


function index() {

    while true; do
    if [[ -f "$DT/i_lk" ]]; then sleep 1
    else > "$DT/i_lk" & break; fi
    done
    DC_tlt="$DM_tl/${3}/.conf"
    img0='/usr/share/idiomind/images/0.png'
    item="${2}"
    
    if [[ ! -z "${item}" ]] && ! grep -Fxo "${item}" "$DC_tlt/0.cfg"; then
    
        if [[ "$1" = word ]]; then
        
            if [[ "$(grep "$4" "$DC_tlt/0.cfg")" ]] && [[ -n "$4" ]]; then
            sed -i "s/${4}/${4}\n${item}/" "$DC_tlt/0.cfg"
            sed -i "s/${4}/${4}\n${item}/" "$DC_tlt/1.cfg"
            sed -i "s/${4}/${4}\n${item}/" "$DC_tlt/.11.cfg"
            else
            echo "${item}" >> "$DC_tlt/0.cfg"
            echo "${item}" >> "$DC_tlt/1.cfg"
            echo "${item}" >> "$DC_tlt/.11.cfg"; fi
            echo "${item}" >> "$DC_tlt/3.cfg"
            echo -e "FALSE\n${item}\n$img0" >> "$DC_tlt/5.cfg"

        elif [[ "$1" = sentence ]]; then
        
            echo "${item}" >> "$DC_tlt/0.cfg"
            echo "${item}" >> "$DC_tlt/1.cfg"
            echo "${item}" >> "$DC_tlt/4.cfg"
            echo "${item}" >> "$DC_tlt/.11.cfg"
            echo -e "FALSE\n${item}\n$img0" >> "$DC_tlt/5.cfg"
        fi
    fi
        
    if [[ "$1" = edit ]]; then
            
        item="${item}"; item_mod="${4}"
        sed -i "s/${item}/${item_mod}/" "$DC_tlt/.11.cfg"
        
        sust(){
            for inx in "${@}"; do
                if grep -Fxo "${item}" "$inx"; then
                sed -i "s/${item}/${item_mod}/" "$inx"
                fi
            done
        }
        
        sust "$DC_tlt/0.cfg" \
        "$DC_tlt/1.cfg" "$DC_tlt/2.cfg" \
        "$DC_tlt/3.cfg" "$DC_tlt/4.cfg" \
        "$DC_tlt/practice/lsin" \
        "$DC_tlt/practice/fin" "$DC_tlt/practice/mcin" \
        "$DC_tlt/practice/win" "$DC_tlt/practice/iin" \
        "$DC_tlt/6.cfg"
        
    elif [[ "$1" = txt_missing ]]; then
    
        echo "${item}" >> "$DC_tlt/0.cfg"
        echo "${item}" >> "$DC_tlt/1.cfg"
        echo "${item}" >> "$DC_tlt/4.cfg"
        echo -e "FALSE\n${item}\n$img0" >> "$DC_tlt/5.cfg"
    fi
    
    sleep 0.5
    rm -f "$DT/i_lk"
}


function check_grammar_1() {
    
    touch "A.$r" "B.$r" "g.$r"
    while read -r grmrk; do
        chck=$(sed 's/,//;s/\.//g' <<<"${grmrk,,}")
        if grep -Fxq "$chck" <<<"$pronouns"; then
            echo "<span color='#3E539A'>$grmrk</span>" >> "g.$2"
        elif grep -Fxq "$chck" <<<"$nouns_adjetives"; then
            echo "<span color='#496E60'>$grmrk</span>" >> "g.$2"
        elif grep -Fxq "$chck" <<<"$adjetives"; then
            echo "<span color='#3E8A3B'>$grmrk</span>" >> "g.$2"
        elif grep -Fxq "$chck" <<<"$nouns_verbs"; then
            echo "<span color='#62426A'>$grmrk</span>" >> "g.$2"
        elif grep -Fxq "$chck" <<<"$conjunctions"; then
            echo "<span color='#90B33B'>$grmrk</span>" >> "g.$2"
        elif grep -Fxq "$chck" <<<"$verbs"; then
            echo "<span color='#CF387F'>$grmrk</span>" >> "g.$2"
        elif grep -Fxq "$chck" <<<"$prepositions"; then
            echo "<span color='#D67B2D'>$grmrk</span>" >> "g.$2"
        elif grep -Fxq "$chck" <<<"$adverbs"; then
            echo "<span color='#9C68BD'>$grmrk</span>" >> "g.$2"
        else
            echo "$grmrk" >> "g.$2"
        fi
    done < <(sed 's/ /\n/g' <<<"$trgt")
}


function check_grammar_2() {

    if grep -Fxq "${1,,}" <<<"$pronouns"; then echo 'Pron. ';
    elif grep -Fxq "${1,,}" <<<"$nouns_adjetives"; then echo 'Noun, Adj. ';
    elif grep -Fxq "${1,,}" <<<"$adjetives"; then echo 'Adj. ';
    elif grep -Fxq "${1,,}" <<<"$conjunctions"; then echo 'Conj. ';
    elif grep -Fxq "${1,,}" <<<"$prepositions"; then echo 'Prep. ';
    elif grep -Fxq "${1,,}" <<<"$adverbs"; then echo 'Adv. ';
    elif grep -Fxq "${1,,}" <<<"$nouns_verbs"; then echo 'Noun, Verb ';
    elif grep -Fxq "${1,,}" <<<"$verbs"; then echo 'verb. '; fi
}


function clean_0() {
    
    echo "$1" | sed ':a;N;$!ba;s/\n/ /g' \
    | sed 's/&//;s/://;s/\.//g' | sed "s/’/'/;s/|//g" \
    | sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/ -//;s/- //g' \
    | sed 's/^ *//;s/ *$//g' | sed 's/^\s*./\U&\E/g' \
    | tr -s '“' ' ' | tr -s '”' ' ' | tr -s '"' ' ' \
    | sed 's/<[^>]*>//g'
}

function clean_1() {
    
    #iconv -c -f utf8 -t ascii
    if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
    echo "${1}" | sed ':a;N;$!ba;s/\n/ /g' | sed "s/’/'/g" \
    | tr -s '“' ' ' | tr -s '”' ' ' | tr -s '"' ' ' \
    | tr -s '&' ' ' | tr -s ':' ' ' | tr -s '|' ' ' \
    | sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/ -//;s/- //g' \
    | sed 's/^ *//; s/ *$//g' | sed 's/–//g' | sed 's/<[^>]*>//g'
    else
    echo "${1}" | sed ':a;N;$!ba;s/\n/ /g' | sed "s/’/'/g" \
    | tr -s '“' ' ' | tr -s '”' ' ' | tr -s '"' ' ' \
    | tr -s '&' ' ' | tr -s ':' ' ' | tr -s '|' ' ' \
    | sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/ -//;s/- //g' \
    | sed 's/^ *//;s/ *$//g' | sed 's/^\s*./\U&\E/g' \
    | sed 's/–//g' | sed 's/<[^>]*>//g'
    fi
}


function clean_2() {
    
    echo "${1}" | cut -d "|" -f1 | sed 's/!//;s/&//;s/\://; s/\&//g' \
    | sed "s/-//g" | sed 's/^[ \t]*//;s/[ \t]*$//' \
    | sed 's|/||;s/^\s*./\U&\E/g' | sed 's/\：//g' | sed 's/<[^>]*>//g'
}    


function clean_3() {
    
    cd /; cd "$1"; touch "swrd.$2" "twrd.$2"
    if ([ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]); then
    vrbl="${srce}"; lg=$lgt; aw="swrd.$2"; bw="twrd.$2"
    else vrbl="${trgt}"; lg=$lgs; aw="twrd.$2"; bw="swrd.$2"; fi
    echo "${vrbl}" | sed 's/ /\n/g' | grep -v '^.$' \
    | grep -v '^..$' | sed -n 1,50p | sed s'/&//'g \
    | sed 's/,//;s/\?//;s/\¿//;s/;//g;s/\!//;s/\¡//g' \
    | tr -d ')' | tr -d '(' | sed 's/\]//;s/\[//g' | sed 's/<[^>]*>//g'\
    | sed 's/\.//;s/  / /;s/ /\. /;s/ -//;s/- //;s/"//g' > "$aw"
}

function clean_4() {
    
    if [ `wc -c <<<"${1}"` -lt 150 ]; then
    echo "${1}" | sed ':a;N;$!ba;s/\n/ /g' | sed 's/ \+/ /g' \
    | sed 's/–//g' | sed '/^$/d'
    else 
    echo "${1}" | sed ':a;N;$!ba;s/\n/\__/g' | sed 's/ \+/ /g' \
    | sed 's/–//g' | sed '/^$/d'
    fi
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
    -a I$1I2I0I"$2"I$1I2I0I "$3"
}


function tags_6() {
    
    eyeD3 --set-encoding=utf8 \
    -A IWI3I0I"$2"IWI3I0I "$3"
}


function tags_8() {
    
    eyeD3 -p I$1I4I0I"$2"I$1I4I0I "$3"
}


function tags_9() {
    
    eyeD3 --set-encoding=utf8 -A IWI3I0I"$2"IWI3I0IIPWI3I0I"$3"IPWI3I0I "$4"
}


function set_image_1() {
    
    scrot -s --quality 90 img.jpg
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
    DT_r="$1"; cd "$DT_r"; touch "$DT_r/A.$2" "$DT_r/B.$2" "$DT_r/g.$2"; n=1
    
    if [ "$lgt" = ja ] || [ "$lgt" = "zh-cn" ] || [ "$lgt" = ru ]; then
        while [[ $n -le "$(wc -l < "$aw")" ]]; do
        s=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
        t=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
        echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> "$DT_r/A.$2"
        echo "$t"_"$s""" >> "$DT_r/B.$2"
        let n++
        done
    else
        while [[ $n -le "$(wc -l < "$aw")" ]]; do
        t=$(sed -n "$n"p $aw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
        s=$(sed -n "$n"p $bw | awk '{print tolower($0)}' | sed 's/^\s*./\U&\E/g')
        echo ISTI"$n"I0I"$t"ISTI"$n"I0IISSI"$n"I0I"$s"ISSI"$n"I0I >> "$DT_r/A.$2"
        echo "$t"_"$s""" >> "$DT_r/B.$2"
        let n++
        done
    fi
    
    grmrk="$(sed ':a;N;$!ba;s/\n/ /g' < "$DT_r/g.$r")"
    lwrds="$(< "$DT_r/A.$r")"
    pwrds="$(tr '\n' '_' < "$DT_r/B.$r")"
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
    
    synth="$(sed -n 13p "$DC_s/1.cfg" \
    | grep -o synth=\"[^\"]* | grep -o '[^"]*$')"
    DT_r="$2"; cd "$DT_r"
    
    if [[ -n "$synth" ]]; then
    
        if [[ "$synth" = 'festival' ]] || [[ "$synth" = 'text2wave' ]]; then
            lg="${lgtl,,}"

            if ([ $lg = "english" ] \
            || [ $lg = "spanish" ] \
            || [ $lg = "russian" ]); then
            echo "$1" | text2wave -o "$DT_r/s.wav"
            sox "$DT_r/s.wav" "${3}"
            else
            msg "$(gettext "Sorry, can not process this language.")\n" error
            [ "$DT_r" ] && rm -fr "$DT_r"; exit 1; fi
        else
            echo "${1}" | "$synth"
            [ -f *.mp3 ] && mv -f *.mp3 "${3}"
            [ -f *.wav ] && sox *.wav "${3}"
        fi
        
    else
        lg="${lgtl,,}"
        [ $lg = chinese ] && lg=Mandarin
        [ $lg = portuguese ] && lg=brazil
        [ $lg = vietnamese ] && lg=vietnam
        if [ $lg = japanese ]; then msg "$(gettext "Sorry, can not process Japanese language.")\n" error
        [ "$DT_r" ] && rm -fr "$DT_r"; exit 1; fi
        
        espeak "${1}" -v $lg -k 1 -p 40 -a 80 -s 110 -w "$DT_r/s.wav"
        sox "$DT_r/s.wav" "${3}"
    fi
}


function fetch_audio() {
    
    if [ $lgt = ja ] || [ $lgt = "zh-cn" ] || [ $lgt = ru ]; then
    words_list="$2"; else words_list="$1"; fi
    
    while read word; do
        
        if [ ! -f "$DM_tls/${word,,}.mp3" ]; then

            dictt "${word,,}" "$3"
            
            if [ -f "$3/${word,,}.mp3" ]; then
                mv -f "$3/${word,,}.mp3" "$4/${word,,}.mp3"
            else
                voice "${word}" "$3" "$4/${word,,}.mp3"
            fi
        fi
    done < "${words_list}"
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
    echo "$2" | sed 's/\[ \.\.\. ] //g' | sed 's/\.//g' \
    | tr '_' '\n' | sed -n 1~2p | sed '/^$/d' > lst
    else
    cat "$1" | sed 's/\[ \.\.\. ] //g' | sed 's/\.//g' \
    | tr -s "[:blank:]" '\n' | sed '/^$/d' | sed '/"("/d' \
    | grep -v '^.$' | grep -v '^..$' \
    | sed '/")"/d' | sed '/":"/d' | sed 's/[^ ]\+/\L\u&/g' \
    | head -n100 | egrep -v "FALSE" | egrep -v "TRUE" > lst
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
    --width=450 --height=130 --borders=0 \
    --field="" "$txt" \
    --field=":CB" "$tpe!$(gettext "New") *$e$tpcs" \
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
    --width=450 --height=150 --borders=0 \
    --field="" "$txt" \
    --field="" "$srce" \
    --field=":CB" "$tpe!$(gettext "New") *$e$tpcs" \
    --button="$(gettext "Image")":3 \
    --button="$(gettext "Audio")":2 \
    --button=gtk-add:0
}


function dlg_radiolist_1() {
    
    echo "$1" | awk '{print "FALSE\n"$0}' | \
    yad --list --radiolist --title="$(gettext "Word list")" \
    --text="<b>$te</b> <small> $info</small>" \
    --name=Idiomind --class=Idiomind \
    --separator="\n" \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --center --on-top --fixed --no-headers \
    --width=150 --height=420 --borders=5 \
    --column=" " --column=" " \
    --button="gtk-add":0
}


function dlg_checklist_1() {
    
    cat "$1" | awk '{print "FALSE\n"$0}' | \
    yad --list --checklist --title="$(gettext "Word list")" \
    --text="<small> $2 </small>" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --center --on-top --no-headers \
    --text-align=right --buttons-layout=end \
    --width=400 --height=280 --borders=5  \
    --column=" " --column="Select" \
    --button="$(gettext "Close")":1 \
    --button="gtk-add":0 > "$slt"
}


function dlg_checklist_3() {

    slt=$(mktemp $DT/slt.XXXX.x)
    cat "$1" | awk '{print "FALSE\n"$0}' | \
    yad --list --checklist --title="$2" \
    --text="<small>$info</small> " \
    --name=Idiomind --class=Idiomind \
    --dclick-action="'/usr/share/idiomind/add.sh' 'list_words_dclik'" \
    --window-icon="$DS/images/icon.png" \
    --ellipsize=END --text-align=right --center --no-headers \
    --width=600 --height=550 --borders=5 \
    --column="$(wc -l < "$1")" \
    --column="$(gettext "sentences")" \
    --button="$(gettext "Cancel")":1 \
    --button=$(gettext "Edit"):2 \
    --button="gtk-add":0 > "$slt"
}


function dlg_text_info_1() {
    
    cat "$1" | awk '{print "\n\n\n"$0}' | \
    yad --text-info --title="$2" \
    --name=Idiomind --class=Idiomind \
    --editable \
    --window-icon="$DS/images/icon.png" \
    --wrap --margins=30 --fontname=vendana \
    --skip-taskbar --center --on-top \
    --width=600 --height=550 --borders=5 \
    --button="gtk-ok":0 > ./sort
}


function dlg_text_info_3() {

    printf "$2" | yad --text-info --title="Idiomind" \
    --text="$1" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --wrap --margins=5 \
    --center --on-top \
    --width=510 --height=450 --borders=5 \
    "$3" --button="$(gettext "OK")":1
}


function dlg_form_3() {
    
    yad --form --title=$(gettext "Image") "$image" "$label" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --image-on-top \
    --align=center --text-align=center --center --on-top \
    --width=420 --height=320 --borders=5 \
    "$btn2" --button=$(gettext "Close"):1
}


function dlg_progress_1() {
    
    yad --progress --title="$(gettext "Processing")" \
    --window-icon="$DS/images/icon.png" \
    --progress-text=" " --pulsate --percentage="5" --auto-close \
    --skip-taskbar --no-buttons --on-top --fixed \
    --width=200 --height=50 --borders=4 --geometry=240x20-4-4
}


function dlg_progress_2() {

    yad --progress --title="$(gettext "Progress")" \
    --window-icon="$DS/images/icon.png" \
    --progress-text=" " --auto-close \
    --skip-taskbar --no-buttons --on-top --fixed \
    --width=200 --height=50 --borders=4 --geometry=240x20-4-4
}
