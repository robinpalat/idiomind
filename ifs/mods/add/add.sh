#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [ -z "${lgtl}" -o -z "${lgsl}" ]; then
msg "$(gettext "Please check the language settings in the preferences dialog.")\n" error "$(gettext "Information")" & exit 1
fi

function check_s() {
    if [ -z "${1}" ]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r" &
        msg "$(gettext "No topic is active")\n" info Information & exit 1
    fi
    DC_tlt="$DM_tl/${1}/.conf"
    if [[ `wc -l < "${DC_tlt}/0.cfg"` -ge 200 ]]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "You've reached the maximum number of notes for this topic. Max allowed (200)")" info "$(gettext "Information")" & exit
    fi
}

function mksure() {
    e=0; shopt -s extglob
    for str in "${@}"; do
    if [ -z "${str##+([[:space:]])}" ]; then e=1; break; fi
    done
    return $e
}

function index() {
    brk=0; while true; do
    if [ ! -f "$DT/i_lk" -o ${brk} -gt 20 ]; then > "$DT/i_lk" & break
    elif [ -f "$DT/i_lk" ]; then sleep 1; fi
    let brk++; done

    if [[ ${1} = edit ]]; then
        DC_tlt="$DM_tl/${2}/.conf"
        
        sust(){
            if grep -Fxo "${trgt}" "${1}"; then
            sed -i "s/${trgt}/${trgt_mod}/" "${1}"
            fi
        }
        s=1
        while [ ${s} -le 6 ]; do
            sust "${DC_tlt}/${s}.cfg"
            let s++
        done
        if [ -d "${DC_tlt}/practice" ]; then
            cd "${DC_tlt}/practice"
            while read file_pr; do
                sust "${file_pr}"
            done < <(ls ./*)
            rm ./*.tmp
            cd /
        fi
    else
        DC_tlt="${DM_tl}/${tpe}/.conf"
        if [ ! -n "${trgt}" ]; then return 1; fi
        if [ ! -d "${DC_tlt}" ]; then return 1; fi
        img0='/usr/share/idiomind/images/0.png'
        #
        if [ ! -z "${trgt}" ]; then
            if ! grep -Fxq "${trgt}" < <(cat "${DC_tlt}/1.cfg" "${DC_tlt}/2.cfg"); then
                if [[ ${1} = 1 ]]; then
                    unset wrds grmr
                    if [ "$(grep "$4" "${DC_tlt}/1.cfg")" ] && [ -n "$4" ]; then
                    sed -i "s/${4}/${4}\n${trgt}/" "${DC_tlt}/1.cfg"
                    else
                    echo "${trgt}" >> "${DC_tlt}/1.cfg"; fi
                    echo "${trgt}" >> "${DC_tlt}/3.cfg"
                    echo -e "FALSE\n${trgt}\n$img0" >> "${DC_tlt}/5.cfg"

                elif [[ ${1} = 2 ]]; then
                    echo "${trgt}" >> "${DC_tlt}/1.cfg"
                    echo "${trgt}" >> "${DC_tlt}/4.cfg"
                    echo -e "FALSE\n${trgt}\n$img0" >> "${DC_tlt}/5.cfg"
                fi
            fi
            if ! grep -Fo "trgt={${trgt}}" "${DC_tlt}/0.cfg"; then
                pos=`wc -l < "${DC_tlt}/0.cfg"`
                item="${pos}:[type={$1},trgt={$trgt},srce={$srce},exmp={$exmp},defn={$defn},note={$note},wrds={$wrds},grmr={$grmr},].[tag={$tag},mark={$mark},link={$link},].id=[$id]"
                echo "${item}" >> "${DC_tlt}/0.cfg"
            fi
        fi
    fi
    sleep 0.5
    rm -f "$DT/i_lk"
}

function sentence_p() {
    if [ ${2} = 1 ]; then 
        trgt_p="${trgt}"
        srce_p="${srce}"
    elif [ ${2} = 2 ]; then
        trgt_p="${trgt_mod}"
        srce_p="${srce_mod}"
    fi
    
    cdb="$DM_tls/Dictionary/${lgtl}.db"
    table="T`date +%m%y`"; row_trans="$lgsl"
    echo -n "create table if not exists ${table} \
    (Word TEXT, ${row_trans^} TEXT);" |sqlite3 ${cdb}
    if ! grep -q ${lgsl} <<<"$(sqlite3 ${cdb} "PRAGMA table_info(${table});")"; then
        sqlite3 ${cdb} "alter table ${table} add column ${lgsl} TEXT;"
    fi

    r=$((RANDOM%10000))
    cd /; DT_r="$1"; cd "$DT_r"; touch "swrd.$r" "twrd.$r"
    if [ "$lgt" = ja -o "$lgt" = "zh-cn" -o "$lgt" = ru ]; then
        vrbl="${srce_p}"; lg=$lgt; aw="./swrd.$r"; bw="./twrd.$r"
    else
        vrbl="${trgt_p}"; lg=$lgs; aw="./twrd.$r"; bw="./swrd.$r"
    fi
    
    echo "${vrbl}" \
    | python -c 'import sys; print(" ".join(sorted(set(sys.stdin.read().split()))))' \
    | sed 's/ /\n/g' | grep -v '^.$' | grep -v '^..$' \
    | tr -d '*)(,;"“”:' | tr -s '&|{}[]' ' ' \
    | sed 's/,//;s/\?//;s/\¿//;s/;//g;s/\!//;s/\¡//g' \
    | sed 's/\]//;s/\[//;s/<[^>]*>//g' | sed "s/'$//;s/^'//"\
    | sed 's/\.//;s/  / /;s/ /\. /;s/ -//;s/- //;s/"//g' \
    | tr -d '.' | sed 's/^ *//; s/ *$//; /^$/d' > "${aw}"
    translate "$(sed '/^$/d' "${aw}")" auto $lg | tr -d '!?¿,;.' > "${bw}"
    touch "A.$r" "B.$r" "g.$r"
    
    while read -r wrd; do
        w="$(tr -d '\.,;“”"' <<<"${wrd,,}")"
        if [[ `sqlite3 $db "select items from pronouns where items is '${w}';"` ]]; then
            echo "<span color='#3E539A'>${wrd}</span>" >> ./"g.$r"
        elif [[ `sqlite3 $db "select items from nouns_adjetives where items is '${w}';"` ]]; then
            echo "<span color='#496E60'>${wrd}</span>" >> ./"g.$r"
        elif [[ `sqlite3 $db "select items from nouns_verbs where items is '${w}';"` ]]; then
            echo "<span color='#62426A'>${wrd}</span>" >> ./"g.$r"
        elif [[ `sqlite3 $db "select items from conjunctions where items is '${w}';"` ]]; then
            echo "<span color='#90B33B'>${wrd}</span>" >> ./"g.$r"
        elif [[ `sqlite3 $db "select items from prepositions where items is '${w}';"` ]]; then
            echo "<span color='#D67B2D'>${wrd}</span>" >> ./"g.$r"
        elif [[ `sqlite3 $db "select items from adverbs where items is '${w}';"` ]]; then
            echo "<span color='#9C68BD'>${wrd}</span>" >> ./"g.$r"
        elif [[ `sqlite3 $db "select items from adjetives where items is '${w}';"` ]]; then
            echo "<span color='#3E8A3B'>${wrd}</span>" >> ./"g.$r"
        elif [[ `sqlite3 $db "select items from verbs where items is '${w}';"` ]]; then
            echo "<span color='#CF387F'>${wrd}</span>" >> ./"g.$r"
        else
            echo "${wrd}" >> ./"g.$r"
        fi
    done < <(sed 's/ /\n/g' <<<"${trgt_p}")
    
    sed -i 's/\. /\n/g' "${bw}"
    sed -i 's/\. /\n/g' "${aw}"
    touch "$DT_r/A.$r" "$DT_r/B.$r" "$DT_r/g.$r"; bcle=1
    
    if [ "$lgt" = ja -o "$lgt" = "zh-cn" -o "$lgt" = ru ]; then
        while [[ ${bcle} -le $(wc -l < "${aw}") ]]; do
        s=$(sed -n ${bcle}p ${aw} |awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
        t=$(sed -n ${bcle}p ${bw} |awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
        echo "$t"_"$s""" >> "$DT_r/B.$r"
        if ! [[ "${t}" =~ [0-9] ]] && [ -n "${t}" ] && [ -n "${s}" ]; then
            if ! [[ `sqlite3 ${cdb} "select Word from Words where Word is '${t}';"` ]]; then
                echo -n "insert into ${table} (Word,${row_trans^}) \
                values ('${t}','${s}');" |sqlite3 ${cdb}
                echo -n "insert into Words (Word,${row_trans^},Example) \
                values ('${t}','${s}','${trgt}');" |sqlite3 ${cdb}
            elif ! [[ `sqlite3 ${cdb} "select Example from Words where Word is '${t}';"` ]]; then
                echo -n "update Words set Example='${trgt}' where Word='${t}';" |sqlite3 ${cdb}
            fi
        fi
        let bcle++
        done
    else
        while [[ ${bcle} -le $(wc -l < "${aw}") ]]; do
        t=$(sed -n ${bcle}p ${aw} |awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
        s=$(sed -n ${bcle}p ${bw} |awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
        echo "$t"_"$s""" >> "$DT_r/B.$r"
        if ! [[ "${t}" =~ [0-9] ]] && [ -n "${t}" ] && [ -n "${s}" ]; then
            if ! [[ `sqlite3 ${cdb} "select Word from Words where Word is '${t}';"` ]]; then
                echo -n "insert into ${table} (Word,${row_trans^}) \
                values ('${t}','${s}');" |sqlite3 ${cdb}
                echo -n "insert into Words (Word,${row_trans^},Example) \
                values ('${t}','${s}','${trgt}');" |sqlite3 ${cdb}
            elif ! [[ `sqlite3 ${cdb} "select Example from Words where Word is '${t}';"` ]]; then
                echo -n "update Words set Example='${trgt}' where Word='${t}';" |sqlite3 ${cdb}
            fi
        fi
        let bcle++
        done
    fi
    if [ ${2} = 1 ]; then
    grmr="$(sed ':a;N;$!ba;s/\n/ /g' < "$DT_r/g.$r")"
    wrds="$(tr '\n' '_' < "$DT_r/B.$r")"
    elif [ ${2} = 2 ]; then
    grmr_mod="$(sed ':a;N;$!ba;s/\n/ /g' < "$DT_r/g.$r")"
    wrds_mod="$(tr '\n' '_' < "$DT_r/B.$r")"
    fi
}

function word_p() {
    cdb="$DM_tls/Dictionary/${lgtl}.db"
    table="T`date +%m%y`"; row_trans="$lgsl"
    echo -n "create table if not exists ${table} \
    (Word TEXT, ${row_trans^} TEXT);" |sqlite3 ${cdb}
    if ! grep -q ${lgsl} <<<"$(sqlite3 ${cdb} "PRAGMA table_info(${table});")"; then
        sqlite3 ${cdb} "alter table ${table} add column ${lgsl} TEXT;"
    fi
    if ! [[ `sqlite3 ${cdb} "select Word from Words where Word is '${trgt}';"` ]] \
    && ! [[ "${trgt}" =~ [0-9] ]] && [ -n "${trgt}" ] && [ -n "${srce}" ]; then
        echo -n "insert into ${table} (Word,${row_trans^}) \
        values ('${trgt}','${srce}');" |sqlite3 ${cdb}
        echo -n "insert into Words (Word,${row_trans^}) \
        values ('${trgt}','${srce}');" |sqlite3 ${cdb}
    fi
}

function clean_1() {
    echo "${1}" | sed 's/\\n/ /g' | sed ':a;N;$!ba;s/\n/ /g' \
    | sed "s/’/'/g" \
    | sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/ -//;s/- //g' \
    | sed 's/^ *//;s/ *$//g' | sed 's/^\s*./\U&\E/g' \
    | tr -d '/*|",;!¿?()[]&:.<>+'  | sed 's/\¡//g' \
    | sed 's/<[^>]*>//g' | sed 's/ \+/ /g'
}

function clean_0() {
    echo "${1}" | sed 's/\\n/ /g' | sed ':a;N;$!ba;s/\n/ /g' \
    | sed "s/’/'/g" \
    | sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/ -//;s/- //g' \
    | sed 's/^ *//;s/ *$//g' | sed 's/^\s*./\U&\E/g' \
    | tr -d '*|;!¿?[]&:<>+'  | sed 's/\¡//g' \
    | sed 's/<[^>]*>//g' | sed 's/ \+/ /g'
}

function clean_2() {
    if [ "$lgt" = ja -o "$lgt" = "zh-cn" -o "$lgt" = ru ]; then
    echo "${1}" | sed 's/\\n/ /g' | sed ':a;N;$!ba;s/\n/ /g' \
    | sed "s/’/'/g" \
    | tr -d '*\/' | tr -s '*&|{}[]<>+' ' ' \
    | sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/ -//;s/- //g' \
    | sed 's/^ *//; s/ *$//g' | sed 's/ — /__/g' | sed 's/<[^>]*>//g'
    else
    echo "${1}" | sed 's/\\n/ /g' | sed ':a;N;$!ba;s/\n/ /g' \
    | sed "s/’/'/g" \
    | tr -d '*\/' | tr -s '*&|{}[]<>+' ' ' \
    | sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/ -//;s/- //g' \
    | sed 's/^ *//;s/ *$//g' | sed 's/^\s*./\U&\E/g' \
    | sed 's/ — /__/g' | sed "s|/||g" | sed 's/<[^>]*>//g'
    fi
}

function clean_3() {
    echo "${1}" | cut -d "|" -f1 | sed 's/!//;s/&//;s/\://g' \
    | sed "s/-//g" | sed 's/^[ \t]*//;s/[ \t]*$//' | sed "s|/||g" \
    | sed 's/^\s*./\U&\E/g' | sed 's/\：//g' | sed 's/<[^>]*>//g' \
    | tr -d '.*/' | tr -s '&:|{}[]<>+' ' ' | sed 's/ \+/ /g'
}  

function clean_4() {
    if [ `wc -c <<<"${1}"` -lt 180 ]; then
    echo "${1}" | sed ':a;N;$!ba;s/\n/ /g' \
    | tr -d '*/"' | tr -s '&:|{}[]<>+' ' ' \
    | sed 's/ — / /;s/--/ /g' | sed '/^$/d' | sed 's/ \+/ /g'
    else
    echo "${1}" | sed ':a;N;$!ba;s/\n/\__/g' \
    | tr -d '*/"' | tr -s '&:|{}[]<>+' ' ' \
    | sed 's/ — /__/;s/--/ /g' | sed '/^$/d' | sed 's/ \+/ /g'
    fi
}

function clean_5() {
    sed -n -e '1x;1!H;${x;s-\n- -gp}' \
    | sed 's/<[^>]*>//g' | sed 's/ \+/ /g' \
    | sed '/^$/d' |  sed 's/ \+/ /;s/\://;s/"//g' \
    | sed 's/^[ \t]*//;s/[ \t]*$//;s/^ *//; s/ *$//g' \
    | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' | grep -v '^..$' \
    | grep -v '^.$' | sed 's/<[^>]\+>//;s/\://g' \
    | sed 's/\&quot;/\"/g' | sed "s/\&#039;/\'/g" \
    | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
    | sed 's/ — /\n/g' \
    | sed 's/[<>£§]//; s/&amp;/\&/g' | sed 's/ *<[^>]\+> */ /g' \
    | sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' | sed 's/\. //g' \
    | sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' | sed 's/\? //g' \
    | sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' | sed 's/\! //g' \
    | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… //g' \
    | sed 's/__/\n/g'
}

function clean_6() {
    sed 's/\\n/./g' \
    | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//' \
    | sed 's/ — /\n/g' \
    | sed 's/ \+/ /;s/\://;s/\&quot;/\"/;s/^ *//;s/ *$//g' \
    | sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' | sed 's/\. //g' \
    | sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' | sed 's/\? //g' \
    | sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' | sed 's/\! //g' \
    | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… //g'
    
}

function clean_7() {
    sed 's/^ *//;s/ *$//g' | sed 's/^[ \t]*//;s/[ \t]*$//' \
    | sed 's/ \+/ /;s/\://;s/"//g' \
    | sed '/^$/d' | sed 's/ — /\n/g' \
    | sed 's/\&quot;/\"/g' | sed "s/\&#039;/\'/g" \
    | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
    | sed 's/ *<[^>]\+> */ /; s/[<>£§]//; s/\&amp;/\&/g' \
    | sed 's/,/\n/g' | sed 's/。/\n/g' \
    | sed 's/__/\n/g'
}

function clean_8() {
     sed 's/\[ \.\.\. \]//g' \
    | sed 's/^ *//;s/ *$//g' | sed 's/^[ \t]*//;s/[ \t]*$//' \
    | sed 's/ \+/ /;s/\://;s/"//g' \
    | sed '/^$/d' | sed 's/ — /\n/g' \
    | sed 's/\&quot;/\"/g' | sed "s/\&#039;/\'/g" \
    | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
    | sed 's/ *<[^>]\+> */ /; s/[<>£§]//; s/\&amp;/\&/g' \
    | sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' | sed 's/\. / /g' \
    | sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' | sed 's/\? / /g' \
    | sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' | sed 's/\! / /g' \
    | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… / /g' \
    | sed 's/__/ \n/g' | sed 's/ \+/ /g'
}

function set_image_1() {
    scrot -s --quality 90 "$DT_r/img.jpg"
    /usr/bin/convert "$DT_r/img.jpg" -interlace Plane -thumbnail 110x90^ \
    -gravity center -extent 110x90 -quality 90% "$DT_r/ico.jpg"
}

function set_image_2() {
    /usr/bin/convert "$DT_r/img.jpg" -interlace Plane -thumbnail 405x275^ \
    -gravity center -extent 400x270 -quality 90% "$DT_r/imgs.jpg"
    mv -f "$DT_r/imgs.jpg" "${2}"
}

function translate() {
    cdb="$DM_tls/Dictionary/${lgtl}.db"
    if [[ `wc -w <<<${1}` = 1 ]] && \
    [[ `sqlite3 ${cdb} "select ${lgsl} from Words where Word is '${1}';"` ]]; then
        sqlite3 ${cdb} "select ${lgsl} from Words where Word is '${1}';"
    else
        internet
        if ! ls "$DC_d"/*."Traslator online.Translator".* 1> /dev/null 2>&1; then
        "$DS_a/Dics/cnfg.sh" 2; fi
        for trans in "$DC_d"/*."Traslator online.Translator".*; do
            trans="$DS_a/Dics/dicts/$(basename "${trans}")"
            [ -e "${trans}" ] && "${trans}" "$@" && break
        done
    fi
}

function tts() {
    if ! ls "$DC_d"/*."TTS online.Pronunciation".* 1> /dev/null 2>&1; then
    "$DS_a/Dics/cnfg.sh" 1; fi
    for convert in "$DC_d"/*."TTS online.Pronunciation".*; do
        convert="$DS_a/Dics/dicts/$(basename "${convert}")"
        [ -e "${convert}" ] && "${convert}" "$@"
        if [ -e "${4}" ]; then break; fi
    done
}

export -f translate tts

function tts_word() {
    if ! ls "$DC_d"/*."TTS online.Word pronunciation".* 1> /dev/null 2>&1; then
        "$DS_a/Dics/cnfg.sh" 0
    fi
    word="${1,,}"
    audio_file="${2}/$word.mp3"
    audio_dwld="${2}/$word"
    if ls "$DC_d"/*."TTS online.Word pronunciation".$lgt 1> /dev/null 2>&1; then
        for dict in $DC_d/*."TTS online.Word pronunciation".$lgt; do
            LINK=""; source "$DS_a/Dics/dicts/$(basename "${dict}")"
            if [ "${LINK}" -a ! -e "$audio_file" ]; then
                wget -T 51 -q -U Mozilla -O "$audio_dwld.$ex" "${LINK}"
                if [[ ${ex} != 'mp3' ]]; then
                    sox "$audio_dwld.$ex" "$audio_dwld.mp3"; rm "$audio_dwld.$ex"
                fi
            fi
            if [ -e "$audio_file" ]; then
                if [[ `du "$audio_file" |cut -f1` -gt 1 ]]; then
                    break
                else 
                    rm "$audio_file"
                fi
            fi
        done
    fi
    if ls "$DC_d"/*."TTS online.Word pronunciation".various 1> /dev/null 2>&1; then
        if [ ! -e "${2}/${1}.mp3" ]; then
            for dict in $DC_d/*."TTS online.Word pronunciation".various; do
                LINK=""; source "$DS_a/Dics/dicts/$(basename "${dict}")"
                if [ "${LINK}" -a ! -e "$audio_file" ]; then
                    wget -T 51 -q -U Mozilla -O "$audio_dwld.$ex" "${LINK}"
                    if [[ ${ex} != 'mp3' ]]; then
                        sox "$audio_dwld.$ex" "$audio_dwld.mp3"; rm "$audio_dwld.$ex"
                    fi
                fi
                if [ -e "$audio_file" ]; then
                    if [[ `du "$audio_file" |cut -f1` -gt 1 ]]; then
                        break
                    else 
                        rm "$audio_file"
                    fi
                fi
            done
        fi
    fi
}

function img_word() {
    if ls "$DC_d"/*."Script.Download image".* 1> /dev/null 2>&1; then
        if [ ! -e "${DM_tls}/images/${1,,}-0.jpg" ]; then
            touch "$DT/img${1}.lk"
            for img in "$DC_d"/*."Script.Download image".*; do
                img="$DS_a/Dics/dicts/$(basename "${img}")"
                [ -e "${img}" ] && "${img}" "${1}"
                
                if [ -e "$DT/${1}.jpg" ]; then
                if [[ `du "$DT/${1}.jpg" |cut -f1` -gt 10 ]]; then
                break; else rm -f "$DT/${1}.jpg"; fi; fi
            done
            
            if [ ! -e "$DT/${1}.jpg" ]; then
            for img in "$DC_d"/*."Script.Download image".*; do
                img="$DS_a/Dics/dicts/$(basename "${img}")"
                [ -e "${img}" ] && "${img}" "${2}"
                
                if [ -e "$DT/${2}.jpg" ]; then
                if [[ `du "$DT/${2}.jpg" |cut -f1` -gt 10 ]]; then
                break; else rm -f "$DT/${2}.jpg"; fi; fi
            done; fi
            
            if [ -e "$DT/${1}.jpg" -o -e "$DT/${2}.jpg" ]; then
            [ -e "$DT/${1}.jpg" ] && img_file="$DT/${1}.jpg" || img_file="$DT/${2}.jpg"
            /usr/bin/convert "${img_file}" -interlace Plane -thumbnail 405x275^ \
            -gravity center -extent 400x270 -quality 90% "${DM_tls}/images/${1,,}-0.jpg"
            rm -f "${img_file}"; fi
            rm -f "$DT/img${1}.lk"
        fi
    fi
}

function voice() {
    txaud="$(grep -o txaud=\"[^\"]* "$DC_s/1.cfg" |grep -o '[^"]*$')"
    DT_r="$2"; cd "$DT_r"
    if [ -n "${txaud}" ]; then
        echo "${1}" | $txaud "$DT_r/f.wav"
        sox "$DT_r"/*.wav "${3}"
        if [ $? != 0 ]; then
            notify-send -i idiomind "$(gettext "Please check the speech synthesizer configuration in the preferences dialog.")" & exit 1
        fi
    else
        return 1
    fi
}

function fetch_audio() {
    if ! ls "$DC_d"/*."TTS online.Word pronunciation".* 1> /dev/null 2>&1; then
    "$DS_a/Dics/cnfg.sh" 0
    fi
    if [ $lgt = ja -o $lgt = "zh-cn" -o $lgt = ru ]; then
        words_list="${2}"; else words_list="${1}"
    fi
    while read -r Word; do
        word="${Word,,}"
        audio_file="$DM_tls/audio/$word.mp3"
        audio_dwld="${2}/$word"
        if [ ! -e "$audio_file" ]; then
            for dict in "$DC_d"/*."TTS online.Word pronunciation".$lgt; do
                LINK=""; source "$DS_a/Dics/dicts/$(basename "${dict}")"
                if [ "${LINK}" -a ! -e "$audio_file" ]; then
                    wget -T 51 -q -U Mozilla -O "$audio_dwld.$ex" "${LINK}"
                    if [[ ${ex} != 'mp3' ]]; then
                        sox "$audio_dwld.$ex" "$audio_dwld.mp3"; rm "$audio_dwld.$ex"
                    fi
                fi
                if [ -e "$audio_file" ]; then
                    if [[ `du "$audio_file" |cut -f1` -gt 1 ]]; then
                        break
                    else 
                        rm "$audio_file"
                    fi
                fi
            done
            for dict in "$DC_d"/*."TTS online.Word pronunciation".various; do
                LINK=""; source "$DS_a/Dics/dicts/$(basename "${dict}")"
                if [ "${LINK}" -a ! -e "$audio_file" ]; then
                    wget -T 51 -q -U Mozilla -O "$audio_dwld.$ex" "${LINK}"
                    if [[ ${ex} != 'mp3' ]]; then
                        sox "$audio_dwld.$ex" "$audio_dwld.mp3"; rm "$audio_dwld.$ex"
                    fi
                fi
                if [ -e "$audio_file" ]; then
                    if [[ `du "$audio_file" |cut -f1` -gt 1 ]]; then
                        break
                    else 
                        rm "$audio_file"
                    fi
                fi
            done
        fi
    done < "${words_list}"
}

function list_words_2() {
    if [ $lgt = ja -o $lgt = 'zh-cn' -o $lgt = ru ]; then
    echo "${1}" | awk 'BEGIN{RS=ORS=" "}!a[$0]++' \
    | tr -d '*/“”"' | tr '_' '\n' | sed -n 1~2p | sed '/^$/d'
    else
    echo "${1}" | awk 'BEGIN{RS=ORS=" "}!a[$0]++' \
    | tr -d '*/“”"' | tr '_' '\n' | sed -n 1~2p | sed '/^$/d'
    fi
}

function list_words_3() {
    if [ $lgt = ja -o $lgt = 'zh-cn' -o $lgt = ru ]; then
    echo "${2}" | awk 'BEGIN{RS=ORS=" "}!a[$0]++' \
    | sed 's/\[ \.\.\. ] //g' | sed 's/\.//g' \
    | tr '_' '\n' | tr -d ',;' | sed -n 1~2p | sed '/^$/d' > "$DT_r/lst"
    else
    echo "${1}" | awk 'BEGIN{RS=ORS=" "}!a[$0]++' \
    | sed 's/\[ \.\.\. ] //g' | sed 's/\.//g' \
    | tr -s "[:blank:]" '\n' | tr -d ',;()' \
    | sed '/^$/d' | sed '/"("/d' \
    | grep -v '^.$' | grep -v '^..$' \
    | sed 's/[^ ]\+/\L\u&/g' \
    | head -n100 | egrep -v "FALSE" | egrep -v "TRUE" > "$DT_r/lst"
    fi
} >/dev/null 2>&1

function dlg_form_0() {
    yad --form --title="$(gettext "New Topic")" \
    --name=Idiomind --class=Idiomind \
    --separator='|' \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --center --on-top \
    --width=450 --height=100 --borders=0 \
    --field="$(gettext "Name")" "$1" \
    --field="$(gettext "Type")":CB "$(gettext "Normal")!$(gettext "Tag")" \
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

function dlg_checklist_1() {
    echo "${1}" | awk '{print "FALSE\n"$0}' | \
    yad --list --checklist --title="$(gettext "Word list")" \
    --text="<small> $2 </small>" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --center --on-top --no-headers \
    --text-align=right --buttons-layout=end \
    --width=400 --height=280 --borders=5  \
    --column=" " --column="Select" \
    --button="$(gettext "Cancel")":1 \
    --button="gtk-add":0
}

function dlg_checklist_3() {
    cat "${1}" | awk '{print "FALSE\n"$0}' | \
    yad --list --checklist --title="$(gettext "New note")" \
    --name=Idiomind --class=Idiomind \
    --dclick-action="'/usr/share/idiomind/add.sh' 'list_words_dclik'" \
    --window-icon="$DS/images/icon.png" \
    --ellipsize=END --center --no-click --text-align=right \
    --width=700 --height=380 --borders=5 \
    --column="$(gettext "Select")" \
    --column="$(wc -l < "${1}") $(gettext "notes found")" \
    --button=$(gettext "Edit"):2 \
    --button="$(gettext "Cancel")":1 \
    --button="gtk-add":0 > "$slt"
}

function dlg_text_info_1() {
    cat "${1}" | awk '{print "\n\n\n"$0}' | \
    yad --text-info --title="$(gettext "Edit")" \
    --name=Idiomind --class=Idiomind \
    --editable \
    --window-icon="$DS/images/icon.png" \
    --wrap --margins=30 --fontname=vendana \
    --skip-taskbar --center --on-top \
    --width=700 --height=500 --borders=5 \
    --button="gtk-ok":0
}

function msg_3() {
    cmd_listen="$DS/play.sh play_word "\"${3}\"""
    [ -n "$5" ] && title="$5" || title=Idiomind
    yad --title="$title" --text="$1" --image="$2" \
    --name=Idiomind --class=Idiomind \
    --always-print-result \
    --window-icon="$DS/images/icon.png" \
    --image-on-top --on-top --sticky --center \
    --width=400 --height=120 --borders=3 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Play")":"$cmd_listen" \
    --button="$(gettext "Yes")":0
}

function dlg_text_info_3() {
    echo -e "${2}" | yad --text-info \
    --title="$(gettext "Some notes could not be added to your list")" \
    --text="${1}" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --wrap --margins=5 \
    --center --on-top \
    --width=510 --height=300 --borders=5 \
    "${3}" --button="$(gettext "OK")":1
}

function dlg_form_3() {
    yad --form --title=$(gettext "Image") "$image" "$label" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --image-on-top \
    --align=center --text-align=center --center --on-top \
    --width=420 --height=320 --borders=5 \
    "${btn2}" --button="    $(gettext "Close")    ":1
}

function dlg_progress_1() {
    yad --progress --title="$(gettext "Processing")" \
    --name=Idiomind --class=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --progress-text=" " \
    --pulsate --percentage="5" --auto-close \
    --undecorated --skip-taskbar --no-buttons \
    --on-top --mouse --fixed \
    --width=200 --height=50 --borders=2
}

function cleanups() {
    for fl in "$@"; do
        if [ -d "${fl}" ]; then
            rm -fr "${fl}"
        elif [ -f "${fl}" ]; then
            rm -f "${fl}"
        fi
    done
}
