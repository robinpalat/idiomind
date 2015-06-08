#!/bin/bash
# -*- ENCODING: UTF-8 -*-

drts="$DS/practice"
strt="$drts/strt.sh"
cd "${DC_tlt}/practice"
all=$(wc -l < ./d.0)
listen="Listen"
easy=0
hard=0
ling=0
f=0

score() {

    touch d.0 d.1 d.2 d.3
    awk '!a[$0]++' d.2 > d2.tmp
    awk '!a[$0]++' d.3 > d3.tmp
    grep -Fxvf d3.tmp d2.tmp > d.2
    mv -f d3.tmp d.3

    if [[ "$1" -ge $all ]]; then
        play "$drts/all.mp3" & 
        echo "s9.$(tr -s '\n' '|' < ./d.1).s9" >> "$log"
        echo "$(date "+%a %d %B")" > d.lock
        echo 21 > .4
        "$strt" 4 &
        exit 1
        
    else
        [[ -f ./d.l ]] && echo $(($(< ./d.l)+easy)) > d.l || echo $easy > d.l
        s=$(< ./d.l)
        v=$((100*s/all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [[ $v -le $c ]]; then
            echo "$n" > .4; break; fi
            ((c=c+5))
            let n++
        done

        "$strt" 9 $easy $ling $hard & exit 1
    fi
}

dialog2() {
    
    hint="$(echo "$@" | tr -s "'" ' '|awk '{print tolower($0)}' \
    |sed 's/\b\(.\)/\u\1/g'|tr -s ',' ' ' \
    |sed 's|\.||;s|\,||;s|\;||g'|sed 's|[a-z]|\.|g'|sed 's| |\t|g' \
    |sed 's|\.|\ .|g' | tr "[:upper:]" "[:lower:]"|sed 's/^\s*./\U&\E/g')"
    text="<span font_desc='Free Sans Bold 11' color='#717171'>$hint</span>\n"
    
    entry=$(>/dev/null | yad --text-info --title="$(gettext "Practice")" \
    --text="$text\n" \
    --name=Idiomind --class=Idiomind \
    --fontname="Free Sans 14" --fore=4A4A4A --justify=fill \
    --margins=5 --editable --wrap \
    --window-icon="$DS/images/icon.png" --image="$DS/practice/bar.png" \
    --buttons-layout=end --skip-taskbar --undecorated --center --on-top \
    --text-align=left --align=left --image-on-top \
    --height=215 --width=560 --borders=4 \
    --button="$(gettext "Exit")":1 \
    --button="$(gettext "Listen")":"$cmd_play" \
    --button=" $(gettext "Check") >> ":0)
    }
    
check() {
    
    yad --form --title="$(gettext "Practice")" \
    --name=Idiomind --class=Idiomind \
    --image="/usr/share/idiomind/practice/bar.png" $aut \
    --selectable-labels \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --wrap --scroll --image-on-top --center --on-top \
    --undecorated --buttons-layout=end \
    --width=560 --height=250 --borders=12 \
    --button="$(gettext "Listen")":"$cmd_play" \
    --button="$(gettext "Next")":2 \
    --field="":lbl --text="<span font_desc='Free Sans 14'>${wes}</span>\\n" \
    --field="<span font_desc='Free Sans 9'>$(sed 's/\,*$/\./g' <<<"$OK")\n\nhits $prc</span>\n":lbl
    }
    
get_text() {
    
    trgt=$(echo "${1}" | sed 's/^ *//; s/ *$//')
    chk=`echo "${trgt}" | awk '{print tolower($0)}'`
    }

result() {
    
    clean() {
    sed 's/ /\n/g' \
    | sed 's/,//;s/\!//;s/\?//;s/¿//;s/\¡//;s/(//;s/)//;s/"//g' \
    | sed 's/\-//;s/\[//;s/\]//;s/\.//;s/\://;s/\|//;s/)//;s/"//g' \
    | tr -d '“' | tr -d '”' | tr -d '&' | tr -d ':' | tr -d '!'
    }
    if [[ `wc -w < <<<"$chk"` -gt 6 ]]; then
    out=`awk '{print tolower($0)}' <<<"${entry}" | clean | grep -v '^.$'`
    in=`awk '{print tolower($0)}' <<<"${chk}" | clean | grep -v '^.$'`
    else
    out=`awk '{print tolower($0)}' <<<"${entry}" | clean`
    in=`awk '{print tolower($0)}' <<<"${chk}" | clean`
    fi
    
    echo "${chk}" > chk.tmp
    while read -r line; do
    
        if grep -Fxq "${line}" <<<"$in"; then
            sed -i "s/"${line}"/<b>"${line}"<\/b>/g" chk.tmp
            [[ -n "${line}" ]] && echo \
            "<span color='#3A9000'><b>${line^}</b></span>  " >> ./words.tmp
            [[ -n "${line}" ]] && echo "${line}" >> mtch.tmp
        else
            [[ -n "${line}" ]] && echo \
            "<span color='#7B4A44'><b>${line^}</b></span>  " >> ./words.tmp
        fi
        
    done < <(sed 's/ /\n/g' <<<"$out")
    
    OK=$(tr '\n' ' ' < ./words.tmp)
    sed 's/ /\n/g' < ./chk.tmp > all.tmp
    porc=$((100*$(cat ./mtch.tmp | wc -l)/$(wc -l < ./all.tmp)))
    
    if [[ $porc -ge 70 ]]; then
        echo "${trgt}" >> d.1
        easy=$((easy+1))
        color=3AB452
        
    elif [[ $porc -ge 50 ]]; then
        echo "${trgt}" >> d.2
        ling=$((ling+1))
        color=E5801D
        
    else
        [ -n "$entry" ] && echo "${trgt}" >> d.3
        [ -n "$entry" ] && hard=$((hard+1))
        color=D11B5D
    fi
    
    prc="<b>$porc%</b>"
    wes="$(< ./chk.tmp)"
    rm chk.tmp
    }

while read trgt; do

    fname="$(echo -n "${trgt}" | md5sum | rev | cut -c 4- | rev)"
    if [[ -f "${DM_tlt}/$fname.mp3" ]]; then

        get_text "${trgt}"
        cmd_play="play "\"${DM_tlt}/$fname.mp3\"""

        (sleep 0.5 && play "${DM_tlt}/$fname.mp3") &
        dialog2 "${trgt}"
        ret=$(echo "$?")
        
        if [[ $ret = 1 ]]; then
            break &
            killall play
            "$drts/cls.sh" comp d $easy $ling $hard $all &
            exit 1
        else
            killall play &
            result "${trgt}"
        fi
    
        check "${trgt}"
        ret=$(echo "$?")
        
        if [[ $ret = 1 ]]; then
            break &
            killall play &
            rm -f mtch.tmp words.tmp
            "$drts/cls.sh" comp d $easy $ling $hard $all &
            exit 1
            
        elif [[ $ret -eq 2 ]]; then
            killall play &
            rm -f mtch.tmp words.tmp &
        fi
    fi

done < ./d.tmp

score $easy
