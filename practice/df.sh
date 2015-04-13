#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#source /usr/share/idiomind/ifs/c.conf
drtt="$DM_tlt/words"
drts="$DS/practice/"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/8.cfg"
all=$(cat fin | wc -l)
easy=0
hard=0
ling=0
[ -f fin2 ] && rm fin2
[ -f fin3 ] && rm fin3

score() {

    if [[ $(($(< l_f)+$1)) -ge $all ]]; then
        play "$drts/all.mp3" &
        echo "w9.$(tr -s '\n' '|' < ok.f).w9" >> "$log"
        rm fin fin1 fin2 ok.f
        echo "$(date "+%a %d %B")" > look_f
        echo 21 > .iconf
        "$strt" 1 &
        exit 1
        
    else
        [ -f l_f ] && echo "$(($(cat l_f)+$easy))" > l_f || echo "$easy" > l_f
        s=$(cat l_f)
        v=$((100*$s/$all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [ "$v" -le "$c" ]; then
            echo "$n" > .iconf; break; fi
            ((c=c+5))
            let n++
        done
        
        [ -f fin2 ] && rm fin2
        if [ -f fin3 ]; then
            echo "w6.$(tr -s '\n' '|' < fin3).w6" >> "$log"
            rm fin3; fi
        "$strt" 6 "$easy" "$ling" "$hard" & exit 1
    fi
}

fonts() {
    
    fname="$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
    src=$(eyeD3 "$drtt/$fname.mp3" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
    s=$((40-$(wc -c <<<"$1")))
    c=$((25-$(wc -c <<<"$1")))
    acuestion="\n\n<span font_desc='Free Sans $s'><b>$1</b></span>"
    bcuestion="\n<span font_desc='Free Sans $c'>$1</span>"
    answer="<span font_desc='Free Sans $s'><b>$src</b></span>"
}

cuestion() {
    
    yad --form --text-align=center --undecorated --center --on-top  \
    --skip-taskbar --title=" " --borders=5 --buttons-layout=spread \
    --timeout=10 \
    --field="$acuestion":lbl \
    --align=center --width=375 --height=270 \
    --button=" $(gettext "Exit") ":1 \
    --button=" $(gettext "Answer") >> ":0
}

answer() {
    
    yad --form --text-align=center --undecorated --center --on-top \
    --skip-taskbar --title=" " --borders=5 \
    --timeout=10 \
    --buttons-layout=spread --align=center \
    --field="$bcuestion":lbl \
    --field="":lbl \
    --field="$answer":lbl \
    --width=375 --height=270 \
    --button="     $(gettext "I don't know")     ":3 \
    --button="     $(gettext "I know")     ":2
}

while read trgt; do

    fonts "$trgt"
    cuestion
    ret=$(echo "$?")

    if [ $ret = 1 ]; then
        break &
        "$drts/cls" f "$easy" "$ling" "$hard" "$all" &
        exit 1
        
    else
        answer
        ans=$(echo "$?")

        if [ $ans = 2 ]; then
            echo "$trgt" >> ok.f
            easy=$(($easy+1))

        elif [ $ans = 3 ]; then
            echo "$trgt" >> fin2
            hard=$(($hard+1))
        fi
        
    fi
done < fin1

if [ ! -f fin2 ]; then

    score "$easy"
    
else

    while read trgt; do

        fonts "$trgt"
        cuestion
        ret=$(echo "$?")
        
        if [ $ret = 1 ]; then
            break &
            "$drts/cls" f "$easy" "$ling" "$hard" "$all" &
            exit 1
        
        else
            answer
            ans=$(echo "$?")
            
            if [ $ans = 2 ]; then
                hard=$(($hard-1))
                ling=$(($ling+1))
                
            elif [ $ans = 3 ]; then
                echo "$trgt" >> fin3
            fi
            
        fi
    done < fin2
    
    score "$easy"
fi
