#!/bin/bash
# -*- ENCODING: UTF-8 -*-

cfg0="$DC_tlt/0.cfg"
drts="$DS/practice"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/log"
all=$(egrep -cv '#|^$' ./a.0)
easy=0
hard=0
ling=0

score() {
    
    "$drts"/cls.sh comp a &

    if [[ $(($(< ./a.l)+${1})) -ge ${all} ]]; then
        play "$drts/all.mp3" &
        echo -e "w9.$(tr -s '\n' '|' < ./a.1).w9\nokp.1.okp" >> "$log"
        echo "$(date "+%a %d %B")" > ./a.lock
        echo 21 > .1
        "$strt" 1 a & exit
        
    else
        [ -f ./a.l ] && echo $(($(< ./a.l)+easy)) > ./a.l || echo ${easy} > ./a.l
        s=$(< ./a.l)
        v=$((100*s/all))
        n=1; c=1
        while [ ${n} -le 21 ]; do
            if [ ${n} -eq 21 ]; then echo $((n-1)) > ./.1
            elif [ ${v} -le ${c} ]; then
            echo ${n} > ./.1; break; fi
            ((c=c+5))
            let n++
        done

        if [ -f ./a.3 ]; then
        echo -e "w6.$(tr -s '\n' '|' < ./a.3).w6" >> "$log"; fi
        
        "$strt" 6 a ${easy} ${ling} ${hard} & exit
    fi
}

fonts() {

    item="$(grep -F -m 1 "trgt={${1}}" "${cfg0}" |sed 's/},/}\n/g')"
    src="$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")"

    s=$((38-${#src}))
    c=$((28-${#1}))
    h=$((34-${#1}))
    acuestion="\n<span font_desc='Free Sans $s'><b>$1</b></span>"
    bcuestion="\n<span font_desc='Free Sans $c'>$1</span>"
    answer="<span font_desc='Free Sans Bold $h'><i>$src</i></span>"
}

cuestion() {
    
    yad --form --title="$(gettext "Practice")" \
    --timeout=10 \
    --skip-taskbar --text-align=center --center --on-top \
    --undecorated --buttons-layout=spread --align=center \
    --width=360 --height=250 --borders=8 \
    --field="\n$acuestion":lbl \
    --button="$(gettext "Exit")":1 \
    --button="    $(gettext "Continue") >>    ":0
}

answer() {
    
    yad --form --title="$(gettext "Practice")" \
    --timeout=10 --selectable-labels \
    --skip-taskbar --text-align=center --center --on-top \
    --undecorated --buttons-layout=spread --align=center \
    --width=360 --height=250 --borders=8 \
    --field="$bcuestion":lbl \
    --field="":lbl \
    --field="$answer":lbl \
    --button="  $(gettext "I did not know it")  ":3 \
    --button="  $(gettext "I Knew it")  ":2
}


while read trgt; do

    fonts "${trgt}"
    cuestion

    if [ $? = 1 ]; then
        break &
        "$drts"/cls.sh comp a ${easy} ${ling} ${hard} ${all} & exit
        
    else
        answer
        ans="$?"

        if [ ${ans} = 2 ]; then
            echo "${trgt}" >> a.1
            easy=$((easy+1))

        elif [ ${ans} = 3 ]; then
            echo "${trgt}" >> a.2
            hard=$((hard+1))
        fi
    fi
done < ./a.tmp

if [ ! -f ./a.2 ]; then

    score ${easy}
    
else
    while read trgt; do

        fonts "${trgt}"
        cuestion
        
        if [ $? = 1 ]; then
            break &
            "$drts"/cls.sh comp a ${easy} ${ling} ${hard} ${all} & exit
        
        else
            answer
            ans="$?"
            
            if [ ${ans} = 2 ]; then
                hard=$((hard-1))
                ling=$((ling+1))
                
            elif [ ${ans} = 3 ]; then
                echo "${trgt}" >> a.3
            fi
        fi
    done < ./a.2

    score ${easy}
fi
