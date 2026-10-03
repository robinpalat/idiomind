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
if [ -r "$DS/addons/Resources/common.sh" ]; then
    source "$DS/addons/Resources/common.sh"
fi
source "$DS/default/sets.cfg"
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}

# Agrupamiento visible (misma lista que cnfg.sh, sin Search definition)
task=( 'Search audio' 'Convert text to audio' 'Translate' 'Search image' )

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
    # No valid audio produced - only write a message if no specific one exists.
    # Never blame the API key without evidence from the failed reply itself:
    # a failed download with a configured key is a network/service problem.
    if [ ! -f "$msgs/$fname" ] || [ ! -s "$msgs/$fname" ]; then
        if [ -s "$af" ] && file -b "$af" 2>/dev/null |grep -qiE 'text|empty' \
        && grep -qiE 'ERROR:|result=error' "$af" 2>/dev/null; then
            if grep -qiE 'key is not|key not available|invalid.*key|key.*invalid|no key|missing key|wrong key|credential|error=1([^0-9]|$)|error=997([^0-9]|$)' "$af" 2>/dev/null; then
                # The service itself reports a credential problem.
                echo "<span color='#C15F27'>No key configuration</span>" > "$msgs/$fname"
            elif grep -qiE 'quota|credit|expir|limit|inactive|denied|error=3([^0-9]|$)' "$af" 2>/dev/null; then
                # The service itself reports quota/account problems.
                echo "<span color='#C15F27'>API quota exhausted (cuota de API agotada o cuenta inactiva)</span>" > "$msgs/$fname"
            else
                echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$fname"
            fi
        elif [ -s "$af" ] && file -b "$af" 2>/dev/null |grep -qiE 'text|empty|json' \
        && grep -qiE '"error"|insufficient_quota|invalid_api_key|rate_limit' "$af" 2>/dev/null; then
            # JSON API error with explicit diagnosis (e.g. OpenAI TTS).
            if grep -qiE 'insufficient_quota|credit_balance|quota_exceeded|billing|out_of_credit' "$af" 2>/dev/null; then
                echo "<span color='#C15F27'>API quota exhausted (cuota de API agotada o cuenta inactiva)</span>" > "$msgs/$fname"
            elif grep -qiE 'incorrect_api_key|invalid_api_key|invalid_authentication|unauthorized|authentication_failed|\<key\>|credential' "$af" 2>/dev/null; then
                echo "<span color='#C15F27'>No key configuration</span>" > "$msgs/$fname"
            elif grep -qiE 'rate_limit|too_many_requests' "$af" 2>/dev/null; then
                echo "<span color='#C15F27'>Request limit exceeded</span>" > "$msgs/$fname"
            else
                _emsg=$(grep -oE '"message"[ ]*:[ ]*"[^"]{1,160}' "$af" 2>/dev/null | head -1 | sed 's/^"message"[ ]*:[ ]*"//;s/[<>&]//g')
                if [ -n "$_emsg" ]; then
                    echo "<span color='#C15F27'>Error: ${_emsg}</span>" > "$msgs/$fname"
                else
                    echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$fname"
                fi
            fi
        else
            echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$fname"
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

function live_task_norm() {
    case "$1" in
        'Download audio') echo 'Search audio' ;;
        'Download image') echo 'Search image' ;;
        *) echo "$1" ;;
    esac
}

function live_emit_row() {
    # $1 = basename, $2 = fifo. Emite la misma fila de 6 lineas que cnfg.sh
    # (Enable, Provider, Type, Is used for, Language, Status) a la
    # misma instancia YAD via --listen, sin cerrar el dialogo.
    local _fname="$1" _fifo="${2:-$RES_LIVE_FIFO}"
    [ -n "$_fname" ] || return 1
    [ -p "$_fifo" ] || return 1
    local _st="FALSE" _tl _icon
    [ -f "$DC_e/$_fname" ] && _st="TRUE"
    if declare -F resource_get_field >/dev/null 2>&1; then
        _tl="$(resource_get_field "$DS_a/Resources/scripts/$_fname" "TLANGS")"
    else
        _tl=$(grep -o TLANGS=\"[^\"]* "$DS_a/Resources/scripts/$_fname" 2>/dev/null |grep -o '[^"]*$')
    fi
    if ! echo "$_tl" |grep -E "$lgt" >/dev/null 2>&1; then
        _icon="$DS/addons/Resources/b.png"
    elif [ ! -f "$msgs/$_fname" ]; then
        _icon="$DS/addons/Resources/c.png"
    else
        _icon="$DS/addons/Resources/a.png"
    fi
    {
        printf '%s\n' "$_st"
        sed 's/\./\n/g' <<< "$_fname"
        printf '%s\n' "$_icon"
    } > "$_fifo" 2>/dev/null || return 1
}

