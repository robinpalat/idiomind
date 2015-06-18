#!/bin/bash
# -*- ENCODING: UTF-8 -*-

cfg0="$DC_tlt/0.cfg"
drtt="$DM_tlt/images"
drts="$DS/practice"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/8.cfg"
all=$(wc -l < ./e.0)
easy=0
hard=0
ling=0

score() {
    
    "$drts"/cls.sh comp e &

    if [[ $(($(< ./e.l)+$1)) -ge $all ]]; then
        play "$drts/all.mp3" &
        echo ".w9.$(tr -s '\n' '|' < ./e.1).w9." >> "$log"
        echo -e ".okp.1.okp." >> "$log"
        echo "$(date "+%a %d %B")" > e.lock
        echo 21 > .5
        "$strt" 5 e &
        exit 1
        
    else
        [ -f ./e.l ] && echo $(($(< ./e.l)+easy)) > ./e.l || echo "$easy" > ./e.l
        s=$(< ./e.l)
        v=$((100*s/all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [[ "$v" -le "$c" ]]; then
            echo "$n" > ./.5; break; fi
            ((c=c+5))
            let n++
        done

        if [ -f ./e.3 ]; then
        echo ".w6.$(tr -s '\n' '|' < ./e.3).w6." >> "$log"; fi
        
        "$strt" 10 e "$easy" "$ling" "$hard" & exit 1
    fi
}


fonts() {
    
    pos=`grep -Fon -m 1 "trgt={${1}}" "${cfg0}" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
    item=`sed -n ${pos}p "${cfg0}" |sed 's/},/}\n/g'`
    src=`grep -oP '(?<=srce={).*(?=})' <<<"${item}"`
    id="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${item}")"

    img="$drtt/$id.jpg"
    [ ! -f "$img" ] && img="$DS/practice/images/img_2.jpg"
    srcel="<span font_desc='Free Sans 10'><i>($src)</i></span>"
    trgtl="<span font_desc='Free Sans 15'><b>$1</b></span>"
}

cuestion() {
    
    yad --form --title="$(gettext "Practice")" \
    --image="$img" \
    --skip-taskbar --text-align=center --align=center --center --on-top \
    --image-on-top --undecorated --buttons-layout=spread \
    --width=418 --height=380 --borders=6 \
    --button="$(gettext "Exit")":1 \
    --button="    $(gettext "Answer") >>    ":0
}

answer() {
    
    yad --form --title="$(gettext "Practice")" \
    --image="$img" \
    --timeout=20 --selectable-labels \
    --skip-taskbar --text-align=center --align=center --center --on-top \
    --image-on-top --undecorated --buttons-layout=spread \
    --width=418 --height=380 --borders=6 \
    --field="$trgtl   $srcel":lbl \
    --button="  $(gettext "I did not know it")  ":3 \
    --button="  $(gettext "I Knew it")  ":2
}

while read trgt; do

    fonts "$trgt"
    cuestion
    ret=$(echo "$?")
    
    if [[ $ret = 1 ]]; then
        break &
        "$drts"/cls.sh comp e "$easy" "$ling" "$hard" "$all" &
        exit 1
        
    else
        answer
        ans=$(echo "$?")

        if [[ $ans = 2 ]]; then
            echo "$trgt" >> e.1
            easy=$((easy+1))

        elif [[ $ans = 3 ]]; then
            echo "$trgt" >> e.2
            hard=$((hard+1))
        fi
    fi
    
done < ./e.tmp

if [ ! -f ./e.2 ]; then

    score "$easy"
    
else
    while read trgt; do

        fonts "$trgt"
        cuestion
        ret=$(echo "$?")
        
        if [[ $ret = 1 ]]; then
            break &
            "$drts"/cls.sh comp e "$easy" "$ling" "$hard" "$all" &
            exit 1

        else
            answer
            ans=$(echo "$?")
            
            if [[ $ans = 2 ]]; then
                hard=$((hard-1))
                ling=$((ling+1))
                
            elif [[ $ans = 3 ]]; then
                echo "$trgt" >> e.3
            fi
        fi
        
    done < ./e.2
    
    score "$easy"
fi
