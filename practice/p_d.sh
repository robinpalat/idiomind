#!/bin/bash
# -*- ENCODING: UTF-8 -*-

cfg0="$DC_tlt/0.cfg"
drts="$DS/practice"
strt="$drts/strt.sh"
cd "${DC_tlt}/practice"
all=$(egrep -cv '#|^$' ./d.0)
hits="$(gettext "hits")"
listen="Listen"
"$DS/stop.sh" 2
easy=0
hard=0
ling=0
f=0

score() {
    
    "$drts"/cls.sh comp d &

    if [[ ${1} -ge ${all} ]]; then
        play "$drts/all.mp3" & 
        echo ".s9.$(tr -s '\n' '|' < ./d.1).s9." >> "$log"
        echo -e ".okp.1.okp." >> "$log"
        echo "$(date "+%a %d %B")" > ./d.lock
        echo 21 > .4
        "$strt" 4 d & exit
        
    else
        [ -f ./d.l ] && echo $(($(< ./d.l)+easy)) > ./d.l || echo ${easy} > ./d.l
        s=$(< ./d.l)
        v=$((100*s/all))
        n=1; c=1
        while [[ ${n} -le 21 ]]; do
            if [[ ${v} -le ${c} ]]; then
            echo ${n} > ./.4; break; fi
            ((c=c+5))
            let n++
        done

        "$strt" 9 d ${easy} ${ling} ${hard} & exit
    fi
}

dialog2() {

    hint="$(echo "$@" | tr -d "',.;?!¿¡()" | tr -d '"' \
    | awk '{print tolower($0)}' \
    |sed 's/\b\(.\)/\u\1/g' | sed 's/ /         /g' \
    |sed 's|[a-z]|\.|g' \
    |sed 's|\.|\ .|g' \
    | tr "[:upper:]" "[:lower:]" \
    |sed 's/^\s*./\U&\E/g')"
    text="<span font_desc='Free Sans Bold $sz' color='#717171'>$hint</span>\n"
    
    entry=$(>/dev/null | yad --form --title="$(gettext "Practice")" \
    --text="$text" \
    --name=Idiomind --class=Idiomind \
    --separator="" \
    --window-icon="$DS/images/icon.png" --image="$DS/practice/images/bar.png" \
    --buttons-layout=end --skip-taskbar --undecorated --center --on-top \
    --text-align=left --align=left --image-on-top \
    --width=510 --height=220 --borders=10 \
    --field="" "" \
    --field="$(gettext "Listen"):BTN" "$cmd_play" \
    --button="$(gettext "Exit")":1 \
    --button="  $(gettext "Check")  ":0)
    }
    
check() {
    
    sz=$((sz+3))
    yad --form --title="$(gettext "Practice")" \
    --text="<span font_desc='Free Sans $sz'>${wes}</span>\\n" \
    --name=Idiomind --class=Idiomind \
    --image="/usr/share/idiomind/practice/images/bar.png" $aut \
    --selectable-labels \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --wrap --scroll --image-on-top --center --on-top \
    --undecorated --buttons-layout=end \
    --width=510 --height=250 --borders=10 \
    --button="$(gettext "Next >>")":2 \
    --field="":lbl \
    --field="<span font_desc='Free Sans 10'>$OK\n\n$prc $hits</span>":lbl
    }
    
get_text() {
    
    trgt=$(echo "${1}" | sed 's/^ *//; s/ *$//')
    [ ${#trgt} -ge 110 ] && sz=10 || sz=11
    [ ${#trgt} -le 80 ] && sz=12
    chk=`echo "${trgt}" | awk '{print tolower($0)}'`
    }


result() {
    
    clean() {
    sed 's/ /\n/g' \
    | sed 's/,//;s/\!//;s/\?//;s/¿//;s/\¡//;s/(//;s/)//;s/"//g' \
    | sed 's/\-//;s/\[//;s/\]//;s/\.//;s/\://;s/\|//;s/)//;s/"//g' \
    | tr -d '|“”&:!'
    }
    if [[ `wc -w <<<"$chk"` -gt 6 ]]; then
    out=`awk '{print tolower($0)}' <<<"${entry}" | clean | grep -v '^.$'`
    in=`awk '{print tolower($0)}' <<<"${chk}" | clean | grep -v '^.$'`
    else
    out=`awk '{print tolower($0)}' <<<"${entry}" | clean`
    in=`awk '{print tolower($0)}' <<<"${chk}" | clean`
    fi
    
    echo "${chk}" > ./chk.tmp
    while read -r line; do
    
        if grep -Fxq "${line}" <<<"$in"; then
            sed -i "s/"${line}"/<b>"${line}"<\/b>/g" ./chk.tmp
            [ -n "${line}" ] && echo \
            "<span color='#3A9000'><b>${line^}</b></span>  " >> ./words.tmp
            [ -n "${line}" ] && echo "${line}" >> ./mtch.tmp
        else
            [ -n "${line}" ] && echo \
            "<span color='#7B4A44'><b>${line^}</b></span>  " >> ./words.tmp
        fi
        
    done < <(sed 's/ /\n/g' <<<"$out")
    
    OK=$(tr '\n' ' ' < ./words.tmp)
    sed 's/ /\n/g' < ./chk.tmp > ./all.tmp; touch ./mtch.tmp
    porc=$((100*$(cat ./mtch.tmp | wc -l)/$(wc -l < ./all.tmp)))
    
    if [ ${porc} -ge 70 ]; then
        echo "${trgt}" >> ./d.1
        export easy=$((easy+1))
        color=3AB452
        
    elif [ ${porc} -ge 50 ]; then
        echo "${trgt}" >> ./d.2
         export ling=$((ling+1))
        color=E5801D
        
    else
        [ -n "$entry" ] && echo "${trgt}" >> ./d.3
        [ -n "$entry" ] && export hard=$((hard+1))
        color=D11B5D
    fi
    
    prc="<b>$porc%</b>"
    wes="$(< ./chk.tmp)"
    rm ./chk.tmp
    }

while read trgt; do

    pos=`grep -Fon -m 1 "trgt={${trgt}}" "${cfg0}" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
    item=`sed -n ${pos}p "${cfg0}" |sed 's/},/}\n/g'`
    fname=`grep -oP '(?<=id=\[).*(?=\])' <<<"${item}"`
    get_text "${trgt}"
    
    cmd_play="$DS/play.sh play_sentence ${fname} "\"${trgt}\"""
    (sleep 0.5 && "$DS/play.sh" play_sentence ${fname} "${trgt}") &

    dialog2 "${trgt}"
    ret="$?"
    
    if [[ $ret = 1 ]]; then
        break &
        killall play
        "$drts"/cls.sh comp d ${easy} ${ling} ${hard} ${all} & exit
    else
        killall play &
        result "${trgt}"
    fi

    check "${trgt}"
    ret="$?"
    
    if [[ $ret = 1 ]]; then
        break &
        killall play &
        rm -f ./mtch.tmp ./words.tmp
        "$drts"/cls.sh comp d ${easy} ${ling} ${hard} ${all} & exit
        
    elif [[ $ret -eq 2 ]]; then
        killall play &
        rm -f ./mtch.tmp ./words.tmp &
    fi

done < ./d.tmp

score ${easy}
