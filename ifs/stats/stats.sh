#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
source "$DS/ifs/mods/cmns.sh"

dir1="$DM_tl/${tpc}/.conf"
dir2="$DM_tl/${tpc}/.conf/practice"
month=`date +%m`; year=`date +%y`
ydata="$DM_tl/.share/data/$year.log"
pre_data="$DM_tl/.share/data/pre_data"
pre_data_words="$DM_tl/.share/data/pre_data_words"
data="/tmp/.idiomind_stats"
db="$DM_tl/.share/data/log.db"
week=`date +%b%d`
month=`date +%b`
[ ! -e "$ydata" ] && c=0 || c=1

function create_db() {
    if [ ! -e db="$DM_tl/.share/data/log.db" ]; then
        
        mtable="M`date +%y`"
        echo -n "create table if not exists ${mtable} \
        (month TEXT, val0 TEXT, val1 TEXT, val2 TEXT, val3 TEXT);" |sqlite3 ${db}
        
        wtable="W`date +%y`"
        echo -n "create table if not exists ${wtable} \
        (week TEXT, val0 TEXT, val1 TEXT, val2 TEXT, val3 TEXT);" |sqlite3 ${db}
        
    fi
}

function save_topic_stats() {

    count() {
        n=1; a=0; b=0; c=0; d=0; tot=0; pos=0; rev=0; neg=0
        old_IFS=$IFS; IFS=$'\n'
        
        for tpc in $(< "$DM_tl/.share/1.cfg"); do
            pos=0; rev=0; neg=0; emp=0; cfg1=0; cfg2=0; stts=""
            dir1="$DM_tl/${tpc}/.conf"
            dir2="$DM_tl/${tpc}/.conf/practice"
            stts=$(sed -n 1p "$dir1/8.cfg")
            if [ -e "$dir1/1.cfg" ]; then
            cfg1=`egrep -cv '#|^$' < "$dir1/1.cfg"`; fi
            if [ -e "$dir1/2.cfg" ]; then
            cfg2=`egrep -cv '#|^$' < "$dir1/2.cfg"`; fi
            if [[ ${stts} =~ $numer ]]; then
                if [ ${stts} -le 10 -a ${stts} -ge 7 ]; then
                    pos=0; neg=${cfg2}; rev=0; emp=0
                elif [ ${stts} = 5 -o ${stts} = 6 ]; then
                    pos=${cfg2}; neg=0; rev=${cfg1}; emp=0
                elif [ ${stts} = 3 -o ${stts} = 4 ]; then
                    pos=${cfg2}; neg=0; rev=0; emp=0
                else
                    pos=${cfg2}; neg=0; rev=0; emp=${cfg1}
                fi
            fi
            a=$((a+emp)); b=$((b+pos))
            c=$((c+rev)); d=$((d+neg))
            echo "${a},${b},${c},${d}"
            
        done | tail -n 1
    }
    IFS=$old_IFS
    
    data=`count`
    tot=`cut -d ',' -f 1 <<<"$data"`
    pos=`cut -d ',' -f 2 <<<"$data"`
    rev=`cut -d ',' -f 3 <<<"$data"`
    neg=`cut -d ',' -f 4 <<<"$data"`
    mtable="M`date +%y`"
    
    if [ $1 = 0 ]; then
        if ! grep -q ${month} <<<"$(sqlite3 ${db} "PRAGMA table_info(${mtable});")"; then
            sqlite3 ${db} "insert into ${mtable} (month,val0,val1,val2,val3) \
            values ('${month}','${tot}','${pos}','${rev}','${neg}');"
        fi
    fi
    
    echo "${tot},${pos},${rev},${neg}" > "$pre_data"
}


