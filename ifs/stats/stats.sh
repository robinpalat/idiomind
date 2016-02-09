#!/bin/bash
# -*- ENCODING: UTF-8 -*-

month=`date +%m`; year=`date +%y`
ydata="$DM_tl/.share/data/$year.log"
pre_data="$DM_tl/.share/data/pre_data"
pre_data_words="$DM_tl/.share/data/pre_data_words"
data="/tmp/.idiomind_stats"
[ ! -e "$ydata" ] && c=0 || c=1

mkstats1() {
    for m in {01..12}; do 
        declare t$m=0; declare p$m=0; declare r$m=0; declare n$m=0
        [ ${c} = 0 ] && echo "M$m.0,0,0,0.M$m" >> "$ydata"
    done
    for m in {01..12}; do
        if [[ ${month} = ${m} ]]; then
            declare t$m=`cut -d ',' -f 1 <"$pre_data"`
            declare p$m=`cut -d ',' -f 2 <"$pre_data"`
            declare r$m=`cut -d ',' -f 3 <"$pre_data"`
            declare n$m=`cut -d ',' -f 4 <"$pre_data"`
            rm "$pre_data"; break
        else
            var=`grep -o -P "(?<=M$m.).*(?=\.M$m)" "$ydata"`
            declare t$m=`cut -d ',' -f 1 <<<"$var"`
            declare p$m=`cut -d ',' -f 2 <<<"$var"`
            declare r$m=`cut -d ',' -f 3 <<<"$var"`
            declare n$m=`cut -d ',' -f 4 <<<"$var"`
        fi
    done
    field_0="[$t01,$t02,$t03,$t04,$t05,$t06,$t07,$t08,$t09,$t10,$t11,$t12]"
    field_1="[$p01,$p02,$p03,$p04,$p05,$p06,$p07,$p08,$p09,$p10,$p11,$p12]"
    field_2="[$r01,$r02,$r03,$r04,$r05,$r06,$r07,$r08,$r09,$r10,$r11,$r12]"
    field_3="[$n01,$n02,$n03,$n04,$n05,$n06,$n07,$n08,$n09,$n10,$n11,$n12]"
    echo -e "data1='[{\"f0\":$field_0,\"f1\":$field_1,\"f2\":$field_2,\"f3\":$field_3}]';" > "$data"
}

mkstats2() {
    for m in {01..12}; do 
        declare t$m=0; declare p$m=0; declare r$m=0; declare n$m=0
        [ ${c} = 0 ] && echo "M$m.0,0,0,0.M$m" >> "$ydata"
    done
    for m in {01..12}; do
        if [[ ${month} = ${m} ]]; then
            declare t$m=`cut -d ',' -f 1 <"$pre_data"`
            declare p$m=`cut -d ',' -f 2 <"$pre_data"`
            declare r$m=`cut -d ',' -f 3 <"$pre_data"`
            declare n$m=`cut -d ',' -f 4 <"$pre_data"`
            rm "$pre_data"; break
        else
            var=`grep -o -P "(?<=M$m.).*(?=\.M$m)" "$ydata"`
            declare t$m=`cut -d ',' -f 1 <<<"$var"`
            declare p$m=`cut -d ',' -f 2 <<<"$var"`
            declare r$m=`cut -d ',' -f 3 <<<"$var"`
            declare n$m=`cut -d ',' -f 4 <<<"$var"`
        fi
    done
    field_0="[$t01,$t02,$t03,$t04,$t05,$t06,$t07,$t08,$t09,$t10,$t11,$t12]"
    field_1="[$p01,$p02,$p03,$p04,$p05,$p06,$p07,$p08,$p09,$p10,$p11,$p12]"
    field_2="[$r01,$r02,$r03,$r04,$r05,$r06,$r07,$r08,$r09,$r10,$r11,$r12]"
    field_3="[$n01,$n02,$n03,$n04,$n05,$n06,$n07,$n08,$n09,$n10,$n11,$n12]"
    echo -e "data2='[{\"f0\":$field_0,\"f1\":$field_1,\"f2\":$field_2,\"f3\":$field_3}]';" >> "$data"
}

if [ -e "$pre_data" ]; then
    mkstats1
fi

if [ -e "$pre_data_words" ]; then
    mkstats2
fi

function stats() {
    yad --html --uri="$DS/ifs/stats/1.html" --browser \
    --title="$(gettext "Stats")" \
    --name=Idiomind --class=Idiomind \
    --orient=vert --window-icon=idiomind --on-top --center \
    --buttons-layout=edge --gtkrc="$DS/default/gtkrc.cfg" \
    --width=670 --height=470 --borders=0  \
    --button="<small>$(gettext "Words")</small>":"$DS/ifs/mods/topic/Dictionary.sh" \
    --button="<small>$(gettext "Close")</small>":1
} >/dev/null 2>&1

stats
