#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf

function tts() {
    
    cd "$3"; x=1; xargs -n10 | tr -s "'" "|" <<<"${1}" > ./temp
    while read chnk; do
        [[ -n "$chnk" ]] && wget -q -U Mozilla -O "$DT_r/tmp$x.mp3" \
        "https://translate.google.com/translate_tts?ie=UTF-8&tl=$2&q=$(tr -s "|" "'" <<<"$chnk")"
        ((x=x+1))
    done < ./temp

    cat $(ls tmp[0-9]*.mp3 | sort -n | tr '\n' ' ') > "$4"
    find . -name "tmp*.mp3" -exec rm -rf {} \;
}
