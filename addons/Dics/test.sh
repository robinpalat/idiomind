#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}

mkdir "$DT/dict_test"
DC_d="$DC_a/dict/disables"
DC_e="$DC_a/dict/enables"
msgs="$DC_a/dict/msgs"
check_dir "$msgs"

function test_() {
    f_lock 1 "$DT/dicts_lk"
    internet
    
    echo "1"
    
    if [ "$(cut -d "|" -f1 <<< "$c")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # TRANSLATORS"
        echo "5"
        
        for trans in "$DC_d"/*."Traslator online.Translator".*; do
            filename="$(basename "${trans}")"; cleanups "$msgs/$filename"
            trans="$DS_a/Dics/dicts/$filename"
            if [ -f "${trans}" ]; then
                re="$("${trans}" "This is a test" auto $lgs)"
                if [ -n "${re}" ]; then
                    :
                else
                    echo "FAIL" > "$msgs/$filename"
                fi
            fi
        done
        
        echo "7"
        st="$(gettext "This is a test")"
        for trans in "$DC_e"/*."Traslator online.Translator".*; do
            filename="$(basename "${trans}")"; cleanups "$msgs/$filename"
            trans="$DS_a/Dics/dicts/$filename"
            if [ -f "${trans}" ]; then
                re="$("${trans}" "This is a test" auto $lgs)"
                if [ -n "${re}" ]; then
                    :
                else
                    echo "FAIL" > "$msgs/$filename"
                fi
            fi
        done
    fi
    
    if [ "$(cut -d "|" -f3 <<< "$c")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # AUDIO - Sentences"
        echo "10"

        if ls "$DC_d"/*."TTS online.Pronunciation".* 1> /dev/null 2>&1; then
            n=10
            for dict in "$DC_d"/*."TTS online.Pronunciation".*; do
                audio_file="$DT/dict_test/${n}_audio"
                filename="$(basename "${dict}")"; cleanups "$msgs/$filename"
                unset TESTURL; source "$DS_a/Dics/dicts/$filename"
                if [ -n "${TESTURL}" ]; then
                    wget -T 15 -q -U "$useragent" -O "$audio_file.$EX" "${TESTURL}"
                    if [[ ${EX} != 'mp3' ]]; then
                        mv -f "$audio_file.$EX" "$audio_file.mp3"
                    fi
                fi
                if [ -f "$audio_file.mp3" ]; then
                    if file -b --mime-type "$audio_file.mp3" |grep -o -E 'mpeg|mp3|' >/dev/null 2>&1 \
                    && [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 200 ]]; then
                        :
                    else 
                        echo "FAIL" > "$msgs/$filename"
                    fi
                fi
                
                cleanups "$audio_file.mp3"
                let n++
            done
        fi
        
        echo "20"
        
        if ls "$DC_e"/*."TTS online.Pronunciation".* 1> /dev/null 2>&1; then
             n=20
            for dict in "$DC_e"/*."TTS online.Pronunciation".*; do
                audio_file="$DT/dict_test/${n}_audio"
                filename="$(basename "${dict}")"; cleanups "$msgs/$filename"
                unset TESTURL; source "$DS_a/Dics/dicts/$filename"
                if [ -n "${TESTURL}" ]; then
                    wget -T 15 -q -U "$useragent" -O "$audio_file.$EX" "${TESTURL}"
                    if [[ ${EX} != 'mp3' ]]; then
                        mv -f "$audio_file.$EX" "$audio_file.mp3"
                    fi
                fi
                if [ -f "$audio_file.mp3" ]; then
                    if file -b --mime-type "$audio_file.mp3" |grep -o -E 'mpeg|mp3|' >/dev/null 2>&1 \
                    && [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 200 ]]; then
                        :
                    else 
                        echo "FAIL" > "$msgs/$filename"
                    fi
                fi
                
                cleanups "$audio_file.mp3"
                let n++
            done
        fi
    fi

    if [ "$(cut -d "|" -f5 <<< "$c")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # AUDIO - Words"
        echo "50"

        if ls "$DC_d"/*."TTS online.Word pronunciation".* 1> /dev/null 2>&1; then
            n=50
            for dict in $DC_d/*."TTS online.Word pronunciation".*; do
                filename="$(basename "${dict}")"; cleanups "$msgs/$filename"
                audio_file="$DT/dict_test/${n}_audio"
                unset TESTURL; source "$DS_a/Dics/dicts/$filename"
                if [ -n "${TESTURL}" ]; then
                    wget -T 15 -q -U "$useragent" -O "$audio_file.$EX" "${TESTURL}"
                    if [[ ${EX} != 'mp3' ]]; then
                        mv -f "$audio_file.$EX" "$audio_file.mp3"
                    fi
                fi
                if [ -f "$audio_file.mp3" ]; then
                    if file -b --mime-type "$audio_file.mp3" |grep -o -E 'mpeg|mp3|' >/dev/null 2>&1 \
                    && [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 200 ]]; then
                        :
                    else
                        filename="$(basename "${dict}")"
                        echo "FAIL" > "$msgs/$filename"
                    fi
                fi
                
                cleanups "$audio_file.mp3"
                let n++
            done
        fi

        echo "60"
        
        if ls "$DC_e"/*."TTS online.Word pronunciation".* 1> /dev/null 2>&1; then
            n=60
            for dict in $DC_e/*."TTS online.Word pronunciation".*; do
                filename="$(basename "${dict}")"; cleanups "$msgs/$filename"
                audio_file="$DT/dict_test/${n}_audio"
                unset TESTURL; source "$DS_a/Dics/dicts/$filename"
                if [ -n "${TESTURL}" ]; then
                    wget -T 15 -q -U "$useragent" -O "$audio_file.$EX" "${TESTURL}"
                    if [[ ${EX} != 'mp3' ]]; then
                        mv -f "$audio_file.$EX" "$audio_file.mp3"
                    fi
                fi
                if [ -f "$audio_file.mp3" ]; then
                    if file -b --mime-type "$audio_file.mp3" |grep -o -E 'mpeg|mp3|' >/dev/null 2>&1 \
                    && [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 200 ]]; then
                        :
                    else
                        echo "FAIL" > "$msgs/$filename"
                    fi
                fi
                
                cleanups "$audio_file.mp3"
                let n++
            done
        fi
    fi

    if [ "$(cut -d "|" -f2 <<< "$c")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # WEB PAGES"
        echo "70"
        
        word="test"
        export query="$word" lgt
        if ls "$DC_d"/*."Link.Search definition".* 1> /dev/null 2>&1; then
            for dict in $DC_d/*."Link.Search definition".*; do
                filename="$(basename "${dict}")"; cleanups "$msgs/$filename"
                eval _url="$(< "$DS_a/Dics/dicts/$filename")"
                if curl -v "$_url" 2>&1 |grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
                    :
                else 
                    echo "FAIL" > "$msgs/$filename"
                fi
            done  
        fi
        
        echo "80"
        if ls "$DC_e"/*."Link.Search definition".* 1> /dev/null 2>&1; then
            for dict in $DC_e/*."Link.Search definition".*; do
                filename="$(basename "${dict}")"; cleanups "$msgs/$filename"
                eval _url="$(< "$DS_a/Dics/dicts/$filename")"
                if curl -v "$_url" 2>&1 |grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
                    :
                else 
                    echo "FAIL" > "$msgs/$filename"
                fi
            done  
        fi
    fi

    if [ "$(cut -d "|" -f4 <<< "$c")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # IMAGE DOWNLOADER"
        echo "90"
        
        if ls "$DC_d"/*."Script.Download image".* 1> /dev/null 2>&1; then
            for Script in "$DC_d"/*."Script.Download image".*; do
                filename="$(basename "${Script}")"; cleanups "$msgs/$filename"
                Script="$DS_a/Dics/dicts/$filename"
                TLANGS=$(grep -o TLANGS=\"[^\"]* "$Script" |grep -o '[^"]*$')
                TESTWORD=$(grep -o TESTWORD=\"[^\"]* "$Script" |grep -o '[^"]*$')
                [ -f "${Script}" ] && "${Script}" "${TESTWORD}" "_TEST_"
                if [ -f "$DT/${TESTWORD}.jpg" ]; then
                    if [[ $(du "$DT/${TESTWORD}.jpg" |cut -f1) -gt 10 ]]; then
                        :
                    else 
                        echo "FAIL" > "$msgs/$filename"
                    fi
                fi
                cleanups "$DT/${TESTWORD}.jpg"
            done
        fi

        echo "95"
        if ls "$DC_e"/*."Script.Download image".* 1> /dev/null 2>&1; then
            for Script in "$DC_e"/*."Script.Download image".*; do
                filename="$(basename "${Script}")"; cleanups "$msgs/$filename"
                Script="$DS_a/Dics/dicts/$filename"
                TLANGS=$(grep -o TLANGS=\"[^\"]* "$Script" |grep -o '[^"]*$')
                TESTWORD=$(grep -o TESTWORD=\"[^\"]* "$Script" |grep -o '[^"]*$')
                [ -f "${Script}" ] && "${Script}" "${TESTWORD}" "_TEST_"
                if [ -f "$DT/${TESTWORD}.jpg" ]; then
                    if [[ $(du "$DT/${TESTWORD}.jpg" |cut -f1) -gt 10 ]]; then
                        :
                    else 
                        echo "FAIL" > "$msgs/$filename"
                    fi
                fi
                cleanups "$DT/${TESTWORD}.jpg"
            done
        fi
    fi
    
    # ---------------------------------------------------

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
    export c="TRUE|TRUE|TRUE|TRUE|TRUE|"
    echo -e "\n-- testing online resources..."
    test_
    echo -e "\ttesting online resources ok"
else
    cnf1=$(mktemp "$DT/cnf1.XXXXXX")
    yad --form --title="$(gettext "Test")" \
    --text="$(gettext "Options")\n" \
    --name=Idiomind --class=Idiomind \
    --center --columns=2 --output-by-row \
    --on-top --skip-taskbar \
    --width=400 --height=200 --borders=10 \
    --always-print-result --print-all --align=right \
    --field=" $(gettext "Translate")":CHK "" \
    --field=" $(gettext "Convert text to audio")":CHK "" \
    --field=" $(gettext "Search audio")":CHK "" \
    --field=" $(gettext "Search definition")":CHK "" \
    --field=" $(gettext "Search image")":CHK "" \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Apply")":0 > "$cnf1"
    ret=$?; [ $ret = 1 ] && exit
    export c="$(< "$cnf1")"; cleanups "$cnf1"
    
    ( echo "1"; echo "#  "; test_ ) | dlg_progress_2
fi

if [[ "$1" != 1 ]]; then 
    "$DS/addons/Dics/cnfg.sh"
fi
