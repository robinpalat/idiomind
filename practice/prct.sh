#!/bin/bash
# -*- ENCODING: UTF-8 -*-

strt="$DS/practice/strt.sh"
cls="$DS/practice/cls.sh"
log="$DC_s/log"
cfg0="$DC_tlt/0.cfg"
cfg1="$DC_tlt/1.cfg"
cfg3="$DC_tlt/3.cfg"
cfg4="$DC_tlt/4.cfg"
dir="$DC_tlt/practice"
touch "$dir/log1" "$dir/log2" "$dir/log3"

lock() {
    
    yad --title="$(gettext "Practice Completed")" \
    --text="<b>$(gettext "Practice Completed")</b>\\n   $(< "$1")\n " \
    --window-icon="$DS/images/icon.png" --on-top --skip-taskbar \
    --center --image="$DS/practice/images/21.png" \
    --width=360 --height=120 --borders=5 \
    --button="   $(gettext "Restart")   ":0 \
    --button=Ok:2
}

get_list() {
    
    if [ $ttest = a -o $ttest = b -o $ttest = c ]; then
    
        > "$dir/${ttest}.0"
        if [[ `wc -l < "${cfg4}"` -gt 0 ]]; then

            grep -Fvx -f "${cfg4}" "${cfg1}" > "$DT/${ttest}.0"
            tac "$DT/${ttest}.0" |sed '/^$/d' > "$dir/${ttest}.0"
            rm -f "$DT/${ttest}.0"
        else
            tac "${cfg1}" |sed '/^$/d' > "$dir/${ttest}.0"
        fi
        
        if [ $ttest = b ]; then
        
            if [ ! -f "$dir/b.srces" ]; then
            
            ( echo "5"
            while read word; do
            
                item="$(grep -F -m 1 "trgt={${word}}" "${cfg0}" |sed 's/},/}\n/g')"
                echo "$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")" >> "$dir/b.srces"
            
            done < "$dir/${ttest}.0" ) | yad --progress \
            --width 50 --height 35 --undecorated \
            --pulsate --auto-close \
            --skip-taskbar --center --no-buttons
            fi
        fi
        
    elif [ $ttest = d ]; then
    
        > "$DT/images"
        if [[ `wc -l < "${cfg4}"` -gt 0 ]]; then
        
            grep -Fxvf "${cfg4}" "${cfg1}" > "$DT/images"
        else
            tac "${cfg1}" > "$DT/images"
        fi
        > "$dir/${ttest}.0"
        
        ( echo "5"
        while read -r itm; do
        if [ -f "$DM_tls/images/${itm,,}-0.jpg" ]; then
        echo "${itm}" >> "$dir/${ttest}.0"; fi
        done < "$DT/images" ) | yad --progress \
        --width 50 --height 35 --undecorated \
        --pulsate --auto-close \
        --skip-taskbar --center --no-buttons
        
        sed -i '/^$/d' "$dir/${ttest}.0"
        [ -f "$DT/images" ] && rm -f "$DT/images"
    
    elif [ $ttest = e ]; then
    
        if [[ `wc -l < "${cfg3}"` -gt 0 ]]; then
            grep -Fxvf "${cfg3}" "${cfg1}" > "$DT/slist"
            tac "$DT/slist" |sed '/^$/d' > "$dir/${ttest}.0"
            rm -f "$DT/slist"
        else
            tac "${cfg1}" |sed '/^$/d' > "$dir/${ttest}.0"
        fi
    fi
}

starting() {
    
    yad --title="$1" \
    --text=" $1.\n" --image=info \
    --window-icon="$DS/images/icon.png" --skip-taskbar --center --on-top \
    --width=360 --height=120 --borders=5 \
    --button=Ok:1
    "$strt" & exit 1
}

practice() {

    cd "$DC_tlt/practice"
    ttest="${1}"

    if [ -f "$dir/${ttest}.lock" ]; then
    
        lock "$dir/${ttest}.lock"
        if [ $? -eq 0 ]; then
        "$cls" restart ${ttest} & exit
        else
        "$strt" & exit
        fi
    fi

    if [ -f "$dir/${ttest}.0" -a -f "$dir/${ttest}.1" ]; then
    
        grep -Fxvf  "$dir/${ttest}.1" "$dir/${ttest}.0" > "$dir/${ttest}.tmp"
        if [[ "$(egrep -cv '#|^$' < "$dir/${ttest}.tmp")" = 0 ]]; then
        lock "$dir/${ttest}.lock" & exit; fi
        echo " practice --restarting session"
        
    else
        get_list
        cp -f "$dir/${ttest}.0" "$dir/${ttest}.tmp"
        
        if [[ `wc -l < "$dir/${ttest}.0"` -lt 2 ]]; then \
        starting "$(gettext "Not enough items to start")"
        echo " practice --new session"; fi
    fi
    
    [ -f "$dir/${ttest}.2" ] && rm "$dir/${ttest}.2"
    [ -f "$dir/${ttest}.3" ] && rm "$dir/${ttest}.3"
    "$DS/practice/p_${ttest}.sh"
}

case "$1" in
    1)
    practice a ;;
    2)
    practice b ;;
    3)
    practice c ;;
    4)
    practice d ;;
    5)
    practice e ;;
esac

