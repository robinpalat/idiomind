#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[[ -z "$DM" ]] && source /usr/share/idiomind/ifs/c.conf
DIR="$DS/practice"
[ -n "$(ps -A | pgrep -f "$DIR/p_a.sh")" ] && killall "$DIR/p_a.sh" &
[ -n "$(ps -A | pgrep -f "$DIR/p_b.sh")" ] && killall "$DIR/p_b.sh" &
[ -n "$(ps -A | pgrep -f "$DIR/p_c.sh")" ] && killall "$DIR/p_c.sh" &
[ -n "$(ps -A | pgrep -f "$DIR/p_d.sh")" ] && killall "$DIR/p_d.sh" &
[ -n "$(ps -A | pgrep -f "$DIR/p_e.sh")" ] && killall "$DIR/p_e.sh" &
[ -n "$(ps -A | pgrep -f "$DIR/prct.sh")" ] && killall "$DIR/prct.sh" &
[ -n "$(ps -A | pgrep -f "$DIR/strt.sh")" ] && killall "$DIR/strt.sh" &
[ -n "$(ps -A | pgrep -f play)" ] && killall play &
if [ -d "$DC_tlt/practice" ]; then
cd "$DC_tlt/practice"

stats() {
    
    n=1; c=1
    while [[ $n -le 21 ]]; do
        if [[ $v -le $c ]]; then
        echo $n > "${1}"; break; fi
        ((c=c+5))
        let n++
    done
}

easy="$3"; ling="$4"; hard="$5"; all="$6"
[[ $2 = a ]] && icon=1 && _stats=6
[[ $2 = b ]] && icon=2 && _stats=7
[[ $2 = c ]] && icon=3 && _stats=8
[[ $2 = d ]] && icon=4 && _stats=9
[[ $2 = e ]] && icon=5 && _stats=10

if [[ "$1" = restart ]]; then
    
    rm ./"${2}.lock" ./"${2}.0" ./"${2}.1" \
    ./"${2}.2" ./"${2}.3" ./log1 ./log2 ./log3
    [ -f ./b.srces ] && rm ./b.srces
    echo "1" > ./."${icon}"
    echo "0" > ./"${2}.l"
    touch ./log1 ./log2 ./log3
    "$DIR/strt.sh" & exit

elif [[ $1 = comp ]]; then

    awk '{a[$0]++}END{for(i in a){if(a[i]==3)print i}}' *.1 > ./log1
    awk '{a[$0]++}END{for(i in a){if(a[i]==2)print i}}' *.2 > ./log2
    awk '{a[$0]++}END{for(i in a){if(a[i]==2)print i}}' *.3 > ./log3

    if [ -n "$3" ]; then
    
        [ -f ./"${2}".l ] \
        && echo $(($(< ./"${2}".l)+easy)) > ./"${2}".l \
        || echo "$easy" > ./"${2}".l
        v=$((100*$(< ./"${2}".l)/all))
        stats ./."${icon}"
        "$DIR/strt.sh" $_stats ${2} "$easy" "$ling" "$hard" &
    fi
    
    exit
fi
fi
