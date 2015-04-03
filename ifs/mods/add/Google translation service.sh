#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf

function tts() {
    
    cd "$3"; file=1;
    while read -r chnk; do
        if [ -n "$chnk" ]; then
        quote="$(sed -s "s/|/\'/g" <<<"$chnk")"
        wget -q -U Mozilla -O "$DT_r/tmp$file.mp3" "https://translate.google.com/translate_tts?ie=UTF-8&tl=$2&q=$quote"
        fi
        ((file=file+1))
    done <<<"$(tr -s "'" "|" <<<"$1" | xargs -n7)"

    cat $(ls tmp[0-9]*.mp3 | sort -n | tr '\n' ' ') > "$4"
    find . -name "tmp*.mp3" -exec rm -rf {} \;
}
