#!/bin/bash
# -*- ENCODING: UTF-8 -*-

cfg0="$DC_tlt/0.cfg"
drts="$DS/practice"
strt="$drts/strt.sh"
cd "${DC_tlt}/practice"
all=$(wc -l < ./d.0)
hits="$(gettext "hits")"
synth="$(grep -o synth=\"[^\"]* "$DC_s/1.cfg" |grep -o '[^"]*$')"
listen="Listen"
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
        echo "$(date "+%a %d %B")" > d.lock
        echo 21 > .4
        "$strt" 4 d &
        exit 1
        
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

        "$strt" 9 d ${easy} ${ling} ${hard} & exit 1
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
    
    entry=$(>/dev/null | yad --text-info --title="$(gettext "Practice")" \
    --text="$text" \
    --name=Idiomind --class=Idiomind \
    --fontname="Free Sans 14" --fore=4A4A4A --justify=fill \
    --margins=5 --editable --wrap \
    --window-icon="$DS/images/icon.png" --image="$DS/practice/images/bar.png" \
    --buttons-layout=end --skip-taskbar --undecorated --center --on-top \
    --text-align=left --align=left --image-on-top \
    --width=510 --height=220 --borders=5 \
    --button="$(gettext "Exit")":1 \
    --button="$(gettext "Listen")":"$cmd_play" \
    --button=" $(gettext "Check") >> ":0)
    }
    
check() {
    
    sz=$((sz+3))
    yad --form --title="$(gettext "Practice")" \
    --name=Idiomind --class=Idiomind \
    --image="/usr/share/idiomind/practice/images/bar.png" $aut \
    --selectable-labels \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --wrap --scroll --image-on-top --center --on-top \
    --undecorated --buttons-layout=end \
    --width=510 --height=250 --borders=10 \
    --button="$(gettext "Listen")":"$cmd_play" \
    --button="$(gettext "Next")":2 \
    --field="":lbl --text="<span font_desc='Free Sans $sz'>${wes}</span>\\n" \
    --field="<span font_desc='Free Sans 11'>$OK\n\n$prc $hits</span>\n":lbl
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
    | tr -d '“”&:!'
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
    
    if [[ $porc -ge 70 ]]; then
        echo "${trgt}" >> ./d.1
        easy=$((easy+1))
        color=3AB452
        
    elif [[ $porc -ge 50 ]]; then
        echo "${trgt}" >> ./d.2
        ling=$((ling+1))
        color=E5801D
        
    else
        [ -n "$entry" ] && echo "${trgt}" >> ./d.3
        [ -n "$entry" ] && hard=$((hard+1))
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
    
    if [ -f "${DM_tlt}/$fname.mp3" ]; then
    cmd_play="play "\"${DM_tlt}/$fname.mp3\"""
    (sleep 0.5 && play "${DM_tlt}/${fname}.mp3") &
    else
        if [ -n "${synth}" ]; then
        cmd_play="${synth} "\"${trgt}\"""
        (sleep 0.5 && "${synth}" "${trgt}") &
        else
        cmd_play="espeak -v $lg -k 1 -s 150 "\"${trgt}\"""
        (sleep 0.5 && espeak -v $lg -k 1 -s 150 "${trgt}") & fi
    fi
    
    dialog2 "${trgt}"
    ret="$?"
    
    if [[ $ret = 1 ]]; then
        break &
        killall play
        "$drts"/cls.sh comp d ${easy} ${ling} ${hard} ${all} &
        exit 1
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
        "$drts"/cls.sh comp d ${easy} ${ling} ${hard} ${all} &
        exit 1
        
    elif [[ $ret -eq 2 ]]; then
        killall play &
        rm -f ./mtch.tmp ./words.tmp &
    fi

done < ./d.tmp

score ${easy}
