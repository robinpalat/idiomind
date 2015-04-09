#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
dir="$DC/addons/dict"
enables="$DC/addons/dict/enables"
disables="$DC/addons/dict/disables"
lgt=$(lnglss $lgtl)
lgs=$(lnglss $lgsl)
new="#!/bin/bash
# argument \"\$1\" = \"word\"
# 
#
_NAME=\"\"
_LANG=\"\""

function test_() {
    
    [[ $_LANG = en ]] && test=test
    [[ $_LANG = fr ]] && test=test
    [[ $_LANG = de ]] && test=test
    [[ $_LANG = 'zh-cn' ]] && test=测试
    [[ $_LANG = it ]] && test=test
    [[ $_LANG = ja ]] && test=テスト
    [[ $_LANG = pt ]] && test=teste
    [[ $_LANG = es ]] && test=test
    [[ $_LANG = vi ]] && test=thử
    [[ $_LANG = ru ]] && test=тест
    [[ $_LANG = auto ]] && test=test
}

function dialog_edit() {
    
    yad --text-info --title="$_NAME" \
    --name=Idiomind --class=Idiomind \
    --filename="$script" --print-all --always-print-result \
    --window-icon="idiomind" --skip-taskbar --buttons-layout=end --center --on-top \
    --width=480 --height=350 --borders=0 \
    --editable --fontname=monospace --margins=4 --wrap \
    --button=Cancel:1 \
    --button=Delete:2 \
    --button=Test:4 \
    --button=Save:5 > $DT/script.sh
}

function dict_list() {

    cd "$enables/"
    find . -not -name "*.$lgt" -and -not -name "*.auto" -type f \
    -exec mv --target-directory="$disables/" {} +
    
    ls * > .dicts
    while read dict; do
        echo 'TRUE'
        echo "$dict" | sed 's/\./\n/g'
    done < .dicts
    
    cd "$disables/"; ls * > .dicts
    while read dict; do
        echo 'FALSE'
        echo "$dict" | sed 's/\./\n/g'
    done < .dicts
}

if [ "$1" = edit_dlg ]; then

        if [[ "$2" = 2 ]]; then 
        script="$DT/new.sh"; else
        printf "$new" > "$DT/new.sh"
        script="$DT/new.sh"; fi
        _NAME="untitled"
        _LANG=""
        dialog_edit
        ret=$(echo $?)
         
    if [ $ret -eq 5 ]; then
        
        _NAME=$(cat "$DT/script.sh" | grep -o -P '(?<=_NAME=").*(?=")')
        _LANG=$(cat "$DT/script.sh" | grep -o -P '(?<=_LANG=").*(?=")')
        
        if ([ -n "$_NAME" ] && [ -n "$_LANG" ]); then
        mv -f "$DT/script.sh" "$disables/$_NAME.$_LANG"
        fi
        "$DS_a/Dics/cnfg.sh"
        
    elif [ $ret -eq 4 ]; then
        
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
    _NAME="$3"
    _LANG="$4"
    dialog_edit
    ret=$(echo $?)
    
    if [ $ret -eq 2 ]; then
    
        msg_2 " $(gettext "Confirm")\n" dialog-question yes no
        rt=$(echo $?)
        [ $rt -eq 0 ] && rm "$script"; exit
    
    elif [ $ret -eq 5 ]; then
    
        _NAME=$(grep -F "_NAME=" "$script" | grep -o -P '(?<=_NAME=").*(?=")')
        _LANG=$(grep -F "_LANG=" "$script" | grep -o -P '(?<=_LANG=").*(?=")')
        [ -z "$_NAME" ] && _NAME="$3"
        [ -z "$_LANG" ] && _LANG="$4"
        mv -f "$DT/script.sh" "$dir/$stts/$_NAME.$_LANG"
        
    elif [ $ret -eq 4 ]; then
    
        internet; test_
        cd  "$DT"; sh "$DT/script.sh" "$test"
        [ -f "$DT/$test.mp3" ] && play "$DT/$test.mp3" || msg Fail info
        rm -f "$DT/$test.mp3"
        mv -f "$DT/script.sh" "$dir/$stts/$_NAME.$_LANG"
        "$DS_a/Dics/cnfg.sh" dlk_dlg "$2" "$_NAME" "$_LANG"
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
    --window-icon="idiomind" --expand-column=2 --skip-taskbar --center \
    --width=480 --height=350 --borders=15 \
    --column=" ":CHK \
    --column="$(gettext "Available dictionaries")":TEXT \
    --column=" ":TEXT \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Add")":2 \
    --button=OK:0)"
    
    ret=$?
    
        if [ "$ret" -eq 2 ]; then
        
                "$DS_a/Dics/cnfg.sh" edit_dlg
        
        elif [ "$ret" -eq 0 ]; then
        
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
            
            cd "$enables/"
            ls -d -1 "$PWD"/*.$lgt > "$dir/.dicts"
            ls -d -1 "$PWD"/*.auto >> "$dir/.dicts"; 
        
        fi
        
    rm -f "$DT/new.sh" "$DT/script.sh"
    exit 1
fi
