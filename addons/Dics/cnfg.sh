#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
dir="$DC/addons/dict"
enables="$DC/addons/dict/enables"
disables="$DC/addons/dict/disables"
lgt=$(lnglss "$lgtl")
lgs=$(lnglss "$lgsl")

dialog_edit() {
    
    yad --text-info --title="$Name" \
    --name=Idiomind --class=Idiomind \
    --filename="$script" --print-all --always-print-result \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --buttons-layout=end --center --on-top \
    --width=490 --height=360 --borders=0 \
    --editable --fontname=monospace --margins=4 --wrap \
    --button=Cancel:1 \
    --button=Save:5 > "$DT/script.sh"
}

dict_list() {

    cd "$enables/"
    find . -not -name "*.$lgt" -and -not -name "*.various" -type f \
    -exec mv --target-directory="$disables/" {} +
    
    while read -r dict; do
        if [ -n "$dict" ]; then
        echo 'TRUE'
        echo "$dict" | sed 's/\./\n/g'; fi
    done < <(ls "$enables/")
    
    while read -r dict; do
        if [ -n "$dict" ]; then
        echo 'FALSE'
        echo "$dict" | sed 's/\./\n/g'; fi
    done < <(ls "$disables/")
    
}

if [ "$1" = add_dlg ]; then

        if [[ "$2" = 2 ]]; then 
        script="$DT/new.sh"; else
        printf "$new_script" > "$DT/new.sh"
        script="$DT/new.sh"; fi
        Name="New script"
        Language=""
        dialog_edit
         
    if [ $? -eq 5 ]; then
        
        if [ -z "$(< "$DT/script.sh")" ]; then
        
        rm "$DT/script.sh"
        "$DS_a/Dics/cnfg.sh" & exit
            
        else
        Name=$(grep -o -P '(?<=Name=").*(?=")' "$DT/script.sh" | sed 's/\.//g')
        Language=$(grep -o -P '(?<=Language=").*(?=")' "$DT/script.sh" | sed 's/\.//g')
            
            if [ -n "$Name" ] && [ -n "$Language" ]; then
            mv -f "$DT/script.sh" "$disables/$Name.$Language"
            fi
            
        "$DS_a/Dics/cnfg.sh"
        fi
        
    else
        "$DS_a/Dics/cnfg.sh"
    fi

elif [ "$1" = edit_dlg ]; then

    [ "$2" = TRUE ] && stts=enables
    [ "$2" = FALSE ] && stts=disables
    script="$dir/$stts/$3.$4.$5"
    Name="$3"
    Type="$4"
    Language="$5"
    dialog_edit

    if [ $? -eq 5 ]; then
    
        Name=$(grep -F "Name=" "$script" | grep -o -P '(?<=Name=").*(?=")' | sed 's/\.//g')
        Language=$(grep -F "Language=" "$script" | grep -o -P '(?<=Language=").*(?=")' | sed 's/\.//g')
        [ -z "$Name" ] && Name="$3"
        [ -z "$Language" ] && Language="$4"
            
        if [ -z "$(< "$DT/script.sh")" ]; then
        rm "$DT/script.sh" "$dir/$stts/$Name.$Language" & exit
        else
        mv -f "$DT/script.sh" "$dir/$stts/$Name.$Language" & exit
        fi
        
    fi
    
elif [ -z "${1}" ]; then

    if [ ! -d "$DC_d" -o ! -d "$DC_a/dict/disables" ]; then
    mkdir -p "$enables"; mkdir -p "$disables"
    echo -e "$lgtl\n$v_dicts" > "$DC_a/dict/.dict"
    cp -f "$DS/addons/Dics/disables"/* "$disables/"; fi
    
    [[ "${2}" = f ]] && tex="--text=$3" || tex="--center"
    sel="$(dict_list | yad --list --title="$(gettext "Dictionaries")" \
    --name=Idiomind --class=Idiomind "$tex" \
    --print-all --always-print-result --separator="|" \
    --dclick-action='_' \
    --window-icon="$DS/images/icon.png" \
    --expand-column=2 --search-column=3 --hide-column=3 \
    --tooltip-column=3 --regex-search \
    --center --on-top \
    --width=600 --height=360 --borders=10 \
    --column=" ":CHK \
    --column="$(gettext "Available resources")":TEXT \
    --column="$(gettext "Type")":TEXT \
    --column="$(gettext "Task")                                ":TEXT \
    --column="$(gettext "Language")":TEXT \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Add")":2 \
    --button=OK:0)"
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
                        && mv -f "$enables/$name.$type.$tget.$lgt" "$disables/$name.$type.$tget.$lgt"
                    fi
                    if [ ! -f "$disables/$name.$type.$tget.various" ]; then
                        [ -f "$enables/$name.$type.$tget.various" ] \
                        && mv -f "$enables/$name.$type.$tget.various" "$disables/$name.$type.$tget.various"
                    fi
                fi
                if grep 'TRUE'  <<<"$dict"; then
                    if [ ! -f "$enables/$name.$type.$tget.$lgt" ]; then
                        [ -f "$disables/$name.$type.$tget.$lgt" ] \
                        && mv -f "$disables/$name.$type.$tget.$lgt" "$enables/$name.$type.$tget.$lgt"
                    fi
                    if [ ! -f "$enables/$name.$type.$tget.various" ]; then
                        [ -f "$disables/$name.$type.$tget.various" ] \
                        && mv -f "$disables/$name.$type.$tget.various" "$enables/$name.$type.$tget.various"
                    fi
                fi

            done <<<"$sel"
        fi
        
    rm -f "$DT/new.sh" "$DT/script.sh"
    exit 1
fi
