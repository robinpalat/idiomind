#!/bin/bash
# -*- ENCODING: UTF-8 -*-

drts="$DS/practice"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
all=$(wc -l < ./d.0)
listen="Listen"
easy=0
hard=0
ling=0
f=0

score() {

    if [[ "$1" -ge $all ]]; then
        play "$drts/all.mp3" & 
        echo "s9.$(tr -s '\n' '|' < ./d.1).s9" >> "$log"
        echo "$(date "+%a %d %B")" > d.lock
        echo 21 > .4
        "$strt" 4 &
        exit 1
        
    else
        [ -f ./d.l ] && echo $(($(< ./d.l)+easy)) > d.l || echo $easy > d.l
        s=$(< ./d.l)
        v=$((100*s/all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [ "$v" -le "$c" ]; then
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

    SE=$(yad --text-info --title="$(gettext "Practice")" \
    --text="$text" \
    --name=Idiomind --class=Idiomind \
    --fontname="Free Sans 14" --fore=4A4A4A --justify=fill \
    --margins=5 --editable --wrap \
    --window-icon="$DS/images/icon.png" --image="$DS/practice/bar.png" \
    --buttons-layout=end --skip-taskbar --undecorated --center --on-top \
    --text-align=left --align=left --image-on-top \
    --height=215 --width=560 --borders=3 \
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
    --field="":lbl --text="<span font_desc='Free Sans 14'>$wes</span>\\n" \
    --field="<span font_desc='Free Sans 9'>$(sed 's/\,*$/\./g' <<<"$OK")\n\nhits $prc</span>\n":lbl
    }
    
get_text() {
    
    WEN=$(echo "$1" | sed 's/^ *//; s/ *$//')
    echo "$WEN" | awk '{print tolower($0)}' > quote
    }

result() {
    
    awk '{print tolower($0)}' <<<"$SE" | sed 's/ /\n/g' | grep -v '^.$' \
    | sed 's/,//;s/\!//;s/\?//;s/¿//;s/\¡//;s/(//;s/)//;s/"//g' \
    | sed 's/\-//;s/\[//;s/\]//;s/\.//;s/\://;s/\|//;s/)//;s/"//g' > ./d_ing.tmp
    awk '{print tolower($0)}' < ./quote | sed 's/ /\n/g' | grep -v '^.$' \
    | sed 's/,//;s/\!//;s/\?//;s/¿//;s/\¡//;s/(//;s/)//;s/"//g' \
    | sed 's/\-//;s/\[//;s/\]//;s/\.//;s/\://;s/\|//;s/)//;s/"//g' > ./d_all.tmp
    
    (
    n=1;
    while read -r line; do
        > ./d_words.tmp
        if grep -oFx "$line" ./d_all.tmp; then
            sed -i "s/"$line"/<b>"$line"<\/b>/g" quote
            [ -n "$line" ] && echo \
            "<span color='#3A9000'><b>${line^}</b></span>  " >> ./d_words.tmp
            [ -n "$line" ] && echo "$line" >> d_ok.tmp
        else
            [ -n "$line" ] && echo \
            "<span color='#7B4A44'><b>${line^}</b></span>  " >> ./d_words.tmp
        fi
        let n++
        
    done <<<"$(sed 's/ /\n/g' < ./d_ing.tmp)"
    )
    
    OK=$(tr '\n' ' ' < ./d_words.tmp)
    sed 's/ /\n/g' < ./quote > d_all.tmp
    porc=$((100*$(cat ./d_ok.tmp | wc -l)/$(cat ./d_all.tmp | wc -l)))
    
    if [[ $porc -ge 70 ]]; then
        echo "$WEN" >> d.1
        easy=$((easy+1))
        color=3AB452
        
    elif [[ $porc -ge 50 ]]; then
        ling=$((ling+1))
        color=E5801D
        
    else
        hard=$((hard+1))
        color=D11B5D
    fi
    
    prc="<b>$porc%</b>"
    wes="$(< quote)"
    rm allc quote
    }

n=1
while [[ $n -le "$(wc -l < ./d.tmp)" ]]; do

    trgt="$(sed -n "$n"p d.tmp)"
    fname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
    
    if [[ $n = 1 ]]; then
    info="<sub>$(gettext "Try to write the sentence you're listening to")...</sub>"
    else info=""; fi
    
    if [ -f "$DM_tlt/$fname.mp3" ]; then

        get_text "$trgt"
        cmd_play="play "\"$DM_tlt/$fname.mp3\"""

        (sleep 0.5 && play "$DM_tlt/$fname.mp3") &
        dialog2 "$trgt"
        ret=$(echo "$?")
        
        if [ $ret = 1 ]; then
            break &
            killall play
            "$drts/cls.sh" comp_d $easy $ling $hard $all &
            exit 1
        else
            killall play &
            result "$trgt"
        fi
    
        check "$trgt"
        ret=$(echo "$?")
        
        if [ $ret = 1 ]; then
            break &
            killall play &
            "$drts/cls.sh" comp_d $easy $ling $hard $all &
            exit 1
            
        elif [ $ret -eq 2 ]; then
            killall play &
        fi
    fi
    let n++
done

score $easy
