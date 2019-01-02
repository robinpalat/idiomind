#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}
cleanups "$DT/test_fail" "$DT/test_ok" "$DT/dict_test"
mkdir "$DT/dict_test"
if [ "$1" = 1 ]; then DC_d="$DC_a/dict/disables"; fi

function dlg_progress_2() {
    yad --progress --title="Idiomind" \
    --text="$(gettext "Please wait while resources are being tested...")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind --align=right \
    --progress-text=" " --auto-close \
    --percentage="0" \
    --no-buttons --on-top --fixed \
    --width=420 --height=80 --borders=8
}

( echo "1"
echo "#  ";
internet

echo "5"
echo "# TRANSLATOR";
st="$(gettext "This is a test")"
for trans in "$DC_d"/*."Traslator online.Translator".*; do
    trans="$DS_a/Dics/dicts/$(basename "${trans}")"
    name="$(cut -f 1 -d '.' <<< "$(basename "${trans}")")"
    echo "# TRANSLATOR  ($name)";
    if [ -f "${trans}" ]; then 
        re="$("${trans}" "$st" auto $lgs)"
        echo -e "$(basename "${trans}")" >> "$DT/test_ok"
    else
        echo -e "$(basename "${trans}"):\nFAIL\n\n" >> "$DT/test_fail" 
    fi
done

echo "10"
echo "# AUDIO";
word="$(gettext "This is a test")"
for dict in "$DC_d"/*."TTS online.Pronunciation".*; do
    name="$(cut -f 1 -d '.' <<< "$(basename "${dict}")")"
    echo "# AUDIO  ($name)";
    audio_file="$DT/dict_test/$(basename "${dict}").mp3"
    LINK=""; source "$DS_a/Dics/dicts/$(basename "${dict}")"
    if [ -n "${LINK}" ]; then
        wget -T 30 -q -U "$useragent" -O "$audio_file" "${LINK}"
    fi
    if [ -f "$audio_file" ]; then
        if file -b --mime-type "$audio_file" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
        && [[ $(du -b "$audio_file" |cut -f1) -gt 120 ]]; then
            echo -e "$(basename "${dict}")" >> "$DT/test_ok"
        else 
            echo -e "$(basename "${dict}"):\nFAIL\n\n" >> "$DT/test_fail"
        fi
    fi
    cleanups "$audio_file"
done

echo "30"
echo "# AUDIO WORDS SPECIFIC LANG";
word="$(gettext "test")"
audio_file="$DT/dict_test/audio"
if ls "$DC_d"/*."TTS online.Word pronunciation".$lgt 1> /dev/null 2>&1; then
    for dict in $DC_d/*."TTS online.Word pronunciation".$lgt; do
        LINK=""; source "$DS_a/Dics/dicts/$(basename "${dict}")"
        name="$(cut -f 1 -d '.' <<< "$(basename "${dict}")")"
        echo "# AUDIO  ($name)";
        if [ -n "${LINK}" ]; then
            wget -T 51 -q -U "$useragent" -O "$audio_file.$ex" "${LINK}"
            if [[ ${ex} != 'mp3' ]]; then
                mv -f "$audio_file.$ex" "$audio_file.mp3"
            fi
        fi
        if [ -f "$audio_file.mp3" ]; then
            if file -b --mime-type "$audio_file.mp3" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
            && [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 120 ]]; then
                echo -e "$(basename "${dict}")" >> "$DT/test_ok"
            else
                echo -e "$(basename "${dict}"):\nFAIL\n\n" >> "$DT/test_fail"
            fi
        fi
        cleanups "$audio_file.mp3"
    done
fi

echo "50"
echo "# AUDIO WORDS VARIOUS LANGS";
word="$(gettext "test")"
audio_file="$DT/dict_test/audio"
if ls "$DC_d"/*."TTS online.Word pronunciation".various 1> /dev/null 2>&1; then
    for dict in $DC_d/*."TTS online.Word pronunciation".various; do
        LINK=""; source "$DS_a/Dics/dicts/$(basename "${dict}")"
        name="$(cut -f 1 -d '.' <<< "$(basename "${dict}")")"
        echo "# AUDIO  ($name)";
        if [ -n "${LINK}" ]; then
            wget -T 51 -q -U "$useragent" -O "$audio_file.$ex" "${LINK}"
            if [[ ${ex} != 'mp3' ]]; then
                mv -f "$audio_file.$ex" "$audio_file.mp3"
            fi
        fi
        if [ -f "$audio_file.mp3" ]; then
            if file -b --mime-type "$audio_file.mp3" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
            && [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 120 ]]; then
                echo -e "$(basename "${dict}")" >> "$DT/test_ok" 
            else
                echo -e "$(basename "${dict}"):\nFAIL\n\n" >> "$DT/test_fail"
            fi
        fi
        cleanups "$audio_file.mp3"
    done
fi

echo "70"
echo "# ONLINE PAGES";
word="$(gettext "test")"
export query="$word"
if ls "$DC_d"/*."Link.Search definition".* 1> /dev/null 2>&1; then
    for dict in $DC_d/*."Link.Search definition".*; do
        name="$(cut -f 1 -d '.' <<< "$(basename "${dict}")")"
        echo "# WEBPAGES  ($name)";
        _url="$(< "$DS_a/Dics/dicts/$(basename "$dict")")"

        if curl -v "$_url" 2>&1 |grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
            echo -e "$(basename "${dict}")" >> "$DT/test_ok"
        else 
            echo -e "$(basename "${dict}"):\nFAIL\n\n" >> "$DT/test_fail"
        fi
    done  
fi

echo "90"
echo "# IMAGE DOWNLOADER";
word="$(gettext "test")"

if ls "$DC_d"/*."Script.Download image".* 1> /dev/null 2>&1; then
    for Script in "$DC_d"/*."Script.Download image".*; do
        Script="$DS_a/Dics/dicts/$(basename "${Script}")"
        name="$(cut -f 1 -d '.' <<< "$(basename "${Script}")")"
        echo "# IMAGES  ($name)";
        [ -f "${Script}" ] && "${Script}" "${word}"
        if [ -f "$DT/${word}.jpg" ]; then
            if [[ $(du "$DT/${word}.jpg" |cut -f1) -gt 10 ]]; then
                echo -e "$(basename "${Script}")" >> "$DT/test_ok" 
            else 
                echo -e "$(basename "${Script}"):\nFAIL\n\n" >> "$DT/test_fail"
            fi
        fi
        cleanups "$DT/${word}.jpg"
    done
fi

mv "$DT/test_ok" "$DC_a/dict/test"
cat "$DT/test_fail" >> "$DC_a/dicts.inf"
cleanups "$DT/dict_test" "$DT/test_fail"
echo "100"

 ) | dlg_progress_2
 
if [ "$1" != 1 ]; then "$DS/addons/Dics/cnfg.sh"; fi
