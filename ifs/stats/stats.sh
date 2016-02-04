#!/bin/bash
# -*- ENCODING: UTF-8 -*-

pdata="$DM_tl/.pre_data"
if [ -e "$pdata" ]; then
    data="$DM_tl/.data"
    tot=$(cut -d ',' -f 1 < "$pdata")
    pos=$(cut -d ',' -f 2 < "$pdata")
    neg=$(cut -d ',' -f 3 < "$pdata")
    month=`date +%m`; rm "$pdata"
    for m in {1..12}; do
        if [ $month = 0$m -o $month = $m ]; then
            declare t$m=$tot
            declare p$m=$pos
            declare n$m=$neg
        else
            declare t$m=0
            declare p$m=0
            declare n$m=0
        fi
    done
    field_1="[$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8,$t9,$t10,$t11,$t12]"
    field_2="[$p1,$p2,$p3,$p4,$p5,$p6,$p7,$p8,$p9,$p10,$p11,$p12]"
    field_3="[$n1,$n2,$n3,$n4,$n5,$n6,$n7,$n8,$n9,$n10,$n11,$n12]"
    echo -e "data='[{\"f0\":$field_1,\"f1\":$field_2,\"f2\":$field_3}]';" > "$data"
fi

function stats() {

    yad --html --uri="/usr/share/idiomind/ifs/stats/1.html" --browser \
    --title="$(gettext "Stats")" \
    --name=Idiomind --class=Idiomind \
    --orient=vert --window-icon=idiomind --on-top --center \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --width=620 --height=420 --borders=2 --splitter=280 \
    --button="<small>$(gettext "Close")</small>":1
    
} >/dev/null 2>&1

stats
