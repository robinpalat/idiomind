#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function progress() {
    yad --progress \
    --progress-text="$1" \
    --undecorated \
    --pulsate --auto-close --on-top \
    --skip-taskbar --center --no-buttons
}

function f_lock() {
    brk=0
    while true; do
        if [ ! -e "${1}" -o ${brk} -gt 20 ]; then touch "${1}" & break
        elif [ -e "${1}" ]; then sleep 1; fi
        let brk++
    done
}

function create_db() {
    if [ ! -e db="$DM_tl/.share/data/log.db" ]; then
        mtable="M`date +%y`"
        echo -n "create table if not exists ${mtable} \
        (month TEXT, val0 TEXT, val1 TEXT, val2 TEXT, val3 TEXT, val4 TEXT);" |sqlite3 ${db}
        wtable="W`date +%y`"
        echo -n "create table if not exists ${wtable} \
        (week TEXT, val0 TEXT, val1 TEXT, val2 TEXT, val3 TEXT, val4 TEXT, val5 TEXT);" |sqlite3 ${db}
        echo -n "$(date +%m/%d/%Y)" > ${tdate}
        echo -n "$(date +%m/%d/%Y)" > ${wdate}
    fi
}

function save_topic_stats() {
    count() {
        n=1; a=0; b=0; c=0; d=0; e=0
        old_IFS=$IFS; IFS=$'\n'
        for tpc in $(cd "$DM_tl"; find ./ -maxdepth 1 \
        -type d -not -path '*/\.*' |sed 's|\./||g;/^$/d'); do
            pos=0; rev=0; neg=0; emp=0; idd=0; cfg1=0; cfg2=0; stts=""
            dir1="$DM_tl/${tpc}/.conf"
            dir2="$DM_tl/${tpc}/.conf/practice"
            stts=$(sed -n 1p "$dir1/8.cfg")
            if [ -e "$dir1/1.cfg" ]; then
            cfg1=`egrep -cv '#|^$' < "$dir1/1.cfg"`; fi
            if [ -e "$dir1/2.cfg" ]; then
            cfg2=`egrep -cv '#|^$' < "$dir1/2.cfg"`; fi
            if [[ ${stts} =~ $numer ]]; then
                if [ ${stts} -le 10 -a ${stts} -ge 7 ]; then
                    neg=${cfg2}
                elif [ ${stts} = 5 -o ${stts} = 6 ]; then
                    pos=${cfg2}; rev=${cfg1}
                elif [ ${stts} = 3 -o ${stts} = 4 ]; then
                    pos=${cfg2}
                elif [ ${stts} = 12 ]; then
                    idd=$((cfg1+cfg2))
                else
                    pos=${cfg2}; emp=${cfg1}
                fi
            fi
            a=$((a+emp))
            b=$((b+pos))
            c=$((c+rev))
            d=$((d+neg))
            e=$((e+idd))
            echo "${a},${b},${c},${d},${e}"
        done |tail -n 1
        IFS=$old_IFS
    }

    data=`count`
    tot=`cut -d ',' -f 1 <<<"$data"`
    pos=`cut -d ',' -f 2 <<<"$data"`
    rev=`cut -d ',' -f 3 <<<"$data"`
    neg=`cut -d ',' -f 4 <<<"$data"`
    idd=`cut -d ',' -f 5 <<<"$data"`
    ! [[ ${tot} =~ $numer ]] && tot=0
    ! [[ ${pos} =~ $numer ]] && pos=0
    ! [[ ${rev} =~ $numer ]] && rev=0
    ! [[ ${neg} =~ $numer ]] && neg=0
    ! [[ ${idd} =~ $numer ]] && idd=0
    
    mtable="M`date +%y`"
    if [ $1 = 0 ]; then
        if [[ `sqlite3 ${db} "select month from '${mtable}' where month is '${month}';"` ]]; then :
        else
            sqlite3 ${db} "insert into ${mtable} (month,val0,val1,val2,val3,val4) \
            values ('${month}','${tot}','${pos}','${rev}','${neg}','${idd}');"
            echo -n "$(date +%m/%d/%Y)" > ${tdate}
        fi
    fi
    echo "${tot},${pos},${rev},${neg},${idd}" > ${pross}
}


