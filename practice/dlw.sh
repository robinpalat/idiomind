#!/bin/bash
# -*- ENCODING: UTF-8 -*-

drtt="$DM_tlt/words"
drts="$DS/practice"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/8.cfg"
all=$(wc -l < ./lwin)
easy=0
hard=0
ling=0
[ -f lwin2 ] && rm lwin2
[ -f lwin3 ] && rm lwin3

score() {

    if [[ $(($(< ./l_w)+$1)) -ge $all ]]; then
        play "$drts/all.mp3" &
        echo "w9.$(tr -s '\n' '|' < ./ok.w).w9" >> "$log"
        rm lwin lwin1 lwin2 lwin3 ok.w
        echo "$(date "+%a %d %B")" > lock_lw
        echo 21 > .icon3
        "$strt" 3 &
        exit 1
        
    else
        [ -f l_w ] && echo $(($(< ./l_w)+easy)) > l_w || echo $easy > l_w
        s=$(< ./l_w)
        v=$((100*s/all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [ "$v" -le "$c" ]; then
            echo "$n" > .icon3; break; fi
            ((c=c+5))
            let n++
        done
        
        [ -f lwin2 ] && rm lwin2
        if [ -f lwin3 ]; then
        echo "w6.$(tr -s '\n' '|' < lwin3).w6" >> "$log"
        echo "$(< lwin3)" >> "log"
        rm lwin3; fi
        
        "$strt" 8 $easy $ling $hard & exit 1
    fi
}

fonts() {
    
    if [ $p = 2 ]; then
    [ $lgtl = Japanese ] || [ $lgtl = Chinese ] || [ $lgtl = Russian ] \
    && lst="${1:0:1} ${1:5:5}" || lst=$(echo "$1" | awk '$1=$1' FS= OFS=" " | tr aeiouy '.')
    elif [ $p = 1 ]; then
    [ $lgtl = Japanese ] || [ $lgtl = Chinese ] || [ $lgtl = Russian ] \
    && lst="${1:0:1} ${1:5:5}" || lst=$(echo "${1^}" | sed "s|[a-z]|"\ \."|g"); fi
    
    s=$((30-${#1}))
    img="/usr/share/idiomind/images/fc.png"
    lcuestion="\n\n<span font_desc='Verdana $s' color='#717171'><b>$lst</b></span>\n\n\n\n\n"

    }

cuestion() {
    
    fname="$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
    cmd_play="play "\"$drtt/$fname.mp3\"""
    
    (sleep 0.5 && play "$drtt/$fname".mp3) &
    yad --form --title="$(gettext "Practice")" \
    --text="$lcuestion" \
    --timeout=20 \
    --skip-taskbar --text-align=center --center --on-top \
    --buttons-layout=spread --image-on-top --undecorated \
    --width=370 --height=270 --borders=5 \
    --field="$(gettext "Play")":BTN "$cmd_play" \
    --button="$(gettext "Exit")":1 \
    --button="  $(gettext "No")  ":3 \
    --button="  $(gettext "Yes")  ":2
    }


p=1
while read trgt; do

    fonts "${trgt,,}"
    cuestion "$trgt"
    ans=$(echo "$?")
    
    if [ $ans = 2 ]; then
            echo "$trgt" >> ok.w
            easy=$((easy+1))

    elif [ $ans = 3 ]; then
            echo "$trgt" >> lwin2
            hard=$((hard+1))

    elif [ $ans = 1 ]; then
        break &
        "$drts/cls.sh" w $easy $ling $hard $all &
        exit 1
    fi
done < ./lwin1

if [ ! -f ./lwin2 ]; then

    score $easy
    
else
    p=2
    while read trgt; do

        fonts "${trgt,,}"
        cuestion "$trgt"
        ans=$(echo "$?")
          
        if [ $ans = 2 ]; then
                hard=$((hard-1))
                ling=$((ling+1))
                
        elif [ $ans = 3 ]; then
                echo "$trgt" >> lwin3

        elif [ $ans = 1 ]; then
            break &
            "$drts/cls.sh" w $easy $ling $hard $all &
            exit 1
        fi
    done < ./lwin2
    
    score $easy
fi
