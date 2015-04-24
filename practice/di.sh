#!/bin/bash
# -*- ENCODING: UTF-8 -*-

drtt="$DM_tlt/words"
drts="$DS/practice"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/8.cfg"
all=$(wc -l < ./iin)
easy=0
hard=0
ling=0
[ -f iin2 ] && rm iin2
[ -f iin3 ] && rm iin3

score() {

    if [[ $(($(< l_i)+$1)) -ge $all ]]; then
        play "$drts/all.mp3" &
        echo "w9.$(tr -s '\n' '|' < ok.i).w9" >> "$log"
        rm iin iin1 iin2 ok.i
        echo "$(date "+%a %d %B")" > lock_i
        echo 21 > .iconi
        "$strt" 5 &
        exit 1
        
    else
        [ -f l_i ] && echo $(($(< l_i)+easy)) > l_i || echo "$easy" > l_i
        s=$(< l_i)
        v=$((100*s/all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [ "$v" -le "$c" ]; then
            echo "$n" > .iconi; break; fi
            ((c=c+5))
            let n++
        done
        
        [ -f iin2 ] && rm iin2
        if [ -f iin3 ]; then
        echo "w6.$(tr -s '\n' '|' < iin3).w6" >> "$log"
        echo "$(< iin3)" >> "log"
        rm iin3; fi
        
        "$strt" 10 "$easy" "$ling" "$hard" & exit 1
    fi
}


fonts() {
    
    fname="$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
    src=$(eyeD3 "$drtt/$fname.mp3" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
    img="$drtt/images/$fname.jpg"
    s=$((48-${#1}))
    c=$((28-${#1}))
    cuestion="\n\n<span font_desc='Free Sans $s'><b>$1</b></span>"
    answer="<span font_desc='Free Sans $c'>$src</span>"
}

cuestion() {
    
    yad --form --title="$(gettext "Practice")" \
    --image="$img" \
    --skip-taskbar --text-align=center --align=center --center --on-top \
    --image-on-top --undecorated --buttons-layout=spread \
    --width=415 --height=340 --borders=4 \
    --button=" $(gettext "Exit") ":1 \
    --button="   $(gettext "Answer") >>   ":0
}


answer() {
    
    yad --form --title="$(gettext "Practice")" \
    --timeout=20 \
    --skip-taskbar --text-align=center --align=center --center --on-top \
    --undecorated --buttons-layout=spread \
    --width=415 --height=340 --borders=4 \
    --field="\n$cuestion":lbl \
    --field="$answer":lbl \
    --button="     $(gettext "I don't know")     ":3 \
    --button="     $(gettext "I know")     ":2
}
while read trgt; do

    fonts "$trgt"
    cuestion
    ret=$(echo "$?")
    
    if [ $ret = 1 ]; then
        break &
        "$drts/cls.sh" i "$easy" "$ling" "$hard" "$all" &
        exit 1
        
    else
        answer
        ans=$(echo "$?")

        if [ $ans = 2 ]; then
            echo "$trgt" >> ok.i
            easy=$((easy+1))

        elif [ $ans = 3 ]; then
            echo "$trgt" >> iin2
            hard=$((hard+1))
        fi
    fi
    
done < iin1

if [ ! -f iin2 ]; then

    score "$easy"
    
else
    while read trgt; do

        fonts "$trgt"
        cuestion
        ret=$(echo "$?")
        
        if [ $ret = 1 ]; then
            break &
            "$drts/cls.sh" i "$easy" "$ling" "$hard" "$all" &
            exit 1

        else
            answer
            ans=$(echo "$?")
            
            if [ $ans = 2 ]; then
                hard=$((hard-1))
                ling=$((ling+1))
                
            elif [ $ans = 3 ]; then
                echo "$trgt" >> iin3
            fi
        fi
        
    done < iin2
    
    score "$easy"
fi
