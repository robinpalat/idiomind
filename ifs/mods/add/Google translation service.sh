#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf

function translate() {
    
    result=$(curl -s -i --user-agent "" -d "sl=$2" -d "tl=$3" --data-urlencode text="$1" https://translate.google.com)
    encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
    trd=$(iconv -f $encoding <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8)
    echo "$trd"
}

function audio_recognizer() {
    
    echo "$(wget -q -U "Mozilla/5.0" --post-file "$1" --header="Content-Type: audio/x-flac; rate=16000" \
    -O - "https://www.google.com/speech-api/v2/recognize?&lang="$2"-"$3"&key=$4")"
}

function tts() {
    
    cd $3; xargs -n10 < "${1}" > ./temp
    [[ -n "$(sed -n 1p ./temp)" ]] && wget -q -U Mozilla -O $DT_r/tmp01.mp3 \
    "https://translate.google.com/translate_tts?ie=UTF-8&tl=$2&q=$(sed -n 1p ./temp)"
    [[ -n "$(sed -n 2p ./temp)" ]] && wget -q -U Mozilla -O $DT_r/tmp02.mp3 \
    "https://translate.google.com/translate_tts?ie=UTF-8&tl=$2&q=$(sed -n 2p ./temp)"
    [[ -n "$(sed -n 3p ./temp)" ]] && wget -q -U Mozilla -O $DT_r/tmp03.mp3 \
    "https://translate.google.com/translate_tts?ie=UTF-8&tl=$2&q=$(sed -n 3p ./temp)"
    [[ -n "$(sed -n 4p ./temp)" ]] && wget -q -U Mozilla -O $DT_r/tmp04.mp3 \
    "https://translate.google.com/translate_tts?ie=UTF-8&tl=$2&q=$(sed -n 4p ./temp)"
    cat $(ls tmp[0-9]*.mp3 | sort -n | tr '\n' ' ') > "$4"
    find . -name "tmp*.mp3" -exec rm -rf {} \;

}

