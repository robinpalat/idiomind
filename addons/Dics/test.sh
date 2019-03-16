#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}
cleanups "$DT/test_fail" "$DT/test_ok" \
"$DT/dict_test" "$DC_a/dict/ok.list" \
"$DC_a/dict/ok_nolang.list"

mkdir "$DT/dict_test"
DC_d="$DC_a/dict/disables"
DC_e="$DC_a/dict/enables"
msgs="$DC_a/dict/msgs"
cleanups "$msgs"
check_dir "$msgs"

function test_() {
    f_lock 1 "$DT/dicts_lk"
    internet
    
    # ---------------------------------------------------
    # TRANSLATORS"
    echo "5"
    
    for trans in "$DC_d"/*."Traslator online.Translator".*; do
        filename="$(basename "${trans}")"
        trans="$DS_a/Dics/dicts/$filename"
        if [ -f "${trans}" ]; then 
            re="$("${trans}" "This is a test" auto $lgs)"
            echo "$filename" >> "$DT/test_ok"
        else
            echo "FAIL" > "$msgs/$filename"
        fi
    done
    echo "7"
    st="$(gettext "This is a test")"
    for trans in "$DC_e"/*."Traslator online.Translator".*; do
        filename="$(basename "${trans}")"
        trans="$DS_a/Dics/dicts/$filename"
        if [ -f "${trans}" ]; then 
            re="$("${trans}" "This is a test" auto $lgs)"
            echo "$filename" >> "$DT/test_ok"
        else
            echo "FAIL" > "$msgs/$filename"
        fi
    done

    # ---------------------------------------------------
    # AUDIO - Sentences"
    echo "10"

    if ls "$DC_d"/*."TTS online.Pronunciation".* 1> /dev/null 2>&1; then
        n=10
        for dict in "$DC_d"/*."TTS online.Pronunciation".*; do
            audio_file="$DT/dict_test/${n}_audio"
            filename="$(basename "${dict}")"
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
                
                    if echo "$TLANGS" |grep -E "$lgt" >/dev/null 2>&1; then
                        echo "$filename" >> "$DT/test_ok"
                    else
                        echo "$filename" >> "$DT/test_ok_nolang"
                    fi
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
            filename="$(basename "${dict}")"
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
                
                    if echo "$TLANGS" |grep -E "$lgt" >/dev/null 2>&1; then
                        echo "$filename" >> "$DT/test_ok"
                    else
                        echo "$filename" >> "$DT/test_ok_nolang"
                    fi
                else 
                    echo "FAIL" > "$msgs/$filename"
                fi
            fi
            
            cleanups "$audio_file.mp3"
            let n++
        done
    fi

    # ---------------------------------------------------
    # AUDIO - Words"
    echo "50"

    if ls "$DC_d"/*."TTS online.Word pronunciation".* 1> /dev/null 2>&1; then
        n=50
        for dict in $DC_d/*."TTS online.Word pronunciation".*; do
            filename="$(basename "${dict}")"
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
                
                    if echo "$TLANGS" |grep -E "$lgt" >/dev/null 2>&1; then
                        echo "$filename" >> "$DT/test_ok"
                    else
                        echo "$filename" >> "$DT/test_ok_nolang"
                    fi
                else
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
            filename="$(basename "${dict}")"
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
                
                    if echo "$TLANGS" |grep -E "$lgt" >/dev/null 2>&1; then
                        echo "$filename" >> "$DT/test_ok"
                    else
                        echo "$filename" >> "$DT/test_ok_nolang"
                    fi
                else
                    echo "FAIL" > "$msgs/$filename"
                fi
            fi
            
            cleanups "$audio_file.mp3"
            let n++
        done
    fi

    # ---------------------------------------------------
    # WEB PAGES"
    echo "70"
    
    word="test"
    export query="$word" lgt
    if ls "$DC_d"/*."Link.Search definition".* 1> /dev/null 2>&1; then
        for dict in $DC_d/*."Link.Search definition".*; do
            filename="$(basename "${dict}")"
            eval _url="$(< "$DS_a/Dics/dicts/$filename")"
            if curl -v "$_url" 2>&1 |grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
                echo "$filename" >> "$DT/test_ok"
            else 
                echo "FAIL" > "$msgs/$filename"
            fi
        done  
    fi
    
    echo "80"
    if ls "$DC_e"/*."Link.Search definition".* 1> /dev/null 2>&1; then
        for dict in $DC_e/*."Link.Search definition".*; do
            filename="$(basename "${dict}")"
            eval _url="$(< "$DS_a/Dics/dicts/$filename")"
            if curl -v "$_url" 2>&1 |grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
                echo "$filename" >> "$DT/test_ok"
            else 
                echo "FAIL" > "$msgs/$filename"
            fi
        done  
    fi

    # ---------------------------------------------------
    # IMAGE DOWNLOADER"
    echo "90"
    
    if ls "$DC_d"/*."Script.Download image".* 1> /dev/null 2>&1; then
        for Script in "$DC_d"/*."Script.Download image".*; do
            filename="$(basename "${Script}")"
            Script="$DS_a/Dics/dicts/$filename"
            TLANGS=$(grep -o TLANGS=\"[^\"]* "$Script" |grep -o '[^"]*$')
            TWORD=$(grep -o TWORD=\"[^\"]* "$Script" |grep -o '[^"]*$')
            [ -f "${Script}" ] && "${Script}" "${TWORD}" "_TEST_"
            if [ -f "$DT/${TWORD}.jpg" ]; then
                if [[ $(du "$DT/${TWORD}.jpg" |cut -f1) -gt 10 ]]; then
                    if echo "$TLANGS" |grep -E "$lgt" >/dev/null 2>&1; then
                        echo "$filename" >> "$DT/test_ok"
                    else
                        echo "$filename" >> "$DT/test_ok_nolang"
                    fi
                else 
                    echo "FAIL" > "$msgs/$filename"
                fi
            fi
            cleanups "$DT/${TWORD}.jpg"
        done
    fi

    echo "95"
    if ls "$DC_e"/*."Script.Download image".* 1> /dev/null 2>&1; then
        for Script in "$DC_e"/*."Script.Download image".*; do
            filename="$(basename "${Script}")"
            Script="$DS_a/Dics/dicts/$filename"
            TLANGS=$(grep -o TLANGS=\"[^\"]* "$Script" |grep -o '[^"]*$')
            TWORD=$(grep -o TWORD=\"[^\"]* "$Script" |grep -o '[^"]*$')
            [ -f "${Script}" ] && "${Script}" "${TWORD}" "_TEST_"
            if [ -f "$DT/${TWORD}.jpg" ]; then
                if [[ $(du "$DT/${TWORD}.jpg" |cut -f1) -gt 10 ]]; then
                    if echo "$TLANGS" |grep -E "$lgt" >/dev/null 2>&1; then
                        echo "$filename" >> "$DT/test_ok"
                    else
                        echo "$filename" >> "$DT/test_ok_nolang"
                    fi
                else 
                    echo "FAIL" > "$msgs/$filename"
                fi
            fi
            cleanups "$DT/${TWORD}.jpg"
        done
    fi

    # ---------------------------------------------------
    mv "$DT/test_ok" "$DC_a/dict/ok.list"
    mv "$DT/test_ok_nolang" "$DC_a/dict/ok_nolang.list"
    
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
