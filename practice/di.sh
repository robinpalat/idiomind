#!/bin/bash
# -*- ENCODING: UTF-8 -*-

drtt="$DM_tlt/words"
drts="$DS/practice"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/8.cfg"
all=$(wc -l < ./e.0)
easy=0
hard=0
ling=0
[ -f e.2 ] && rm e.2
[ -f e.3 ] && rm e.3

score() {

    if [[ $(($(< ./e.l)+$1)) -ge $all ]]; then
        play "$drts/all.mp3" &
        echo "w9.$(tr -s '\n' '|' < ./e.ok).w9" >> "$log"
        rm e.0 e.1 e.2 e.ok
        echo "$(date "+%a %d %B")" > e.lock
        echo 21 > .5
        "$strt" 5 &
        exit 1
        
    else
        [ -f e.l ] && echo $(($(< ./e.l)+easy)) > e.l || echo "$easy" > e.l
        s=$(< ./e.l)
        v=$((100*s/all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [ "$v" -le "$c" ]; then
            echo "$n" > .5; break; fi
            ((c=c+5))
            let n++
        done

        if [ -f e.2 ]; then
        echo "$(< ./e.2)" >> "log2"; rm e.2 ; fi
        
        if [ -f e.3 ]; then
        echo "w6.$(tr -s '\n' '|' < ./e.3).w6" >> "$log"
        echo "$(< ./e.3)" >> "log3"; rm e.3; fi
        
        "$strt" 10 "$easy" "$ling" "$hard" & exit 1
    fi
}


fonts() {
    
    fname="$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
    src=$(eyeD3 "$drtt/$fname.mp3" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
    img="$drtt/images/$fname.jpg"
    [ ! -f "$img" ] && img="$DS/practice/img_2.jpg"
    s=$((24-${#src}))
    t=$((45-${#1}))
    srcel="\n\n<span font_desc='Free Sans $s'><i>$src</i></span>"
    trgtl="<span font_desc='Free Sans $t'><b>$1</b></span>"
}

cuestion() {
    
    yad --form --title="$(gettext "Practice")" \
    --image="$img" \
    --skip-taskbar --text-align=center --align=center --center --on-top \
    --image-on-top --undecorated --buttons-layout=spread \
    --width=415 --height=340 --borders=4 \
    --button="$(gettext "Exit")":1 \
    --button="    $(gettext "Answer") >>    ":0
}


answer() {
    
    yad --form --title="$(gettext "Practice")" \
    --timeout=20 --selectable-labels \
    --skip-taskbar --text-align=center --align=center --center --on-top \
    --undecorated --buttons-layout=spread \
    --width=415 --height=340 --borders=4 \
    --field="\n$srcel":lbl \
    --field="":lbl \
    --field="$trgtl":lbl \
    --button="  $(gettext "I did not know it")  ":3 \
    --button="  $(gettext "I Knew it")  ":2
}
while read trgt; do

    fonts "$trgt"
    cuestion
    ret=$(echo "$?")
    
    if [ $ret = 1 ]; then
        break &
        "$drts/cls.sh" comp_e "$easy" "$ling" "$hard" "$all" &
        exit 1
        
    else
        answer
        ans=$(echo "$?")

        if [ $ans = 2 ]; then
            echo "$trgt" >> e.ok
            easy=$((easy+1))

        elif [ $ans = 3 ]; then
            echo "$trgt" >> e.2
            hard=$((hard+1))
        fi
    fi
    
done < ./e.1

if [ ! -f e.2 ]; then

    score "$easy"
    
else
    while read trgt; do

        fonts "$trgt"
        cuestion
        ret=$(echo "$?")
        
        if [ $ret = 1 ]; then
            break &
            "$drts/cls.sh" comp_e "$easy" "$ling" "$hard" "$all" &
            exit 1

        else
            answer
            ans=$(echo "$?")
            
            if [ $ans = 2 ]; then
                hard=$((hard-1))
                ling=$((ling+1))
                
            elif [ $ans = 3 ]; then
                echo "$trgt" >> e.3
            fi
        fi
        
    done < ./e.2
    
    score "$easy"
fi
