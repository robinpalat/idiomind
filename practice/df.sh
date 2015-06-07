#!/bin/bash
# -*- ENCODING: UTF-8 -*-

drtt="$DM_tlt/words"
drts="$DS/practice"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/8.cfg"
all=$(wc -l < ./a.0)
easy=0
hard=0
ling=0

score() {
    
    touch a.0 a.1 a.2 a.3
    awk '!a[$0]++' a.2 > a2.tmp
    awk '!a[$0]++' a.3 > a3.tmp
    grep -Fxvf a3.tmp a2.tmp > a.2
    mv -f a3.tmp a.3

    if [[ $(($(< ./a.l)+$1)) -ge $all ]]; then
        play "$drts/all.mp3" &
        echo "w9.$(tr -s '\n' '|' < ./a.1).w9" >> "$log"
        echo "$(date "+%a %d %B")" > a.lock
        echo 21 > .1
        "$strt" 1 &
        exit 1
        
    else
        [ -f a.l ] && echo $(($(< ./a.l)+easy)) > a.l || echo "$easy" > a.l
        s=$(< ./a.l)
        v=$((100*s/all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [ "$v" -le "$c" ]; then
            echo "$n" > .1; break; fi
            ((c=c+5))
            let n++
        done

        if [ -f a.3 ]; then
        echo "w6.$(tr -s '\n' '|' < ./a.3).w6" >> "$log"; fi
        
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
    answer="<span font_desc='Free Sans Bold $s'><i>$src</i></span>"
}

cuestion() {
    
    yad --form --title="$(gettext "Practice")" \
    --timeout=10 \
    --skip-taskbar --text-align=center --center --on-top \
    --undecorated --buttons-layout=spread --align=center \
    --width=395 --height=290 --borders=5 \
    --field="$acuestion":lbl \
    --button="$(gettext "Exit")":1 \
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
        "$drts/cls.sh" comp a "$easy" "$ling" "$hard" "$all" &
        exit 1
        
    else
        answer
        ans=$(echo "$?")

        if [ $ans = 2 ]; then
            echo "$trgt" >> a.1
            easy=$((easy+1))

        elif [ $ans = 3 ]; then
            echo "$trgt" >> a.2
            hard=$((hard+1))
        fi
    fi
done < ./a.tmp

if [ ! -f ./a.2 ]; then

    score "$easy"
    
else
    while read trgt; do

        fonts "$trgt"
        cuestion
        ret=$(echo "$?")
        
        if [ $ret = 1 ]; then
            break &
            "$drts/cls.sh" comp a "$easy" "$ling" "$hard" "$all" &
            exit 1
        
        else
            answer
            ans=$(echo "$?")
            
            if [ $ans = 2 ]; then
                hard=$((hard-1))
                ling=$((ling+1))
                
            elif [ $ans = 3 ]; then
                echo "$trgt" >> a.3
            fi
        fi
    done < ./a.2

    score "$easy"
fi
