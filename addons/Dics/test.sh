#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}
cleanups "$DT/test_fail" "$DT/test_ok" "$DT/Dtest"
mkdir "$DT/Dtest"

function dlg_progress_2() {
    yad --progress --title="$(gettext "Performing Tests")" \
    --text="$(gettext "Please wait")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind --align=right \
    --progress-text=" " --auto-close \
    --percentage="0" \
    --no-buttons --on-top --fixed \
    --width=300 --height=80 --borders=5
}

( echo "1"
echo "# $(gettext " ")";


#  TRANSLATOR
echo "5"
echo "# TRANSLATOR";
st="$(gettext "This is a test")"
for trans in "$DC_d"/*."Traslator online.Translator".*; do
    trans="$DS_a/Dics/dicts/$(basename "${trans}")"
    name="$(cut -f 1 -d '.' <<< "$(basename "${trans}")")"
    task="$(cut -f 2 -d '.' <<< "$(basename "${trans}")")"
    if [ -f "${trans}" ]; then 
        re="$("${trans}" "$st" auto $lgs)"
        echo -e "$(basename "${trans}")" >> "$DT/test_ok"
    else
        echo -e "$(basename "${trans}"):\nFAIL\n\n" >> "$DT/test_fail" 
    fi
done

#  AUDIO SENTENCES
echo "10"
echo "# AUDIO SENTENCES";
word="$(gettext "This is a test")"
for dict in "$DC_d"/*."TTS online.Pronunciation".*; do
    name="$(cut -f 1 -d '.' <<< "$(basename "${dict}")")"
    task="$(cut -f 2 -d '.' <<< "$(basename "${dict}")")"
    audio_file="$DT/Dtest/$(basename "${dict}").mp3"
    LINK=""; source "$DS_a/Dics/dicts/$(basename "${dict}")"
    if [ -n "${LINK}" ]; then
        wget -T 51 -q -U "$useragent" -O "$DT/Dtest/audio.mp3" "${LINK}"
    fi
    if [ -f "$DT/Dtest/audio.mp3" ]; then
        if file -b --mime-type "$DT/Dtest/audio.mp3" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
        && [[ $(du -b "$DT/Dtest/audio.mp3" |cut -f1) -gt 120 ]]; then
            echo -e "$(basename "${dict}")" >> "$DT/test_ok"
        else 
            echo -e "$(basename "${dict}"):\nFAIL\n\n" >> "$DT/test_fail" 
            cleanups "$DT_r/audio.mp3"
        fi
    fi
done

#  AUDIO WORDS SPECIFIC LANG
echo "30"
echo "# AUDIO WORDS SPECIFIC LANG";
word="$(gettext "test")"
audio_dwld="$DT/Dtest/audio"
if ls "$DC_d"/*."TTS online.Word pronunciation".$lgt 1> /dev/null 2>&1; then
    for dict in $DC_d/*."TTS online.Word pronunciation".$lgt; do
        LINK=""; source "$DS_a/Dics/dicts/$(basename "${dict}")"
        if [ -n "${LINK}" ]; then
            wget -T 51 -q -U "$useragent" -O "$audio_dwld.$ex" "${LINK}"
            if [[ ${ex} != 'mp3' ]]; then
                mv -f "$audio_dwld.$ex" "$audio_dwld.mp3"
            fi
        fi
        if [ -f "$audio_dwld.mp3" ]; then
            if file -b --mime-type "$audio_dwld.mp3" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
            && [[ $(du -b "$audio_dwld.mp3" |cut -f1) -gt 120 ]]; then
                echo -e "$(basename "${dict}")" >> "$DT/test_ok"
            else
                echo -e "$(basename "${dict}"):\nFAIL\n\n" >> "$DT/test_fail"
                cleanups "$audio_dwld.mp3"
            fi
        fi
    done
fi

##  AUDIO WORDS VARIOUS LANGS
echo "50"
echo "# AUDIO WORDS VARIOUS LANGS";
word="$(gettext "test")"
audio_dwld="$DT/Dtest/audio"
if ls "$DC_d"/*."TTS online.Word pronunciation".various 1> /dev/null 2>&1; then
    for dict in $DC_d/*."TTS online.Word pronunciation".various; do
        LINK=""; source "$DS_a/Dics/dicts/$(basename "${dict}")"
        if [ -n "${LINK}" ]; then
            wget -T 51 -q -U "$useragent" -O "$audio_dwld.$ex" "${LINK}"
            if [[ ${ex} != 'mp3' ]]; then
                mv -f "$audio_dwld.$ex" "$audio_dwld.mp3"
            fi
        fi
        if [ -f "$audio_dwld.mp3" ]; then
            if file -b --mime-type "$audio_dwld.mp3" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
            && [[ $(du -b "$audio_dwld.mp3" |cut -f1) -gt 120 ]]; then
                echo -e "$(basename "${dict}")" >> "$DT/test_ok" 
            else
                echo -e "$(basename "${dict}"):\nFAIL\n\n" >> "$DT/test_fail"
                cleanups "$audio_dwld.mp3"
            fi
        fi
    done
fi

##  ONLINE PAGES
echo "70"
echo "# ONLINE PAGES";
word="$(gettext "test")"
export query="$word"
if ls "$DC_d"/*."Link.Search definition".* 1> /dev/null 2>&1; then
    for dict in $DC_d/*."Link.Search definition".*; do
        _url="$(< "$DS_a/Dics/dicts/$(basename "$dict")")"

        if curl -v "$_url" 2>&1 |grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
            echo -e "$(basename "${dict}")" >> "$DT/test_ok"
        else 
            echo -e "$(basename "${dict}"):\nFAIL\n\n" >> "$DT/test_fail"
        fi
    done  
fi

##  IMAGE DOWNLOADER
echo "80"
echo "# IMAGE DOWNLOADER";
word="$(gettext "test")"

if ls "$DC_d"/*."Script.Download image".* 1> /dev/null 2>&1; then
    for Script in "$DC_d"/*."Script.Download image".*; do
        Script="$DS_a/Dics/dicts/$(basename "${Script}")"
        [ -f "${Script}" ] && "${Script}" "${word}"
        if [ -f "$DT/${word}.jpg" ]; then
            if [[ $(du "$DT/${word}.jpg" |cut -f1) -gt 10 ]]; then
                echo -e "$(basename "${Script}")" >> "$DT/test_ok" 
            else 
                echo -e "$(basename "${Script}"):\nFAIL\n\n" >> "$DT/test_fail"
                rm -f "$DT/${word}.jpg"
            fi
        fi
    done
fi

mv "$DT/test_ok" "$DC_a/dict/test_ok"
cat "$DT/test_fail" >> "$DC_a/dicts.err"
echo "100"

 ) | dlg_progress_2
 
$DS/addons/Dics/cnfg.sh
