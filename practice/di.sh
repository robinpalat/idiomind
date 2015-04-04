#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#source /usr/share/idiomind/ifs/c.conf
drtt="$DM_tlt/words"
drts="$DS/practice/"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/8.cfg"
all=$(cat iin | wc -l)
easy=0
hard=0
ling=0
[ -f iin2 ] && rm iin2
[ -f iin3 ] && rm iin3

function score() {

    if [ "$(($(cat l_i)+$1))" -ge "$all" ]; then
        echo "w9.$(tr -s '\n' '|' < ok.i).w9" >> "$log"
        rm iin iin1 iin2 ok.i
        echo "$(date "+%a %d %B")" > look_i
        echo 21 > .iconi
        play "$drts/all.mp3" & $strt 5 &
        killall di.sh
        exit 1
        
    else
        [ -f l_i ] && echo "$(($(cat l_i)+$easy))" > l_i || echo "$easy" > l_i
        s=$(cat l_i)
        v=$((100*$s/$all))
        n=1; c=1
        while [ "$n" -le 21 ]; do
                if [ "$v" -le "$c" ]; then
                echo "$n" > .iconi; break; fi
                ((c=c+5))
            let n++
        done
        
        [ -f iin2 ] && rm iin2
        if [ -f iin3 ]; then
            echo "w6.$(tr -s '\n' '|' < iin3).w6" >> "$log"
            rm iin3; fi
        "$strt" 10 "$easy" "$ling" "$hard" & exit 1
    fi
}

function fonts() {
    
    fname="$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
    src=$(eyeD3 "$drtt/$fname.mp3" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
    s=$((25-$(echo "$1" | wc -c)))
    img="$drtt/images/$fname.jpg"
    lcuestion="<b>$1</b>"
    lanswer="<small><small><small>$1</small></small></small> | <b>$src</b>"
}

function cuestion() {
    
    yad --form --text-align=center --undecorated \
    --center --on-top --image-on-top --image="$img" \
    --skip-taskbar --title=" " --borders=5 \
    --buttons-layout=spread --align=center \
    --field="\n<span font_desc='Free Sans $s'>$lcuestion</span>":lbl \
    --width=375 --height=280 \
    --button=" $(gettext "Exit") ":1 \
    --button=" $(gettext "Answer") >> ":0
}

function answer() {
    
    yad --form --text-align=center --undecorated \
    --center --on-top --image-on-top --image="$img" \
    --skip-taskbar --title=" " --borders=5 \
    --buttons-layout=spread --align=center \
    --field="<span font_desc='Free Sans $s'><small><small><small>$llcuestion</small></small></small></span>":lbl \
    --field="":lbl \
    --field="<span font_desc='Free Sans $s'><b>$src</b></span>":lbl \
    --width=375 --height=280 \
    --button="     $(gettext "I don't know")     ":3 \
    --button="     $(gettext "I know")     ":2
}

while read trgt; do

    fonts "$trgt"
    cuestion
    ret=$(echo "$?")
    
    if [ $ret = 0 ]; then
        answer
        ans=$(echo "$?")

        if [ "$ans" = 2 ]; then
            echo "$trgt" >> ok.i
            easy=$(($easy+1))

        elif [ $ans = 3 ]; then
            echo "$trgt" >> iin2
            hard=$(($hard+1))
        fi

    elif [ $ret = 1 ]; then
        "$drts/cls" i "$easy" "$ling" "$hard" "$all" &
        break &
        exit 1
        
    fi
done < iin1

if [ ! -f iin2 ]; then

    score "$easy"
    
else

    while read trgt; do

        fonts "$trgt"
        cuestion
        ret=$(echo "$?")
        
        if [ $ret = 0 ]; then
            answer
            ans=$(echo "$?")
            
            if [ $ans = 2 ]; then
                hard=$(($hard-1))
                ling=$(($ling+1))
                
            elif [ $ans = 3 ]; then
                echo "$trgt" >> iin3
            fi
            
        elif [ $ret = 1 ]; then
            "$drts/cls" i "$easy" "$ling" "$hard" "$all" &
            break &
            exit 1
        fi
    done < iin2
    
    score "$easy"
fi
