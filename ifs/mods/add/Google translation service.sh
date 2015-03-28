#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf

#function translate() {
    
    #result=$(curl -s -i --user-agent "" -d "sl=$2" -d "tl=$3" --data-urlencode text="$1" https://translate.google.com)
    #encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
    #iconv -f "$encoding" <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8
#}

function audio_recognizer() {
    
    wget -q -U "Mozilla/5.0" --post-file "$1" --header="Content-Type: audio/x-flac; rate=16000" \
    -O - "https://www.google.com/speech-api/v2/recognize?&lang="$2"-"$3"&key=$4"
}

function tts() {
    
    cd "$3"; n=1; xargs -n10 | tr -s "'" "|" <<<"${1}" > ./temp
    while read chnk; do
        [[ -n "$chnk" ]] && wget -q -U Mozilla -O "$DT_r/tmp$n.mp3" \
        "https://translate.google.com/translate_tts?ie=UTF-8&tl=$2&q=$(tr -s "|" "'" <<<"$chnk")"
        ((n=n+1))
    done < ./temp

    cat $(ls tmp[0-9]*.mp3 | sort -n | tr '\n' ' ') > "$4"
    find . -name "tmp*.mp3" -exec rm -rf {} \;
}