function live_test_one() {
    # Prueba un solo proveedor y deja msgs/ + enables/disables como test_().
    # $1 = basename, $2 = 1 si estaba habilitado, 0 si deshabilitado.
    local filename="$1" _enabled="${2:-0}"
    local res trans Script audio_file img re st
    local TESTWORD EXECUT TESTSTRING EX FILECONF TESTURL _sv1 _sv2
    case "$filename" in
        *."Traslator online.Translate".*)
            cleanups "$msgs/$filename"
            trans="$DS_a/Resources/scripts/$filename"
            if [ -f "${trans}" ]; then
                re="$("${trans}" "This is a test" auto $lgs 2>/dev/null)"
                if [ -n "${re##+([[:space:]])}" ]; then
                    :
                else
                    echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
                    if [ "$_enabled" = 1 ]; then
                        mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                    fi
                fi
            fi
            ;;
        *."TTS online.Convert text to audio".*)
            audio_file="$DT/res_test/live_audio"
            cleanups "$msgs/$filename"
            unset TESTURL EXECUT TESTSTRING EX FILECONF; _sv1="$1"; _sv2="$2"; set --; source "$DS_a/Resources/scripts/$filename" 2>/dev/null; set -- "$_sv1" "$_sv2"
            if ! check_lang "$filename"; then
                if [ "$_enabled" = 1 ]; then
                    mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                fi
            else
                rm -f "$audio_file"*
                if [ -n "${EXECUT##+([[:space:]])}" ]; then
                    if [[ ! $(which $EXECUT 2>/dev/null) ]]; then
                        echo "<span color='#C15F27'>$(gettext "For this utility, please install the package:")</span> $EXECUT" > "$msgs/$filename"
                    else
                        "$DS_a/Resources/scripts/$filename" "$TESTSTRING" "$audio_file.$EX" 2>/dev/null
                    fi
                else
                    if [ -n "${TESTURL##+([[:space:]])}" ]; then
                        wget -T 15 -q -U "$useragent" -O "$audio_file.$EX" "${TESTURL}" 2>/dev/null
                    fi
                fi
                if [[ ${EX} != 'mp3' ]]; then
                    mv -f "$audio_file.$EX" "$audio_file.mp3" 2>/dev/null
                fi
                check_audio "$filename" "$audio_file.mp3"
                if [ "$_enabled" = 1 ] && [ -f "$msgs/$filename" ]; then
                    if is_permanent_error "$filename"; then
                        mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                    fi
                fi
                cleanups "$audio_file"*
            fi
            ;;
        *."TTS offline.Convert text to audio".*)
            audio_file="$DT/res_test/live_audio"
            cleanups "$msgs/$filename"
            unset EXECUT TLANGS; _sv1="$1"; _sv2="$2"; set --; source "$DS_a/Resources/scripts/$filename" 2>/dev/null; set -- "$_sv1" "$_sv2"
            if ! check_lang "$filename"; then
                if [ "$_enabled" = 1 ]; then
                    mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                fi
            else
                if [ -n "${EXECUT##+([[:space:]])}" ] && [[ ! $(which $EXECUT 2>/dev/null) ]]; then
                    echo "<span color='#C15F27'>$(gettext "For this utility, please install the package:")</span> $EXECUT" > "$msgs/$filename"
                    if [ "$_enabled" = 1 ]; then
                        mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                    fi
                else
                    "$DS_a/Resources/scripts/$filename" "this is a test" "$audio_file" 2>/dev/null
                    if [ -f "$audio_file.mp3" ]; then
                        :
                    elif [ -f "$audio_file.wav" ]; then
                        sox "$audio_file.wav" "$audio_file.mp3" 2>/dev/null
                    else
                        echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
                        if [ "$_enabled" = 1 ]; then
                            mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                        fi
                    fi
                    cleanups "$audio_file.mp3"
                fi
            fi
            ;;
        *."TTS online.Download audio".*)
            audio_file="$DT/res_test/live_audio"
            cleanups "$msgs/$filename"
            unset TESTURL EXECUT FILECONF; _sv1="$1"; _sv2="$2"; set --; source "$DS_a/Resources/scripts/$filename" 2>/dev/null; set -- "$_sv1" "$_sv2"
            if ! check_lang "$filename"; then
                if [ "$_enabled" = 1 ]; then
                    mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                fi
            else
                rm -f "$audio_file"*
                if [ -n "${EXECUT##+([[:space:]])}" ] && [[ ! $(which $EXECUT 2>/dev/null) ]]; then
                    echo "<span color='#C15F27'>$(gettext "For this utility, please install the package:")</span> $EXECUT" > "$msgs/$filename"
                    if [ "$_enabled" = 1 ]; then
                        mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                    fi
                else
                    if [ -n "${TESTURL##+([[:space:]])}" ]; then
                        wget -T 15 -q -U "$useragent" -O "$audio_file.$EX" "${TESTURL}" 2>/dev/null
                        if [[ ${EX} != 'mp3' ]]; then
                            mv -f "$audio_file.$EX" "$audio_file.mp3" 2>/dev/null
                        fi
                    fi
                    check_audio "$filename" "$audio_file.mp3"
                    if [ "$_enabled" = 1 ] && [ -f "$msgs/$filename" ]; then
                        if is_permanent_error "$filename"; then
                            mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
                        fi
                    fi
                    cleanups "$audio_file"*
                fi
            fi
            ;;
        *."Script.Download image".*)
            cleanups "$msgs/$filename"
            Script="$DS_a/Resources/scripts/$filename"
            TESTWORD=$(grep -o TESTWORD=\"[^\"]* "$Script" 2>/dev/null |grep -o '[^"]*$')
            [ -f "${Script}" ] && "${Script}" "${TESTWORD}" "_TEST_" 2>/dev/null
            img="$DT/${TESTWORD}.jpg"
            if [ ! -f "$img" ]; then
                img="$DT/${TESTWORD}.png"
            fi
            check_image "$filename" "$img"
            if [ "$_enabled" = 1 ] && [ -f "$msgs/$filename" ]; then
                mv -f "$DC_e/$filename" "$DC_d/$filename" 2>/dev/null
            fi
            cleanups "$DT/${TESTWORD}.jpg" "$DT/${TESTWORD}.png"
            ;;
        *)
            return 0
            ;;
    esac
}

