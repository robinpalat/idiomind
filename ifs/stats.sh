#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function f_lock() {
    brk=0
    while true; do
        if [ ! -e "${1}" -o ${brk} -gt 20 ]; then touch "${1}" & break
        elif [ -e "${1}" ]; then sleep 1; fi; let brk++
    done
}

function create_db() {
    if [ ! -e "${db}" ]; then
        echo -n "create table if not exists ${mtable} \
        (month TEXT, val0 TEXT, val1 TEXT, val2 TEXT, val3 TEXT, val4 TEXT);" |sqlite3 "${db}"
        echo -n "create table if not exists ${wtable} \
        (week TEXT, val0 TEXT, val1 TEXT, val2 TEXT, val3 TEXT, val4 TEXT, val5 TEXT);" |sqlite3 "${db}"
        echo -n "create table if not exists 'expire_month' (date TEXT);" |sqlite3 "${db}"
        echo -n "create table if not exists 'expire_week' (date TEXT);" |sqlite3 "${db}"
        touch "${no_data}"
    fi
}

function save_topic_stats() {
    count() {
        n=1; f0=0; f1=0; f2=0; f3=0; f4=0
        old_IFS=$IFS; IFS=$'\n'
        for tpc in $(cd "$DM_tl"; find ./ -maxdepth 1 \
        -type d -not -path '*/\.*' |sed 's|\./||g;/^$/d'); do
            C0=0; C1=0; C2=0; C3=0; C4=0; G1=0; G2=0
            dir1="$DM_tl/${tpc}/.conf"
            stts=""; stts=$(sed -n 1p "$dir1/8.cfg")

            if [ -e "$dir1/1.cfg" ]; then
                G1=$(egrep -cv '#|^$' "$dir1/1.cfg"); fi
            if [ -e "$dir1/2.cfg" ]; then
                G2=$(egrep -cv '#|^$' "$dir1/2.cfg"); fi

            if [[ ${stts} =~ $int ]]; then
                if [ ${stts} -le 10 -a ${stts} -ge 7 ]; then
                    C3=${G2}
                elif [ ${stts} = 5 -o ${stts} = 6 ]; then
                    C1=${G2}; C2=${G1}
                elif [ ${stts} = 3 -o ${stts} = 4 ]; then
                    C1=${G2}
                elif [ ${stts} = 12 ]; then
                    C4=$((G1+G2))
                else
                    C1=${G2}; C0=${G1}
                fi
            fi
            f0=$((f0+C0))
            f1=$((f1+C1))
            f2=$((f2+C2))
            f3=$((f3+C3))
            f4=$((f4+C4))
            echo "${f0},${f1},${f2},${f3},${f4}"
            
        done |tail -n 1
        IFS=$old_IFS
    }

    rdata=$(count)
    f0=$(cut -d ',' -f 1 <<< "$rdata"); ! [[ ${f0} =~ $int ]] && f0=0
    f1=$(cut -d ',' -f 2 <<< "$rdata"); ! [[ ${f1} =~ $int ]] && f1=0
    f2=$(cut -d ',' -f 3 <<< "$rdata"); ! [[ ${f2} =~ $int ]] && f2=0
    f3=$(cut -d ',' -f 4 <<< "$rdata"); ! [[ ${f3} =~ $int ]] && f3=0
    f4=$(cut -d ',' -f 5 <<< "$rdata"); ! [[ ${f4} =~ $int ]] && f4=0

    if [ -f "${no_data}" ] && [[ ${f0} -gt 10 ]]; then
        rm -f "${no_data}"
    elif [[ ${f0} -lt 10 ]]; then
        touch "${no_data}"
    fi

    if [[ "$1" = 1 ]]; then
        if [[ $(sqlite3 ${db} "select month from '${mtable}' where month is '${month}';") ]]; then :
        else
            dte=$(sqlite3 ${db} "select date from 'expire_month';")
            sqlite3 ${db} "insert into ${mtable} (month,val0,val1,val2,val3,val4) \
            values ('${month}','${f0}','${f1}','${f2}','${f3}','${f4}');"
        fi
    fi
    echo "${f0},${f1},${f2},${f3},${f4}" > "${pross}"
}

