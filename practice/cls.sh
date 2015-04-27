#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
DIR="$DS/practice"

[ -n "$(ps -A | pgrep -f "$DIR/df.sh")" ] && killall "$DIR/df.sh" &
[ -n "$(ps -A | pgrep -f "$DIR/dmc.sh")" ] && killall "$DIR/dmc.sh" &
[ -n "$(ps -A | pgrep -f "$DIR/dlw.sh")" ] && killall "$DIR/dlw.sh" &
[ -n "$(ps -A | pgrep -f "$DIR/dls.sh")" ] && killall "$DIR/dls.sh" &
[ -n "$(ps -A | pgrep -f "$DIR/di.sh")" ] && killall "$DIR/di.sh" &
[ -n "$(ps -A | pgrep -f "$DIR/prct.sh")" ] && killall "$DIR/prct.sh" &
[ -n "$(ps -A | pgrep -f "$DIR/strt.sh")" ] && killall "$DIR/strt.sh" &
[ -n "$(ps -A | pgrep -f play)" ] && killall play &

cd "$DC_tlt/practice"
easy="$2"; ling="$3"; hard="$4"; all="$5"

if [ "$1" = df ]; then
    rm lock_f fin fin1 fin2 fin3 ok.f
    echo "1" > .icon1
    echo "0" > l_f
    "$DIR/strt.sh" & exit
elif [ "$1" = dm ]; then
    rm lock_mc mcin1 mcin2 mcin3 word1.idx ok.m
    echo "1" > .icon2
    echo "0" > l_m
    "$DIR/strt.sh" & exit
elif [ "$1" = dw ]; then
    rm lock_lw lwin lwin1 lwin2 lwin3 ok.w
    echo "1" > .icon3
    echo "0" > l_w
    "$DIR/strt.sh" & exit
elif [ "$1" = ds ]; then
    rm lock_ls lsin ok.s
    echo "1" > .icon4
    echo "0" > l_s
    "$DIR/strt.sh" & exit
elif [ "$1" = di ]; then
    rm lock_i iin iin1 iin2 iin3 ok.i
    echo "1" > .icon5
    echo "0" > l_i
    "$DIR/strt.sh" & exit
fi

stats() {
    
    n=1; c=1
    while [[ $n -le 21 ]]; do
        if [[ $v -le $c ]]; then
        echo "$n" > "$1"; break; fi
        ((c=c+5))
        let n++
    done
}

if [ "$1" = f ]; then

    [ ./fin3 ] && echo "$(< ./fin3)" >> log
    [ ./l_f ] && echo $(($(< ./l_f)+easy)) > ./l_f || echo "$easy" > ./l_f
    v=$((100*$(< ./l_f)/all))
    stats ./.icon1
    "$DIR/strt.sh" 6 "$easy" "$ling" "$hard" & exit 1

elif [ "$1" = m ]; then

    [ ./mcin3 ] && echo "$(< ./mcin3)" >> log
    [ ./l_m ] && echo $(($(< ./l_m)+easy)) > ./l_m || echo "$easy" > ./l_m
    v=$((100*$(< ./l_m)/all))
    stats ./.icon2
    "$DIR/strt.sh" 7 "$easy" "$ling" "$hard" & exit 1

elif [ "$1" = w ]; then

    [ ./lwin3 ] && echo "$(< ./lwin3)" >> log
    [ ./l_w ] && echo $(($(< ./l_w)+easy)) > ./l_w || echo "$easy" > ./l_w
    v=$((100*$(< ./l_w)/all))
    stats ./.icon3
    "$DIR/strt.sh" 8 "$easy" "$ling" "$hard" & exit 1

elif [ "$1" = s ]; then

    [ ./quote ] && rm quote; [ ./all ] && rm ./all; [ ./ing ] && rm ./ing
    [ ./l_s ] && echo $(($(< ./l_s)+easy)) > ./l_s || echo "$easy" > ./l_s
    v=$((100*$(< ./l_s)/all))
    stats ./.icon4
    "$DIR/strt.sh" 9 "$easy" "$ling" "$hard" & exit 1
    
elif [ "$1" = i ]; then

    [ ./iin3 ] && echo "$(< ./iin3)" >> log
    [ ./l_i ] && echo $(($(< ./l_i)+easy)) > ./l_i || echo "$easy" > ./l_i
    v=$((100*$(< ./l_i)/all))
    stats ./.icon5
    "$DIR/strt.sh" 10 "$easy" "$ling" "$hard" & exit 1
fi
