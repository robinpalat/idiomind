#!/bin/bash
# -*- ENCODING: UTF-8 -*-

drtt="$DM_tlt/words"
drts="$DS/practice"
strt="$drts/strt.sh"
snd="$drts/no.mp3"
cd "$DC_tlt/practice"
log="$DC_s/8.cfg"
all=$(wc -l < ./b.0)
easy=0
hard=0
ling=0
[ -f b.2 ] && rm b.2
[ -f b.3 ] && rm b.3

score() {

    if [[ $(($(< ./b.l)+$1)) -ge $all ]]; then
        play "$drts/all.mp3" &
        echo "w9.$(tr -s '\n' '|' < ./b.ok).w9" >> "$log"
        rm b.0 b.1 b.2 b.3 b.ok
        echo "$(date "+%a %d %B")" > b.lock
        echo 21 > .2
        "$strt" 2 &
        exit 1
        
    else
        [ -f b.l ] && echo $(($(< ./b.l)+easy)) > b.l || echo $easy > b.l
        s=$(< ./b.l)
        v=$((100*s/all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [ "$v" -le "$c" ]; then
            echo "$n" > .2; break; fi
            ((c=c+5))
            let n++
        done
        
        if [ -f b.2 ]; then
        echo "$(< ./b.2)" >> "log2"; rm b.2 ; fi
        
        if [ -f b.3 ]; then
        echo "w6.$(tr -s '\n' '|' < ./b.3).w6" >> "$log"
        echo "$(< ./b.3)" >> "log3"; rm b.3; fi
        
        "$strt" 7 $easy $ling $hard & exit 1
    fi
}


fonts() {
    
    fname="$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
    wes=$(eyeD3 "$drtt/$fname.mp3" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
    ras=$(sort -Ru b.lst | egrep -v "$wes" | head -5)
    ess=$(grep "$wes" ./b.lst)
    printf "$ras\n$ess" > b.tmp
    ells=$(sort -Ru b.tmp | head -6)
    echo "$ells" > b.tmp
    sed '/^$/d' b.tmp > b.w
    s=$((40-${#1}))
    cuestion="\n<span font_desc='Free Sans $s'><b>$1</b></span>\n\n"
    }


ofonts() {
    while read item; do
        echo "<big>$item</big>"
    done < ./b.w
    }


mchoise() {
    
    dlg=$(ofonts | yad --list --title="$(gettext "Practice")" \
    --text="$cuestion" \
    --timeout=15 --selectable-labels \
    --skip-taskbar --text-align=center --center --on-top \
    --buttons-layout=edge --undecorated \
    --no-headers \
    --width=410 --height=350 --borders=6 \
    --column=Option \
    --button="$(gettext "Exit")":1 \
    --button="$(gettext "OK")":0)
}

while read trgt; do

    fonts "$trgt"
    mchoise "$trgt"
    ret=$(echo "$?")
    
    if [ $ret = 0 ]; then
    
        if echo "$dlg" | grep "$wes"; then
            echo "$trgt" >> b.ok
            easy=$((easy+1))
            
        else
            play "$snd" &
            echo "$trgt" >> b.2
            hard=$((hard+1))
        fi  
            
    elif [ $ret = 1 ]; then
        break &
        "$drts/cls.sh" comp_b $easy $ling $hard $all &
        exit 1
    fi
    
done < ./b.1
    
if [ ! -f ./b.2 ]; then

    score $easy
    
else
    while read trgt; do

        fonts "$trgt"
        mchoise "$trgt"
        ret=$(echo "$?")
        
        if [ $ret = 0 ]; then
        
            if echo "$dlg" | grep "$wes"; then
                hard=$((hard-1))
                ling=$((ling+1))
                
            else
                play "$snd" &
                echo "$trgt" >> b.3
            fi

        elif [ $ret = 1 ]; then
            break &
            "$drts/cls.sh" comp_b $easy $ling $hard $all &
            exit 1
        fi
        
    done < ./b.2
    
    score $easy
fi
