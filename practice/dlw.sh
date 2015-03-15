#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#source /usr/share/idiomind/ifs/c.conf
drtt="$DM_tlt/words"
drts="$DS/practice/"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/8.cfg"
all=$(cat lwin | wc -l)
easy=0
hard=0
ling=0
[ -f lwin2 ] && rm lwin2
[ -f lwin3 ] && rm lwin3

function score() {

    if [ "$(($(cat l_w)+$1))" -ge "$all" ] ; then
        echo "w9.$(tr -s '\n' ';' < ok.w).w9" >> "$log"
        rm lwin lwin1 lwin2 lwin3 ok.w
        echo "$(date "+%a %d %B")" > look_lw
        echo 21 > .iconlw
        play $drts/all.mp3 & $strt 3 &
        killall dlw.sh
        exit 1
        
    else
        [ -f l_w ] && echo "$(($(cat l_w)+$easy))" > l_w || echo $easy > l_w
        s=$(cat l_w)
        v=$((100*$s/$all))
        n=1; c=1
        while [ "$n" -le 21 ]; do
                if [ "$v" -le "$c" ]; then
                echo "$n" > .iconlw; break; fi
                ((c=c+5))
            let n++
        done
        
        [ -f lwin2 ] && rm lwin2
        if [ -f lwin3 ]; then
            echo "w6.$(tr -s '\n' ';' < lwin3).w6" >> "$log"
            rm lwin3; fi
        $strt 7 $easy $ling $hard & exit 1
    fi
}

function fonts() {
    
    [ $lgtl = Japanese ] || [ $lgtl = Chinese ] || [ $lgtl = Russian ] \
    && lst="${1:0:1} ${1:5:5}" || lst=$(echo "$1" | awk '$1=$1' FS= OFS=" " | tr aeiouy '.')
    
    if [ -f "$drtt/images/$fname.jpg" ]; then
        img="$drtt/images/$fname.jpg"
        s=$((20-$(echo "$1" | wc -c)))
        lcuestion="$lst"
        lanswer="$1"
    else
        s=$((40-$(echo "$1" | wc -c)))
        img="/usr/share/idiomind/images/fc.png"
        lcuestion="$lst"
        lanswer="$1"
    fi
    
    }

function cuestion() {
    
    fname="$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
    play="play '$drtt/$fname.mp3'"
    play "$drtt/$fname".mp3 &
    yad --form --align=center --undecorated \
    --center --on-top --image-on-top --image="$img" \
    --skip-taskbar --title=" " --borders=3 \
    --buttons-layout=spread \
    --field="<span font_desc='Free Sans $s'><b>$lcuestion</b></span>":lbl \
    --width=371 --height=280 \
    --button="$(gettext "Exit")":1 \
    --button="Play":"$play" \
    --button="$(gettext "Check Answer") >>":0
    }

function answer() {
    
    yad --form --align=center --undecorated \
    --center --on-top --image-on-top --image="$img" \
    --skip-taskbar --title=" " --borders=3 \
    --buttons-layout=spread \
    --field="<span font_desc='Free Sans $s'><b>$lanswer</b></span>":lbl \
    --width=371 --height=280 \
    --button="    $(gettext "I don't know")    ":3 \
    --button="    $(gettext "I know")    ":2
    }

while read trgt; do

    fonts "$trgt"
    cuestion "$trgt"
    ret=$(echo "$?")
    
    if [ $ret = 0 ]; then
        answer "$trgt"
        ans=$(echo "$?")

        if [ $ans = 2 ]; then
            echo "$trgt" >> ok.w
            easy=$(($easy+1))

        elif [ $ans = 3 ]; then
            echo "$trgt" >> lwin2
            hard=$(($hard+1))
        fi

    elif [[ $ret = 1 ]]; then
        $drts/cls w $easy $ling $hard $all &
        break &
        exit 1
        
    fi
done < lwin1

if [ ! -f lwin2 ]; then

    score $easy
    
else

    while read trgt; do

        fonts "$trgt"
        cuestion "$trgt"
        ret=$(echo "$?")
        
        if [ $ret = 0 ]; then
            answer "$trgt"
            ans=$(echo "$?")
            
            if [ $ans = 2 ]; then
                hard=$(($hard-1))
                ling=$(($ling+1))
                
            elif [ $ans = 3 ]; then
                echo "$trgt" >> lwin3
            fi
            
        elif [ $ret = 1 ]; then
            $drts/cls w $easy $ling $hard $all &
            break &
            exit 1
        fi
    done < lwin2
    
    score $easy
fi
