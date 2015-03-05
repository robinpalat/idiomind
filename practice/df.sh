#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#source /usr/share/idiomind/ifs/c.conf
drtt="$DM_tlt/words"
drts="$DS/practice/"
strt="$drts/strt.sh"
cd "$DC_tlt/practice"
w9=$DC_s/cfg.22
all=$(cat fin | wc -l)
easy=0
hard=0
ling=0

[[ -f fin2 ]] && rm fin2
[[ -f fin3 ]] && rm fin3

function score() {

    if [ "$(($(cat l_f)+$1))" -ge "$all" ]; then
        
        rm fin fin1 fin2 fin3 ok.f
        echo "$(date "+%a %d %B")" > look_f
        echo 21 > .iconf
        play $drts/all.mp3 & $strt 1 &
        killall df.sh
        exit 1
        
    else
        [[ -f l_f ]] && echo "$(($(cat l_f)+$easy))" > l_f || echo $easy > l_f
        s=$(cat l_f)
        v=$((100*$s/$all))
        n=1; c=1
        while [ "$n" -le 21 ]; do
                if [[ "$v" -le "$c" ]]; then
                echo "$n" > .iconf; break; fi
                ((c=c+5))
            let n++
        done
        
        [[ -f fin2 ]] && rm fin2
        [[ -f fin3 ]] && rm fin3
        $strt 5 $easy $ling $hard & exit 1
    fi
}

function fonts() {
    
    
    fname="$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
    src=$(eyeD3 "$drtt/$fname.mp3" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
    [[ $n = 1 ]] && info="<small> $(gettext "means")...</small>" || info=""
    

    if [ -f "$drtt/images/$fname.jpg" ]; then
    s=$((25-$(echo "$1" | wc -c)))
    img="$drtt/images/$fname.jpg"
    lcuestion="<b>$1</b>"
    lanswer="<small><small><small>$1</small></small></small>  |  <b>$src</b>"
    else
    s=$((40-$(echo "$1" | wc -c)))
    img="/usr/share/idiomind/images/fc.png"
    lcuestion="<b>$1</b>"
    lanswer="<small><small><small>$1</small></small></small>\n<b>$src</b>"
    fi
    }

function cuestion() {
    
    yad --form --text-align=center --undecorated \
    --center --on-top --image-on-top --image="$img" \
    --skip-taskbar --title=" " --borders=3 \
    --buttons-layout=spread --align=center \
    --field="<span font_desc='Free Sans $s'>$lcuestion</span>":lbl \
    --width=371 --height=280 \
    --button="   $(gettext "Exit")   ":1 \
    --button="   $(gettext "Check Answer") >>   ":0
    }

function answer() {
    
    yad --form --text-align=center --undecorated \
    --center --on-top --image-on-top --image="$img" \
    --skip-taskbar --title=" " --borders=3 \
    --buttons-layout=spread --align=center \
    --field="<span font_desc='Free Sans $s'>$lanswer</span>":lbl \
    --width=371 --height=280 \
    --button="    $(gettext "I don't know")    ":3 \
    --button="    $(gettext "I know")    ":2
    }


while read trgt; do

    fonts "$trgt"
    cuestion
    ret=$(echo "$?")
    
    if [[ $ret = 0 ]]; then
        answer
        ans=$(echo "$?")

        if [[ $ans = 2 ]]; then
            echo "$trgt" | tee -a ok.f $w9
            easy=$(($easy+1))

        elif [[ $ans = 3 ]]; then
            echo "$trgt" | tee -a fin2 w6
            hard=$(($hard+1))
        fi

    elif [[ $ret = 1 ]]; then
        $drts/cls f $easy $ling $hard $all &
        break &
        exit 1
        
    fi
done < fin1

if [[ ! -f fin2 ]]; then

    score $easy
    
else

    while read trgt; do

        fonts "$trgt"
        cuestion
        ret=$(echo "$?")
        
        if [[ $ret = 0 ]]; then
            answer
            ans=$(echo "$?")
            
            if [[ $ans = 2 ]]; then
                hard=$(($hard-1))
                ling=$(($ling+1))
                
            elif [[ $ans = 3 ]]; then
                echo "$trgt" | tee -a fin3 w6
            fi
            
        elif [[ $ret = 1 ]]; then
            $drts/cls f $easy $ling $hard $all &
            break &
            exit 1
        fi
    done < fin2
    
    score $easy
fi
