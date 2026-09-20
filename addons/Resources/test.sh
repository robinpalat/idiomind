#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# ============================================================
# Resource Addon — Provider Testing Framework
# ============================================================
#
# Tests all resource providers across all categories:
#   - Translators
#   - TTS online (sentences)
#   - TTS offline
#   - TTS online (words)
#   - Link definitions
#   - Image downloaders
#
# For each provider, tests whether it produces valid output.
# Providers with permanent errors (key/quota) are auto-disabled.
# Providers with temporary errors stay enabled.
#
# Entry points:
#   test.sh              → interactive (shows YAD checkboxes)
#   test.sh 1            → silent mode (all categories)
#   test.sh silence      → silent mode with echo output

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}

mkdir "$DT/res_test"
DC_d="$DC_a/resources/disables"
DC_e="$DC_a/resources/enables"
msgs="$DC_a/resources/msgs"
check_dir "$msgs"

function check_audio() {
    # $1 = resource filename, $2 = path to candidate audio file
    local fname="$1" af="$2"
    if [ -s "$af" ]; then
        if file -b --mime-type "$af" |grep -E 'audio|mpeg|mp3|ogg|wav' >/dev/null 2>&1 \
        && [[ $(du -b "$af" |cut -f1) -gt 200 ]]; then
            # Valid audio - clear any previous error
            cleanups "$msgs/$fname"
            return 0   # valid audio, leave message removed
        fi
    fi
    # No valid audio produced - only write generic message if no specific one exists
    if [ ! -f "$msgs/$fname" ] || [ ! -s "$msgs/$fname" ]; then
        if [ -f "$FILECONF" ] && [ -n "$(< "$FILECONF")" ]; then
            echo "<span color='#C15F27'>No key configuration</span>" > "$msgs/$fname"
        else
            echo "<span color='#C15F27'>It's not working</span>" > "$msgs/$fname"
        fi
    fi
    return 1
}

function is_permanent_error() {
    # $1 = filename to check in msgs/
    # Returns 0 if error is permanent (should disable), 1 if temporary (keep enabled)
    local fname="$1"
    if [ ! -f "$msgs/$fname" ]; then
        return 1  # no error message, not permanent
    fi
    local msg=$(< "$msgs/$fname")
    # Strip HTML tags for pattern matching
    local plain_msg=$(echo "$msg" | sed 's/<[^>]*>//g')
    
    # Permanent errors: API key issues, quota, credits, account
    if echo "$plain_msg" | grep -qiE "key inválida|key no configurada|no key configuration|credenciales|cuota de API|créditos|agotada|suscripción vencida|cuenta inactiva|sin acceso"; then
        return 0
    fi
    # Temporary errors: service down, rate limit, connection
    # These should NOT auto-disable
    return 1
}

function check_image() {
    # $1 = resource filename, $2 = path to candidate image file
    local fname="$1" img="$2"
    if [ -s "$img" ]; then
        if file -b --mime-type "$img" |grep -E 'image|jpeg|png|gif' >/dev/null 2>&1; then
            return 0   # valid image
        fi
    fi
    echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$fname"
    return 1
}

function check_lang() {
    # $1 = resource filename
    # Sets the resource state according to the declared TLANGS against the
    # language being learned ($lgt). When the resource declares languages and
    # the learned language is not among them, writes the failure status into
    # msgs/ (this is what the info dialog shows as "Status") and returns 1.
    if [ -n "${TLANGS##+([[:space:]])}" ]; then
        if ! echo "$TLANGS" |grep -E "$lgt" >/dev/null 2>&1; then
            echo "<span color='#C15F27'>$(gettext "Not available for the language you are learning.")</span>" > "$msgs/$1"
            return 1
        fi
    fi
    return 0
}

