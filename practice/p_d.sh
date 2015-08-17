#!/bin/bash
# -*- ENCODING: UTF-8 -*-

cfg0="$DC_tlt/0.cfg"
drtt="$DM_tlt/images"
drts="$DS/practice"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/log"
all=$(egrep -cv '#|^$' ./d.0)
easy=0
hard=0
ling=0

score() {
    
    "$drts"/cls.sh comp d &

    if [[ $(($(< ./d.l)+${1})) -ge ${all} ]]; then
        play "$drts/all.mp3" &
        echo -e "w9.$(tr -s '\n' '|' < ./d.1).w9\nokp.1.okp" >> "$log"
        echo "$(date "+%a %d %B")" > ./d.lock
        echo 21 > .4
        "$strt" 4 d & exit
        
    else
        [ -f ./d.l ] && echo $(($(< ./d.l)+easy)) > ./d.l || echo ${easy} > ./d.l
        s=$(< ./d.l)
        v=$((100*s/all))
        n=1; c=1
        while [ ${n} -le 21 ]; do
            if [ ${n} -eq 21 ]; then echo $((n-1)) > ./.4
            elif [ ${v} -le ${c} ]; then
            echo ${n} > ./.4; break; fi
            ((c=c+5))
            let n++
        done

        if [ -f ./d.3 ]; then
        echo -e "w6.$(tr -s '\n' '|' < ./d.3).w9" >> "$log"; fi
        
        "$strt" 9 d ${easy} ${ling} ${hard} & exit
    fi
}

fonts() {
    
    item="$(grep -F -m 1 "trgt={${trgt}}" "${cfg0}" |sed 's/},/}\n/g')"
    srce=`grep -oP '(?<=srce={).*(?=})' <<<"${item}"`
    img="$DM_tls/images/${trgt,,}-0.jpg"
    [ ${#trgt} -gt 10 -o ${#srce} -gt 10 ] && trgt_f_c=14 || trgt_f_c=15
    [ ! -f "$img" ] && img="$DS/practice/images/img_2.jpg"
    cuest="<span font_desc='Free Sans ${trgt_f_c}'> ${srce} </span>"
    aswer="<span font_desc='Free Sans Bold ${trgt_f_c}'>${trgt}</span>"
}

cuestion() {
    
    yad --form --title="$(gettext "Practice")" \
    --image="$img" \
    --skip-taskbar --text-align=center --align=center --center --on-top \
    --image-on-top --undecorated --buttons-layout=spread \
    --width=418 --height=370 --borders=5 \
    --field="$cuest":lbl \
    --button="$(gettext "Exit")":1 \
    --button=" $(gettext "Continue") >> ":0
}

answer() {
    
    yad --form --title="$(gettext "Practice")" \
    --image="$img" \
    --selectable-labels \
    --skip-taskbar --text-align=center --align=center --center --on-top \
    --image-on-top --undecorated --buttons-layout=spread \
    --width=418 --height=370 --borders=5 \
    --field="$aswer":lbl \
    --button="  $(gettext "I did not know it")  ":3 \
    --button="  $(gettext "I Knew it")  ":2
}

while read -r trgt; do

    fonts
    cuestion
    
    if [ $? = 1 ]; then
        break &
        "$drts"/cls.sh comp d ${easy} ${ling} ${hard} ${all} & exit
        
    else
        answer
        ans="$?"

        if [ ${ans} = 2 ]; then
            echo "${trgt}" >> d.1
            easy=$((easy+1))

        elif [ ${ans} = 3 ]; then
            echo "${trgt}" >> d.2
            hard=$((hard+1))
        fi
    fi
    
done < ./d.tmp

if [ ! -f ./d.2 ]; then

    score ${easy}
    
else
    while read -r trgt; do

        fonts
        cuestion

        if [ $? = 1 ]; then
            break &
            "$drts"/cls.sh comp d ${easy} ${ling} ${hard} ${all} & exit

        else
            answer
            ans="$?"
            
            if [ ${ans} = 2 ]; then
                hard=$((hard-1))
                ling=$((ling+1))
                
            elif [ ${ans} = 3 ]; then
                echo "${trgt}" >> d.3
            fi
        fi
        
    done < ./d.2
    
    score ${easy}
fi