function save_word_stats() {
    count() {
        a=0; b=0; c=10; d=0; e=0; f=0
        old_IFS=$IFS; IFS=$'\n'
        for tpc in $(cd "$DM_tl"; find ./ -maxdepth 1 \
        -type d -not -path '*/\.*' |sed 's|\./||g;/^$/d'); do
            log1=0; log2=0; log3=0
            _log1=0; _log2=0; _log3=0; _log4=0; _log5=0; cfg3=0; stts=""
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
                    :
                elif [ ${stts} = 5 -o ${stts} = 6 ]; then
                    _log1=${log1}; _log2=${log2}; _log3=${log3}
                    _log4=$((log2+log3))
                elif [ ${stts} = 3 -o ${stts} = 4 ]; then
                    _log1=${cfg3}
                elif [ ${stts} = 12 ]; then
                    _log5=${cfg3}
                else 
                    _log1=${log1}; _log2=${log2}; _log3=${log3}
                fi
            fi
            a=$((a+_log1))
            b=$((b+_log2))
            c=$((c+_log3))
            e=$((e+_log4))
            d=$((d+cfg3))
            f=$((f+_log5))
            echo "${d},${a},${b},${c},${e},${f}"
        done |tail -n 1
        IFS=$old_IFS
    }
    
    data=`count`
    log0=`cut -d ',' -f 1 <<< "${data}"`
    log1=`cut -d ',' -f 2 <<< "${data}"`
    log2=`cut -d ',' -f 3 <<< "${data}"`
    log3=`cut -d ',' -f 4 <<< "${data}"`
    log4=`cut -d ',' -f 5 <<< "${data}"`
    log5=`cut -d ',' -f 6 <<< "${data}"`
    ! [[ ${log0} =~ $numer ]] && log0=0
    ! [[ ${log1} =~ $numer ]] && log1=0
    ! [[ ${log2} =~ $numer ]] && log2=0
    ! [[ ${log3} =~ $numer ]] && log3=0
    ! [[ ${log4} =~ $numer ]] && log4=0
    ! [[ ${log5} =~ $numer ]] && log5=0
    wtable="W`date +%y`"
    if [[ `sqlite3 ${db} "select week from '${wtable}' where week is '${week^}';"` ]]; then :
    else
        sqlite3 ${db} "insert into ${wtable} (week,val0,val1,val2,val3,val4,val5) \
        values ('${week^}','${log0}','${log1}','${log2}','${log3}','${log4}','${log5}');"
        echo -n "$(date +%m/%d/%Y)" > ${wdate}
    fi
}


function mk_topic_stats() {
    data="/tmp/.idiomind_stats"
    month=`date +%m`
    mtable="M`date +%y`"
    exec 4< <(sqlite3 "$db" "select val0 FROM ${mtable}" |tail -n11)
    exec 5< <(sqlite3 "$db" "select val1 FROM ${mtable}" |tail -n11)
    exec 6< <(sqlite3 "$db" "select val2 FROM ${mtable}" |tail -n11)
    exec 7< <(sqlite3 "$db" "select val3 FROM ${mtable}" |tail -n11)
    exec 8< <(sqlite3 "$db" "select val4 FROM ${mtable}" |tail -n11)
    
    for m in {01..12}; do
        declare t$m=0; declare p$m=0
        declare r$m=0; declare n$m=0
        declare i$m=0
    done
    
    for m in {01..12}; do
        if [[ ${month} = ${m} ]]; then
            declare t$m=`cut -d ',' -f 1 < ${pross}`
            declare p$m=`cut -d ',' -f 2 < ${pross}`
            declare r$m=`cut -d ',' -f 3 < ${pross}`
            declare n$m=`cut -d ',' -f 4 < ${pross}`
            declare i$m=`cut -d ',' -f 5 < ${pross}`
            rm -f ${pross}; break
        else
            read cfg0 <&4
            read cfg1 <&5
            read cfg2 <&6
            read cfg3 <&7
            read cfg4 <&7
            ! [[ ${cfg0} =~ $numer ]] && cfg0=0
            ! [[ ${cfg1} =~ $numer ]] && cfg1=0
            ! [[ ${cfg2} =~ $numer ]] && cfg2=0
            ! [[ ${cfg3} =~ $numer ]] && cfg3=0
            ! [[ ${cfg4} =~ $numer ]] && cfg4=0
            declare t$m=${cfg0}
            declare p$m=${cfg1}
            declare r$m=${cfg2}
            declare n$m=${cfg3}
            declare n$m=${cfg4}
        fi
    done
    field_0="[$t01,$t02,$t03,$t04,$t05,$t06,$t07,$t08,$t09,$t10,$t11,$t12]"
    field_1="[$p01,$p02,$p03,$p04,$p05,$p06,$p07,$p08,$p09,$p10,$p11,$p12]"
    field_2="[$r01,$r02,$r03,$r04,$r05,$r06,$r07,$r08,$r09,$r10,$r11,$r12]"
    field_3="[$n01,$n02,$n03,$n04,$n05,$n06,$n07,$n08,$n09,$n10,$n11,$n12]"
    field_4="[$i01,$i02,$i03,$i04,$i05,$i06,$i07,$i08,$i09,$i10,$i11,$i12]"
    echo -e "data1='[{\"f0\":$field_0,\"f1\":$field_1,\"f2\":$field_2,\"f3\":$field_3,\"f4\":$field_4}]';" > ${data}

    wtable="W`date +%y`"
    exec 3< <(sqlite3 "$db" "select week FROM ${wtable}" |tail -n9)
    exec 4< <(sqlite3 "$db" "select val0 FROM ${wtable}" |tail -n9)
    exec 5< <(sqlite3 "$db" "select val1 FROM ${wtable}" |tail -n9)
    exec 6< <(sqlite3 "$db" "select val2 FROM ${wtable}" |tail -n9)
    exec 7< <(sqlite3 "$db" "select val3 FROM ${wtable}" |tail -n9)
    exec 8< <(sqlite3 "$db" "select val4 FROM ${wtable}" |tail -n9)
    exec 9< <(sqlite3 "$db" "select val5 FROM ${wtable}" |tail -n9)
    for m in {01..10}; do
        read week <&3
        read log0 <&4
        read log1 <&5
        read log2 <&6
        read log3 <&7
        read log4 <&8
        read log5 <&8
        if [ -n "$week" ]; then
            ! [[ ${log0} =~ $numer ]] && log0=0
            ! [[ ${log1} =~ $numer ]] && log1=0
            ! [[ ${log2} =~ $numer ]] && log2=0
            ! [[ ${log3} =~ $numer ]] && log3=0
            ! [[ ${log4} =~ $numer ]] && log4=0
            ! [[ ${log5} =~ $numer ]] && log5=0
            declare a$m=${week}
            declare b$m=${log0}
            declare c$m=${log1}
            declare d$m=${log2}
            declare e$m=${log3}
            declare f$m=${log4}
            declare g$m=${log5}
        else
            declare a$m=" "
            declare b$m=0
            declare c$m=0
            declare d$m=0
            declare e$m=0
            declare f$m=0
            declare g$m=0
        fi
    done
    field_0="[\"$a01\",\"$a02\",\"$a03\",\"$a04\",\"$a05\",\"$a06\",\"$a07\",\"$a08\",\"$a09\",\"$a10\"]"
    field_1="[$b01,$b02,$b03,$b04,$b05,$b06,$b07,$b08,$b09,$b10]"
    field_2="[$c01,$c02,$c03,$c04,$c05,$c06,$c07,$c08,$c09,$c10]"
    field_3="[$d01,$d02,$d03,$d04,$d05,$d06,$d07,$d08,$d09,$d10]"
    field_4="[$e01,$e02,$e03,$e04,$e05,$e06,$e07,$e08,$e09,$e10]"
    field_5="[$f01,$f02,$f03,$f04,$f05,$f06,$f07,$f08,$f09,$f10]"
    field_6="[$g01,$g02,$g03,$g04,$g05,$g06,$g07,$g08,$g09,$g10]"
    echo -e "data2='[{\"f0\":$field_0,\"f1\":$field_1,\"f2\":$field_2,\"f3\":$field_3,\"f4\":$field_4,\"f5\":$field_5,\"f6\":$field_6}]';" >> ${data}
    cp -f ${data} ${databk}
}