function save_word_stats() {
    count() {
        f0=0; f1=0; f2=0; f3=0; f4=0; f5=0
        old_IFS=$IFS; IFS=$'\n'
        for tpc in $(cd "$DM_tl"; find ./ -maxdepth 1 \
        -type d -not -path '*/\.*' |sed 's|\./||g;/^$/d'); do
            G0=0; G1=0; G2=0; G3=0
            C1=0; C2=0; C3=0; C4=0; C5=0
            dir1="$DM_tl/${tpc}/.conf"
            dir2="$dir1/practice"
            stts=""; stts=$(sed -n 1p "$dir1/8.cfg")
            
            if [ -f "$dir1/3.cfg" ]; then
                G0=$(egrep -cv '#|^$' "$dir1/3.cfg"); fi
            if [ -f "$dir2/log1" ]; then
                G1=$(egrep -cv '#|^$' "$dir2/log1"); fi
            if [ -f "$dir2/log2" ]; then
                G2=$(egrep -cv '#|^$' "$dir2/log2"); fi
            if [ -f "$dir2/log3" ]; then
                G3=$(egrep -cv '#|^$' "$dir2/log3"); fi
            
            if [[ ${stts} =~ $int ]]; then
                if [ ${stts} -le 10 -a ${stts} -ge 7 ]; then :
                elif [ ${stts} = 5 -o ${stts} = 6 ]; then
                    C1=${G1}; C2=${G2}; C3=${G3}
                    C4=$((G2+G3))
                elif [ ${stts} = 3 -o ${stts} = 4 ]; then
                    C1=${G0}
                elif [ ${stts} = 12 ]; then
                    C5=${G0}
                else 
                    C1=${G1}; C2=${G2}; C3=${G3}
                fi
            fi
            f0=$((f0+G0))
            f1=$((f1+C1))
            f2=$((f2+C2))
            f3=$((f3+C3))
            f4=$((f4+C4))
            f5=$((f5+C5))
            echo "${f0},${f1},${f2},${f3},${f4},${f5}"
            
        done |tail -n 1
        IFS=$old_IFS
    }

    if [[ $(sqlite3 ${db} "select week from '${wtable}' where week is '${week^}';") ]]; then :
    else
        rdata=$(count)
        D0=$(cut -d ',' -f 1 <<< "${rdata}"); ! [[ ${D0} =~ $int ]] && D0=0
        D1=$(cut -d ',' -f 2 <<< "${rdata}"); ! [[ ${D1} =~ $int ]] && D1=0
        D2=$(cut -d ',' -f 3 <<< "${rdata}"); ! [[ ${D2} =~ $int ]] && D2=0
        D3=$(cut -d ',' -f 4 <<< "${rdata}"); ! [[ ${D3} =~ $int ]] && D3=0
        D4=$(cut -d ',' -f 5 <<< "${rdata}"); ! [[ ${D4} =~ $int ]] && D4=0
        D5=$(cut -d ',' -f 6 <<< "${rdata}"); ! [[ ${D5} =~ $int ]] && D5=0
        
        dte=$(sqlite3 ${db} "select date from 'expire_month';")
        sqlite3 "${db}" "insert into ${wtable} (week,val0,val1,val2,val3,val4,val5) \
        values ('${week^}','${D0}','${D1}','${D2}','${D3}','${D4}','${D5}');"
    fi
}

