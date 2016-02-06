#!/bin/bash
# -*- ENCODING: UTF-8 -*-

month=`date +%m`; year=`date +%y`
ydata="$DM_tl/.share/data/$year.log"
pdata="$DM_tl/.share/data/pre_data"
data="/tmp/.idiomind_stats"
[ ! -e "$ydata" ] && c=0 || c=1

if [ -e "$pdata" ]; then
    for m in {01..12}; do declare t$m=0; declare p$m=0; declare n$m=0
        [ ${c} = 0 ] && echo "M$m.0,0,0.M$m" >> "$ydata"
    done
    for m in {01..12}; do
        if [[ ${month} = ${m} ]]; then
            declare t$m=`cut -d ',' -f 1 <"$pdata"`
            declare p$m=`cut -d ',' -f 2 <"$pdata"`
            declare n$m=`cut -d ',' -f 3 <"$pdata"`
            rm "$pdata"; break
        else
            var=`grep -o -P "(?<=M$m.).*(?=\.M$m)" "$ydata"`
            declare t$m=`cut -d ',' -f 1 <<<"$var"`
            declare p$m=`cut -d ',' -f 2 <<<"$var"`
            declare n$m=`cut -d ',' -f 3 <<<"$var"`
        fi
    done
    field_1="[$t01,$t02,$t03,$t04,$t05,$t06,$t07,$t08,$t09,$t10,$t11,$t12]"
    field_2="[$p01,$p02,$p03,$p04,$p05,$p06,$p07,$p08,$p09,$p10,$p11,$p12]"
    field_3="[$n01,$n02,$n03,$n04,$n05,$n06,$n07,$n08,$n09,$n10,$n11,$n12]"
    echo -e "data='[{\"f0\":$field_1,\"f1\":$field_2,\"f2\":$field_3}]';" > "$data"
fi

function stats() {
    yad --html --uri="$DS/ifs/stats/1.html" --browser \
    --title="$(gettext "Stats")" \
    --name=Idiomind --class=Idiomind \
    --orient=vert --window-icon=idiomind --on-top --center \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --width=620 --height=420 --borders=2 --splitter=280 \
    --button="<small>$(gettext "Close")</small>":1
} >/dev/null 2>&1

stats
