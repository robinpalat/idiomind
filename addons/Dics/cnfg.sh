#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
dir="$DC/addons/dict"
enables="$DC/addons/dict/enables"
disables="$DC/addons/dict/disables"
lgt=$(lnglss "$lgtl")
lgs=$(lnglss "$lgsl")
task=( 'Word pronunciation' 'Pronunciation' 'Translator' \
'Search definition' 'Search images' 'Download images' '_' )


function add_dlg() {

    langs=( 'various' 'zh-cn' 'en' 'fr' 'de' 'it' 'ja' 'pt' 'ru' 'es' 'vi' )
    i=FALSE; cd "$HOME"
    add="$(yad --file --title="$(gettext "Add resource")" \
    --text=" $(gettext "Browse to and select the file that you want to add.")" \
    --class=Idiomind --name=Idiomind \
    --window-icon="$DS/images/icon.png" --center --on-top \
    --width=650 --height=550 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0 |cut -d "|" -f1)"
    ret=$?
    
    if [ $ret -eq 0 -a -f "${add}" ]; then

        info="$(basename "${add}")"
        name="$(cut -d "." -f1 <<<"$info")"
        type="$(cut -d "." -f2 <<<"$info")"
        tget="$(cut -d "." -f3  <<<"$info")"
        lang="$(cut -d "." -f4  <<<"$info")"
        test="$(cut -d "." -f5  <<<"$info")"
        if [ -z "$name" ]; then i=TRUE; fi
        if [ -z "$type" ]; then i=TRUE; fi
        if [ -z "$tget" ]; then i=TRUE; fi
        if [ -z "$lang" ]; then i=TRUE; fi
        if [ -n "$test" ]; then i=TRUE; fi
        if [ ${#name} -gt 50 -o ${#type} -gt 50 ]; then i=TRUE; fi
        if ! grep -Fo "${tget}" <<<"${task[@]}"; then i=TRUE; fi
        if ! grep -Fo "${lang}" <<<"${langs[@]}"; then i=TRUE; fi

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
    "$DS_a/Dics/dicts/$3.$4.$5.$6" dlgcnfg "$@"
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
        sed 's/\./\n/g' <<<"${dict}"; fi
    done < <(ls "$enables/")
    
    while read -r dict; do
        if [ -n "${dict}" ]; then
        echo 'FALSE'
        if grep -E ".$lgt|.various" <<<"${dict}">/dev/null 2>&1; then
        sed 's/\./\n/g' <<<"${dict}"| \
        sed "3s|${sus}|<span color='#333333' background='#F2DADA'>${sus}<\/span>|"
        else echo "${dict}" |sed 's/\./\n/g'; fi
        fi
    done < <(ls "$disables/")
    }
   
    if [ ! -d "$DC_d" -o ! -d "$DC_a/dict/disables" ]; then
    mkdir -p "$enables"; mkdir -p "$disables"
    echo -e "$lgtl\n$v_dicts" > "$DC_a/dict/.dict"
    for r in "$DS_a/Dics/dicts"/*; do > "$disables/$(basename "$r")"; done; fi
    
    txtinf=" $(gettext "Please, select at least one resource for each task")"
    if [[ -n "${1}" ]]; then text="--text=$txtinf"; n=${1}
    else text="--center"; n=6; fi

    sel="$(dict_list ${n} | yad --list \
    --title="$(gettext "Dictionaries")" \
    --name=Idiomind --class=Idiomind "${text}" \
    --print-all --always-print-result --separator="|" \
    --dclick-action="$DS_a/Dics/cnfg.sh dclk" \
    --window-icon="$DS/images/icon.png" \
    --expand-column=2 --hide-column=3 \
    --search-column=4 --regex-search --tooltip-column=3 \
    --center --on-top \
    --width=650 --height=380 --borders=10 \
    --column="$(gettext "Enable")":CHK \
    --column="$(gettext "Resource")":TEXT \
    --column="$(gettext "Type")":TEXT \
    --column="$(gettext "Task")                                         ":TEXT \
    --column="$(gettext "Language")          ":TEXT \
    --button="$(gettext "Add")":2 \
    --button=OK:0 \
    --button="$(gettext "Cancel")":1)"
    ret=$?
    
        if [ $ret -eq 2 ]; then
        
                "$DS_a/Dics/cnfg.sh" add_dlg
        
        elif [ $ret -eq 0 ]; then

            while read -r dict; do
                name="$(cut -d "|" -f2 <<<"$dict")"
                type="$(cut -d "|" -f3 <<<"$dict")"
                tget="$(cut -d "|" -f4  <<<"$dict")"
                
                if grep 'FALSE' <<<"$dict"; then
                    if [ ! -f "$disables/$name.$type.$tget.$lgt" ]; then
                        [ -f "$enables/$name.$type.$tget.$lgt" ] \
                        && mv -f "$enables/$name.$type.$tget.$lgt" \
                        "$disables/$name.$type.$tget.$lgt"
                    fi
                    if [ ! -f "$disables/$name.$type.$tget.various" ]; then
                        [ -f "$enables/$name.$type.$tget.various" ] \
                        && mv -f "$enables/$name.$type.$tget.various" \
                        "$disables/$name.$type.$tget.various"
                    fi
                fi
                if grep 'TRUE'  <<<"$dict"; then
                    if [ ! -f "$enables/$name.$type.$tget.$lgt" ]; then
                        [ -f "$disables/$name.$type.$tget.$lgt" ] \
                        && mv -f "$disables/$name.$type.$tget.$lgt" \
                        "$enables/$name.$type.$tget.$lgt"
                    fi
                    if [ ! -f "$enables/$name.$type.$tget.various" ]; then
                        [ -f "$disables/$name.$type.$tget.various" ] \
                        && mv -f "$disables/$name.$type.$tget.various" \
                        "$enables/$name.$type.$tget.various"
                    fi
                fi
            done < <(sed 's/<[^>]*>//g' <<<"$sel")
        fi
    exit 1
    
} >/dev/null 2>&1


case "$1" in
    add_dlg)
    add_dlg "$@" ;;
    dclk)
    dclk "$@" ;;
    cpfile)
    cpfile "$@" ;;
    *)
    dlg "$@" ;;
esac

