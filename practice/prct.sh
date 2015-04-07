#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  

source /usr/share/idiomind/ifs/c.conf
strt="$DS/practice/strt.sh"
cls="$DS/practice/cls"
log="$DC_s/8.cfg"
DF="$DS/practice/df.sh"
DLW="$DS/practice/dlw.sh"
DMC="$DS/practice/dmc.sh"
DLS="$DS/practice/dls.sh"
DI="$DS/practice/di.sh"
Wi="$DC_tlt/3.cfg"
Si="$DC_tlt/4.cfg"
Li="$DC_tlt/1.cfg"
cd "$DC_tlt/practice"

look() {
    
    yad --title="$practice - $tpc" --borders=5 --center \
    --on-top --skip-taskbar --window-icon=idiomind \
    --center --image="$DS/practice/icons_st/21.png" --button=Ok:2 \
    --button="   $(gettext "Restart")   ":0 --width=360 --height=120 \
    --text="<b>   $(gettext "Complete practice")</b>\\n   $(cat $1)\n "
}

get_list() {
    
    if [ "$(cat "$Si" | wc -l)" -gt 0 ]; then
        grep -Fxvf "$Si" "$Li" > "$1"
    else
        cat "$Li" > "$1"
    fi
}

get_list_images() {

    if [ "$(cat "$Si" | wc -l)" -gt 0 ]; then
        grep -Fxvf "$Si" "$Li" > "$DT/images"
    else
        cat "$Li" > "$DT/images"
    fi
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
    echo "5" ; sleep 0
    while read word; do
        fname="$(echo -n "$word" | md5sum | rev | cut -c 4- | rev)"
        file="$DM_tlt/words/$fname.mp3"
        echo "$(eyeD3 "$file" | grep -o -P "(?<=IWI2I0I).*(?=IWI2I0I)")" >> word1.idx
    done < mcin
    ) | yad --progress \
    --width 50 --height 35 --undecorated \
    --pulsate --auto-close \
    --skip-taskbar --center --no-buttons
}

get_list_sentences() {
    
    if [ "$(cat "$Wi" | wc -l)" -gt 0 ]; then
        grep -Fxvf "$Wi" "$Li" > "$1"
    else
        cat "$Li" > "$1"
    fi
}

starting() {
    
    yad --center --borders=5 --image=info \
    --title=$(gettext "Practice") --on-top --window-icon=idiomind \
    --button=Ok:1 --skip-taskbar --width=330 --height=130 \
    --text="  $1.  "
    "$strt" & killall prct.sh.sh & exit 1
}

flashcards() {

    cd "$DC_tlt/practice"
    
    if [ -f look_f ]; then
        look "look_f"
        ret=$(echo "$?")
        if [ "$ret" -eq 0 ]; then
        "$cls" df & exit
        else
        "$strt" & exit
        fi
    fi

    if ([ -f fin ] && [ -f ok.f ]); then
        echo "w9.$(tr -s '\n' '|' < ok.f).w9" >> "$log"
        grep -Fxvf ok.f fin > fin1
        echo " practice --restarting session"
    else
        get_list fin && cp -f fin fin1
        [[ "$(cat fin  | wc -l)" -lt 4 ]] && starting "$(gettext "Not enough words to start")"
        echo " practice --new session"
    fi
    
    "$DF"
}

multiple_choise() {

    cd "$DC_tlt/practice"
    
    if [ -f look_mc ]; then
        look "look_mc"
        ret=$(echo "$?")
        if [[ "$ret" -eq 0 ]]; then
        "$cls" dm & exit
        else
        "$strt" & exit
        fi
    fi

    if ([ -f mcin ] && [ -f ok.m ]); then
        echo "w9.$(tr -s '\n' '|' < ok.m).w9" >> "$log"
        grep -Fxvf ok.m mcin > mcin1
        echo " practice --restarting session"
        
    else
        get_list mcin && cp -f mcin mcin1
        if [ ! -f word1.idx ]; then
            get_list_mchoice; fi
        [[ "$(cat mcin  | wc -l)" -lt 4 ]] && starting "$(gettext "Not enough words to start")"
         echo " practice --new session"
    fi

    "$DMC"
}

listen_words() {

    cd "$DC_tlt/practice"
    
    if [[ -f look_lw ]]; then
        look "look_lw"
        ret=$(echo "$?")
        if [[ "$ret" -eq 0 ]]; then
        "$cls" dw & exit
        else
        "$strt" & exit
        fi
    fi

    if ([ -f lwin ] && [ -f ok.w ]); then
        echo "w9.$(tr -s '\n' '|' < ok.w).w9" >> "$log"
        grep -Fxvf ok.w lwin > lwin1
        echo " practice --restarting session"
    else
        get_list lwin && cp -f lwin lwin1
        [[ "$(cat lwin  | wc -l)" -lt 4 ]] && starting "$(gettext "Not enough words to start")"
        echo " practice --new session"
    fi
    
    "$DLW"
}

listen_sentences() {

    cd "$DC_tlt/practice"
    
    if [ -f look_ls ]; then
        look "look_ls"
        ret=$(echo "$?")
        if [[ "$ret" -eq 0 ]]; then
        "$cls" ds & exit
        else
        "$strt" & exit
        fi
    fi

    if ([ -f lsin ] && [ -f ok.s ]); then
        echo "w6.$(tr -s '\n' '|' < ok.s).w6" >> "$log"
        grep -Fxvf ok.s lsin > lsin1
        echo " practice --restarting session"
    else
        get_list_sentences lsin && cp -f lsin lsin1
        [[ "$(cat lsin  | wc -l)" -lt 1 ]] && starting "$(gettext "Not enough sentences to start")"
        echo " practice --new session"
    fi
    
    "$DLS"
}

images() {

    cd "$DC_tlt/practice"
    
    if [ -f look_i ]; then
        look "look_i"
        ret=$(echo "$?")
        if [ "$ret" -eq 0 ]; then
        "$cls" di & exit
        else
        "$strt" & exit
        fi
    fi

    if ([ -f iin ] && [ -f ok.i ]); then
        echo "w9.$(tr -s '\n' '|' < ok.i).w9" >> "$log"
        grep -Fxvf ok.i iin > iin1
        echo " practice --restarting session"
    else
        
        get_list_images iin && cp -f iin iin1
        [[ "$(cat iin  | wc -l)" -lt 4 ]] && starting "$(gettext "Not enough images to start")"
        echo " practice --new session"
    fi
    
    "$DI"
}

case "$1" in
    f)
    flashcards ;;
    m)
    multiple_choise ;;
    w)
    listen_words ;;
    s)
    listen_sentences ;;
    i)
    images ;;
esac

