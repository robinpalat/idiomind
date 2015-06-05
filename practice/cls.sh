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
    rm a.lock a.0 a.1 a.2 a.3 a.ok
    echo "1" > .1
    echo "0" > a.l
    "$DIR/strt.sh" & exit
elif [ "$1" = restart_b ]; then
    rm b.lock b.1 b.2 b.3 b.lst b.w b.tmp b.ok
    echo "1" > .2
    echo "0" > b.l
    "$DIR/strt.sh" & exit
elif [ "$1" = restart_c ]; then
    rm c.lock c.0 c.1 c.2 c.3 c.ok
    echo "1" > .3
    echo "0" > c.l
    "$DIR/strt.sh" & exit
elif [ "$1" = restart_d ]; then
    rm d.lock d.0 d.ok
    echo "1" > .4
    echo "0" > d.l
    "$DIR/strt.sh" & exit
elif [ "$1" = restart_e ]; then
    rm e.lock e.0 e.1 e.2 e.3 e.ok
    echo "1" > .5
    echo "0" > e.l
    "$DIR/strt.sh" & exit
fi

if [ "$1" = comp_a ]; then

    [ ./a.2 ] && echo "$(< ./a.2)" >> log2
    [ ./a.3 ] && echo "$(< ./a.3)" >> log3
    [ ./a.l ] && echo $(($(< ./a.l)+easy)) > ./a.l || echo "$easy" > ./a.l
    v=$((100*$(< ./a.l)/all))
    stats ./.1
    "$DIR/strt.sh" 6 "$easy" "$ling" "$hard" & exit 1

elif [ "$1" = comp_b ]; then

    [ ./b.2 ] && echo "$(< ./b.2)" >> log2
    [ ./b.3 ] && echo "$(< ./b.3)" >> log3
    [ ./b.l ] && echo $(($(< ./b.l)+easy)) > ./b.l || echo "$easy" > ./b.l
    v=$((100*$(< ./b.l)/all))
    stats ./.2
    "$DIR/strt.sh" 7 "$easy" "$ling" "$hard" & exit 1

elif [ "$1" = comp_c ]; then

    [ ./c.2 ] && echo "$(< ./c.2)" >> log2
    [ ./c.3 ] && echo "$(< ./c.3)" >> log3
    [ ./c.l ] && echo $(($(< ./c.l)+easy)) > ./c.l || echo "$easy" > ./c.l
    v=$((100*$(< ./c.l)/all))
    stats ./.3
    "$DIR/strt.sh" 8 "$easy" "$ling" "$hard" & exit 1

elif [ "$1" = comp_d ]; then

    [ ./quote ] && rm quote; [ ./all ] && rm ./all; [ ./ing ] && rm ./ing
    [ ./d.l ] && echo $(($(< ./d.l)+easy)) > ./d.l || echo "$easy" > ./d.l
    v=$((100*$(< ./d.l)/all))
    stats ./.4
    "$DIR/strt.sh" 9 "$easy" "$ling" "$hard" & exit 1
    
elif [ "$1" = comp_e ]; then

    [ ./e.2 ] && echo "$(< ./e.2)" >> log2
    [ ./e.3 ] && echo "$(< ./e.3)" >> log3
    [ ./e.l ] && echo $(($(< ./e.l)+easy)) > ./e.l || echo "$easy" > ./e.l
    v=$((100*$(< ./e.l)/all))
    stats ./.5
    "$DIR/strt.sh" 10 "$easy" "$ling" "$hard" & exit 1
fi
