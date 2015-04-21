#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
dir="$DC/addons/dict"
enables="$DC/addons/dict/enables"
disables="$DC/addons/dict/disables"
lgt=$(lnglss "$lgtl")
lgs=$(lnglss "$lgsl")
new="#!/bin/bash
# argument \"$1\" = \"word\"
# eg.languages: en
#
Name=\"\"
Language=\"\""

function test_() {
    
    [[ $Language = en ]] && test=test
    [[ $Language = fr ]] && test=test
    [[ $Language = de ]] && test=test
    [[ $Language = 'zh-cn' ]] && test=测试
    [[ $Language = it ]] && test=test
    [[ $Language = ja ]] && test=テスト
    [[ $Language = pt ]] && test=teste
    [[ $Language = es ]] && test=test
    [[ $Language = vi ]] && test=thử
    [[ $Language = ru ]] && test=тест
    [[ $Language = auto ]] && test=test
}

function dialog_edit() {
    
    yad --text-info --title="$Name" \
    --name=Idiomind --class=Idiomind \
    --filename="$script" --print-all --always-print-result \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --buttons-layout=end --center --on-top \
    --width=480 --height=350 --borders=0 \
    --editable --fontname=monospace --margins=4 --wrap \
    --button=Cancel:1 \
    --button=Delete:2 \
    --button=Test:4 \
    --button=Save:5 > "$DT/script.sh"
}

function dict_list() {

    cd "$enables/"
    find . -not -name "*.$lgt" -and -not -name "*.auto" -type f \
    -exec mv --target-directory="$disables/" {} +
    
    while read -r dict; do
        if [ -n "$dict" ]; then
        echo 'TRUE'
        echo "$dict" | sed 's/\./\n/g'; fi
    done <<<"$(ls "$enables/")"
    
    while read -r dict; do
        if [ -n "$dict" ]; then
        echo 'FALSE'
        echo "$dict" | sed 's/\./\n/g'; fi
    done <<<"$(ls "$disables/")"
}

if [ "$1" = edit_dlg ]; then

        if [[ "$2" = 2 ]]; then 
        script="$DT/new.sh"; else
        printf "$new" > "$DT/new.sh"
        script="$DT/new.sh"; fi
        Name="untitled"
        Language=""
        dialog_edit
        ret=$(echo $?)
         
    if [[ $ret -eq 5 ]]; then
        
        Name=$(grep -o -P '(?<=Name=").*(?=")' "$DT/script.sh" | sed 's/\.//g')
        Language=$(grep -o -P '(?<=Language=").*(?=")' "$DT/script.sh" | sed 's/\.//g')
        
        if ([ -n "$Name" ] && [ -n "$Language" ]); then
        mv -f "$DT/script.sh" "$disables/$Name.$Language"
        fi
        "$DS_a/Dics/cnfg.sh"
        
    elif [[ $ret -eq 4 ]]; then
        
        internet; test_
        cd  "$DT"; sh "$DT/script.sh" "$test"
        [ -f "$DT/$test.mp3" ] && play "$DT/$test.mp3" || msg Fail info
        rm -f "$DT/$test.mp3"
        mv -f "$DT/script.sh" "$DT/new.sh"
        "$DS_a/Dics/cnfg.sh" edit_dlg 2
    else
        "$DS_a/Dics/cnfg.sh"
    fi

elif [ "$1" = dlk_dlg ]; then

    [ "$2" = TRUE ] && stts=enables
    [ "$2" = FALSE ] && stts=disables
    script="$dir/$stts/$3.$4"
    Name="$3"
    Language="$4"
    dialog_edit
    ret=$(echo $?)
    
    if [[ $ret -eq 2 ]]; then
    
        msg_2 "$(gettext "Confirm")\n" dialog-question \
        "$(gettext "Delete")" "$(gettext "Cancel")" "$(gettext "Confirm")"
        rt=$(echo $?)
        [[ $rt -eq 0 ]] && rm "$script"; exit
    
    elif [[ $ret -eq 5 ]]; then
    
        Name=$(grep -F "Name=" "$script" | grep -o -P '(?<=Name=").*(?=")' | sed 's/\.//g')
        Language=$(grep -F "Language=" "$script" | grep -o -P '(?<=Language=").*(?=")' | sed 's/\.//g')
        [ -z "$Name" ] && Name="$3"
        [ -z "$Language" ] && Language="$4"
        mv -f "$DT/script.sh" "$dir/$stts/$Name.$Language"
        
    elif [[ $ret -eq 4 ]]; then
    
        internet; test_
        cd  "$DT"; sh "$DT/script.sh" "$test"
        [ -f "$DT/$test.mp3" ] && play "$DT/$test.mp3" || msg Fail info
        rm -f "$DT/$test.mp3"
        mv -f "$DT/script.sh" "$dir/$stts/$Name.$Language"
        "$DS_a/Dics/cnfg.sh" dlk_dlg "$2" "$Name" "$Language"
    fi
    
elif [ -z "$1" ]; then

    if [ ! -d "$DC_a/dict/" ]; then
        mkdir -p "$enables"
        mkdir -p "$disables"
        cp -f "$DS/addons/Dics/disables"/* "$disables/"
    fi
    
    if [ "$2" = f ]; then
    tex="--text=$3\n"; else
    tex="--center"; fi
    
    sel="$(dict_list | yad --list --title="$(gettext "Dictionaries")" \
    --name=Idiomind --class=Idiomind "$tex" \
    --print-all --always-print-result --separator=" " \
    --dclick-action='/usr/share/idiomind/addons/Dics/cnfg.sh dlk_dlg' \
    --window-icon="$DS/images/icon.png" \
    --expand-column=2 --skip-taskbar --center \
    --width=480 --height=350 --borders=10 \
    --column=" ":CHK \
    --column="$(gettext "Available dictionaries")":TEXT \
    --column=" ":TEXT \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Add")":2 \
    --button=OK:0)"
    
    ret=$?
    
        if [[ $ret -eq 2 ]]; then
        
                "$DS_a/Dics/cnfg.sh" edit_dlg
        
        elif [[ $ret -eq 0 ]]; then
        
            n=1
            while [ $n -le "$(echo "$sel" | wc -l)" ]; do
            
                dict=$(echo "$sel" | sed -n "$n"p)
                d=$(echo "$dict" | awk '{print ($2)}')
                
                if echo "$dict" | grep 'FALSE'; then
                    if [ ! -f "$disables/$d.$lgt" ]; then
                        [ -f "$enables/$d.$lgt" ] \
                        && mv -f "$enables/$d.$lgt" "$disables/$d.$lgt"
                    fi
                    if [ ! -f "$disables/$d.auto" ]; then
                        [ -f "$enables/$d.auto" ] \
                        && mv -f "$enables/$d.auto" "$disables/$d.auto"
                    fi
                fi
                if echo "$dict" | grep 'TRUE'; then
                    if [ ! -f "$enables/$d.$lgt" ]; then
                        [ -f "$disables/$d.$lgt" ] \
                        && mv -f "$disables/$d.$lgt" "$enables/$d.$lgt"
                    fi
                    if [ ! -f "$enables/$d.auto" ]; then
                        [ -f "$disables/$d.auto" ] \
                        && mv -f "$disables/$d.auto" "$enables/$d.auto"
                    fi
                fi
                let n++
            done
        fi
        
    rm -f "$DT/new.sh" "$DT/script.sh"
    exit 1
fi