function save_word_stats() {

    count() {
        a=0; b=0; c=10; d=0; e=0
        old_IFS=$IFS; IFS=$'\n'
    
        for tpc in $(cat "$DM_tl/.share/1.cfg"); do
            log1=0; log2=0; log3=0
            _log1=0; _log2=0; _log3=0; _log4=0; cfg3=0; stts=""
            dir1="$DM_tl/${tpc}/.conf"
            dir2="$DM_tl/${tpc}/.conf/practice"
            stts=$(sed -n 1p "$dir1/8.cfg")
            
            if [ -f "$dir2/log1" ]; then
            log1=`wc -l < "$dir2/log1"`; fi
            if [ -f "$dir2/log2" ]; then
            log2=`wc -l < "$dir2/log2"`; fi
            if [ -f "$dir2/log3" ]; then
            log3=`wc -l < "$dir2/log3"`; fi
            if [ -f "$dir1/3.cfg" ]; then
            cfg3=`wc -l < "$dir1/3.cfg"`; fi
            
            if [[ ${stts} =~ $numer ]]; then
                if [ ${stts} -le 10 -a ${stts} -ge 7 ]; then
                    _log1=0; _log2=0; _log3=0; _log4=0
                    
                elif [ ${stts} = 5 -o ${stts} = 6 ]; then
                    _log1=${log1}; _log2=${log2}; _log3=${log3}
                    _log4=$((log2+log3))
                    
                elif [ ${stts} = 3 -o ${stts} = 4 ]; then
                    _log1=${cfg3}; _log2=0; _log3=0; _log4=0
                    
                else 
                    _log1=${log1}; _log2=${log2}; _log3=${log3}; _log4=0
                fi
            fi

            a=$((a+_log1)); b=$((b+_log2))
            c=$((c+_log3)); e=$((e+_log4)); d=$((d+cfg3))
            echo "${d},${a},${b},${c},${e}"
            
        done | tail -n 1
    }
    
    IFS=$old_IFS
    data=`count`
    log0=`cut -d ',' -f 1 <<<"$data"`
    log1=`cut -d ',' -f 2 <<<"$data"`
    log2=`cut -d ',' -f 3 <<<"$data"`
    log3=`cut -d ',' -f 4 <<<"$data"`
    log4=`cut -d ',' -f 5 <<<"$data"`
    wtable="W`date +%y`"
    
    if ! [ `sqlite3 ${db} "select week from '${wtable}' where week is '${week}';"` ]; then
    sqlite3 ${db} "insert into ${wtable} (week,total,val1,val2,val3,val4) \
    values ('${week}','${log0}','${log1}','${log2}','${log3}','${log4}');"
    fi
}


function mk_topic_stats() {
    
    data="/tmp/.idiomind_stats"
    month=`date +%m`
    for m in {01..12}; do
        declare t$m=0; declare p$m=0; declare r$m=0; declare n$m=0
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
    # -------------------------------------------
    wtable="W`date +%y`"
    exec 3< <(sqlite3 "$db" "select week FROM ${wtable}")
    exec 4< <(sqlite3 "$db" "select total FROM ${wtable}")
    exec 5< <(sqlite3 "$db" "select val1 FROM ${wtable}")
    exec 6< <(sqlite3 "$db" "select val2 FROM ${wtable}")
    exec 7< <(sqlite3 "$db" "select val3 FROM ${wtable}")
    exec 8< <(sqlite3 "$db" "select val4 FROM ${wtable}")
    for m in {01..10}; do
        read week <&3
        read log0 <&4
        read log1 <&5
        read log2 <&6
        read log3 <&7
        read log4 <&8
        if [ -n "$week" ]; then
            declare a$m=${week}
            declare b$m=${log0}
            declare c$m=${log1}
            declare d$m=${log2}
            declare e$m=${log3}
            declare f$m=${log4}
        else
            declare a$m=""
            declare b$m=0
            declare c$m=0
            declare d$m=0
            declare e$m=0
            declare f$m=0
        fi
    done
    field_0="[\"$a01\",\"$a02\",\"$a03\",\"$a04\",\"$a05\",\"$a06\",\"$a07\",\"$a08\",\"$a09\",\"$a10\"]"
    field_1="[$b01,$b02,$b03,$b04,$b05,$b06,$b07,$b08,$b09,$b10]"
    field_2="[$c01,$c02,$c03,$c04,$c05,$c06,$c07,$c08,$c09,$c10]"
    field_3="[$d01,$d02,$d03,$d04,$d05,$d06,$d07,$d08,$d09,$d10]"
    field_4="[$e01,$e02,$e03,$e04,$e05,$e06,$e07,$e08,$e09,$e10]"
    field_5="[$f01,$f02,$f03,$f04,$f05,$f06,$f07,$f08,$f09,$f10]"
    echo -e "data2='[{\"f0\":$field_0,\"f1\":$field_1,\"f2\":$field_2,\"f3\":$field_3,\"f4\":$field_4,\"f5\":$field_5}]';" >> "$data"
    
}

# ----------------------------------------------
create_db


( echo "1"
if [ `date +%d` = 28 ]; then
    save_topic_stats 0
fi

if [ `date +%w` = 7 ]; then
    save_word_stats
fi

#save_topic_stats 0
#save_word_stats
#mk_topic_stats
) | progress

function stats() {
    yad --html --uri="$DS/ifs/stats/1.html" --browser \
    --title="$(gettext "Stats")" \
    --name=Idiomind --class=Idiomind \
    --orient=vert --window-icon=idiomind --on-top --center \
    --buttons-layout=edge --gtkrc="$DS/default/gtkrc.cfg" \
    --width=670 --height=450 --borders=0  \
    --button="<small>$(gettext "Words")</small>":"$DS/ifs/mods/topic/Dictionary.sh" \
    --button="<small>$(gettext "Close")</small>":1
    
}

stats














