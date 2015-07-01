#!/bin/bash
# -*- ENCODING: UTF-8 -*-

cfg0="$DC_tlt/0.cfg"
drts="$DS/practice"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/8.cfg"
all=$(egrep -cv '#|^$' ./c.0)
"$DS/stop.sh" 2
easy=0
hard=0
ling=0


score() {
    
    "$drts"/cls.sh comp c &

    if [[ $(($(< ./c.l)+${1})) -ge ${all} ]]; then
        play "$drts/all.mp3" &
        echo ".w9.$(tr -s '\n' '|' < ./c.1).w9." >> "$log"
        echo -e ".okp.1.okp." >> "$log"
        echo "$(date "+%a %d %B")" > ./c.lock
        echo 21 > .3
        "$strt" 3 c & exit
        
    else
        [ -f ./c.l ] && echo $(($(< ./c.l)+easy)) > ./c.l || echo ${easy} > ./c.l
        s=$(< ./c.l)
        v=$((100*s/all))
        n=1; c=1
        while [[ ${n} -le 21 ]]; do
            if [[ ${v} -le ${c} ]]; then
            echo ${n} > ./.3; break; fi
            ((c=c+5))
            let n++
        done
        
        if [ -f ./c.3 ]; then
        echo ".w6.$(tr -s '\n' '|' < ./c.3).w6." >> "$log"; fi
        
        "$strt" 8 c ${easy} ${ling} ${hard} & exit
    fi
}

fonts() {
    
    if [[ $p = 2 ]]; then
    [ $lgtl = Japanese -o $lgtl = Chinese -o $lgtl = Russian ] \
    && lst="${1:0:1} ${1:5:5}" || lst=$(echo "$1" | awk '$1=$1' FS= OFS=" " | tr aeiouy '.')
    elif [[ $p = 1 ]]; then
    [ $lgtl = Japanese -o $lgtl = Chinese -o $lgtl = Russian ] \
    && lst="${1:0:1} ${1:5:5}" || lst=$(echo "${1^}" | sed "s|[a-z]|"\ \."|g")
    fi
    
    s=$((30-${#1}))
    img="/usr/share/idiomind/images/fc.png"
    lcuestion="\n\n<span font_desc='Verdana $s' color='#717171'><b>$lst</b></span>\n\n\n\n"

    }

cuestion() {
    
    cmd_play="$DS/play.sh play_word ${1}"
    (sleep 0.5 && "$DS/play.sh" play_word "${1}") &

    yad --form --title="$(gettext "Practice")" \
    --text="$lcuestion" \
    --timeout=20 \
    --skip-taskbar --text-align=center --center --on-top \
    --buttons-layout=spread --image-on-top --undecorated \
    --width=380 --height=240 --borders=8 \
    --field="$(gettext "Play")":BTN "$cmd_play" \
    --button="$(gettext "Exit")":1 \
    --button="  $(gettext "No")  ":3 \
    --button="  $(gettext "Yes")  ":2
    }


p=1
while read trgt; do

    fonts "${trgt,,}"
    cuestion "${trgt}"
    ans="$?"
    
    if [ ${ans} = 2 ]; then
        echo "${trgt}" >> c.1
        easy=$((easy+1))

    elif [ ${ans} = 3 ]; then
        echo "${trgt}" >> c.2
        hard=$((hard+1))

    elif [ ${ans} = 1 ]; then
        break &
        "$drts"/cls.sh comp c ${easy} ${ling} ${hard} ${all} & exit
    fi
done < ./c.tmp

if [ ! -f ./c.2 ]; then

    score ${easy}
    
else
    p=2
    while read trgt; do

        fonts "${trgt,,}"
        cuestion "${trgt}"
        ans="$?"
          
        if [ ${ans} = 2 ]; then
            hard=$((hard-1))
            ling=$((ling+1))
                
        elif [ ${ans} = 3 ]; then
            echo "${trgt}" >> c.3

        elif [ ${ans} = 1 ]; then
            break &
            "$drts"/cls.sh comp c ${easy} ${ling} ${hard} ${all} & exit
        fi
    done < ./c.2
    
    score ${easy}
fi
