#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
export lgt=${tlangs[$tlng]}
export lgs=${slangs[$slng]}
dir="$DC/addons/dict"
enables="$dir/enables"
disables="$dir/disables"
msgs="$DC/addons/dict/msgs"
DC_a="$HOME/.config/idiomind/addons"
check_dir "$msgs"

task=( 'Word pronunciation' 'Pronunciation' 'Translator' \
'Search definition' 'Search images' 'Download images' '_' )

function add_dlg() {
    langs=( 'various' 'zh-cn' 'en' 'fr' \
    'de' 'it' 'ja' 'pt' 'ru' 'es' 'vi' )
    i=FALSE; cd "$HOME"
    add="$(yad --file --title="$(gettext "Add resource")" \
    --text=" $(gettext "Browse to and select the file that you want to add.")" \
    --class=Idiomind --name=Idiomind \
    --window-icon=idiomind --center \
    --width=650 --height=550 --borders=5 --on-top \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0 |cut -d "|" -f1)"
    ret=$?
    
    if [ $ret -eq 0 -a -f "${add}" ]; then
        info="$(basename "${add}")"
        name="$(cut -d "." -f1 <<< "$info")"; if [ -z "$name" ]; then i=TRUE; fi
        type="$(cut -d "." -f2 <<< "$info")"; if [ -z "$type" ]; then i=TRUE; fi
        tget="$(cut -d "." -f3 <<< "$info")"; if [ -z "$tget" ]; then i=TRUE; fi
        lang="$(cut -d "." -f4 <<< "$info")"; if [ -z "$lang" ]; then i=TRUE; fi
        test="$(cut -d "." -f5 <<< "$info")"; if [ -n "$test" ]; then i=TRUE; fi

        if [ ${#name} -gt 50 -o ${#type} -gt 50 ]; then i=TRUE; fi
        if ! grep -Fo "${tget}" <<< "${task[@]}"; then i=TRUE; fi
        if ! grep -Fo "${lang}" <<< "${langs[@]}"; then i=TRUE; fi

        if [ ${i} = TRUE ]; then
            msg "$(gettext "You have entered an Invalid format").\n" \
            error "$(gettext "You have entered an Invalid format")"
        else
            if [ -f /usr/bin/gksu ]; then
                gksu -S -m "$(gettext "Idiomind requires admin privileges for this task")" "$DS_a/Dics/cnfg.sh" \
                cpfile "${add}" "$DS_a/Dics/dicts"/ "$DC_a/dict/disables/$(basename "${add}")"
            elif [ -f /usr/bin/kdesudo ]; then
                kdesudo -d --comment="$(gettext "Idiomind requires admin privileges for this task")" "$DS_a/Dics/cnfg.sh" \
                cpfile "${add}" "$DS_a/Dics/dicts"/ "$DC_a/dict/disables/$(basename "${add}")"
            else
                msg "$(gettext "No authentication program found").\n" error \
                "$(gettext "No authentication program found")"
                exit 1
            fi
        fi
    fi
    "$DS_a/Dics/cnfg.sh"
}

function dclk() {
    
    [ "$2" = TRUE ] && dir=enables
    [ "$2" = FALSE ] && dir=disables
    fname="$3.$4.$5.$6"
    
    if [ "$4" = "Link" ]; then
        TLANGS="zh-cn, en, ja, pt, es, ru, it, de, fr"
        INFO="$(gettext "Link to web page")"
        LANGUAGES="Undefined"
        if [ ! -f "$msgs/$fname" ]; then
            STATUS="Ok"
        else
            STATUS="Break"
        fi
        CONF="FALSE"
    else
        source "$DS_a/Dics/dicts/$3.$4.$5.$6"
    fi

    name="<b>$3</b>"
    icon="$DS/addons/Dics/c.png"

    if [ -f "$msgs/$fname" ]; then
        STATUS="$(< "$msgs/$fname")"
        icon="$DS/addons/Dics/a.png"
    elif grep -Fxq "$fname" "$DC_a/dict/ok_nolang.list" >/dev/null 2>&1; then
        STATUS="$(gettext "Not available for the language you are learning.")"
        icon="$DS/addons/Dics/b.png"
    fi

    if [[ "$CONF" = "TRUE" ]]; then
        fileconf="$DC_a/dict/$3.cfg"
        SPEED=""
        VOICES=""
        [ ! -f "$fileconf" ] && touch "$fileconf"
        if [[ -z "$(< "$fileconf")" ]]; then
            echo -e "voice=\"\"\nspeed=\"\"\nkey=\"\"" > "$fileconf"
        fi
        key=$(grep -o key=\"[^\"]* "$fileconf" |grep -o '[^"]*$')
        speed=$(grep -o speed=\"[^\"]* "$fileconf" |grep -o '[^"]*$')
        voice=$(grep -o voice=\"[^\"]* "$fileconf" |grep -o '[^"]*$' |sed 's/(null)//')
        SPEED="$speed!Slow!Normal!Fast"

        c=$(yad --form --title="${3}" \
        --text="$name\n<small>\n<b>$(gettext "Languages"):</b>\n$LANGUAGES\n\n<b>$(gettext "Information"):</b>\n$INFO\n\n<b>$(gettext "Status:")</b>\n $STATUS</small>\n" \
        --image=$icon \
        --name=Idiomind --class=Idiomind \
        --window-icon="$DS/images/icon.png" --center \
        --on-top --skip-taskbar --expand-column=3 \
        --width=600 --height=200 --borders=12 \
        --always-print-result --editable --print-all --align=right \
        --field=Voice:CB "" \
        --field=Speed:CB "$SPEED" \
        --field="Key" "$key" \
        --button="$(gettext "Cancel")":1 \
        --button="$(gettext "OK")":0)
        ret=$?

        if [ $ret = 0 ]; then
            sed -i "s/voice=.*/voice=\"$(cut -d "|" -f1 <<< "$c")\"/g" "$fileconf"
            sed -i "s/speed=.*/speed=\"$(cut -d "|" -f2 <<< "$c")\"/g" "$fileconf"
            sed -i "s/key=.*/key=\"$(cut -d "|" -f3 <<< "$c")\"/g" "$fileconf"
        fi
    else
        yad --form --title="${3}" \
        --text="$name\n<small>\n<b>$(gettext "Languages"):</b>\n$LANGUAGES\n\n<b>$(gettext "Information"):</b>\n$INFO\n\n<b>$(gettext "Status:")</b>\n $STATUS</small>\n" \
        --image=$icon \
        --name=Idiomind --class=Idiomind \
        --window-icon="$DS/images/icon.png" --center \
        --on-top --skip-taskbar --expand-column=3 \
        --width=600 --height=200 --fixed --borders=12 \
        --align=right \
        --button="$(gettext "Close")":1 
    fi

}

function cpfile() {
    cp -f "${2}" "${3}"/
    > "${4}"; sudo chmod 777 "${4}"
}

function dlg() {
    if [ -f "$DT/dicts" ]; then
        (sleep 20 && cleanups "$DT/dicts") & exit 1
    fi
    dict_list() {
        sus="${task[$1]}"
        cd "$enables"/
        find . -not -name "*.$lgt" -and -not -name "*.various" -type f \
        -exec mv --target-directory="$disables/" {} +
        
        while read -r dict; do
            if [ -n "${dict}" ]; then
                echo 'TRUE'
                sed 's/\./\n/g' <<< "${dict}"
                if grep "${dict}" <<< "$test_ok" >/dev/null 2>&1; then
                    echo "$DS/addons/Dics/c.png"
                elif grep "${dict}" <<< "$test_ok_nolang" >/dev/null 2>&1; then
                    echo "$DS/addons/Dics/b.png"
                else
                    echo "$DS/addons/Dics/a.png"
                fi
            fi
        done < <(ls "$enables"/)
        while read -r dict; do
            if [ -n "${dict}" ]; then
                echo 'FALSE'
                if grep -E ".$lgt|.various" <<< "${dict}">/dev/null 2>&1; then
                    sed 's/\./\n/g' <<< "${dict}"| \
                    sed "3s|${sus}|<span color='#2BB62D'>${sus}<\/span>|"
                else 
                    sed 's/\./\n/g' <<< "${dict}"
                fi
                if grep "${dict}" <<< "$test_ok" >/dev/null 2>&1; then
                    echo "$DS/addons/Dics/c.png"
                elif grep "${dict}" <<< "$test_ok_nolang" >/dev/null 2>&1; then
                    echo "$DS/addons/Dics/b.png"
                else
                    echo "$DS/addons/Dics/a.png"
                fi
            fi
        done < <(ls "$disables"/)
    }

    if [ -f "$DC_s/dics_first_run" ]; then
        "$DS_a/Dics/test.sh" 1
        plus="$(gettext "To start is okay select all, later, according to your preferences you can disable some.")\n"
        rm "$DC_s/dics_first_run"
    fi
    inf="<b>$(gettext "Please, select at least one resource for each task")</b>\n$plus"
    if [[ -n "${1}" ]]; then 
        text="--text=$inf"; n=${1}
    else 
        text="--center"; n=6
    fi
    
    if [ -f "$DC_a/dict/ok.list" ] ; then
        test_ok="$(< "$DC_a/dict/ok.list")"
    else
        test_ok=""
    fi
    
    if [ -f "$DC_a/dict/ok_nolang.list" ] ; then
        test_ok_nolang="$(< "$DC_a/dict/ok_nolang.list")"
    else
        test_ok_nolang=""
    fi
    
    sel="$(dict_list ${n} |yad --list \
    --title="$(gettext "Dictionaries")" \
    --name=Idiomind --class=Idiomind "${text}" \
    --print-all --always-print-result --separator="|" \
    --dclick-action="$DS_a/Dics/cnfg.sh _dclk_" \
    --window-icon=idiomind \
    --expand-column=0 --hide-column=3 \
    --search-column=4 --regex-search \
    --center \
    --width=680 --height=430 --borders=10 \
    --column="$(gettext "Enable")":CHK \
    --column="$(gettext "Resource")":TEXT \
    --column="$(gettext "Type")":TEXT \
    --column="$(gettext "Task")":TEXT \
    --column="$(gettext "Language")":TEXT \
    --column="$(gettext "Status")":IMG \
    --button="$(gettext "Add")":2 \
    --button="$(gettext "Test")":3 \
    --button="$(gettext "Save")!gtk-apply":0 \
    --button="$(gettext "Close")":1)"
    ret=$?
        
        if [ $ret -eq 2 ]; then
                "$DS_a/Dics/cnfg.sh" add_dlg
        elif [ $ret -eq 0  -o $ret -eq 3 ]; then
            while read -r dict; do
                name="$(cut -d "|" -f2 <<< "$dict")"
                type="$(cut -d "|" -f3 <<< "$dict")"
                tget="$(cut -d "|" -f4 <<< "$dict")"
                
                if grep 'FALSE' <<< "$dict"; then
                    if [ ! -f "$disables/$name.$type.$tget.$lgt" ]; then
                        if [ -f "$enables/$name.$type.$tget.$lgt" ]; then 
                            mv -f "$enables/$name.$type.$tget.$lgt" \
                            "$disables/$name.$type.$tget.$lgt"
                        fi
                    fi
                    if [ ! -f "$disables/$name.$type.$tget.various" ]; then
                        if [ -f "$enables/$name.$type.$tget.various" ]; then 
                            mv -f "$enables/$name.$type.$tget.various" \
                            "$disables/$name.$type.$tget.various"
                        fi
                    fi
                fi
                if grep 'TRUE' <<< "$dict"; then
                    if [ ! -f "$enables/$name.$type.$tget.$lgt" ]; then
                        if [ -f "$disables/$name.$type.$tget.$lgt" ]; then 
                            mv -f "$disables/$name.$type.$tget.$lgt" \
                            "$enables/$name.$type.$tget.$lgt"
                        fi
                    fi
                    if [ ! -f "$enables/$name.$type.$tget.various" ]; then
                        if [ -f "$disables/$name.$type.$tget.various" ]; then 
                            mv -f "$disables/$name.$type.$tget.various" \
                            "$enables/$name.$type.$tget.various"
                        fi
                    fi
                fi
                if [ -f "$disables/$name.$type.$tget.$lgt" -a \
                -f "$enables/$name.$type.$tget.$lgt" ]; then
                    rm "$disables/$name.$type.$tget.$lgt"
                fi
            done < <(sed 's/<[^>]*>//g' <<< "${sel}")
            
            if [ $ret -eq 3 ]; then "$DS_a/Dics/test.sh"; fi
        fi
    exit 1
    
} >/dev/null 2>&1

function update_config_dir() {
    [ ! -d "$enables" ] && mkdir -p "$enables"
    [ ! -d "$disables" ] && mkdir -p "$disables"
    lsdics="$(ls "$DS_a/Dics/dicts/")"
    
    while read -r dict; do
        if [ ! -e "$enables/$(basename "${dict}")" \
            -a ! -e "$disables/$(basename "${dict}")" ]; then
            echo -e "\tadded dict: $(basename "${dict}")"
            > "$disables/$(basename "${dict}")"; fi
    done <<< "${lsdics}"
    
    if [ -f "$DC_s/recommended_dicts_first_run" ]; then # recommended_dicts_first_run
    
        cleanups "$DC_s/recommended_dicts_first_run"  \
        "$DC_s/dics_first_run"
    
        #lsdics="$(ls "$disables/")"
    
        #"$DS_a/Dics/test.sh" 1 silence
        #if [ -f "$DC_a/dict/test" ] ; then
            #test_ok="$(< "$DC_a/dict/test")"
        #fi
        
            #if grep "${dict}" <<< "${test_ok}"  >/dev/null 2>&1; then
                #echo "-- enable dict: ${dict}"
                #mv -f "$disables/${dict}" "$enables/${dict}"
            #fi
            
        if ls "$disables"/*.various 1> /dev/null 2>&1; then
            mv -f "$disables"/*.various "$enables"/
        fi
        
        if ls "$disables"/*.$lgt 1> /dev/null 2>&1; then
            mv -f "$disables"/*.$lgt "$enables"/
        fi
    fi
    while read -r dict; do
        if ! grep "$(basename "${dict}")" <<< "${lsdics}">/dev/null 2>&1; then
            cleanups "$enables/${dict}"; echo "-- removed: $(basename "${dict}")"
        fi
    done < <(ls "$enables")
    while read -r dict; do
        if ! grep "$(basename "${dict}")" <<< "${lsdics}">/dev/null 2>&1; then
            cleanups "$disables/${dict}"; echo "-- removed: $(basename "${dict}")"
        fi
    done < <(ls "$disables")
}

case "$1" in
    add_dlg)
    add_dlg "$@" ;;
    _dclk_)
    dclk "$@" ;;
    cpfile)
    cpfile "$@" ;;
    errors)
    dlg_text_info_3 ;;
    updt_dicts)
    update_config_dir "$@" ;;
    *)
    dlg "$@" ;;
esac