function test_live() {
    # Bucle vivo agrupado por task: prueba cada proveedor y emite su fila
    # de inmediato a la misma lista YAD. El progreso sale por stdout
    # para el progress bar. No cierra ni reabre el dialogo.
    local _fifo="${1:-$RES_LIVE_FIFO}"
    [ -p "$_fifo" ] || return 1
    trap 'f_lock 3 "$DT/scripts_lk" 2>/dev/null' EXIT INT TERM
    f_lock 1 "$DT/scripts_lk"
    internet
    mkdir -p "$DT/res_test"
    local _en_snap _dis_snap _ordered _total _i _pct _fname _rtask _norm sus res _flag _entry
    _en_snap="$(ls "$DC_e"/ 2>/dev/null)"
    _dis_snap="$(ls "$DC_d"/ 2>/dev/null)"
    # Lista unica precalculada en orden de task: cada proveedor aparece
    # una sola vez con su estado inicial. Asi lo testeado y lo emitido
    # coinciden siempre, tambien tras varias pasadas con movimientos.
    _ordered=""
    for sus in "${task[@]}"; do
        while read -r res; do
            [ -n "${res}" ] || continue
            _fname="$(basename "$res")"
            _rtask="$(cut -d'.' -f3 <<< "$_fname")"
            _norm="$(live_task_norm "$_rtask")"
            [ "$_norm" = "$sus" ] || continue
            _ordered+="${sus}|1|${_fname}"$'\n'
        done <<< "$_en_snap"
        while read -r res; do
            [ -n "${res}" ] || continue
            _fname="$(basename "$res")"
            _rtask="$(cut -d'.' -f3 <<< "$_fname")"
            _norm="$(live_task_norm "$_rtask")"
            [ "$_norm" = "$sus" ] || continue
            _ordered+="${sus}|0|${_fname}"$'\n'
        done <<< "$_dis_snap"
    done
    _total="$(printf '%s' "$_ordered" | grep -c '[^[:space:]]')"
    [ "$_total" -gt 0 ] || _total=1
    echo "1"
    echo "# $(gettext "Checking providers…")"
    _i=0
    while IFS='|' read -r sus _flag _fname; do
        [ -n "$_fname" ] || continue
        [ -p "$_fifo" ] || break
        live_test_one "$_fname" "$_flag"
        live_emit_row "$_fname" "$_fifo" || break
        _i=$((_i+1))
        _pct=$((1 + _i * 99 / _total))
        echo "$_pct"
        echo "# $sus: $_fname ($_i/$_total)"
    done <<< "$_ordered"
    if [ ! -f "$DC_s/Resources_first_run" ]; then
        cat "$DT/test_fail" >> "$DC_a/scripts.inf" 2>/dev/null
    fi
    cleanups "$DT/res_test" "$DT/test_fail" 2>/dev/null
    echo "100"
    f_lock 3 "$DT/scripts_lk"
    trap - EXIT INT TERM 2>/dev/null
}

