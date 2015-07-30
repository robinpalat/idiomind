#!/bin/bash
# -*- ENCODING: UTF-8 -*-

cfg0="$DC_tlt/0.cfg"
drts="$DS/practice"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/log"
all=$(egrep -cv '#|^$' ./c.0)
easy=0
hard=0
ling=0


score() {
    
    "$drts"/cls.sh comp c &

    if [[ $(($(< ./c.l)+${1})) -ge ${all} ]]; then
        play "$drts/all.mp3" &
        echo -e "w9.$(tr -s '\n' '|' < ./c.1).w9\nokp.1.okp" >> "$log"
        echo "$(date "+%a %d %B")" > ./c.lock
        echo 21 > .3
        "$strt" 3 c & exit
        
    else
        [ -f ./c.l ] && echo $(($(< ./c.l)+easy)) > ./c.l || echo ${easy} > ./c.l
        s=$(< ./c.l)
        v=$((100*s/all))
        n=1; c=1
        while [ ${n} -le 21 ]; do
            if [ ${n} -eq 21 ]; then echo $((n-1)) > ./.3
            elif [ ${v} -le ${c} ]; then
            echo ${n} > ./.3; break; fi
            ((c=c+5))
            let n++
        done
        
        if [ -f ./c.3 ]; then
        echo -e "w6.$(tr -s '\n' '|' < ./c.3).w6" >> "$log"; fi
        
        "$strt" 8 c ${easy} ${ling} ${hard} & exit
    fi
}

fonts() {
    
    if [[ $p = 2 ]]; then
    [ $lgtl = Japanese -o $lgtl = Chinese -o $lgtl = Russian ] \
    && lst="${trgt:0:1} ${trgt:5:5}" || lst=$(echo "${trgt,,}" |awk '$1=$1' FS= OFS=" " |tr aeiouy '.')
    elif [[ $p = 1 ]]; then
    [ $lgtl = Japanese -o $lgtl = Chinese -o $lgtl = Russian ] \
    && lst="${trgt:0:1} ${trgt:5:5}" || lst=$(echo "${trgt^}" |sed "s|[a-z]|"\ \."|g")
    fi
    
    item="$(grep -F -m 1 "trgt={${trgt}}" "${cfg0}" |sed 's/},/}\n/g')"
    id="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${item}")"
    s=$((30-${#trgt}))
    lcuestion="\n\n<span font_desc='Verdana ${s}' color='#717171'><b>${lst}</b></span>\n\n\n"
    }

cuestion() {
    
    cmd_play="$DS/play.sh play_word "\"${trgt}\"" ${id}"
    (sleep 0.5 && "$DS/play.sh" play_word "${trgt}" ${id}) &

    yad --form --title="$(gettext "Practice")" \
    --text="$lcuestion" \
    --skip-taskbar --text-align=center --center --on-top \
    --buttons-layout=edge --image-on-top --undecorated \
    --width=350 --height=210 --borders=10 \
    --field="$(gettext "Pronounce")":BTN "$cmd_play" \
    --button="$(gettext "Exit")":1 \
    --button="  $(gettext "No")  ":3 \
    --button="  $(gettext "Yes")  ":2
    }


p=1
while read trgt; do

    fonts 
    cuestion
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

        fonts
        cuestion
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
