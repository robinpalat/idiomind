#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}


mkdir "$DT/Dtest"

# -------------------------------

echo -e "------- Translations\n" > "$DT/test.txt"
st="$(gettext "This is a test")"
for trans in "$DC_d"/*."Traslator online.Translator".*; do
    trans="$DS_a/Dics/dicts/$(basename "${trans}")"
    name="$(cut -f 1 -d '.' <<< "$(basename "${trans}")")"
    task="$(cut -f 2 -d '.' <<< "$(basename "${trans}")")"
    if [ -f "${trans}" ]; then 
        re="$("${trans}" "$st" auto $lgs)"
        echo -e "${name}: $task\nTest: OK\nResult: $re\n\n" >> "$DT/test.txt"
    else
        echo -e "${name}: $task\nTest: FAIL\nResult: null\n\n" >> "$DT/test.txt"
    fi
done


# -------------------------------

echo -e "\n------- Audio download for frases\n" >> "$DT/test.txt"
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
            mv -f "$DT/Dtest/audio.mp3" "${audio_file}"
        
            echo -e "${name}: $task\nTest: OK\nResult: $re\n\n" >> "$DT/test.txt"
        elif [ -f "$DC_a/dicts.err" ]; then
            re="$(< "$DC_a/dicts.err")"
            cleanups "$DT_r/audio.mp3" "$DC_a/dicts.err"
            echo -e "${name}: $task\nTest: FAIL\nResult: $re\n\n" >> "$DT/test.txt"
        else 
            cleanups "$DT_r/audio.mp3"
            echo -e "${name}: $task\nTest: FAIL\nResult: null\n\n" >> "$DT/test.txt"
        fi
    fi
done

# -------------------------------



#echo -e "\nAudio download for Words en \n\n" >> "$DT/test.txt"
#word="$(gettext "This is a test")"
#audio_dwld="$DT/Dtest/audio"

#if ls "$DC_d"/*."TTS online.Word pronunciation".$lgt 1> /dev/null 2>&1; then

    #for dict in $DC_d/*."TTS online.Word pronunciation".$lgt; do

        #LINK=""; source "$DS_a/Dics/dicts/$(basename "${dict}")"
        #if [ -n "${LINK}" ]; then
            #wget -T 51 -q -U "$useragent" -O "$audio_dwld.$ex" "${LINK}"
            #if [[ ${ex} != 'mp3' ]]; then
                #mv -f "$audio_dwld.$ex" "$audio_dwld.mp3"
            #fi
        #fi
        #if [ -f "$audio_dwld.mp3" ]; then
            #if file -b --mime-type "$audio_dwld.mp3" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
            #&& [[ $(du -b "$audio_dwld.mp3" |cut -f1) -gt 120 ]]; then
            
                #mv -f "$audio_dwld.mp3" "${audio_file}"
                #echo -e "$(basename "${dict}"):\nOK\n\n" >> "$DT/test.txt" 
                
            #else
                #echo -e "$(basename "${dict}"):\nFAIL\n\n" >> "$DT/test.txt" 
                #cleanups "$audio_dwld.mp3"
            #fi
        #fi
        
        
        
    #done
#fi







## -------------------------------


#echo -e "\nAudio download for Words varios languages \n\n" >> "$DT/test.txt"
#word="$(gettext "This is a test")"
#audio_dwld="$DT/Dtest/audio"


#if ls "$DC_d"/*."TTS online.Word pronunciation".various 1> /dev/null 2>&1; then

    #for dict in $DC_d/*."TTS online.Word pronunciation".various; do
           
        #LINK=""; source "$DS_a/Dics/dicts/$(basename "${dict}")"
        #if [ -n "${LINK}" ]; then
            #wget -T 51 -q -U "$useragent" -O "$audio_dwld.$ex" "${LINK}"
            #if [[ ${ex} != 'mp3' ]]; then
                #mv -f "$audio_dwld.$ex" "$audio_dwld.mp3"
            #fi
        #fi
        #if [ -f "$audio_dwld.mp3" ]; then
            #if file -b --mime-type "$audio_dwld.mp3" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
            #&& [[ $(du -b "$audio_dwld.mp3" |cut -f1) -gt 120 ]]; then
            
                #mv -f "$audio_dwld.mp3" "${audio_file}"
                #echo -e "$(basename "${dict}"):\nOK\n\n" >> "$DT/test.txt" 
                
            #else
                #echo -e "$(basename "${dict}"):\nFAIL\n\n" >> "$DT/test.txt" 
                #cleanups "$audio_dwld.mp3"
            #fi
        #fi

    #done
           
#fi

