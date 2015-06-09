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

score() {
    
    touch b.0 b.1 b.2 b.3
    awk '!a[$0]++' b.2 > b2.tmp
    awk '!a[$0]++' b.3 > b3.tmp
    grep -Fxvf b3.tmp b2.tmp > b.2
    mv -f b3.tmp b.3

    if [[ $(($(< ./b.l)+$1)) -ge $all ]]; then
        play "$drts/all.mp3" &
        echo ".w9.$(tr -s '\n' '|' < ./b.1).w9." >> "$log"
        echo -e ".okp.1.okp." >> "$log"
        echo "$(date "+%a %d %B")" > b.lock
        echo 21 > .2
        "$strt" 2 &
        exit 1
        
    else
        [[ -f b.l ]] && echo $(($(< ./b.l)+easy)) > b.l || echo $easy > b.l
        s=$(< ./b.l)
        v=$((100*s/all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [[ "$v" -le "$c" ]]; then
            echo "$n" > .2; break; fi
            ((c=c+5))
            let n++
        done

        if [[ -f b.3 ]]; then
        echo ".w6.$(tr -s '\n' '|' < ./b.3).w6." >> "$log"; fi
        
        "$strt" 7 $easy $ling $hard & exit 1
    fi
}


fonts() {
    
    fname="$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
    wes=$(eyeD3 "$drtt/$fname.mp3" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
    ras=$(sort -Ru b.srces | egrep -v "$wes" | head -5)
    ess=$(grep "$wes" ./b.srces)
    echo -e "$ras\n$ess" | sort -Ru | head -6 | sed '/^$/d' > srce.tmp
    s=$((40-${#1}))
    cuestion="\n<span font_desc='Free Sans $s'><b>$1</b></span>\n\n"
    }


ofonts() {
    while read item; do
        echo "<big>$item</big>"
    done < ./srce.tmp
    }


mchoise() {
    
    dlg=$(ofonts | yad --list --title="$(gettext "Practice")" \
    --text="$cuestion" \
    --timeout=15 --selectable-labels \
    --skip-taskbar --text-align=center --center --on-top \
    --buttons-layout=edge --undecorated \
    --no-headers \
    --width=410 --height=350 --borders=8 \
    --column=Option \
    --button="$(gettext "Exit")":1 \
    --button="$(gettext "OK")":0)
}

while read trgt; do

    fonts "$trgt"
    mchoise "$trgt"
    ret=$(echo "$?")
    
    if [[ $ret = 0 ]]; then
    
        if echo "$dlg" | grep "$wes"; then
            echo "$trgt" >> b.1
            easy=$((easy+1))
            
        else
            play "$snd" &
            echo "$trgt" >> b.2
            hard=$((hard+1))
        fi  
            
    elif [[ $ret = 1 ]]; then
        break &
        "$drts/cls.sh" comp b $easy $ling $hard $all &
        exit 1
    fi
    
done < ./b.tmp
    
if [[ ! -f ./b.2 ]]; then

    score $easy
    
else
    while read trgt; do

        fonts "$trgt"
        mchoise "$trgt"
        ret=$(echo "$?")
        
        if [[ $ret = 0 ]]; then
        
            if echo "$dlg" | grep "$wes"; then
                hard=$((hard-1))
                ling=$((ling+1))
                
            else
                play "$snd" &
                echo "$trgt" >> b.3
            fi

        elif [[ $ret = 1 ]]; then
            break &
            "$drts/cls.sh" comp b $easy $ling $hard $all &
            exit 1
        fi
        
    done < ./b.2
    
    score $easy
fi
