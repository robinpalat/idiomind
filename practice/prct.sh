#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public cfg1cense as published by
#  the Free Software Foundation; either version 2 of the cfg1cense, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public cfg1cense for more details.
#  
#  You should have received a copy of the GNU General Public cfg1cense
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  

[[ -z "$DM" ]] && source /usr/share/idiomind/ifs/c.conf
strt="$DS/practice/strt.sh"
cls="$DS/practice/cls.sh"
log="$DC_s/8.cfg"
cfg0="$DC_tlt/0.cfg"
cfg1="$DC_tlt/1.cfg"
cfg3="$DC_tlt/3.cfg"
cfg4="$DC_tlt/4.cfg"
directory="$DC_tlt/practice"
touch "$directory/log.1" "$directory/log.2" "$directory/log.3"

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
    
    if [[ $ttest = a || $ttest = b || $ttest = c ]]; then
    
        > "$directory/${ttest}.0"
        if [[ `wc -l < "${cfg4}"` -gt 0 ]]; then

            grep -Fvx -f "${cfg4}" "${cfg1}" > "$DT/${ttest}.0"
            tac "$DT/${ttest}.0" |sed '/^$/d' > "$directory/${ttest}.0"
            rm -f "$DT/${ttest}.0"
        else
            tac "${cfg1}" |sed '/^$/d' > "$directory/${ttest}.0"
        fi
        
        if [[ $ttest = b ]]; then
        
            if [ ! -f "$directory/b.srces" ]; then
            (
            echo "5"
            while read word; do
            
                item="$(grep -F -m 1 "trgt={${word}}" "${cfg0}" |sed 's/},/}\n/g')"
                echo "$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")" >> "$directory/b.srces"
            
            done < "$directory/${ttest}.0"
            ) | yad --progress \
            --width 50 --height 35 --undecorated \
            --pulsate --auto-close \
            --skip-taskbar --center --no-buttons
            fi
        fi
    
    elif [[ $ttest = d ]]; then
    
        if [[ `wc -l < "${cfg3}"` -gt 0 ]]; then
            grep -Fxvf "${cfg3}" "${cfg1}" > "$DT/slist"
            tac "$DT/slist" |sed '/^$/d' > "$directory/${ttest}.0"
            rm -f "$DT/slist"
        else
            tac "${cfg1}" |sed '/^$/d' > "$directory/${ttest}.0"
        fi
    
    elif [[ $ttest = e ]]; then
    
        > "$DT/images"
        if [[ `wc -l < "${cfg4}"` -gt 0 ]]; then
        
            grep -Fxvf "${cfg4}" "${cfg1}" > "$DT/images"
        else
            tac "${cfg1}" > "$DT/images"
        fi

        > "$directory/${ttest}.0"
        
        (
        echo "5"
        while read itm; do
    
            item="$(grep -F -m 1 "trgt={${itm}}" "${cfg0}" |sed 's/},/}\n/g')"
            fname="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${item}")"
            if [ -f "$DM_tlt/images/$fname.jpg" ]; then
                echo "$itm" >> "$directory/${ttest}.0"; fi

        done < "$DT/images"
        ) | yad --progress \
        --width 50 --height 35 --undecorated \
        --pulsate --auto-close \
        --skip-taskbar --center --no-buttons
        
        sed -i '/^$/d' "$directory/${ttest}.0"
        [ -f "$DT/images" ] && rm -f "$DT/images"
    
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

    if [ -f "$directory/${ttest}.lock" ]; then
    
        lock  "$directory/${ttest}.lock"
        ret=$(echo "$?")
        if [[ $ret -eq 0 ]]; then
        "$cls" restart ${ttest} & exit
        else
        "$strt" & exit
        fi
    fi

    if [ -f "$directory/${ttest}.0" ] && [ -f "$directory/${ttest}.1" ]; then
    
        echo "w9.$(tr -s '\n' '|' < "$directory/${ttest}.1").w9" >> "$log"
        grep -Fxvf  "$directory/${ttest}.1" "$directory/${ttest}.0" > "$directory/${ttest}.tmp"
        echo " practice --restarting session"
        
    else
        get_list
        cp -f "$directory/${ttest}.0" "$directory/${ttest}.tmp"
        
        if [[ `wc -l < "$directory/${ttest}.0"` -lt 2 ]]; then \
        starting "$(gettext "Not enough words to start")"
        echo " practice --new session"; fi
    fi
    
    [ "$directory/${ttest}.2" ] && rm "$directory/${ttest}.2"
    [ "$directory/${ttest}.3" ] && rm "$directory/${ttest}.3"
    "$DS/practice/p_$ttest.sh"
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

