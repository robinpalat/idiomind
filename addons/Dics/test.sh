#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}
cleanups "$DT/test_fail" "$DT/test_ok" "$DT/dict_test"
mkdir "$DT/dict_test"
DC_d="$DC_a/dict/disables"
DC_e="$DC_a/dict/enables"
msgs="$DC_a/dict/msgs"
check_dir "$msgs"


function test_() {
    f_lock 1 "$DT/dicts_lk"
    internet
    
    # ---------------------------------------------------
    # TRANSLATORS"
    echo "5"
    
    st="$(gettext "This is a test")"
    for trans in "$DC_d"/*."Traslator online.Translator".*; do
        fname="$(basename "${trans}")"
        trans="$DS_a/Dics/dicts/$fname"
        name="$(cut -f 1 -d '.' <<< "$fname")"
        if [ -f "${trans}" ]; then 
            re="$("${trans}" "$st" auto $lgs)"
            echo -e "$fname" >> "$DT/test_ok"
        else
            echo -e "FAIL" > "$msgs/$fname"
        fi
    done
    echo "7"
    st="$(gettext "This is a test")"
    for trans in "$DC_e"/*."Traslator online.Translator".*; do
        fname="$(basename "${trans}")"
        trans="$DS_a/Dics/dicts/$fname"
        name="$(cut -f 1 -d '.' <<< "$fname")"
        if [ -f "${trans}" ]; then 
            re="$("${trans}" "$st" auto $lgs)"
            echo -e "$fname" >> "$DT/test_ok"
        else
            echo -e "FAIL" > "$msgs/$fname"
        fi
    done

    # ---------------------------------------------------
    
    # AUDIO"
    echo "10"
    
    word="$(gettext "This is a test")"
    for dict in "$DC_d"/*."TTS online.Pronunciation".*; do
        fname="$(basename "${dict}")"
        name="$(cut -f 1 -d '.' <<< "$fname")"
        audio_file="$DT/dict_test/$fname.mp3"
        LINK=""; source "$DS_a/Dics/dicts/$fname"
        if [ -n "${LINK}" ]; then
            wget -T 30 -q -U "$useragent" -O "$audio_file" "${LINK}"
        fi
        if [ -f "$audio_file" ]; then
            if file -b --mime-type "$audio_file" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
            && [[ $(du -b "$audio_file" |cut -f1) -gt 120 ]]; then
                echo -e "$fname" >> "$DT/test_ok"
            else 
                echo -e "FAIL" > "$msgs/$fname"
            fi
        fi
        cleanups "$audio_file"
    done
    
    echo "20"
    for dict in "$DC_e"/*."TTS online.Pronunciation".*; do
        fname="$(basename "${dict}")"
        name="$(cut -f 1 -d '.' <<< "$fname")"
        audio_file="$DT/dict_test/$fname.mp3"
        LINK=""; source "$DS_a/Dics/dicts/$fname"
        if [ -n "${LINK}" ]; then
            wget -T 30 -q -U "$useragent" -O "$audio_file" "${LINK}"
        fi
        if [ -f "$audio_file" ]; then
            if file -b --mime-type "$audio_file" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
            && [[ $(du -b "$audio_file" |cut -f1) -gt 120 ]]; then
                echo -e "$fname" >> "$DT/test_ok"
            else 
                echo -e "FAIL" > "$msgs/$fname"
            fi
        fi
        cleanups "$audio_file"
    done

    # ---------------------------------------------------

    # AUDIO WORD SPECIFIC LANGUAGE"
    echo "30"
    
    word="$(gettext "test")"
    audio_file="$DT/dict_test/audio"
    if ls "$DC_d"/*."TTS online.Word pronunciation".$lgt 1> /dev/null 2>&1; then
        for dict in $DC_d/*."TTS online.Word pronunciation".$lgt; do
            fname="$(basename "${dict}")"
            name="$(cut -f 1 -d '.' <<< "$fname")"
            LINK=""; source "$DS_a/Dics/dicts/$fname"
            if [ -n "${LINK}" ]; then
                wget -T 51 -q -U "$useragent" -O "$audio_file.$ex" "${LINK}"
                if [[ ${ex} != 'mp3' ]]; then
                    mv -f "$audio_file.$ex" "$audio_file.mp3"
                fi
            fi
            if [ -f "$audio_file.mp3" ]; then
                if file -b --mime-type "$audio_file.mp3" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
                && [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 120 ]]; then
                    echo -e "$fname" >> "$DT/test_ok"
                else
                    echo -e "FAIL" > "$msgs/$fname"
                fi
            fi
            cleanups "$audio_file.mp3"
        done
    fi

    echo "40"
    if ls "$DC_e"/*."TTS online.Word pronunciation".$lgt 1> /dev/null 2>&1; then
        for dict in $DC_e/*."TTS online.Word pronunciation".$lgt; do
            fname="$(basename "${dict}")"
            name="$(cut -f 1 -d '.' <<< "$fname")"
            LINK=""; source "$DS_a/Dics/dicts/$fname"
            if [ -n "${LINK}" ]; then
                wget -T 51 -q -U "$useragent" -O "$audio_file.$ex" "${LINK}"
                if [[ ${ex} != 'mp3' ]]; then
                    mv -f "$audio_file.$ex" "$audio_file.mp3"
                fi
            fi
            if [ -f "$audio_file.mp3" ]; then
                if file -b --mime-type "$audio_file.mp3" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
                && [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 120 ]]; then
                    echo -e "$fname" >> "$DT/test_ok"
                else
                    echo -e "FAIL" > "$msgs/$fname"
                fi
            fi
            cleanups "$audio_file.mp3"
        done
    fi

    # ---------------------------------------------------
    
    # AUDIO WORDS VARIOUS LANGS"
    echo "50"
   
    word="$(gettext "test")"
    audio_file="$DT/dict_test/audio"
    if ls "$DC_d"/*."TTS online.Word pronunciation".various 1> /dev/null 2>&1; then
        for dict in $DC_d/*."TTS online.Word pronunciation".various; do
            fname="$(basename "${dict}")"
            LINK=""; source "$DS_a/Dics/dicts/$fname"
            name="$(cut -f 1 -d '.' <<< "$fname")"
            if [ -n "${LINK}" ]; then
                wget -T 51 -q -U "$useragent" -O "$audio_file.$ex" "${LINK}"
                if [[ ${ex} != 'mp3' ]]; then
                    mv -f "$audio_file.$ex" "$audio_file.mp3"
                fi
            fi
            if [ -f "$audio_file.mp3" ]; then
                if file -b --mime-type "$audio_file.mp3" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
                && [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 120 ]]; then
                    echo -e "$fname" >> "$DT/test_ok" 
                else
                    echo -e "FAIL" > "$msgs/$fname"
                fi
            fi
            cleanups "$audio_file.mp3"
        done
    fi

    echo "60"
    if ls "$DC_e"/*."TTS online.Word pronunciation".various 1> /dev/null 2>&1; then
        for dict in $DC_e/*."TTS online.Word pronunciation".various; do
            fname="$(basename "${dict}")"
            LINK=""; source "$DS_a/Dics/dicts/$fname"
            name="$(cut -f 1 -d '.' <<< "$fname")"
            if [ -n "${LINK}" ]; then
                wget -T 51 -q -U "$useragent" -O "$audio_file.$ex" "${LINK}"
                if [[ ${ex} != 'mp3' ]]; then
                    mv -f "$audio_file.$ex" "$audio_file.mp3"
                fi
            fi
            if [ -f "$audio_file.mp3" ]; then
                if file -b --mime-type "$audio_file.mp3" |grep -E 'mpeg|mp3|' >/dev/null 2>&1 \
                && [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 120 ]]; then
                    echo -e "$fname" >> "$DT/test_ok" 
                else
                    echo -e "FAIL" > "$msgs/$fname"
                fi
            fi
            cleanups "$audio_file.mp3"
        done
    fi

    # ---------------------------------------------------
    
    # WEB PAGES"
    echo "70"
    
    word="$(gettext "test")"
    export query="$word"
    if ls "$DC_d"/*."Link.Search definition".* 1> /dev/null 2>&1; then
        for dict in $DC_d/*."Link.Search definition".*; do
            fname="$(basename "${dict}")"
            name="$(cut -f 1 -d '.' <<< "$fname")"
            _url="$(< "$DS_a/Dics/dicts/$fname")"
            if curl -v "$_url" 2>&1 |grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
                echo -e "$fname" >> "$DT/test_ok"
            else 
                echo -e "FAIL" > "$msgs/$fname"
            fi
        done  
    fi
    
    echo "80"
    if ls "$DC_e"/*."Link.Search definition".* 1> /dev/null 2>&1; then
        for dict in $DC_e/*."Link.Search definition".*; do
            name="$(cut -f 1 -d '.' <<< "$fname")"
            _url="$(< "$DS_a/Dics/dicts/$fname")"
            if curl -v "$_url" 2>&1 |grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
                echo -e "$fname" >> "$DT/test_ok"
            else 
                echo -e "FAIL" > "$msgs/$fname"
            fi
        done  
    fi

    # ---------------------------------------------------

    # IMAGE DOWNLOADER"
    echo "90"
    
    word="$(gettext "test")"

    if ls "$DC_d"/*."Script.Download image".* 1> /dev/null 2>&1; then
        for Script in "$DC_d"/*."Script.Download image".*; do
            fname="$(basename "${Script}")"
            Script="$DS_a/Dics/dicts/$fname"
            name="$(cut -f 1 -d '.' <<< "$fname")"
            [ -f "${Script}" ] && "${Script}" "${word}"
            if [ -f "$DT/${word}.jpg" ]; then
                if [[ $(du "$DT/${word}.jpg" |cut -f1) -gt 10 ]]; then
                    echo -e "$fname" >> "$DT/test_ok"
                else 
                    echo -e "FAIL" > "$msgs/$fname"
                fi
            fi
            cleanups "$DT/${word}.jpg"
        done
    fi

    echo "95"
    if ls "$DC_e"/*."Script.Download image".* 1> /dev/null 2>&1; then
        for Script in "$DC_e"/*."Script.Download image".*; do
            fname="$(basename "${Script}")"
            Script="$DS_a/Dics/dicts/$fname"
            name="$(cut -f 1 -d '.' <<< "$fname")"
            [ -f "${Script}" ] && "${Script}" "${word}"
            if [ -f "$DT/${word}.jpg" ]; then
                if [[ $(du "$DT/${word}.jpg" |cut -f1) -gt 10 ]]; then
                    echo -e "$fname" >> "$DT/test_ok"
                else 
                    echo -e "FAIL" > "$msgs/$fname"
                fi
            fi
            cleanups "$DT/${word}.jpg"
        done
    fi

    # ---------------------------------------------------
    mv "$DT/test_ok" "$DC_a/dict/test"
    if [ ! -f "$DC_s/dics_first_run" ]; then
        cat "$DT/test_fail" >> "$DC_a/dicts.inf"
    fi
    cleanups "$DT/dict_test" "$DT/test_fail"
    echo "100"
    f_lock 3 "$DT/dicts_lk"
}

function dlg_progress_2() {
    yad --progress --title="Idiomind" \
    --text="<b>$(gettext "Please wait while online resources are being tested...")</b>" \
    --name=Idiomind --class=Idiomind \
    --window-icon=idiomind --align=right \
    --progress-text=" " --pulsate \
    --percentage="0" --auto-close \
    --no-buttons --on-top --fixed \
    --width=420 --borders=10
}

if [[ "$2" = 'silence' ]]; then
    echo -e "\n-- testing online resources..."
    test_
    echo -e "\n-- testing online resources concluded"
else
    ( echo "1"; echo "#  "; test_ ) | dlg_progress_2
fi

if [[ "$1" != 1 ]]; then 
    "$DS/addons/Dics/cnfg.sh"
fi