function test_() {
    f_lock 1 "$DT/scripts_lk"
    internet
    
    # the "c" variable is overwritten while sourcing the resource scripts,
    # so capture the test options in a dedicated variable here (before any source)
    testopts="$c"
    
    echo "1"
    
    if [ "$(cut -d "|" -f1 <<< "$testopts")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # TRANSLATORS"
        echo "5"
        
        for trans in "$DC_d"/*."Traslator online.Translate".*; do
            filename="$(basename "${trans}")"; cleanups "$msgs/$filename"
            trans="$DS_a/Resources/scripts/$filename"
            if [ -f "${trans}" ]; then
                re="$("${trans}" "This is a test" auto $lgs)"
                if [ -n "${re##+([[:space:]])}" ]; then
                    :
                else
                    echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
                fi
            fi
        done
        
        echo "7"
        st="$(gettext "This is a test")"
        for trans in "$DC_e"/*."Traslator online.Translate".*; do
            filename="$(basename "${trans}")"; cleanups "$msgs/$filename"
            trans="$DS_a/Resources/scripts/$filename"
            
            if [ -f "${trans}" ]; then
                re="$("${trans}" "This is a test" auto $lgs)"
                if [ -n "${re##+([[:space:]])}" ]; then
                    :
                else
                    echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
                    mv -f "$DC_e/$filename" "$DC_d/$filename"
                fi
            fi
        done
    fi

    if [ "$(cut -d "|" -f2 <<< "$testopts")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # AUDIO - Sentences"
        echo "10"

        if ls "$DC_d"/*."TTS online.Convert text to audio".* 1> /dev/null 2>&1; then
            n=10
            for res in "$DC_d"/*."TTS online.Convert text to audio".*; do
                audio_file="$DT/res_test/${n}_audio"
                filename="$(basename "${res}")"; cleanups "$msgs/$filename"
                unset TESTURL EXECUT TESTSTRING EX FILECONF; source "$DS_a/Resources/scripts/$filename"
                if ! check_lang "$filename"; then continue; fi
                rm -f "$audio_file"*
                
                if [ -n "${EXECUT##+([[:space:]])}" ]; then # if exe
                    if [[ ! $(which $EXECUT) ]]; then
                        echo "<span color='#C15F27'>$(gettext "For this utility, please install the package:")</span> $EXECUT" > "$msgs/$filename"
                    else
                        "$DS_a/Resources/scripts/$filename" "$TESTSTRING" "$audio_file.$EX"
                    fi
                else
                    if [ -n "${TESTURL##+([[:space:]])}" ]; then # if url based
                        wget -T 15 -q -U "$useragent" -O "$audio_file.$EX" "${TESTURL}"
                    fi
                fi
                    
                if [[ ${EX} != 'mp3' ]]; then
                    mv -f "$audio_file.$EX" "$audio_file.mp3"
                fi
                    
                check_audio "$filename" "$audio_file.mp3"

                cleanups "$audio_file"*
                let n++
                echo 10+n
            done
        fi
        
        echo "20"
        
        if ls "$DC_e"/*."TTS online.Convert text to audio".* 1> /dev/null 2>&1; then
             n=20
             for res in "$DC_e"/*."TTS online.Convert text to audio".*; do
                audio_file="$DT/res_test/${n}_audio"
                filename="$(basename "${res}")"; cleanups "$msgs/$filename"
                unset TESTURL EXECUT TESTSTRING EX FILECONF; source "$DS_a/Resources/scripts/$filename"
                if ! check_lang "$filename"; then
                    mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                    continue
                fi
                rm -f "$audio_file"*
                
                if [ -n "${EXECUT##+([[:space:]])}" ]; then # if exe
                    if [[ ! $(which $EXECUT) ]]; then
                        echo "<span color='#C15F27'>$(gettext "For this utility, please install the package:")</span> $EXECUT" > "$msgs/$filename"
                    else
                        "$DS_a/Resources/scripts/$filename" "$TESTSTRING" "$audio_file.$EX"
                    fi
                else
                    if [ -n "${TESTURL##+([[:space:]])}" ]; then # if url based
                        wget -T 15 -q -U "$useragent" -O "$audio_file.$EX" "${TESTURL}"
                    fi
                fi
                    
                if [[ ${EX} != 'mp3' ]]; then
                    mv -f "$audio_file.$EX" "$audio_file.mp3"
                fi
                    
                check_audio "$filename" "$audio_file.mp3"
                # Auto-disable only if error is permanent (key/quota issues)
                if [ -f "$msgs/$filename" ]; then
                    if is_permanent_error "$filename"; then
                        mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                    fi
                fi
                cleanups "$audio_file"*
                let n++
                echo 10+n
            done
        fi
    
        # ---------------------------------------------------
        # AUDIO - offline"
        echo "25"

        if ls "$DC_d"/*."TTS offline.Convert text to audio".* 1> /dev/null 2>&1; then
            n=10
            for res in "$DC_d"/*."TTS offline.Convert text to audio".*; do
                audio_file="$DT/res_test/${n}_audio"
                filename="$(basename "${res}")"; cleanups "$msgs/$filename"
                unset EXECUT TLANGS; source "$DS_a/Resources/scripts/$filename"
                if ! check_lang "$filename"; then continue; fi

                if [ -n "${EXECUT##+([[:space:]])}" ] && [[ ! $(which $EXECUT) ]]; then
                    echo "<span color='#C15F27'>$(gettext "For this utility, please install the package:")</span> $EXECUT" > "$msgs/$filename"
                else
                    "$DS_a/Resources/scripts/$filename" "this is a test" "$audio_file"
                    if [ -f "$audio_file.mp3" ]; then
                        mv -f "$audio_file.mp3" "$audio_file.mp3"
                    elif [ -f "$audio_file.wav" ]; then
                        sox -r 8000 -c 1 "$audio_file.wav" "$audio_file.mp3"
                        mv -f "$audio_file.mp3" "$audio_file.mp3"
                    else
                        echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
                    fi
                    cleanups "$audio_file.mp3"
                fi
                let n++
            done
        fi
        
        echo "35"
        
        if ls "$DC_e"/*."TTS offline.Convert text to audio".* 1> /dev/null 2>&1; then
            n=20
            for res in "$DC_e"/*."TTS offline.Convert text to audio".*; do
                audio_file="$DT/res_test/${n}_audio"
                filename="$(basename "${res}")"; cleanups "$msgs/$filename"
                unset EXECUT TLANGS; source "$DS_a/Resources/scripts/$filename"
                if ! check_lang "$filename"; then
                    mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                    continue
                fi
                
                if [ -n "${EXECUT##+([[:space:]])}" ] && [[ ! $(which $EXECUT) ]]; then
                    echo "<span color='#C15F27'>$(gettext "For this utility, please install the package:")</span> $EXECUT" > "$msgs/$filename"
                    mv -f "$DC_e/$filename" "$DC_d/$filename"
                else
                    "$DS_a/Resources/scripts/$filename" "this is a test" "$audio_file"
                    if [ -f "$audio_file.mp3" ]; then
                        mv -f "$audio_file.mp3" "$audio_file.mp3"
                    elif [ -f "$audio_file.wav" ]; then
                        sox "$audio_file.wav" "$audio_file.mp3"
                        mv -f "$audio_file.mp3" "$audio_file.mp3"
                    else
                        echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
                        mv -f "$DC_e/$filename" "$DC_d/$filename"
                    fi
                    cleanups "$audio_file.mp3"
                fi
                let n++
            done
        fi
    fi

    if [ "$(cut -d "|" -f3 <<< "$testopts")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # AUDIO - Words"
        echo "50"

        if ls "$DC_d"/*."TTS online.Download audio".* 1> /dev/null 2>&1; then
            n=50
            for res in $DC_d/*."TTS online.Download audio".*; do
                filename="$(basename "${res}")"; cleanups "$msgs/$filename"
                audio_file="$DT/res_test/${n}_audio"
                unset TESTURL EXECUT FILECONF; source "$DS_a/Resources/scripts/$filename"
                if ! check_lang "$filename"; then continue; fi
                rm -f "$audio_file"*
                
                if [ -n "${EXECUT##+([[:space:]])}" ] && [[ ! $(which $EXECUT) ]]; then
                    echo "<span color='#C15F27'>$(gettext "For this utility, please install the package:")</span> $EXECUT" > "$msgs/$filename"
                else
                    if [ -n "${TESTURL##+([[:space:]])}" ]; then
                        wget -T 15 -q -U "$useragent" -O "$audio_file.$EX" "${TESTURL}"
                        if [[ ${EX} != 'mp3' ]]; then
                            mv -f "$audio_file.$EX" "$audio_file.mp3"
                        fi
                    fi
                    check_audio "$filename" "$audio_file.mp3"
                    cleanups "$audio_file"*
                fi
                let n++
            done
        fi

        echo "60"
        
        if ls "$DC_e"/*."TTS online.Download audio".* 1> /dev/null 2>&1; then
            n=60
            for res in $DC_e/*."TTS online.Download audio".*; do
                filename="$(basename "${res}")"; cleanups "$msgs/$filename"
                audio_file="$DT/res_test/${n}_audio"
                unset TESTURL EXECUT FILECONF; source "$DS_a/Resources/scripts/$filename"
                if ! check_lang "$filename"; then
                    mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                    continue
                fi
                rm -f "$audio_file"*
                
                if [ -n "${EXECUT##+([[:space:]])}" ] && [[ ! $(which $EXECUT) ]]; then
                    echo "<span color='#C15F27'>$(gettext "For this utility, please install the package:")</span> $EXECUT" > "$msgs/$filename"
                    mv -f "$DC_e/$filename" "$DC_d/$filename"
                else
                    if [ -n "${TESTURL##+([[:space:]])}" ]; then
                        wget -T 15 -q -U "$useragent" -O "$audio_file.$EX" "${TESTURL}"
                        if [[ ${EX} != 'mp3' ]]; then
                            mv -f "$audio_file.$EX" "$audio_file.mp3"
                        fi
                    fi
                    check_audio "$filename" "$audio_file.mp3"
                    # Auto-disable only if error is permanent (key/quota issues)
                    if [ -f "$msgs/$filename" ]; then
                        if is_permanent_error "$filename"; then
                            mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                        fi
                    fi
                    cleanups "$audio_file"*
                fi
                let n++
            done
        fi
    fi

    if [ "$(cut -d "|" -f4 <<< "$testopts")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # WEB PAGES"
        echo "70"
        
        word="test"
        export query="$word" lgt
        if ls "$DC_d"/*."Link.Search definition".* 1> /dev/null 2>&1; then
            for res in $DC_d/*."Link.Search definition".*; do
                filename="$(basename "${res}")"; cleanups "$msgs/$filename"
                eval _url="$(< "$DS_a/Resources/scripts/$filename")"
                if curl -v "$_url" 2>&1 |grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
                    :
                else 
                    echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
                fi
            done  
        fi
        
        echo "80"
        if ls "$DC_e"/*."Link.Search definition".* 1> /dev/null 2>&1; then
            for res in $DC_e/*."Link.Search definition".*; do
                filename="$(basename "${res}")"; cleanups "$msgs/$filename"
                eval _url="$(< "$DS_a/Resources/scripts/$filename")"
                if curl -v "$_url" 2>&1 |grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
                    :
                else 
                    echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
                    mv -f "$DC_e/$filename" "$DC_d/$filename"
                fi
            done  
        fi
    fi

    if [ "$(cut -d "|" -f5 <<< "$testopts")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # IMAGE DOWNLOADER"
        echo "90"
        
        if ls "$DC_d"/*."Script.Download image".* 1> /dev/null 2>&1; then
            for Script in "$DC_d"/*."Script.Download image".*; do
            
                filename="$(basename "${Script}")"; cleanups "$msgs/$filename"
                Script="$DS_a/Resources/scripts/$filename"
                TESTWORD=$(grep -o TESTWORD=\"[^\"]* "$Script" |grep -o '[^"]*$')
                
                [ -f "${Script}" ] && "${Script}" "${TESTWORD}" "_TEST_"
                img="$DT/${TESTWORD}.jpg"
                if [ ! -f "$img" ]; then
                    img="$DT/${TESTWORD}.png"
                fi
                check_image "$filename" "$img"
                cleanups "$DT/${TESTWORD}.jpg" "$DT/${TESTWORD}.png"
            done
        fi

        echo "95"
        if ls "$DC_e"/*."Script.Download image".* 1> /dev/null 2>&1; then
            for Script in "$DC_e"/*."Script.Download image".*; do
            
                filename="$(basename "${Script}")"; cleanups "$msgs/$filename"
                Script="$DS_a/Resources/scripts/$filename"
                TESTWORD=$(grep -o TESTWORD=\"[^\"]* "$Script" |grep -o '[^"]*$')
                
                [ -f "${Script}" ] && "${Script}" "${TESTWORD}" "_TEST_"
                img="$DT/${TESTWORD}.jpg"
                if [ ! -f "$img" ]; then
                    img="$DT/${TESTWORD}.png"
                fi
                check_image "$filename" "$img"
                if [ -f "$msgs/$filename" ]; then
                    mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                fi
                cleanups "$DT/${TESTWORD}.jpg" "$DT/${TESTWORD}.png"
            done
        fi
    fi
    
    # ---------------------------------------------------

    if [ ! -f "$DC_s/Resources_first_run" ]; then
        cat "$DT/test_fail" >> "$DC_a/scripts.inf"
    fi
    cleanups "$DT/res_test" "$DT/test_fail"
    echo "100"
    f_lock 3 "$DT/scripts_lk"
}

function dlg_progress_2() {
    yad --progress --title="$(gettext "Run tests, please wait...")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=$DS/images/logo.png --align=right \
    --progress-text=" " \
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
    yad --form --title="$(gettext "Resource availability")" \
    --text="<b>\n$(gettext "Check the used resources for:")</b>\n" \
    --window-icon=$DS/images/logo.png \
    --name=Idiomind --class=Idiomind \
    --center --columns=1 --output-by-row \
    --on-top --skip-taskbar \
    --width=400 --height=300 --borders=10 \
    --always-print-result --print-all --align=right \
    --field=" $(gettext "Translate")":CHK "" \
    --field=" $(gettext "Convert text to audio")":CHK "" \
    --field=" $(gettext "Download audio (only for words)")":CHK "" \
    --field=" $(gettext "Search definition")":CHK "" \
    --field=" $(gettext "Download image (only for words)")":CHK "" \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Run")":0 > "$cnf1"
    
    ret=$?; [ $ret != 0 ] && exit
    export c="$(< "$cnf1")"; cleanups "$cnf1"
    
    ( echo "1"; echo "#  "; test_ ) | dlg_progress_2
fi

if [[ "$1" != 1 ]]; then 
    "$DS/addons/Resources/cnfg.sh"
fi
