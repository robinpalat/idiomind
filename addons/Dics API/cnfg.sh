#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
export lgt=${tlangs[$tlng]}
export lgs=${slangs[$slng]}
dir="$DC/addons/dict-api"
enables="$DC/addons/dict-api/enables"
disables="$DC/addons/dict-api/disables"
task=( 'Word pronunciation' 'Pronunciation' 'Translator' \
'Search definition' 'Search images' 'Download images' '_' )

function add_dlg() {
    langs=( 'various' 'zh-cn' 'en' 'fr' 'de' 'it' 'ja' 'pt' 'ru' 'es' 'vi' )
    i=FALSE; cd "$HOME"
    add="$(yad --file --title="$(gettext "Add resource")" \
    --text=" $(gettext "Browse to and select the file that you want to add.")" \
    --class=Idiomind --name=Idiomind \
    --window-icon=idiomind --center --on-top \
    --width=650 --height=550 --borders=5 \
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
                gksu -S -m "$(gettext "Idiomind requires admin privileges for this task")" "$DS_a/Dics API/cnfg.sh" \
                cpfile "${add}" "$DS_a/Dics API/dicts"/ "$DC_a/dict-api/disables/$(basename "${add}")"
            elif [ -f /usr/bin/kdesudo ]; then
                kdesudo -d --comment="$(gettext "Idiomind requires admin privileges for this task")" "$DS_a/Dics API/cnfg.sh" \
                cpfile "${add}" "$DS_a/Dics API/dicts"/ "$DC_a/dict-api/disables/$(basename "${add}")"
            else
                msg "$(gettext "No authentication program found").\n" error \
                "$(gettext "No authentication program found")"
                exit 1
            fi
        fi
    fi
    "$DS_a/Dics API/cnfg.sh"
}

function dclk() {
    [ "$2" = TRUE ] && dir=enables
    [ "$2" = FALSE ] && dir=disables
    "$DS_a/Dics API/dicts/$3.$4.$5.$6" dlgcnfg "$@"
}

function cpfile() {
    cp -f "${2}" "${3}"/
    > "${4}"; sudo chmod 777 "${4}"
}

function dlg() {
    dict_list() {
    sus="${task[$1]}"
    cd "$enables/"
    find . -not -name "*.$lgt" -and -not -name "*.various" -type f \
    -exec mv --target-directory="$disables/" {} +
    
    while read -r dict; do
        if [ -n "${dict}" ]; then
            echo 'TRUE'
            sed 's/\./\n/g' <<< "${dict}"; fi
    done < <(ls "$enables/")
    
    while read -r dict; do
        if [ -n "${dict}" ]; then
            echo 'FALSE'
            if grep -E ".$lgt|.various" <<< "${dict}">/dev/null 2>&1; then
                sed 's/\./\n/g' <<< "${dict}"| \
                sed "3s|${sus}|<span color='#0038FF'>${sus}<\/span>|"
            else 
                echo "${dict}" |sed 's/\./\n/g'
            fi
        fi
    done < <(ls "$disables/")
    }
   
    if [ ! -d "$DC_d" -o ! -d "$DC_a/dict-api/disables" ]; then
    mkdir -p "$enables"; mkdir -p "$disables"
    echo -e "$tlng\n$v_dicts" > "$DC_a/dict-api/.dict"
    for r in "$DS_a/Dics API/dicts"/*; do > "$disables/$(basename "$r")"; done; fi
    
    txtinf="$(gettext "Please, select at least one script for each task.\n(To start is okay select all. Later, according to your preferences you can go testing to disable some.)")\n"
    if [ -n "${1}" ]; then text="--text=$txtinf"; n=${1}; else text="--center"; n=6; fi

    sel="$(dict_list ${n} |yad --list \
    --title="$(gettext "Dictionaries API")" \
    --text=" $(gettext "Double-Click to configure") " \
    --name=Idiomind --class=Idiomind "${text}" \
    --print-all --always-print-result --separator="|" \
    --dclick-action="'$DS_a/Dics API/cnfg.sh' dclk" \
    --window-icon=idiomind \
    --expand-column=2 --hide-column=3 \
    --search-column=4 --regex-search \
    --center \
    --width=600 --height=370 --borders=5 \
    --column="$(gettext "Enable")":CHK \
    --column="$(gettext "Resource")":TEXT \
    --column="$(gettext "Type")":TEXT \
    --column="$(gettext "Task")":TEXT \
    --column="$(gettext "Language")":TEXT \
    --button="$(gettext "Add")":2 \
    --button="$(gettext "Cancel")":1 \
    --button=OK:0)"
    ret=$?

        if [ $ret -eq 2 ]; then
                "$DS_a/Dics API/cnfg.sh" add_dlg
        elif [ $ret -eq 0 ]; then
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
                    cleanups "$disables2/$name.$type.$tget.$lgt" \
                    "$disables2/$name.$type.$tget.various"
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
            done < <(sed 's/<[^>]*>//g' <<< "${sel}")
        fi
    exit 1
} >/dev/null 2>&1

function update_config_dir() {
    [ ! -d "$enables" ] && mkdir -p "$enables"
    [ ! -d "$disables" ] && mkdir -p "$disables"
    while read -r dict; do
        if [ ! -e "$enables/$(basename "${dict}")" \
            -a ! -e "$disables/$(basename "${dict}")" ]; then
            echo "-- added dict-api: $(basename "${dict}")"
            > "$disables/$(basename "${dict}")"; fi
    done < <(ls "$DS_a/Dics API/dicts/")
}

case "$1" in
    add_dlg)
    add_dlg "$@" ;;
    dclk)
    dclk "$@" ;;
    cpfile)
    cpfile "$@" ;;
    updt_dicts)
    update_config_dir "$@" ;;
    *)
    dlg "$@" ;;
esac
