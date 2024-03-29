#!/bin/bash
# -*- ENCODING: UTF-8 -*-

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

function test_() {
    f_lock 1 "$DT/scripts_lk"
    internet
    
    echo "1"
    
    if [ "$(cut -d "|" -f1 <<< "$c")" = 'TRUE' ]; then
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

    if [ "$(cut -d "|" -f2 <<< "$c")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # AUDIO - Sentences"
        echo "10"

        if ls "$DC_d"/*."TTS online.Convert text to audio".* 1> /dev/null 2>&1; then
            n=10
            for res in "$DC_d"/*."TTS online.Convert text to audio".*; do
                audio_file="$DT/res_test/${n}_audio"
                filename="$(basename "${res}")"; cleanups "$msgs/$filename"
                unset TESTURL EXECUT TESTSTRING EX; source "$DS_a/Resources/scripts/$filename"
                
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
					
				if [ -f "$audio_file.mp3" ]; then
					if file -b --mime-type "$audio_file.mp3" |grep 'audio|mpeg|mp3|' >/dev/null 2>&1 \
					&& [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 200 ]]; then
						:
					else 
						if [ -f "$FILECONF" ] && [ -n "$(< "$FILECONF")" ]; then
							echo "<span color='#C15F27'>$(gettext "No key configuration")</span>" > "$msgs/$filename"
						else
							echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
						fi
					fi
				else
					if [ -f "$FILECONF" ] && [ -n "$(< "$FILECONF")" ]; then
						echo "<span color='#C15F27'>$(gettext "No key configuration")</span>" > "$msgs/$filename"
					else
						echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
					fi
				fi

                cleanups "$audio_file.mp3"
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
                unset TESTURL EXECUT TESTSTRING EX; source "$DS_a/Resources/scripts/$filename"
                
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
					
				if [ -f "$audio_file.mp3" ]; then
					if file -b --mime-type "$audio_file.mp3" |grep 'audio|mpeg|mp3|' >/dev/null 2>&1 \
					&& [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 200 ]]; then
						:
					else 
						if [ -f "$FILECONF" ] && [ -n "$(< "$FILECONF")" ]; then
							echo "<span color='#C15F27'>$(gettext "No key configuration")</span>" > "$msgs/$filename"
						else
							echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
						fi
					fi
				else
					if [ -f "$FILECONF" ] && [ -n "$(< "$FILECONF")" ]; then
						echo "<span color='#C15F27'>$(gettext "No key configuration")</span>" > "$msgs/$filename"
					else
						echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
					fi
				fi

                cleanups "$audio_file.mp3"
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
                unset EXECUT; source "$DS_a/Resources/scripts/$filename"

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
                unset EXECUT; source "$DS_a/Resources/scripts/$filename"
                
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

    if [ "$(cut -d "|" -f3 <<< "$c")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # AUDIO - Words"
        echo "50"

        if ls "$DC_d"/*."TTS online.Download audio".* 1> /dev/null 2>&1; then
            n=50
            for res in $DC_d/*."TTS online.Download audio".*; do
                filename="$(basename "${res}")"; cleanups "$msgs/$filename"
                audio_file="$DT/res_test/${n}_audio"
                unset TESTURL EXECUT; source "$DS_a/Resources/scripts/$filename"
                
                if [ -n "${EXECUT##+([[:space:]])}" ] && [[ ! $(which $EXECUT) ]]; then
					echo "<span color='#C15F27'>$(gettext "For this utility, please install the package:")</span> $EXECUT" > "$msgs/$filename"
				else
					if [ -n "${TESTURL##+([[:space:]])}" ]; then
						wget -T 15 -q -U "$useragent" -O "$audio_file.$EX" "${TESTURL}"
						if [[ ${EX} != 'mp3' ]]; then
							mv -f "$audio_file.$EX" "$audio_file.mp3"
						fi
					fi
					if [ -f "$audio_file.mp3" ]; then
						if file -b --mime-type "$audio_file.mp3" |grep 'audio|mpeg|mp3|' >/dev/null 2>&1 \
						&& [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 200 ]]; then
							:
						else
							filename="$(basename "${res}")"
							echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
						fi
					fi
					cleanups "$audio_file.mp3"
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
                unset TESTURL EXECUT; source "$DS_a/Resources/scripts/$filename"
                
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
					if [ -f "$audio_file.mp3" ]; then
						if file -b --mime-type "$audio_file.mp3" |grep 'audio|mpeg|mp3|' >/dev/null 2>&1 \
						&& [[ $(du -b "$audio_file.mp3" |cut -f1) -gt 200 ]]; then
							:
						else
							echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
							mv -f "$DC_e/$filename" "$DC_d/$filename"
						fi
					fi
					
					cleanups "$audio_file.mp3"
				fi
                let n++
            done
        fi
    fi

    if [ "$(cut -d "|" -f4 <<< "$c")" = 'TRUE' ]; then
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

    if [ "$(cut -d "|" -f5 <<< "$c")" = 'TRUE' ]; then
        # ---------------------------------------------------
        # IMAGE DOWNLOADER"
        echo "90"
        
        if ls "$DC_d"/*."Script.Download image".* 1> /dev/null 2>&1; then
            for Script in "$DC_d"/*."Script.Download image".*; do
            
                filename="$(basename "${Script}")"; cleanups "$msgs/$filename"
                Script="$DS_a/Resources/scripts/$filename"
                TLANGS=$(grep -o TLANGS=\"[^\"]* "$Script" |grep -o '[^"]*$')
                TESTWORD=$(grep -o TESTWORD=\"[^\"]* "$Script" |grep -o '[^"]*$')
                
                [ -f "${Script}" ] && "${Script}" "${TESTWORD}" "_TEST_"
                if [ -f "$DT/${TESTWORD}.jpg" ]; then
                    if file -b --mime-type "$DT/${TESTWORD}.jpg" |grep 'image'>/dev/null 2>&1; then
                        :
                    else 
                        echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
                    fi
                fi
                cleanups "$DT/${TESTWORD}.jpg"
            done
        fi

        echo "95"
        if ls "$DC_e"/*."Script.Download image".* 1> /dev/null 2>&1; then
            for Script in "$DC_e"/*."Script.Download image".*; do
            
                filename="$(basename "${Script}")"; cleanups "$msgs/$filename"
                Script="$DS_a/Resources/scripts/$filename"
                TLANGS=$(grep -o TLANGS=\"[^\"]* "$Script" |grep -o '[^"]*$')
                TESTWORD=$(grep -o TESTWORD=\"[^\"]* "$Script" |grep -o '[^"]*$')
                
                [ -f "${Script}" ] && "${Script}" "${TESTWORD}" "_TEST_"
                if [ -f "$DT/${TESTWORD}.jpg" ]; then
                    if file -b --mime-type "$DT/${TESTWORD}.jpg" |grep 'image'>/dev/null 2>&1; then
                        :
                    else 
                        echo "<span color='#C15F27'>$(gettext "It's not working")</span>" > "$msgs/$filename"
                        mv -f "$DC_e/$filename" "$DC_d/$filename"
                    fi
                fi
                cleanups "$DT/${TESTWORD}.jpg"
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
