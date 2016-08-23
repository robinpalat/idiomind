#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [ -z "${tlng}" -o -z "${slng}" ]; then
msg "$(gettext "Please check the language settings in the preferences dialog.")\n" \
error "$(gettext "Information")" & exit 1
fi

function check_s() {
    if [ -z "${1}" ]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r" &
        msg "$(gettext "No topic selected")\n" \
        dialog-information "$(gettext "Information")" & exit 1
    fi
    DC_tlt="$DM_tl/${1}/.conf"
    if [[ $(wc -l < "${DC_tlt}/0.cfg") -ge 200 ]]; then
        [ -d "$DT_r" ] && rm -fr "$DT_r"
        msg "$(gettext "You've reached the maximum number of notes for this topic. Max allowed (200)")" \
        dialog-information "$(gettext "Information")" & exit
    fi
}

function mksure() {
    e=0; shopt -s extglob
    for str in "${@}"; do
    if [ -z "${str##+([[:space:]])}" ]; then
    e=1; break; fi
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
            if grep -Fxo "${trgt}" "${1}" 1> /dev/null 2>&1; then
                sed -i "s/^${trgt}$/${trgt_mod}/" "${1}"
            fi
        }
        
        s=1
        while [ ${s} -le 6 ]; do
            sust "${DC_tlt}/${s}.cfg"
            let s++
        done
        if [ -d "${DC_tlt}/practice" ]; then
            cd "${DC_tlt}/practice"
            while read -r file_pr; do
                sust "${file_pr}"
            done < <(ls ./*)
            rm ./*.tmp
            cd /
        fi
    else
        DC_tlt="${DM_tl}/${tpe}/.conf"; type=${1}
        if [ ! -n "${trgt}" ]; then return 1; fi
        if [ ! -d "${DC_tlt}" ]; then return 1; fi
        img0='/usr/share/idiomind/images/0.png'
        #
        if [ ! -z "${trgt}" ]; then
            if ! grep -Fxq "${trgt}" < <(cat "${DC_tlt}/1.cfg" "${DC_tlt}/2.cfg") >/dev/null 2>&1; then
                if [[ ${1} = 1 ]]; then
                    unset wrds grmr
                    echo "${trgt}" >> "${DC_tlt}/1.cfg"
                    echo "${trgt}" >> "${DC_tlt}/3.cfg"
                    echo -e "$img0\n${trgt}\nFALSE\n${srce}" >> "${DC_tlt}/5.cfg"

                elif [[ ${1} = 2 ]]; then
                    echo "${trgt}" >> "${DC_tlt}/1.cfg"
                    echo "${trgt}" >> "${DC_tlt}/4.cfg"
                    echo -e "$img0\n${trgt}\nFALSE\n${srce}" >> "${DC_tlt}/5.cfg"
                fi
            fi
            if ! grep -Fo "trgt{${trgt}}" "${DC_tlt}/0.cfg"; then
                eval newline="$(sed -n 2p $DS/default/vars)"
                echo "${newline}" >> "${DC_tlt}/0.cfg"
            fi
        fi
    fi
    sleep 0.5
    rm -f "$DT/i_lk"
}

function sentence_p() {

    if [ ${1} = 1 ]; then 
        trgt_p="${trgt}"
        srce_p="${srce}"
    elif [ ${1} = 2 ]; then
        trgt_p="${trgt_mod}"
        srce_p="${srce_mod}"
    fi

    cdb="$DM_tls/data/${tlng}.db"
    table="T`date +%m%y`"
    echo -n "create table if not exists ${table} \
    (Word TEXT, ${slng^} TEXT);" |sqlite3 ${cdb}
    if ! grep -q ${slng} <<< "$(sqlite3 ${cdb} "PRAGMA table_info(${table});")"; then
        sqlite3 ${cdb} "alter table ${table} add column ${slng} TEXT;"
    fi

    r=$((RANDOM%10000))
    touch "$DT_r/swrd.$r" "$DT_r/twrd.$r"
    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt}; then
        vrbl="${srce_p}"; lg=$lgt; aw="$DT_r/swrd.$r"; bw="$DT_r/twrd.$r"
    else
        vrbl="${trgt_p}"; lg=$lgs; aw="$DT_r/twrd.$r"; bw="$DT_r/swrd.$r"
    fi
    
    echo "${vrbl}" |sed 's/ ./\U&/g' \
    |python -c 'import sys; print(" ".join(sorted(set(sys.stdin.read().split()))))' \
    |sed 's/ /\n/g' |grep -v '^.$' |grep -v '^..$' \
    |tr -d '*)(,;"“”:' |tr -s '_&|{}[]' ' ' \
    |sed 's/,//;s/\?//;s/\¿//;s/;//g;s/\!//;s/\¡//g' \
    |sed 's/\]//;s/\[//;s/<[^>]*>//g' |sed "s/'$//;s/^'//"\
    |sed 's/\.//;s/  / /;s/ /\. /;s/-$//;s/^-//;s/"//g' \
    |tr -d '.' |sed 's/^ *//; s/ *$//; /^$/d' > "${aw}"
    translate "$(sed '/^$/d' "${aw}")" auto $lg |tr -d '!?¿,;.' > "${bw}"
    
    while read -r wrd; do
        w="$(tr -d '\.,;“”"' <<< "${wrd,,}")"
        if [[ `sqlite3 $db "select items from pronouns where items is '${w}';"` ]]; then
            echo "<span color='#3E539A'>${wrd}</span>" >> "$DT_r/g.$r"
        elif [[ `sqlite3 $db "select items from nouns_adjetives where items is '${w}';"` ]]; then
            echo "<span color='#496E60'>${wrd}</span>" >> "$DT_r/g.$r"
        elif [[ `sqlite3 $db "select items from nouns_verbs where items is '${w}';"` ]]; then
            echo "<span color='#62426A'>${wrd}</span>" >> "$DT_r/g.$r"
        elif [[ `sqlite3 $db "select items from conjunctions where items is '${w}';"` ]]; then
            echo "<span color='#90B33B'>${wrd}</span>" >> "$DT_r/g.$r"
        elif [[ `sqlite3 $db "select items from prepositions where items is '${w}';"` ]]; then
            echo "<span color='#D67B2D'>${wrd}</span>" >> "$DT_r/g.$r"
        elif [[ `sqlite3 $db "select items from adverbs where items is '${w}';"` ]]; then
            echo "<span color='#9C68BD'>${wrd}</span>" >> "$DT_r/g.$r"
        elif [[ `sqlite3 $db "select items from adjetives where items is '${w}';"` ]]; then
            echo "<span color='#3E8A3B'>${wrd}</span>" >> "$DT_r/g.$r"
        elif [[ `sqlite3 $db "select items from verbs where items is '${w}';"` ]]; then
            echo "<span color='#CF387F'>${wrd}</span>" >> "$DT_r/g.$r"
        else
            echo "${wrd}" >> "$DT_r/g.$r"
        fi
    done < <(sed 's/ /\n/g' <<< "${trgt_p}")
    
    sed -i 's/\. /\n/g' "${bw}"
    sed -i 's/\. /\n/g' "${aw}"
    touch "$DT_r/A.$r" "$DT_r/B.$r" "$DT_r/g.$r"; bcle=1
    trgt_q="${trgt//\'/\'\'}"
    
    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt}; then
        while [[ ${bcle} -le $(wc -l < "${aw}") ]]; do
        s=$(sed -n ${bcle}p ${aw} |awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
        t=$(sed -n ${bcle}p ${bw} |awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
        echo "${t}_${s}" >> "$DT_r/B.$r"
        t="${t//\'/\'\'}"
        s="${s//\'/\'\'}"
        
        if ! [[ "${t}" =~ [0-9] ]] && [ -n "${t}" ] && [ -n "${s}" ]; then
            if ! [[ `sqlite3 ${cdb} "select Word from Words where Word is '${t}';"` ]]; then
                sqlite3 ${cdb} "insert into Words (Word,${slng^},Example) values ('${t}','${s}','${trgt_q}');"
                sqlite3 ${cdb} "insert into ${table} (Word,${slng^}) values ('${t}','${s}');"
            elif ! [[ `sqlite3 ${cdb} "select ${slng^} from Words where Word is '${t}';"` ]]; then
                sqlite3 ${cdb} "update Words set ${slng^}='${s}' where Word='${t}';"
            elif ! [[ `sqlite3 ${cdb} "select Example from Words where Word is '${t}';"` ]]; then
                sqlite3 ${cdb} "update Words set Example='${trgt_q}' where Word='${t}';"
            fi
        fi
        let bcle++
        done
    else
        while [[ ${bcle} -le $(wc -l < "${aw}") ]]; do
        t=$(sed -n ${bcle}p ${aw} |awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
        s=$(sed -n ${bcle}p ${bw} |awk '{print tolower($0)}' |sed 's/^\s*./\U&\E/g')
        echo "${t}_${s}" >> "$DT_r/B.$r"
        t="${t//\'/\'\'}"
        s="${s//\'/\'\'}"
        
        if ! [[ "${t}" =~ [0-9] ]] && [ -n "${t}" ] && [ -n "${s}" ]; then
            if ! [[ `sqlite3 ${cdb} "select Word from Words where Word is '${t}';"` ]]; then
                sqlite3 ${cdb} "insert into Words (Word,${slng^},Example) values ('${t}','${s}','${trgt_q}');" 
                sqlite3 ${cdb} "insert into ${table} (Word,${slng^}) values ('${t}','${s}');"
            elif ! [[ `sqlite3 ${cdb} "select ${slng^} from Words where Word is '${t}';"` ]]; then
                sqlite3 ${cdb} "update Words set ${slng^}='${s}' where Word='${t}';"
            elif ! [[ `sqlite3 ${cdb} "select Example from Words where Word is '${t}';"` ]]; then
                sqlite3 ${cdb} "update Words set Example='${trgt_q}' where Word='${t}';"
            fi
        fi
        let bcle++
        done
    fi
    if [ ${1} = 1 ]; then
        export grmr="$(sed ':a;N;$!ba;s/\n/ /g' < "$DT_r/g.$r")"
        export wrds="$(tr '\n' '_' < "$DT_r/B.$r")"
    elif [ ${1} = 2 ]; then
        export grmr_mod="$(sed ':a;N;$!ba;s/\n/ /g' < "$DT_r/g.$r")"
        export wrds_mod="$(tr '\n' '_' < "$DT_r/B.$r")"
    fi
}

function word_p() {
    cdb="$DM_tls/data/${tlng}.db"
    table="T`date +%m%y`"
    trgt_q="${trgt//\'/\'\'}"
    srce_q="${srce//\'/\'\'}"
    
    echo -n "create table if not exists ${table} \
    (Word TEXT, ${slng^} TEXT);" |sqlite3 ${cdb}
    if ! grep -q ${slng} <<< "$(sqlite3 ${cdb} "PRAGMA table_info(${table});")"; then
        sqlite3 ${cdb} "alter table ${table} add column ${slng} TEXT;"
    fi
    if ! [[ "${trgt}" =~ [0-9] ]] && [ -n "${trgt}" ] && [ -n "${srce}" ]; then
        if ! [[ `sqlite3 ${cdb} "select Word from Words where Word is '${trgt}';"` ]]; then
            sqlite3 ${cdb} "insert into ${table} (Word,${slng^}) values ('${trgt_q}','${srce_q}');"
            sqlite3 ${cdb} "insert into Words (Word,${slng^}) values ('${trgt_q}','${srce_q}');"
        elif ! [[ `sqlite3 ${cdb} "select ${slng^} from Words where Word is '${trgt}';"` ]]; then
            sqlite3 ${cdb} "update Words set ${slng^}='${srce_q}' where Word='${trgt}';"
        fi
    fi
}

function clean_0() {
    echo "${1}" |sed 's/\\n/ /g' |sed ':a;N;$!ba;s/\n/ /g' \
    |sed "s/’/'/g" | sed "s/^-\(.*\)/\1/" \
    |sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/-$//;s/^-//' \
    |sed 's/^ *//;s/ *$//g' |sed 's/^\s*./\U&\E/g' \
    |tr -d ':*|;!¿?[]&:<>+'  |sed 's/\¡//g' \
    |sed 's/<[^>]*>//g; s/ \+/ /g'
}

function clean_1() {
    echo "${1}" |sed 's/\\n/ /g' |sed ':a;N;$!ba;s/\n/ /g' \
    |sed "s/’/'/g" | sed "s/^-\(.*\)/\1/" \
    |sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/-$//;s/^-//' \
    |sed 's/^ *//;s/ *$//g' |sed 's/^\s*./\U&\E/g' \
    |tr -s '/' '-' |tr -d '/*|",;!¿?()[]&:.<>+'  |sed 's/\¡//g' \
    |sed 's/<[^>]*>//g; s/ \+/ /g'
}

function clean_2() {
    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt}; then
    echo "${1}" |sed 's/\\n/ /;s/	/ /g' |sed ':a;N;$!ba;s/\n/ /g' \
    |sed "s/’/'/g" |sed 's/quot\;/"/g' \
    |tr -s '/' '-' |tr -d '\*' |tr -s '*&|{}[]<>+' ' ' \
    |sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/-$//;s/^-//' \
    |sed 's/^ *//;s/ *$//g;s/<[^>]*>//g;s/^\s*./\U&\E/g'
    else
    echo "${1}" |sed 's/\\n/ /;s/	/ /g' |sed ':a;N;$!ba;s/\n/ /g' \
    |sed "s/’/'/g" |sed 's/quot\;/"/g' \
    |tr -s '\*&|{}[]<>+' ' ' \
    |sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/-$//;s/^-//' \
    |sed 's/^ *//;s/ *$//g; s/^\s*./\U&\E/g' |tr -s '/' '-' \
    |sed 's|/||g; s/<[^>]*>//g;s/^\s*./\U&\E/g' #; s/-.\s*./\U&\E/g
    fi
}

function clean_3() {
    echo "${1}" |cut -d "|" -f1 |sed 's/!//;s/&//;s/\://g' \
    |sed "s/^[ \t]*//;s/[ \t]*$//;s/‘/'/g" \
    |sed 's/^\s*./\U&\E/g' \
    |sed 's/\：//g;s/<[^>]*>//g' \
    |tr -d '?./*' |tr -s '&:|{}[]<>+' ' ' |sed 's/ \+/ /g'
}  

function clean_4() {
    if [ $(wc -c <<< "${1}") -le ${sentence_chars} ] && \
    [ $(echo -e "${1}" |wc -l) -gt ${sentence_lines} ]; then
    echo "${1}" |sed "s/^-\(.*\)/\1/" | tr -d '*/' |tr -s '&|{}[]<>+' ' ' \
    |sed 's/ — / - /;s/--/ /g; /^$/d;s/ \+/ /g;s/ʺͶ//;s/	/ /g'
    elif [ $(wc -c <<< "${1}") -le ${sentence_chars} ]; then
    echo "${1}" |sed "s/^-\(.*\)/\1/" |sed ':a;N;$!ba;s/\n/ /;s/	/ /g' \
    |tr -d '*/' |tr -s '&|{}[]<>+' ' ' \
    |sed 's/ — / - /;s/--/ /g; /^$/d; s/ \+/ /g;s/ʺͶ//g'
    else
    echo "${1}" |sed "s/^-\(.*\)/\1/" |sed ':a;N;$!ba;s/\n/\__/;s/	/ /g' \
    |tr -d '*/' |tr -s '&|{}[]<>+' ' ' \
    |sed 's/ — /__/;s/--/ /g; /^$/d; s/ \+/ /g;s/ʺͶ//g'
    fi
}

function clean_5() {
    sed -n -e '1x;1!H;${x;s-\n- -gp}' \
    |sed 's/<[^>]*>//g' |sed 's/ \+/ /g' \
    |sed '/^$/d' |sed 's/ \+/ /g' \
    |sed 's/^[ \t]*//;s/[ \t]*$//;s/^ *//; s/ *$//g' \
    |sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' |grep -v '^..$' \
    |grep -v '^.$' |sed 's/<[^>]\+>//g' \
    |sed 's/\&quot;/\"/g' |sed "s/\&#039;/\'/g" \
    |sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
    |sed 's/ — /\n/g' \
    |sed 's/[<>£§]//; s/&amp;/\&/g' |sed 's/ *<[^>]\+> */ /g' \
    |sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g; s/\. //g' \
    |sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g; s/\? //g' \
    |sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g; s/\! //g' \
    |sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g; s/\… //g' \
    |sed 's/__/\n/g;s/ʺͶ//g'
}

function clean_6() {
    sed 's/\\n/./g' \
    |sed '/^$/d' |sed 's/^[ \t]*//;s/[ \t]*$//' \
    |sed 's/ — /\n/g;s/ʺͶ//g' \
    |sed 's/ \+/ /;s/\&quot;/\"/;s/^ *//;s/ *$//g' \
    |sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g; s/\. //g' \
    |sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g; s/\? //g' \
    |sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g; s/\! //g' \
    |sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g; s/\… //g'
}

function clean_7() {
    sed 's/^ *//;s/ *$//g' |sed 's/^[ \t]*//;s/[ \t]*$//' \
    |sed 's/ \+/ /;s/	/ /g' \
    |sed '/^$/d' |sed 's/ — /\n/g' \
    |sed 's/\&quot;/\"/g' |sed "s/\&#039;/\'/g" \
    |sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
    |sed 's/ *<[^>]\+> */ /; s/[<>£§]//; s/\&amp;/\&/g' \
    |sed 's/,/\n/g;s/。/\n/g;s/__/\n/g' |sed 's/ \+/ /g'
}

function clean_8() {
    sed 's/\[ \.\.\. \]//;s/	/ /g' \
    |sed 's/^ *//;s/ *$//g' |sed 's/^[ \t]*//;s/[ \t]*$//' \
    |sed 's/ \+/ /g' \
    |sed '/^$/d' |sed 's/ — /\n/g' \
    |sed 's/\&quot;/\"/g' |sed "s/\&#039;/\'/g" \
    |sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
    |sed 's/ *<[^>]\+> */ /; s/[<>£§]//; s/\&amp;/\&/g' \
    |sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' |sed 's/\. / /g' \
    |sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' |sed 's/\? / /g' \
    |sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' |sed 's/\! / /g' \
    |sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' |sed 's/\… / /g' \
    |sed 's/__/ \n/g;s/ \+/ /g' |sed 's/ \+/ /g'
}

function clean_9() {
    echo "${1}" |sed 's/\\n/ /g' |sed ':a;N;$!ba;s/\n/ /g' \
    |sed "s/’/'/g" \
    |sed 's/ \+/ /;s/^[ \t]*//;s/[ \t]*$//;s/-$//;s/^-//' \
    |sed 's/^ *//;s/ *$//g' |sed 's/^\s*./\U&\E/g' \
    |tr -s '/' '-' |tr -d '/*|[]&<>+' \
    |sed 's/<[^>]*>//g; s/ \+/ /g'
}

function set_image_1() {
    /usr/bin/import "$DT_r/img.jpg"
    /usr/bin/convert "$DT_r/img.jpg" -interlace Plane -thumbnail 110x90^ \
    -gravity center -extent 110x90 -quality 90% "$DT_r/ico.jpg"
}

function set_image_2() {
    /usr/bin/convert "$DT_r/img.jpg" -interlace Plane -thumbnail 405x275^ \
    -gravity center -extent 400x270 -quality 90% "$DT_r/imgs.jpg"
    mv -f "$DT_r/imgs.jpg" "${2}"
}

function translate() {
    cdb="$DM_tls/data/${tlng}.db"; stop=0
    if [[ $(wc -w <<< ${1}) = 1 ]] && [[ "${ttrgt}" != TRUE ]] && \
    [[ `sqlite3 ${cdb} "select ${slng} from Words where Word is '${1}';"` ]]; then
        sqlite3 ${cdb} "select ${slng} from Words where Word is '${1}';"
    else
        if ! ls "$DC_d"/*."Traslator online.Translator".* 1> /dev/null 2>&1; then
            "$DS_a/Dics/cnfg.sh" 2
        fi
        for trans in "$DC_d"/*."Traslator online.Translator".*; do
            trans="$DS_a/Dics/dicts/$(basename "${trans}")"
            if [ -e "${trans}" ]; then "${trans}" "$@" && break; fi
        done
    fi
}

dwld1() {
    LINK=""; source "$1/dicts/$(basename "${dict}")"
    if [ "${LINK}" -a ! -e "$audio_file" ]; then
        wget -T 51 -q -U "$ua" -O "$audio_dwld.$ex" "${LINK}"
        if [[ ${ex} != 'mp3' ]]; then
            mv -f "$audio_dwld.$ex" "$audio_dwld.mp3"
        fi
    fi
    if file -b --mime-type "$audio_file" |grep -E 'audio\/mpeg|mp3|' >/dev/null 2>&1 \
    && [[ $(du -b "$audio_file" |cut -f1) -gt 100 ]]; then
        return 5
    else
        [ -e "$audio_file" ] && rm "$audio_file"
    fi
}

dwld2() {
    LINK=""; source "$1/dicts/$(basename "${dict}")"
    if [ "${LINK}" -a ! -e "${audio_file}" ]; then
        wget -T 51 -q -U "$ua" -O "$DT_r/audio.mp3" "${LINK}"
    fi
    if file -b --mime-type "$DT_r/audio.mp3" |grep -E 'audio\/mpeg|mp3|' >/dev/null 2>&1 \
    && [[ $(du -b "$DT_r/audio.mp3" |cut -f1) -gt 100 ]]; then
        mv -f "$DT_r/audio.mp3" "${audio_file}"; return 5
    else 
        [ -e "$DT_r/audio.mp3" ] && rm "$DT_r/audio.mp3"
    fi
}

export -f translate dwld1 dwld2

function tts_sentence() {
    if ! ls "$DC_d"/*."TTS online.Pronunciation".* 1> /dev/null 2>&1; then
        "$DS_a/Dics/cnfg.sh" 1
    fi
    word="${1}"; DT_r="$2"; audio_file="${3}"
    for dict in "$DC_d"/*."TTS online.Pronunciation".*; do
        dwld2 "$DS_a/Dics"; [ $? = 5 ] && break
    done
}

function tts_word() {
    if ! ls "$DC_d"/*."TTS online.Word pronunciation".* 1> /dev/null 2>&1; then
        "$DS_a/Dics/cnfg.sh" 0
    fi
    word="${1,,}"; audio_file="${2}/$word.mp3"; audio_dwld="${2}/$word"
    if ls "$DC_d"/*."TTS online.Word pronunciation".$lgt 1> /dev/null 2>&1; then
        for dict in $DC_d/*."TTS online.Word pronunciation".$lgt; do
            dwld1 "$DS_a/Dics"; [ $? = 5 ] && break
        done
    fi
    if ls "$DC_d"/*."TTS online.Word pronunciation".various 1> /dev/null 2>&1; then
        if [ ! -e "${2}/${1}.mp3" ]; then
            for dict in $DC_d/*."TTS online.Word pronunciation".various; do
                dwld1 "$DS_a/Dics"; [ $? = 5 ] && break
            done
        fi
    fi
}

function fetch_audio() {
    if ! ls "$DC_d"/*."TTS online.Word pronunciation".* 1> /dev/null 2>&1; then
        "$DS_a/Dics/cnfg.sh" 0
    fi
    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt}; then 
    words_list="${2}"; else words_list="${1}"; fi
    
    while read -r Word; do
        word="${Word,,}"; audio_file="$DM_tls/audio/$word.mp3"
        audio_dwld="$DM_tls/audio/$word"
        if [ ! -e "$audio_file" ]; then
            if ls "$DC_d"/*."TTS online.Word pronunciation".$lgt 1> /dev/null 2>&1; then
                for dict in "$DC_d"/*."TTS online.Word pronunciation".$lgt; do
                    dwld1 "$DS_a/Dics"; [ $? = 5 ] && break
                done
            fi
            if [ ! -e "$audio_file" ]; then
                if ls "$DC_d"/*."TTS online.Word pronunciation".various 1> /dev/null 2>&1; then
                    for dict in "$DC_d"/*."TTS online.Word pronunciation".various; do
                        dwld1 "$DS_a/Dics"; [ $? = 5 ] && break
                    done
                fi
            fi
        fi
    done < "${words_list}"
}

function img_word() {
    if ls "$DC_d"/*."Script.Download image".* 1> /dev/null 2>&1; then
        if [ ! -e "${DM_tls}/images/${1,,}-0.jpg" -a ! -e "${DM_tlt}/images/${1,,}.jpg" ]; then
            touch "$DT/${1}.img"
            for Script in "$DC_d"/*."Script.Download image".*; do
                Script="$DS_a/Dics/dicts/$(basename "${Script}")"
                [ -e "${Script}" ] && "${Script}" "${1}"
                if [ -e "$DT/${1}.jpg" ]; then
                    if [[ $(du "$DT/${1}.jpg" |cut -f1) -gt 10 ]]; then
                        break
                    else 
                        rm -f "$DT/${1}.jpg"
                    fi
                fi
            done
            if [ ! -e "$DT/${1}.jpg" ]; then
                for Script in "$DC_d"/*."Script.Download image".*; do
                    Script="$DS_a/Dics/dicts/$(basename "${Script}")"
                    [ -e "${Script}" ] && "${Script}" "${2}"
                    if [ -e "$DT/${2}.jpg" ]; then
                        if [[ $(du "$DT/${2}.jpg" |cut -f1) -gt 10 ]]; then
                            break
                        else 
                            rm -f "$DT/${2}.jpg"
                        fi
                    fi
                done
            fi
            if [ -e "$DT/${1}.jpg" -o -e "$DT/${2}.jpg" ]; then
                [[ $(wc -w <<< ${1}) -gt 1 ]] && sf="${DM_tlt}/images/${1,,}.jpg" || sf="${DM_tls}/images/${1,,}-0.jpg"
                [ -e "$DT/${1}.jpg" ] && img_file="${1}.jpg" || img_file="${2}.jpg"
                local size="$(/usr/bin/identify -ping -format '%w %h' "$DT/${img_file}")"
                w="$(echo $size |cut -f1 -d ' ')"
                e="$(echo $size |cut -f2 -d ' ')"
                if [[ $((e*100/w)) -gt 80 ]]; then
                    /usr/bin/convert "$DT/${img_file}" -resize 400x270^ "$DT/${img_file}.pre"
                    [ -f "$DT/${img_file}" ] && rm -f "$DT/${img_file}"
                    /usr/bin/convert "$DT/${img_file}.pre" -gravity center \
                    -background white -compress jpeg -extent 400x270 "$DT/${img_file}"
                fi
                /usr/bin/convert "$DT/${img_file}" -interlace Plane -thumbnail 405x275^ \
                -gravity center -extent 400x270 -quality 90% "${sf}"
                cleanups "$DT/${img_file}"
            fi
            cleanups "$DT/${1}.img" "$DT/${img_file}.pre"
        fi
    fi
}

function voice() {
    txaud="$(grep -o txaud=\"[^\"]* "$DC_s/1.cfg" |grep -o '[^"]*$')"
    if [ -n "${txaud}" ]; then
        echo "${1}" |sed 's/<[^>]*>//g' |$txaud "$DT_r/f.wav"
        if [ $? != 0 ]; then
            local info="$(gettext "Please check the speech synthesizer configuration in the preferences dialog.")"
            msg "$info" error Info & exit 1
        fi
        mv "$DT_r"/*.wav "${3}"
    else
        return 1
    fi
}

function list_words_2() {
    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt}; then
        echo "${1}" | awk 'BEGIN{RS=ORS=" "}!a[$0]++' \
        |tr -d '*/“”"' |tr '_' '\n' |sed -n 1~2p |sed '/^$/d'
    else
        echo "${1}" | awk 'BEGIN{RS=ORS=" "}!a[$0]++' \
        |tr -d '*/“”"' |tr '_' '\n' |sed -n 1~2p |sed '/^$/d'
    fi
}

function list_words_3() {
    if grep -o -E 'ja|zh-cn|ru' <<< ${lgt}; then
    echo "${2}" | awk 'BEGIN{RS=ORS=" "}!a[$0]++' \
    |sed 's/\[ \.\.\. ] //g' |sed 's/\.//g' \
    |tr '_' '\n' |tr -d ',;:' |sed -n 1~2p |sed '/^$/d' > "$DT_r/lst"
    else
    echo "${1}" | awk 'BEGIN{RS=ORS=" "}!a[$0]++' \
    |sed 's/\[ \.\.\. ] //g' |sed 's/\.//g' \
    |tr -s "[:blank:]" '\n' |tr -d ':,;()' \
    |sed '/^$/d' |sed '/"("/d' \
    |grep -v '^.$' |grep -v '^..$' \
    |sed 's/[^ ]\+/\L\u&/g' \
    |head -n100 |egrep -v "FALSE" |egrep -v "TRUE" > "$DT_r/lst"
    fi
} >/dev/null 2>&1

function dlg_form_0() {
    yad --form --title="$(gettext "New Topic")" \
    --name=Idiomind --class=Idiomind \
    --separator='|' \
    --window-icon=idiomind \
    --skip-taskbar --fixed --center --on-top \
    --width=450 --height=80 --borders=5 \
    --field="$(gettext "Name")" "$1" \
    --button="$(gettext "OK")":0
}

function dlg_form_1() {
    yad --form --title="$(gettext "New note")" \
    --name=Idiomind --class=Idiomind \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --always-print-result --separator="|" \
    --skip-taskbar --fixed --center --on-top \
    --align=right --image="${img}" \
    --window-icon=idiomind \
    --width=450 --height=120 --borders=5 \
    --field="" "$txt" \
    --field=":CB" "$tpe!$(gettext "New") *$e$tpcs" \
    --button="$(gettext "Image")":3 \
    --button="$(gettext "Audio")":2 \
    --button="$(gettext "Add")"!'list-add':0
}

function dlg_form_2() {
    yad --form --title="$(gettext "New note")" \
    --name=Idiomind --class=Idiomind \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --always-print-result --separator="|" \
    --skip-taskbar --fixed --center --on-top \
    --align=right --image="${img}" \
    --window-icon=idiomind \
    --width=450 --height=160 --borders=5 \
    --field="" "$txt" \
    --field="" "$srce" \
    --field=":CB" "$tpe!$(gettext "New") *$e$tpcs" \
    --button="$(gettext "Image")":3 \
    --button="$(gettext "Audio")":2 \
    --button="$(gettext "Add")"!'list-add':0
}

function dlg_checklist_3() {
    fkey=$((RANDOM*$$))
    awk '{print "TRUE\n"$0}' < "${1}" | \
    yad --list --checklist --tabnum=1 --plug="$fkey" \
    --dclick-action="$DS/add.sh 'list_words_dclik'" --multiple \
    --ellipsize=END --no-headers --text-align=right \
    --column=" " --column=" " |sed '/^$/d' > "$slt" &
    yad --form --tabnum=2 --plug="$fkey" --columns=2 \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --separator="" \
    --field=" ":lbl null \
    --field="$(gettext "Add to"):CB" "$2!$(gettext "New") *$e$tpcs" &
    yad --paned --key="$fkey" \
    --title="$(gettext "Found") $(wc -l < "${1}") $(gettext "notes")" \
    --name=Idiomind --class=Idiomind \
    --skip-taskbar --orient=vert --window-icon=idiomind --center --on-top \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --width=700 --height=350 --borders=5 --splitter=250 \
    --button="gtk-edit":2 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Add")"!'list-add':0
}

function dlg_checklist_1() {
    list() {
        echo "${1}" | while read -r word; do
        if [ -n "$word" ]; then
            echo; echo "<span font_desc='Droid Sans 12'>$word</span>"
        fi
        done
    }
    list "${1}" | yad --list --checklist --title="$(gettext "Add words")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind \
    --mouse --on-top --no-headers \
    --text-align=right --buttons-layout=end \
    --width=380 --height=260 --borders=5  \
    --column=" " --column="Select" \
    --button="  $(gettext "Close")  ":0
}

function dlg_text_info_1() {
    cat "${1}" |awk '{print "\n"$0}' | \
    yad --text-info --title="$(gettext "Edit")" \
    --name=Idiomind --class=Idiomind \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --editable \
    --window-icon=idiomind \
    --wrap --margins=20 --fontname='vendana 11' \
    --skip-taskbar --center --on-top \
    --width=700 --height=450 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Save")":0
}

function msg_3() {
    cmd_listen="$DS/play.sh play_word "\"${3}\"""
    [ -n "$5" ] && title="$5" || title=Idiomind
    yad --title="$title" --text="$1" --image="$2" \
    --name=Idiomind --class=Idiomind \
    --always-print-result \
    --window-icon=idiomind \
    --image-on-top --on-top --sticky --center \
    --width=400 --height=120 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Play")":"$cmd_listen" \
    --button="$(gettext "Yes")":0
}

function dlg_text_info_3() {
    echo -e "${1}" | yad --text-info \
    --title="$(gettext "Some notes could not be added to your list")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind \
    --image="$DS/images/warning.png" \
    --wrap --margins=5 \
    --fixed --center --on-top \
    --width=450 --height=150 --borders=5 \
    "${3}" --button="$(gettext "Close")":1
}

function dlg_form_3() {
    yad --form --title=$(gettext "Image") "$image" "$label" \
    --name=Idiomind --class=Idiomind \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --window-icon=idiomind \
    --buttons-layout=spread --skip-taskbar --image-on-top \
    --align=center --text-align=center --center --on-top \
    --width=420 --height=320 --borders=5 \
    "${btn2}" --button=" $(gettext "Close") ":1
}

function dlg_progress_1() {
    yad --progress \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind \
    --progress-text="$1" \
    --pulsate --auto-close \
    --undecorated --skip-taskbar --no-buttons \
    --on-top --mouse --fixed
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
