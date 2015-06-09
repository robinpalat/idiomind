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
cfg3="$DC_tlt/3.cfg"
cfg4="$DC_tlt/4.cfg"
cfg1="$DC_tlt/1.cfg"
dir="$DC_tlt/practice"
touch "$dir/log.1" "$dir/log.2" "$dir/log.3"

lock() {
    
    yad --title="$(gettext "Practice Completed")" \
    --text="<b>$(gettext "Practice Completed")</b>\\n   $(< $1)\n " \
    --window-icon="$DS/images/icon.png" --on-top --skip-taskbar \
    --center --image="$DS/practice/icons_st/21.png" \
    --width=360 --height=120 --borders=5 \
    --button="   $(gettext "Restart")   ":0 \
    --button=Ok:2
}

get_list() {
    
    if [[ $nm = a ]] || [[ $nm = b ]] || [[ $nm = c ]]; then
    
        > "$dir/${nm}.0"
        if [[ `wc -l < "${cfg4}"` -gt 0 ]]; then
            while read item; do
            grep -Fxo "${item}" "${cfg3}" >> "$dir/${nm}.0"
            done < "${cfg1}"
        else
            cat "${cfg1}" > "$dir/${nm}.0"
        fi
        sed -i '/^$/d' "$dir/${nm}.0"
        
        if [[ $nm = b ]]; then
        
            if [[ ! -f ./b.srces ]]; then
            (
            echo "5"
            while read word; do
            fname="$(echo -n "$word" | md5sum | rev | cut -c 4- | rev)"
            file="$DM_tlt/words/$fname.mp3"
            echo "$(eyeD3 "$file" | grep -o -P "(?<=IWI2I0I).*(?=IWI2I0I)")" >> "$dir/b.srces"
            done < "$dir/${nm}.0"
            ) | yad --progress \
            --width 50 --height 35 --undecorated \
            --pulsate --auto-close \
            --skip-taskbar --center --no-buttons
            fi
        fi
    
    elif [[ $nm = d ]]; then
    
        if [[ `wc -l < "${cfg3}"` -gt 0 ]]; then
            grep -Fxvf "${cfg3}" "${cfg1}" > "$DT/slist"
            tac "$DT/slist" > "$dir/${nm}.0"
            rm -f "$DT/slist"
        else
            tac "${cfg1}" > "$dir/${nm}.0"
        fi
    
    elif [[ $nm = e ]]; then
    
        > "$DT/images"
        if [[ `wc -l < "${cfg4}"` -gt 0 ]]; then
            while read item; do
            grep -Fxo "${item}" "${cfg3}" >> "$DT/images"
            done < "${cfg1}"
        else
            cat "${cfg1}" > "$DT/images"
        fi
        sed -i '/^$/d' "$DT/images"
        
        > "$dir/${nm}.0"
        while read itm; do
            fname="$(echo -n "$itm" | md5sum | rev | cut -c 4- | rev)"
            if [ -f "$DM_tlt/words/images/$fname.jpg" ]; then
            echo "$itm" >>  "$dir/${nm}.0"; fi
        done < "$DT/images"
        
        sed -i '/^$/d'  "$dir/${nm}.0"
        [ -f "$DT/images" ] && rm -f "$DT/images"
    
    fi
}

starting() {
    
    yad --title=$(gettext "Practice ") \
    --text="$1" --image=info \
    --window-icon="$DS/images/icon.png" --skip-taskbar --center --on-top \
    --width=360 --height=120 --borders=5 \
    --button=Ok:1
    "$strt" & exit 1
}

practice() {

    cd "$DC_tlt/practice"
    nm="${1}"

    if [[ -f "$dir/${nm}.lock" ]]; then
    
        lock  "$dir/${nm}.lock"
        ret=$(echo "$?")
        if [[ $ret -eq 0 ]]; then
        "$cls" restart ${nm} & exit
        else
        "$strt" & exit
        fi
    fi

    if [[ -f "$dir/${nm}.0" ]] && [[ -f "$dir/${nm}.1" ]]; then
    
        echo "w9.$(tr -s '\n' '|' <  "$dir/${nm}.1").w9" >> "$log"
        grep -Fxvf  "$dir/${nm}.1"  "$dir/${nm}.0" >  "$dir/${nm}.tmp"
        echo " practice --restarting session"
        
    else
        get_list && cp -f  "$dir/${nm}.0"  "$dir/${nm}.tmp"
        
        [[ `wc -l <  "$dir/${nm}.0"` -lt 2 ]] && starting "$(gettext "Not enough words to start.")"
        echo " practice --new session"
    fi
    
    [  "$dir/${nm}.2" ] && rm  "$dir/${nm}.2"; [ "$dir/${nm}.3" ] && rm  "$dir/${nm}.3"
    "$DS/practice/p_$nm.sh"
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

