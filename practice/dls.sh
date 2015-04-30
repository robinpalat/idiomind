#!/bin/bash
# -*- ENCODING: UTF-8 -*-

drts="$DS/practice"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
all=$(wc -l < ./lsin)
listen="Listen"
easy=0
hard=0
ling=0
f=0

score() {

    if [[ "$1" -ge $all ]]; then
        play "$drts/all.mp3" & 
        echo "s9.$(tr -s '\n' '|' < ok.s).s9" >> "$log"
        rm lsin ok.s
        echo "$(date "+%a %d %B")" > lock_ls
        echo 21 > .icon4
        "$strt" 4 &
        exit 1
        
    else
        [ -f ./l_s ] && echo $(($(< ./l_s)+easy)) > l_s || echo $easy > l_s
        s=$(< ./l_s)
        v=$((100*s/all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [ "$v" -le "$c" ]; then
            echo "$n" > .icon4; break; fi
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
    text="<span font_desc='Serif Bold 12'>$hint</span>\n"

    SE=$(yad --text-info --title="$(gettext "Practice")" \
    --text="$text" \
    --selectable-labels \
    --name=Idiomind --class=Idiomind \
    --fontname="Free Sans 14" --fore=4A4A4A --justify=fill \
    --margins=5 --editable --wrap \
    --window-icon="$DS/images/icon.png" --image="$DS/practice/bar.png" \
    --buttons-layout=end --skip-taskbar --undecorated --center --on-top \
    --text-align=left --align=left --image-on-top \
    --height=225 --width=560 --borders=5 \
    --button="$(gettext "Exit")":1 \
    --button="$(gettext "Listen")":"play '$DM_tlt/$fname.mp3'" \
    --button=" $(gettext "OK") >> ":0)
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
    --button="$(gettext "Exit")":1 \
    --button="$(gettext "Listen")":"play '$DM_tlt/$fname.mp3'" \
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
    | sed 's/\-//;s/\[//;s/\]//;s/\.//;s/\://;s/\|//;s/)//;s/"//g' > ./ing
    awk '{print tolower($0)}' < ./quote | sed 's/ /\n/g' | grep -v '^.$' \
    | sed 's/,//;s/\!//;s/\?//;s/¿//;s/\¡//;s/(//;s/)//;s/"//g' \
    | sed 's/\-//;s/\[//;s/\]//;s/\.//;s/\://;s/\|//;s/)//;s/"//g' > ./all
    
    (
    n=1;
    while read -r line; do
    
        if grep -oFx "$line" ./all; then
            sed -i "s/"$line"/<b>"$line"<\/b>/g" quote
            [ -n "$line" ] && echo \
            "<span color='#3A9000'><b>${line^}</b></span>  " >> ./wrds
            [ -n "$line" ] && echo "$line" >> w.ok
        else
            [ -n "$line" ] && echo \
            "<span color='#7B4A44'><b>${line^}</b></span>  " >> ./wrds
        fi
        let n++
        
    done <<<"$(sed 's/ /\n/g' < ./ing)"
    )
    
    OK=$(tr '\n' ' ' < ./wrds)
    sed 's/ /\n/g' < ./quote > all
    porc=$((100*$(cat ./w.ok | wc -l)/$(cat ./all | wc -l)))
    
    if [[ $porc -ge 70 ]]; then
        echo "$WEN" >> ok.s
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
while [[ $n -le "$(wc -l < ./lsin1)" ]]; do

    trgt="$(sed -n "$n"p lsin1)"
    fname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
    
    if [[ $n = 1 ]]; then
    info="<sub>$(gettext "Try to write the sentence you're listening to")...</sub>"
    else info=""; fi
    
    if [ -f "$DM_tlt/$fname.mp3" ]; then

        get_text "$trgt"

        (sleep 0.5 && play "$DM_tlt/$fname.mp3") &
        dialog2 "$trgt"
        ret=$(echo "$?")
        
        if [ $ret = 1 ]; then
            break &
            killall play
            "$drts/cls.sh" s $easy $ling $hard $all &
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
            rm -f w.ok all ing wrds
            "$drts/cls.sh" s $easy $ling $hard $all &
            exit 1
            
        elif [ $ret -eq 2 ]; then
            killall play &
            rm -f w.ok wrds &
        fi
    fi
    let n++
done

score $easy

