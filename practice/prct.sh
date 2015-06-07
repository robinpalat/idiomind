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

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
strt="$DS/practice/strt.sh"
cls="$DS/practice/cls.sh"
log="$DC_s/8.cfg"
DF="$DS/practice/df.sh"
DLW="$DS/practice/dlw.sh"
DMC="$DS/practice/dmc.sh"
DLS="$DS/practice/dls.sh"
DI="$DS/practice/di.sh"
cfg3="$DC_tlt/3.cfg"
cfg4="$DC_tlt/4.cfg"
cfg1="$DC_tlt/1.cfg"
cd "$DC_tlt/practice"

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
    
    > "$1"
    if [ "$(wc -l < "${cfg4}")" -gt 0 ]; then
        while read item; do
        grep -Fxo "${item}" "${cfg3}" >> "$1"
        done < "${cfg1}"
    else
        cat "${cfg1}" > "$1"
    fi
    sed -i '/^$/d' "$1"
}

get_list_images() {

    > "$DT/images"
    if [ "$(wc -l < "$cfg4")" -gt 0 ]; then
        while read item; do
        grep -Fxo "${item}" "${cfg3}" >> "$DT/images"
        done < "${cfg1}"
    else
        cat "$cfg1" > "$DT/images"
    fi
    sed -i '/^$/d' "$DT/images"
    > "$1"
    
    while read itm; do
        fname="$(echo -n "$itm" | md5sum | rev | cut -c 4- | rev)"
        if [ -f "$DM_tlt/words/images/$fname.jpg" ]; then
        echo "$itm" >> "$1"; fi
    done < "$DT/images"
    [ -f "$DT/images" ] && rm -f "$DT/images"
}

get_list_mchoice() {

    (
    echo "5"
    while read word; do
        fname="$(echo -n "$word" | md5sum | rev | cut -c 4- | rev)"
        file="$DM_tlt/words/$fname.mp3"
        echo "$(eyeD3 "$file" | grep -o -P "(?<=IWI2I0I).*(?=IWI2I0I)")" >> b.srces
    done < ./b.0
    ) | yad --progress \
    --width 50 --height 35 --undecorated \
    --pulsate --auto-close \
    --skip-taskbar --center --no-buttons
}

get_list_sentences() {
    
    if [ "$(wc -l < "$cfg3")" -gt 0 ]; then
        grep -Fxvf "$cfg3" "$cfg1" > "$DT/slist"
        tac "$DT/slist" > "$1"
        rm -f "$DT/slist"
    else
        tac "$cfg1" > "$1"
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

flashcards() {

    cd "$DC_tlt/practice"
    
    if [ -f ./a.lock ]; then
        lock "a.lock"
        ret=$(echo "$?")
        if [ "$ret" -eq 0 ]; then
        "$cls" restart_a & exit
        else
        "$strt" & exit
        fi
    fi

    if [ -f ./a.0 ] && [ -f ./a.1 ]; then
        echo "w9.$(tr -s '\n' '|' < a.1).w9" >> "$log"
        grep -Fxvf a.1 a.0 > a.tmp
        echo " practice --restarting session"
    else
        get_list a.0 && cp -f a.0 a.tmp
        [[ "$(wc -l < ./a.0)" -lt 5 ]] && starting "$(gettext "Not enough words to start.")"
        echo " practice --new session"
    fi
    "$DF"
}

multiple_choise() {

    cd "$DC_tlt/practice"
    
    if [ -f ./b.lock ]; then
        lock "b.lock"
        ret=$(echo "$?")
        if [[ "$ret" -eq 0 ]]; then
        "$cls" restart_b & exit
        else
        "$strt" & exit
        fi
    fi

    if [ -f ./b.0 ] && [ -f ./b.tmp ]; then
        echo "w9.$(tr -s '\n' '|' < b.tmp).w9" >> "$log"
        grep -Fxvf b.tmp b.0 > b.tmp
        echo " practice --restarting session"
        
    else
        get_list b.0 && cp -f b.0 b.tmp
        if [ ! -f b.srces ]; then
            get_list_mchoice; fi
        [[ "$(wc -l < ./b.0)" -lt 4 ]] && starting "$(gettext "Not enough words to start.")"
         echo " practice --new session"
    fi
    "$DMC"
}

listen_words() {

    cd "$DC_tlt/practice"
    
    if [[ -f ./c.lock ]]; then
        lock "c.lock"
        ret=$(echo "$?")
        if [[ "$ret" -eq 0 ]]; then
        "$cls" restart_c & exit
        else
        "$strt" & exit
        fi
    fi

    if [ -f ./c.0 ] && [ -f ./c.1 ]; then
        echo "w9.$(tr -s '\n' '|' < c.1).w9" >> "$log"
        grep -Fxvf c.1 c.0 > c.tmp
        echo " practice --restarting session"
    else
        get_list c.0 && cp -f c.0 c.tmp
        [[ "$(wc -l < ./c.0)" -lt 4 ]] && starting "$(gettext "Not enough words to start.")"
        echo " practice --new session"
    fi
    "$DLW"
}

listen_sentences() {

    cd "$DC_tlt/practice"
    
    if [ -f ./d.lock ]; then
        lock "d.lock"
        ret=$(echo "$?")
        if [[ "$ret" -eq 0 ]]; then
        "$cls" restart_d & exit
        else
        "$strt" & exit
        fi
    fi

    if [ -f ./d.0 ] && [ -f ./d.1 ]; then
        grep -Fxvf d.1 d.0 > d.tmp
        echo " practice --restarting session"
    else
        get_list_sentences d.0 && cp -f d.0 d.tmp
        [[ "$(wc -l < ./d.0)" -lt 1 ]] && starting "$(gettext "Not enough sentences to start.")"
        echo " practice --new session"
    fi
    "$DLS"
}

images() {

    cd "$DC_tlt/practice"
    
    if [ -f e.lock ]; then
        lock "e.lock"
        ret=$(echo "$?")
        if [ "$ret" -eq 0 ]; then
        "$cls" restart_e & exit
        else
        "$strt" & exit
        fi
    fi

    if [ -f ./e.0 ] && [ -f ./e.1 ]; then
        echo "w9.$(tr -s '\n' '|' < e.1).w9" >> "$log"
        grep -Fxvf e.1 e.0 > e.tmp
        echo " practice --restarting session"
    else
        
        get_list_images e.0 && cp -f e.0 e.tmp
        [[ "$(wc -l < ./e.0)" -lt 3 ]] && starting "$(gettext "Not enough images to start.")"
        echo " practice --new session"
    fi
    "$DI"
}

case "$1" in
    1)
    flashcards ;;
    2)
    multiple_choise ;;
    3)
    listen_words ;;
    4)
    listen_sentences ;;
    5)
    images ;;
esac

