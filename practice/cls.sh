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

stats() {
    
    n=1; c=1
    while [[ $n -le 21 ]]; do
        if [[ $v -le $c ]]; then
        echo "$n" > "$1"; break; fi
        ((c=c+5))
        let n++
    done
}

easy="$2"; ling="$3"; hard="$4"; all="$5"

if [ "$1" = restart_a ]; then
    rm a.lock a.0 a.1 a.2 a.3
    echo "1" > .1
    echo "0" > a.l
    "$DIR/strt.sh" & exit
elif [ "$1" = restart_b ]; then
    rm b.lock b.0 b.1 b.2 b.3 b.srces
    echo "1" > .2
    echo "0" > b.l
    "$DIR/strt.sh" & exit
elif [ "$1" = restart_c ]; then
    rm c.lock c.0 c.1 c.2 c.3
    echo "1" > .3
    echo "0" > c.l
    "$DIR/strt.sh" & exit
elif [ "$1" = restart_d ]; then
    rm d.lock d.0 d.1
    echo "1" > .4
    echo "0" > d.l
    "$DIR/strt.sh" & exit
elif [ "$1" = restart_e ]; then
    rm e.lock e.0 e.1 e.2 e.3
    echo "1" > .5
    echo "0" > e.l
    "$DIR/strt.sh" & exit
fi

if [ "$1" = comp_a ]; then
    
    touch a.0 a.1 a.2 a.3
    awk '!a[$0]++' a.2 > a2.tmp
    awk '!a[$0]++' a.3 > a3.tmp
    grep -Fxvf a3.tmp a2.tmp > a.2
    mv -f a3.tmp a.3
    [ -f ./a.l ] && echo $(($(< ./a.l)+easy)) > ./a.l || echo "$easy" > ./a.l
    v=$((100*$(< ./a.l)/all))
    stats ./.1
    "$DIR/strt.sh" 6 "$easy" "$ling" "$hard" & exit

elif [ "$1" = comp_b ]; then
    
    touch b.0 b.1 b.2 b.3
    awk '!a[$0]++' b.2 > b2.tmp
    awk '!a[$0]++' b.3 > b3.tmp
    grep -Fxvf b3.tmp b2.tmp > b.2
    mv -f b3.tmp b.3
    [ -f ./b.l ] && echo $(($(< ./b.l)+easy)) > ./b.l || echo "$easy" > ./b.l
    v=$((100*$(< ./b.l)/all))
    stats ./.2
    "$DIR/strt.sh" 7 "$easy" "$ling" "$hard" & exit

elif [ "$1" = comp_c ]; then

    touch c.0 c.1 c.2 c.3
    awk '!a[$0]++' c.2 > c2.tmp
    awk '!a[$0]++' c.3 > c3.tmp
    grep -Fxvf c3.tmp c2.tmp > c.2
    mv -f c3.tmp c.3
    [ -f ./c.l ] && echo $(($(< ./c.l)+easy)) > ./c.l || echo "$easy" > ./c.l
    v=$((100*$(< ./c.l)/all))
    stats ./.3
    "$DIR/strt.sh" 8 "$easy" "$ling" "$hard" & exit

elif [ "$1" = comp_d ]; then

    [ -f ./quote ] && rm quote; rm *.tmp
    [ -f ./d.l ] && echo $(($(< ./d.l)+easy)) > ./d.l || echo "$easy" > ./d.l
    v=$((100*$(< ./d.l)/all))
    stats ./.4
    "$DIR/strt.sh" 9 "$easy" "$ling" "$hard" & exit
    
elif [ "$1" = comp_e ]; then

    touch e.0 e.1 e.2 e.3
    awk '!a[$0]++' e.2 > e2.tmp
    awk '!a[$0]++' e.3 > e3.tmp
    grep -Fxvf e3.tmp e2.tmp > e.2
    mv -f e3.tmp e.3
    [ -f ./e.l ] && echo $(($(< ./e.l)+easy)) > ./e.l || echo "$easy" > ./e.l
    v=$((100*$(< ./e.l)/all))
    stats ./.5
    "$DIR/strt.sh" 10 "$easy" "$ling" "$hard" & exit
fi
