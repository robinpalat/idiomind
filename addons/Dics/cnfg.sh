#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/trans/$lgs/others.conf
source $DS/ifs/mods/cmns.sh
dir="$DC/addons/dict"
enables="$DC/addons/dict/enables"
disables="$DC/addons/dict/disables"

new="#!/bin/bash
# Argument 1: \"\$1\" = \"word\"
# 
#
name=\"\"
lang=\"\""

function test_() {
    
    [[ $lang = en ]] && test=house
    [[ $lang = fr ]] && test=maison
    [[ $lang = de ]] && test=Haus
    [[ $lang = 'zh-cn' ]] && test=房子
    [[ $lang = it ]] && test=casa
    [[ $lang = ja ]] && test=家
    [[ $lang = pt ]] && test=casa
    [[ $lang = es ]] && test=casa
    [[ $lang = vi ]] && test=nhà
    [[ $lang = ru ]] && test=дом
    [[ $lang = auto ]] && test=house
}

function dialog_edit() {
    
    yad --text-info --width=420 --height=450 --on-top --wrap \
    --buttons-layout=end --center --window-icon=idiomind --margins=4 --print-all \
    --borders=0 --skip-taskbar --editable --fontname=monospace --always-print-result --filename="$script" \
    --button=Cancel:1 --button=Delete:2 --button=Test:4 --button=Save:5 --title="script" > $DT/script.sh
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
        name=""
        lang=""
        dialog_edit
        ret=$(echo $?)
        
    if [ $ret -eq 5 ]; then
        
        name=$(cat "$DT/script.sh" | grep -o -P '(?<=name=").*(?=")')
        lang=$(cat "$DT/script.sh" | grep -o -P '(?<=lang=").*(?=")')
        [ -z "$name" ] && name="untitled"
        [ -z "$lang" ] && lang="__"
        mv -f "$DT/script.sh" "$disables/$name.$lang"
        $DS_a/Dics/cnfg.sh
        
    elif [ $ret -eq 4 ]; then
        
        internet
        test_
        cd  $DT; sh $DT/script.sh $test
        [ -f $DT/$test.mp3 ] && play $DT/$test.mp3 || msg Fail info
        rm -f $DT/$test.mp3
        mv -f $DT/script.sh "$DT/new.sh"
        $DS_a/Dics/cnfg.sh edit_dlg 2
    fi


elif [ "$1" = dlk_dlg ]; then

    [ "$2" = TRUE ] && stts=enables
    [ "$2" = FALSE ] && stts=disables
    script="$dir/$stts/$3.$4"
    name="$3"
    lang="$4"
    dialog_edit
    ret=$(echo $?)
    
    if [ $ret -eq 2 ]; then
    
        msg_2 " Confirm removal\n $name.$lang\n" dialog-question yes no
        rt=$(echo $?)
        [ $rt -eq 0 ] && rm "$script"; exit
    
    elif [ $ret -eq 5 ]; then
    
        name=$(grep -F "_name=" "$script" | grep -o -P '(?<=name=").*(?=")')
        lang=$(grep -F "_lang=" "$script" | grep -o -P '(?<=lang=").*(?=")')
        [ -z "$name" ] && name="$3"
        [ -z "$lang" ] && lang="$4"
        mv -f $DT/script.sh "$dir/$stts/$name.$lang"
        
    elif [ $ret -eq 4 ]; then
    
        internet
        test_
        cd  $DT; sh $DT/script.sh $test
        [ -f $DT/$test.mp3 ] && play $DT/$test.mp3 || msg Fail info
        rm -f $DT/$test.mp3
        mv -f $DT/script.sh "$dir/$stts/$name.$lang"
        $DS_a/Dics/cnfg.sh dlk_dlg "$2" "$name" "$lang"
    fi
    
    
elif [ -z "$1" ]; then

    if [ ! -d "$DC_a/dict/" ]; then
        mkdir -p "$enables"
        mkdir -p "$disables"
        cp -f $DS/addons/Dics/disables/* "$disables/"
    fi
    
    if [ "$2" = f ]; then
        tex="<small>$3\n</small>"
        align="--text-align=left"
    else
        tex=" "
        align="--text-align=right"
    fi
    
    sel="$(dict_list | yad --list --title="Idiomind - $(gettext "Dictionaries")" \
    --center --expand-column=2 --text="$tex" $align \
    --width=420 --height=300 --skip-taskbar --separator=" " \
    --borders=5 --button="$(gettext "Add")":2 --print-all --button=Ok:0 \
    --column=" ":CHK --column="$(gettext "Availables")":TEXT \
    --column="$(gettext "Languages")":TEXT --window-icon=idiomind \
    --buttons-layout=edge --always-print-result \
    --dclick-action='/usr/share/idiomind/addons/Dics/cnfg.sh dlk_dlg')"
    ret=$?
    
        if [ "$ret" -eq 2 ]; then
        
                $DS_a/Dics/cnfg.sh edit_dlg
        
        elif [ "$ret" -eq 0 ]; then
        
            n=1
            while [ $n -le "$(echo "$sel" | wc -l)" ]; do
            
                dict=$(echo "$sel" | sed -n "$n"p)
                d=$(echo "$dict" | awk '{print ($2)}')
                
                if echo "$dict" | grep FALSE; then
                    if [ ! -f "$disables/$d.$lgt" ]; then
                        [ -f "$enables/$d.$lgt" ] \
                        && mv -f "$enables/$d.$lgt" "$disables/$d.$lgt"
                    fi
                    if [ ! -f "$disables/$d.auto" ]; then
                        [ -f "$enables/$d.auto" ] \
                        && mv -f "$enables/$d.auto" "$disables/$d.auto"
                    fi
                fi
                if echo "$dict" | grep TRUE; then
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
            #[ -f *.$lgt ] && ls -d -1 $PWD/*.$lgt > "$dir/.dicts"
            #[ -f *.auto ] && ls -d -1 $PWD/*.auto >> "$dir/.dicts"
            ls -d -1 $PWD/*.$lgt > "$dir/.dicts"
            ls -d -1 $PWD/*.auto >> "$dir/.dicts"; 
        
        fi
        
    exit 1
fi
