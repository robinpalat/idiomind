#!/bin/bash
# -*- ENCODING: UTF-8 -*-

cfg0="$DC_tlt/0.cfg"
drtt="$DM_tlt"
drts="$DS/practice"
strt="$drts/strt.sh"
snd="$drts/no.mp3"
cd "$DC_tlt/practice"
log="$DC_s/log"
all=$(egrep -cv '#|^$' ./b.0)
easy=0
hard=0
ling=0

score() {
    
    "$drts"/cls.sh comp b &

    if [[ $(($(< ./b.l)+${1})) -ge ${all} ]]; then
        play "$drts/all.mp3" &
        echo -e "w9.$(tr -s '\n' '|' < ./b.1).w9\nokp.1.okp" >> "$log"
        echo "$(date "+%a %d %B")" > ./b.lock
        echo 21 > .2
        "$strt" 2 b & exit
        
    else
        [ -f ./b.l ] && echo $(($(< ./b.l)+easy)) > ./b.l || echo ${easy} > ./b.l
        s=$(< ./b.l)
        v=$((100*s/all))
        n=1; c=1
        while [ ${n} -le 21 ]; do
            if [ ${n} -eq 21 ]; then echo $((n-1)) > ./.2
            elif [ ${v} -le ${c} ]; then
            echo ${n} > ./.2; break; fi
            ((c=c+5))
            let n++
        done

        if [ -f ./b.3 ]; then
        echo -e "w6.$(tr -s '\n' '|' < ./b.3).w6" >> "$log"; fi
        
        "$strt" 7 b ${easy} ${ling} ${hard} & exit
    fi
}


fonts() {
    
    item="$(grep -F -m 1 "trgt={${1}}" "${cfg0}" |sed 's/},/}\n/g')"
    wes=`grep -oP '(?<=srce={).*(?=})' <<<"${item}"`

    ras=$(sort -Ru b.srces | egrep -v "$wes" | head -5)
    ess=$(grep "$wes" ./b.srces)
    echo -e "$ras\n$ess" | sort -Ru | head -6 | sed '/^$/d' > srce.tmp
    s=$((36-${#1}))
    cuestion="\n<span font_desc='Free Sans $s' color='#636363'><b>$1</b></span>\n\n"
    }


ofonts() {
    while read item; do
        echo " <b> $item </b> "
    done < ./srce.tmp
    }


mchoise() {
    
    dlg=$(ofonts | yad --list --title="$(gettext "Practice")" \
    --text="$cuestion" \
    --separator=" " --selectable-labels \
    --skip-taskbar --text-align=center --center --on-top \
    --buttons-layout=edge --undecorated \
    --no-headers \
    --width=380 --height=330 --borders=8 \
    --column=Option \
    --button="$(gettext "Exit")":1 \
    --button="$(gettext "OK")":0)
}

while read trgt; do

    fonts "${trgt}"
    mchoise "${trgt}"

    if [ $? = 0 ]; then

        if grep -o "$wes" <<<"${dlg}"; then

            echo "${trgt}" >> b.1
            easy=$((easy+1))
            
        else
            play "$snd" &
            echo "${trgt}" >> b.2
            hard=$((hard+1))
        fi  
            
    elif [ $? = 1 ]; then
        break &
        "$drts"/cls.sh comp b ${easy} ${ling} ${hard} ${all} & exit
    fi
    
done < ./b.tmp
    
if [ ! -f ./b.2 ]; then

    score ${easy}
    
else
    while read trgt; do

        fonts "${trgt}"
        mchoise "${trgt}"
        
        if [ $? = 0 ]; then
        
            if echo "$dlg" | grep "$wes"; then
                hard=$((hard-1))
                ling=$((ling+1))
                
            else
                play "$snd" &
                echo "${trgt}" >> b.3
            fi

        elif [ $? = 1 ]; then
            break &
            "$drts"/cls.sh comp b ${easy} ${ling} ${hard} ${all} & exit
        fi
        
    done < ./b.2
    
    score ${easy}
fi
