#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#  2015/02/27

drts="$DS/practice/"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
all=$(cat lsin | wc -l)
listen="Listen"
easy=0
hard=0
ling=0
f=0

score() {

    if [[ $1 -ge $all ]]; then
        play "$drts/all.mp3" & 
        echo "w6.$(tr -s '\n' '|' < ok.s).w6" >> "$log"
        rm lsin ok.s
        echo "$(date "+%a %d %B")" > look_ls
        echo 21 > .iconls
        "$strt" 4 &
        exit 1
        
    else
        [ -f ./l_s ] && echo "$(($(< l_s)+$easy))" > l_s || echo $easy > l_s
        s=$(< l_s)
        v=$((100*$s/$all))
        n=1; c=1
        while [[ $n -le 21 ]]; do
            if [ "$v" -le "$c" ]; then
            echo "$n" > .iconls; break; fi
            ((c=c+5))
            let n++
        done

        "$strt" 9 $easy $ling $hard & exit 1
    fi
}


dialog1() {
    
    hint="$(iconv -c -f utf8 -t ascii <<<"$1" | tr -s "'" " ")"
    SE=$(yad --center --text-info --image="$IMAGE" "$info" --image-on-top \
    --fontname="Free Sans 15" --justify=fill --editable --wrap \
    --buttons-layout=end --borders=2 --title=" " --margins=5 \
    --text-align=left --height=410 --width=462 --name=Idiomind \
    --align=left --window-icon=idiomind --fore=4A4A4A --class=Idiomind \
    --button="$(gettext "Hint")":"/usr/share/idiomind/practice/hint.sh ${hint}" \
    --button="$listen":"play '$DM_tlt/$fname.mp3'" \
    --button=" $(gettext "OK") >> ":0)
    }
    
dialog2() {
    
    hint="$(iconv -c -f utf8 -t ascii <<<"$1" | tr -s "'" " ")"
    SE=$(yad --center --text-info --fore=4A4A4A --skip-taskbar \
    --fontname="Free Sans 15" --justify=fill --editable --wrap \
    --buttons-layout=end --borders=4 --title=" " "$info" --margins=5 \
    --text-align=left --height=180 --width=470 --name=Idiomind \
    --align=left --window-icon=idiomind --image-on-top --class=Idiomind \
    --button="$(gettext "Hint")":"/usr/share/idiomind/practice/hint.sh ${hint}" \
    --button="$(gettext "Listen")":"play '$DM_tlt/$fname.mp3'" \
    --button=" $(gettext "OK") >> ":0)
    }
    
check() {
    
    yad --form --center --name=Idiomind --buttons-layout=end \
    --width=560 --height=300 --on-top --skip-taskbar --scroll \
    --class=Idiomind $aut --wrap --window-icon=idiomind \
    --borders=10 --selectable-labels \
    --title="" --button="$(gettext "Listen")":"play '$DM_tlt/$fname.mp3'" \
    --button="$(gettext "Next")":2 \
    --field="":lbl --text="<span font_desc='Free Sans 15'>$wes</span>\\n" \
    --field="<span font_desc='Free Sans 9'>$(echo $OK | sed 's/\,*$/\./g') $prc</span>\\n":lbl
    }
    
get_image_text() {
    
    WEN=$(echo "$1" | sed 's/^ *//; s/ *$//')
    echo "$WEN" | awk '{print tolower($0)}' > quote
    }

result() {
    
    echo "$SE" | awk '{print tolower($0)}' \
    | sed 's/ /\n/g' | grep -v '^.$' \
    | sed s'/,//; s/\!//; s/\?//; s/¿//; s/\¡//; s/"//'g > ./ing
    cat quote | awk '{print tolower($0)}' \
    | sed 's/ /\n/g' | grep -v '^.$' \
    | sed s'/,//; s/\!//; s/\?//; s/¿//; s/\¡//; s/"//'g > ./all
    
    (
    n=1;
    while read -r line; do
    
        if cat all | grep -oFx "$line"; then
            sed -i "s/"$line"/<b>"$line"<\/b>/g" quote
            [ -n "$line" ] && echo \
            "<span color='#3A9000'><b>${line^}</b></span>,  " >> ./wrds
            [ -n "$line" ] && echo "$line" >> w.ok
        else
            [ -n "$line" ] && echo \
            "<span color='#7B4A44'><b>${line^}</b></span>,  " >> ./wrds
        fi
        let n++
        
    done <<<"$(sed 's/ /\n/g' < ./ing)"
    )
    
    OK=$(tr '\n' ' ' < ./wrds)
    sed 's/ /\n/g' < ./quote > all
    porc=$((100*$(cat ./w.ok | wc -l)/$(cat ./all | wc -l)))
    
    if [[ $porc -ge 70 ]]; then
        echo "$WEN" >> ok.s
        easy=$(($easy+1))
        color=3AB452
        
    elif [[ $porc -ge 50 ]]; then
        ling=$(($ling+1))
        color=E5801D
        
    else
        hard=$(($hard+1))
        color=D11B5D
    fi
    
    prc="<span background='#$color'><span color='#FFFFFF'> <b>$porc%</b> </span></span>"
    wes="$(cat quote)"
    rm allc quote
    }

n=1
while [[ $n -le $(wc -l < lsin1) ]]; do

    trgt="$(sed -n "$n"p lsin1)"
    fname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
    
    if [[ $n = 1 ]] && [ ! -f "$DM_tlt/words/images/$fname.jpg" ]; then
    info="--text= $(gettext "Try to write the sentence you're listening to")..."
    else info=""; fi
    
    if [ -f "$DM_tlt/$fname.mp3" ]; then

        get_image_text "$trgt"

        if [ -f "$DM_tlt/words/images/$fname.jpg" ]; then
            IMAGE="$DM_tlt/words/images/$fname.jpg"
            (sleep 0.5 && play "$DM_tlt/$fname.mp3") &
            dialog1 "$trgt"
        else
            (sleep 0.5 && play "$DM_tlt/$fname.mp3") &
            dialog2 "$trgt"
        fi
        ret=$(echo "$?")
        
        if [ $ret -eq 0 ]; then
            killall play &
            result "$trgt"
        else
            killall play &
            "$drts/cls" s $easy $ling $hard $all &
            break &
            exit 0; fi
    
        check "$trgt"
        ret=$(echo "$?")
        
        if [ $ret -eq 2 ]; then
            killall play &
            rm -f w.ok wrds "$DT"/*.jpeg *.png &
        else
            killall play &
            rm -f w.ok all ing wrds "$DT"/*.jpeg *.png
            "$drts/cls" s $easy $ling $hard $all &
            break &
            exit 0; fi
    fi
    let n++
done

score $easy

