#!/bin/bash
# -*- ENCODING: UTF-8 -*-

drtt="$DM_tlt/words"
drts="$DS/practice"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/8.cfg"
all=$(wc -l < ./fin)
easy=0
hard=0
ling=0
[ -f fin2 ] && rm fin2
[ -f fin3 ] && rm fin3

score() {

    if [[ $(($(< ./l_f)+$1)) -ge $all ]]; then
        play "$drts/all.mp3" &
        echo "w9.$(tr -s '\n' '|' < ./ok.f).w9" >> "$log"
        rm fin fin1 fin2 ok.f
        echo "$(date "+%a %d %B")" > lock_f
        echo 21 > .icon1
        "$strt" 1 &
        exit 1
        
    else
        [ -f l_f ] && echo $(($(< ./l_f)+easy)) > l_f || echo "$easy" > l_f
        s=$(< ./l_f)
        v=$((100*s/all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [ "$v" -le "$c" ]; then
            echo "$n" > .icon1; break; fi
            ((c=c+5))
            let n++
        done
        
        [ -f fin2 ] && rm fin2
        if [ -f fin3 ]; then
        echo "w6.$(tr -s '\n' '|' < ./fin3).w6" >> "$log"
        echo "$(< ./fin3)" >> "log"
        rm fin3; fi
        
        "$strt" 6 "$easy" "$ling" "$hard" & exit 1
    fi
}

fonts() {
    
    fname="$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
    src=$(eyeD3 "$drtt/$fname.mp3" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
    s=$((42-${#src}))
    c=$((22-${#1}))
    acuestion="\n\n<span font_desc='Free Sans $s'><b>$1</b></span>"
    bcuestion="\n<span font_desc='Free Sans $c'>$1</span>"
    answer="<span font_desc='Free Sans $s'><b>$src</b></span>"
}

cuestion() {
    
    yad --form --title="$(gettext "Practice")" \
    --timeout=10 \
    --skip-taskbar --text-align=center --center --on-top \
    --undecorated --buttons-layout=spread --align=center \
    --width=395 --height=290 --borders=5 \
    --field="$acuestion":lbl \
    --button="gtk-close":1 \
    --button="    $(gettext "Answer") >>    ":0
}

answer() {
    
    yad --form --title="$(gettext "Practice")" \
    --timeout=10 --selectable-labels \
    --skip-taskbar --text-align=center --center --on-top \
    --undecorated --buttons-layout=spread --align=center \
    --width=395 --height=290 --borders=5 \
    --field="$bcuestion":lbl \
    --field="":lbl \
    --field="$answer":lbl \
    --button="  $(gettext "I did not know it")  ":3 \
    --button="  $(gettext "I Knew it")  ":2
}


while read trgt; do

    fonts "$trgt"
    cuestion
    ret=$(echo "$?")

    if [ $ret = 1 ]; then
        break &
        "$drts/cls.sh" f "$easy" "$ling" "$hard" "$all" &
        exit 1
        
    else
        answer
        ans=$(echo "$?")

        if [ $ans = 2 ]; then
            echo "$trgt" >> ok.f
            easy=$((easy+1))

        elif [ $ans = 3 ]; then
            echo "$trgt" >> fin2
            hard=$((hard+1))
        fi
    fi
done < ./fin1

if [ ! -f ./fin2 ]; then

    score "$easy"
    
else
    while read trgt; do

        fonts "$trgt"
        cuestion
        ret=$(echo "$?")
        
        if [ $ret = 1 ]; then
            break &
            "$drts/cls.sh" f "$easy" "$ling" "$hard" "$all" &
            exit 1
        
        else
            answer
            ans=$(echo "$?")
            
            if [ $ans = 2 ]; then
                hard=$((hard-1))
                ling=$((ling+1))
                
            elif [ $ans = 3 ]; then
                echo "$trgt" >> fin3
            fi
        fi
    done < ./fin2
    
    score "$easy"
fi