function test_() {
    f_lock 1 "$DT/scripts_lk"
    internet
    
    # the "c" variable is overwritten while sourcing the resource scripts,
    # so capture the test options in a dedicated variable here (before any source)
    
    echo "1"
    

        # ---------------------------------------------------
        # TRANSLATORS"
        echo "# $(gettext "Checking translators…") ($(gettext "1 of 5 categories"))"
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
    


        # ---------------------------------------------------
        # AUDIO - Sentences"
        echo "# $(gettext "Checking text-to-speech converters…") ($(gettext "2 of 5 categories"))"
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
    


        # ---------------------------------------------------
        # AUDIO - Words"
        echo "# $(gettext "Checking audio downloaders…") ($(gettext "3 of 5 categories"))"
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
    


        # ---------------------------------------------------
        # WEB PAGES"
        echo "# $(gettext "Checking definition finders…") ($(gettext "4 of 5 categories"))"
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
    


        # ---------------------------------------------------
        # IMAGE DOWNLOADER"
        echo "# $(gettext "Checking image downloaders…") ($(gettext "5 of 5 categories"))"
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
    
    
    # ---------------------------------------------------

    if [ ! -f "$DC_s/Resources_first_run" ]; then
        cat "$DT/test_fail" >> "$DC_a/scripts.inf"
    fi
    cleanups "$DT/res_test" "$DT/test_fail"
    echo "100"
    f_lock 3 "$DT/scripts_lk"
}

function dlg_progress_2() {
    yad --progress --title="$(gettext "Testing online provider availability")" \
    --name=Idiomind --class=Idiomind \
    --window-icon=$DS/images/logo.png --align=right \
    --text="$(gettext "Checking the available providers for the selected language.")\n\n<span color='#2BB62D'>●</span> $(gettext "Available")\n<span color='#3498DB'>●</span> $(gettext "Not available for this language")\n<span color='#C15F27'>●</span> $(gettext "Unavailable")\n" \
    --progress-text=" " \
    --percentage="0" --auto-close \
    --no-buttons --on-top --fixed \
    --width=460 --borders=10
}

if [[ "$1" = live ]]; then
    # Modo vivo: la lista YAD ya esta abierta (--listen). Se emite fila
    # por fila al fifo y el progreso a este progress bar. No se reabre cnfg.
    RES_LIVE_FIFO="${2:-$RES_LIVE_FIFO}"
    export RES_LIVE_FIFO
    ( echo "1"; echo "#  "; test_live "$RES_LIVE_FIFO" ) | dlg_progress_2
    exit 0
fi

if [[ "$2" = 'silence' ]]; then
    export c="TRUE|TRUE|TRUE|TRUE|TRUE|"
    echo -e "\n-- testing online resources..."
    test_
    echo -e "\ttesting online resources ok"

else


    ( echo "1"; echo "#  "; test_ ) | dlg_progress_2
fi

if [[ "$1" != 1 && "$1" != live ]]; then
    "$DS/addons/Resources/cnfg.sh"
fi