pross="$DM_tl/.share/data/pre_data"
wdate="$DM_tl/.share/data/wdate"
tdate="$DM_tl/.share/data/tdate"
data="/tmp/.idiomind_stats"
databk="$DM_tl/.share/data/idiomind_stats"
db="$DM_tl/.share/data/log.db"
numer='^[0-9]+$'
week=`date +%b%d`
month=`date +%b`
create_db
dtweek=`date +%w`
dtmnth=`date +%d`
val1=0; val2=0

function pre_comp() {
    if [ -e ${tdate} ]; then
        dte=$(< ${tdate})
        if [ $((($(date +%s)-$(date -d ${dte} +%s))/(24*60*60))) -gt 31 ]; then
            rm -f ${tdate}
        fi
    fi
    if [ -e ${wdate} ]; then
        dte=$(< ${wdate})
        if [ $((($(date +%s)-$(date -d ${dte} +%s))/(24*60*60))) -gt 7 ]; then
            rm -f ${wdate}
        fi
    fi
    if [ ${dtmnth} = 01 -o ${dtweek} = 0 -o ! -e ${data} -o \
    -e ${pross} -o ! -e ${tdate} -o ! -e ${wdate} ]; then
    
        f_lock "$DT/p_stats"
        [ ${dtmnth} = 01 -o ! -e ${tdate} ] && val1=1
        [ ${dtweek} = 0 -o ! -e ${wdate} ] && val2=1
        
        if [ ! -e ${data} -o -e ${pross} ]; then
            val1=1
        fi

        if [ ${val1} = 1 -a ${val2} != 1 ]; then
            save_topic_stats 0
        elif [ ${val2} = 1 ]; then
            save_topic_stats 0; save_word_stats 0
        fi

        mk_topic_stats
        rm -f "$DT/p_stats"
    fi
}

function stats() {
    if [ ! -e ${data} -o -e ${pross} ]; then
        cp -f ${databk} ${data}
        f_lock "$DT/p_stats"
        ( echo 1;
        save_topic_stats 1
        mk_topic_stats
        rm -f "$DT/p_stats"
        ) | progress &
    fi
    yad --html --uri="$DS/ifs/stats/1.html" --browser \
    --title="$(gettext "Stats (Beta)")" \
    --name=Idiomind --class=Idiomind \
    --orient=vert --window-icon=idiomind --center --on-top \
    --width=650 --height=410 --borders=0 \
    --no-buttons
} >/dev/null 2>&1
