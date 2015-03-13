#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#source /usr/share/idiomind/ifs/c.conf
drtt="$DM_tlt/words"
drts="$DS/practice/"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
log="$DC_s/8.cfg"
all=$(cat mcin | wc -l)
easy=0
hard=0
ling=0
[ -f mcin2 ] && rm mcin2
[ -f mcin3 ] && rm mcin3

function score() {

    if [ "$(($(cat l_m)+$1))" -ge "$all" ]; then
        echo "w9.$(tr -s '\n' ';' < ok.m).w9" >> "$log"
        rm mcin mcin1 mcin2 mcin3 ok.m
        echo "$(date "+%a %d %B")" > look_mc
        echo 21 > .iconmc
        play $drts/all.mp3 & $strt 2 &
        killall dmc.sh
        exit 1
        
    else
        [ -f l_m ] && echo "$(($(cat l_m)+$easy))" > l_m || echo $easy > l_m
        s=$(cat l_m)
        v=$((100*$s/$all))
        n=1; c=1
        while [ "$n" -le 21 ]; do
                if [ "$v" -le "$c" ]; then
                echo "$n" > .iconmc; break; fi
                ((c=c+5))
            let n++
        done
        
        [ -f mcin2 ] && rm mcin2
        if [ -f mcin3 ]; then
            echo "w6.$(tr -s '\n' ';' < mcin3).w6" >> "$log"
            rm mcin3; fi
        $strt 6 $easy $ling $hard & exit 1
    fi
}


function fonts() {
    
    fname="$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
    wes=$(eyeD3 "$drtt/$fname.mp3" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
    ras=$(sort -Ru word1.idx | egrep -v "$wes" | head -5)
    ess=$(grep "$wes" word1.idx)
    printf "$ras\n$ess" > word2.tmp
    ells=$(sort -Ru word2.tmp | head -6)
    echo "$ells" > word2.tmp
    sed '/^$/d' word2.tmp > word2.id
    s=$((40-$(echo "$1" | wc -c)))
    }


function ofonts() {
    while read item; do
        echo "<b><big>$item</big></b>"
    done < word2.id
    }


function mchoise() {
    
    dlg=$(ofonts | yad --list --on-top --skip-taskbar --title=" " \
    --width=375 --height=340 --center --undecorated \
    --text-align=center --no-headers --borders=6 \
    --button="$(gettext "Exit")":1 \
    --text="\n<span font_desc='Free Sans $s'><b>$1</b></span>\n\n" \
    --column=Opcion )
}

while read trgt; do

    fonts "$trgt"
    mchoise "$trgt"
    ret=$(echo "$?")
    
    if [ $ret = 0 ]; then
    
        if echo "$dlg" | grep "$wes"; then
            echo "$trgt" >> ok.m
            easy=$(($easy+1))
            
        else
            echo "$trgt" >> mcin2
            hard=$(($hard+1))
        fi  
            
    elif [ $ret = 1 ]; then
        $drts/cls m $easy $ling $hard $all &
        break &
        exit 1
    fi
done < mcin1
    
if [ ! -f mcin2 ]; then

    score $easy
    
else
    while read trgt; do

        fonts "$trgt"
        mchoise "$trgt"
        ret=$(echo "$?")
        
        if [ $ret = 0 ]; then
        
            if echo "$dlg" | grep "$wes"; then
                hard=$(($hard-1))
                ling=$(($ling+1))
                
            else
                echo "$trgt" >> mcin3
            fi

        elif [ $ret = 1 ]; then
            $drts/cls m $easy $ling $hard $all &
            break &
            exit 1
        fi
    done < mcin2
    
    score $easy
fi