function mk_topic_stats() {
    exec 4< <(sqlite3 "$db" "select val0 FROM ${mtable}" |tail -n11)
    exec 5< <(sqlite3 "$db" "select val1 FROM ${mtable}" |tail -n11)
    exec 6< <(sqlite3 "$db" "select val2 FROM ${mtable}" |tail -n11)
    exec 7< <(sqlite3 "$db" "select val3 FROM ${mtable}" |tail -n11)
    exec 8< <(sqlite3 "$db" "select val4 FROM ${mtable}" |tail -n11)
    
    for m in {01..12}; do
        declare a$m=0
        declare b$m=0
        declare c$m=0
        declare d$m=0
        declare e$m=0
    done
    
    for m in {01..12}; do
        if [[ ${dmonth} = ${m} ]]; then
            declare a$m=$(cut -d ',' -f 1 < ${pross})
            declare b$m=$(cut -d ',' -f 2 < ${pross})
            declare c$m=$(cut -d ',' -f 3 < ${pross})
            declare d$m=$(cut -d ',' -f 4 < ${pross})
            declare e$m=$(cut -d ',' -f 5 < ${pross})
            rm -f ${pross}; break
        else
            read D0 <&4; ! [[ ${D0} =~ $int ]] && D0=0
            read D1 <&5; ! [[ ${D1} =~ $int ]] && D1=0
            read D2 <&6; ! [[ ${D2} =~ $int ]] && D2=0
            read D3 <&7; ! [[ ${D3} =~ $int ]] && D3=0
            read D4 <&8; ! [[ ${D4} =~ $int ]] && D4=0
            declare a$m=${D0}
            declare b$m=${D1}
            declare c$m=${D2}
            declare d$m=${D3}
            declare e$m=${D4}
        fi
    done
    field0="[$a01,$a02,$a03,$a04,$a05,$a06,$a07,$a08,$a09,$a10,$a11,$a12]"
    field1="[$b01,$b02,$b03,$b04,$b05,$b06,$b07,$b08,$b09,$b10,$b11,$b12]"
    field2="[$c01,$c02,$c03,$c04,$c05,$c06,$c07,$c08,$c09,$c10,$c11,$c12]"
    field3="[$d01,$d02,$d03,$d04,$d05,$d06,$d07,$d08,$d09,$d10,$d11,$d12]"
    field4="[$e01,$e02,$e03,$e04,$e05,$e06,$e07,$e08,$e09,$e10,$e11,$e12]"
    echo -e "data1='[{\"f0\":$field0,\"f1\":$field1,\"f2\":$field2,\"f3\":$field3,\"f4\":$field4}]';" > "${data}"

    exec 3< <(sqlite3 "$db" "select week FROM ${wtable}" |tail -n9)
    exec 4< <(sqlite3 "$db" "select val0 FROM ${wtable}" |tail -n9)
    exec 5< <(sqlite3 "$db" "select val1 FROM ${wtable}" |tail -n9)
    exec 6< <(sqlite3 "$db" "select val2 FROM ${wtable}" |tail -n9)
    exec 7< <(sqlite3 "$db" "select val3 FROM ${wtable}" |tail -n9)
    exec 8< <(sqlite3 "$db" "select val4 FROM ${wtable}" |tail -n9)
    exec 9< <(sqlite3 "$db" "select val5 FROM ${wtable}" |tail -n9)
    for m in {01..10}; do
        read week <&3
        read D0 <&4
        read D1 <&5
        read D2 <&6
        read D3 <&7
        read D4 <&8
        read D5 <&9
        if [ -n "$week" ]; then
            ! [[ ${D0} =~ $int ]] && D0=0
            ! [[ ${D1} =~ $int ]] && D1=0
            ! [[ ${D2} =~ $int ]] && D2=0
            ! [[ ${D3} =~ $int ]] && D3=0
            ! [[ ${D4} =~ $int ]] && D4=0
            ! [[ ${D5} =~ $int ]] && D5=0
            declare a$m=${week}
            declare b$m=${D0}
            declare c$m=${D1}
            declare d$m=${D2}
            declare e$m=${D3}
            declare f$m=${D4}
            declare g$m=${D5}
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
    fieldw="[\"$a01\",\"$a02\",\"$a03\",\"$a04\",\"$a05\",\"$a06\",\"$a07\",\"$a08\",\"$a09\",\"$a10\"]"
    field0="[$b01,$b02,$b03,$b04,$b05,$b06,$b07,$b08,$b09,$b10]"
    field1="[$c01,$c02,$c03,$c04,$c05,$c06,$c07,$c08,$c09,$c10]"
    field2="[$d01,$d02,$d03,$d04,$d05,$d06,$d07,$d08,$d09,$d10]"
    field3="[$e01,$e02,$e03,$e04,$e05,$e06,$e07,$e08,$e09,$e10]"
    field4="[$f01,$f02,$f03,$f04,$f05,$f06,$f07,$f08,$f09,$f10]"
    field5="[$g01,$g02,$g03,$g04,$g05,$g06,$g07,$g08,$g09,$g10]"
    echo -e "data2='[{\"wk\":$fieldw,\"f0\":$field0,\"f1\":$field1,\"f2\":$field2,\"f3\":$field3,\"f4\":$field4,\"f5\":$field5}]';" >> "${data}"
    cp -f "${data}" "${databk}"
}

pross="$DM_tls/data/pre_data"
data="/tmp/.idiomind_stats"
no_data="${DM_tls}/data/no_data"
databk="$DM_tls/data/idiomind_stats"
db="$DM_tls/data/log.db"
int='^[0-9]+$'
week=$(date +%b%d)
month=$(date +%b)
dtweek=$(date +%w)
dtmnth=$(date +%d)
mtable="M$(date +%y)"
wtable="W$(date +%y)"
dmonth=$(date +%m)
cdate=$(date +%m/%d/%Y)
create_db

function chktb() {
    atable=$1; days=$2
    dte=$(sqlite3 ${db} "select date from '${atable}';")>/dev/null 2>&1
    if ! [[ ${dte} =~ ^[0-9]{2}/[0-9]{2}/[0-9]{4}$ ]]; then
        if [ -z "${dte}" ]; then
            sqlite3 "${db}" "insert into '${atable}' (date) values ('${cdate}');">/dev/null 2>&1
        else
            sqlite3 ${db} "update '${atable}' set date='${cdate}' where date='${dte}';">/dev/null 2>&1
        fi
        echo 1
    else
        if [ $((($(date +%s)-$(date -d ${dte} +%s))/(24*60*60))) -gt ${days} ]; then
        sqlite3 ${db} "update '${atable}' set date='${cdate}' where date='${dte}';">/dev/null 2>&1; echo 0
        else echo 1; fi
    fi
}

function pre_comp() {
    f_lock "$DT/p_stats"
    val1=0; val2=0
    echo -n "create table if not exists 'expire_month' (date TEXT);" |sqlite3 "${db}"
    echo -n "create table if not exists 'expire_week' (date TEXT);" |sqlite3 "${db}"
    
    [ ${dtmnth} = 01 -o $(chktb 'expire_month' 31) = 0 ] && val1=1
    [ ${dtweek} = 0 -o $(chktb 'expire_week' 7) = 0 ] && val2=1

    if [ ${val1} = 1 -a ${val2} != 1 ]; then
        save_topic_stats 1
    elif [ ${val2} = 1 ]; then
        save_topic_stats ${val1}
        save_word_stats
    else
        save_topic_stats 0
    fi

    rm -f "$DT/p_stats"
}

function stats() {
    if [ ! -e "${data}" -o -e "${pross}" ]; then
        f_lock "$DT/p_stats"
        [ ! -e "${data}" ] && cp -f "${databk}" "${data}"
        [ ! -e "${pross}" ] && save_topic_stats 0
        mk_topic_stats
        [ -e "$DT/p_stats"  ] && rm "$DT/p_stats"
    fi
    if [ -f "${no_data}" ]; then
        source "$DS/ifs/cmns.sh"
        msg "$(gettext "Insufficient data")\n" dialog-information " "
    else
        yad --html --uri="$DS/default/pg1.html" \
        --title="$(gettext "Stats (beta)")" \
        --name=Idiomind --class=Idiomind \
        --browser --encoding=UTF-8 \
        --orient=vert --window-icon=idiomind --center --on-top \
        --width=650 --height=410 --borders=0 \
        --no-buttons
    fi
} >/dev/null 2>&1
