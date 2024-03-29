#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"

function weekof() {
    thisweek=$1
    year=$(date +%Y)
    date_fmt="+%b%d"
    weeknum_Jan1=$(date -d $year-01-01 +%W)
    weekday_Jan1=$(date -d $year-01-01 +%u)
    if ((weeknum_Jan1)); then
        first_Mon=$year-01-01
    else
        first_Mon=$year-01-$((01 + (7 - weekday_Jan1 + 1) ))
    fi
    echo "$(date -d "$first_Mon +$((thisweek - 1)) week" "$date_fmt")"
}

function create_db() {
    if [ ! -f "${db}" ]; then
        echo -e "-- new log database\n"
        echo -n "create table if not exists ${mtable} \
        (month TEXT, val0 TEXT, val1 TEXT, val2 TEXT, val3 TEXT, val4 TEXT);" |sqlite3 "${db}"
        for m in {01..12}; do sqlite3 ${db} "insert into ${mtable} (month) values ('${m}');"; done
        echo -n "create table if not exists ${wtable} \
        (w TEXT, week TEXT, val0 TEXT, val1 TEXT, val2 TEXT, val3 TEXT, val4 TEXT, val5 TEXT, val6 TEXT);" |sqlite3 "${db}"
        echo -n "create table if not exists 'expire_month' (date TEXT);" |sqlite3 "${db}"
        echo -n "create table if not exists 'expire_week' (date TEXT);" |sqlite3 "${db}"
        touch "${no_data}"
        val1=1; val2=1; pre_comp
     fi
     if ! [[ "$(sqlite3 ${db} "SELECT name FROM sqlite_master WHERE type='table' AND name='$mtable';")" ]] || \
     ! [[ "$(sqlite3 ${db} "SELECT name FROM sqlite_master WHERE type='table' AND name='$wtable';")" ]]; then
        echo -e "-- new table for log database\n"
        echo -n "create table if not exists ${mtable} \
        (month TEXT, val0 TEXT, val1 TEXT, val2 TEXT, val3 TEXT, val4 TEXT);" |sqlite3 "${db}"
        for m in {01..12}; do sqlite3 ${db} "insert into ${mtable} (month) values ('${m}');"; done
        echo -n "create table if not exists ${wtable} \
        (w TEXT, week TEXT, val0 TEXT, val1 TEXT, val2 TEXT, val3 TEXT, val4 TEXT, val5 TEXT, val6 TEXT);" |sqlite3 "${db}"
        echo -n "create table if not exists 'expire_month' (date TEXT);" |sqlite3 "${db}"
        echo -n "create table if not exists 'expire_week' (date TEXT);" |sqlite3 "${db}"
        touch "${no_data}"
    fi
}

function coll_tpc_stats() {
    
    compute() {
        n=1; f0=0; f1=0; f2=0; f3=0; f4=0
        old_IFS=$IFS; IFS=$'\n'
        for tpc in $(cd "$DM_tl"; find ./ -maxdepth 1 \
        -type d -not -path '*/\.*' |sed 's|\./||g;/^$/d'); do
            C0=0; C1=0; C2=0; C3=0; C4=0; G1=0; G2=0
            dir1="$DM_tl/${tpc}/.conf"
            unset stts
            stts=$(sed -n 1p "$dir1/stts")
            if [[ ${stts} =~ $int ]]; then
                if [ ${stts} -le 10 -a ${stts} -ge 7 ]; then C3=1
                elif [ ${stts} = 5 -o ${stts} = 6 ]; then C2=1
                elif [ ${stts} = 3 -o ${stts} = 4 ]; then C1=1
                elif [ ${stts} = 0 ]; then C4=1
                elif [ ${stts} = 1 ]; then C0=1
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

    rdata=$(compute)
    f0=$(cut -d ',' -f 1 <<< "$rdata"); ! [[ ${f0} =~ $int ]] && f0=0
    f1=$(cut -d ',' -f 2 <<< "$rdata"); ! [[ ${f1} =~ $int ]] && f1=0
    f2=$(cut -d ',' -f 3 <<< "$rdata"); ! [[ ${f2} =~ $int ]] && f2=0
    f3=$(cut -d ',' -f 4 <<< "$rdata"); ! [[ ${f3} =~ $int ]] && f3=0
    f4=$(cut -d ',' -f 5 <<< "$rdata"); ! [[ ${f4} =~ $int ]] && f4=0

    if [ -f "${no_data}" ] && [[ ${f0} -gt 10 ]]; then
        cleanups "${no_data}"
    elif [[ ${f0} -lt 10 ]]; then
        touch "${no_data}"
    fi
    if [[ "$1" = 1 ]]; then
        sqlite3 ${db} "update ${mtable} set val0='${f0}' where month='${dmonth}';"
        sqlite3 ${db} "update ${mtable} set val1='${f1}' where month='${dmonth}';"
        sqlite3 ${db} "update ${mtable} set val2='${f2}' where month='${dmonth}';"
        sqlite3 ${db} "update ${mtable} set val3='${f3}' where month='${dmonth}';"
        sqlite3 ${db} "update ${mtable} set val4='${f4}' where month='${dmonth}';"
    fi
    echo "${f0},${f1},${f2},${f3},${f4}" > "${pross}"
}

function coll_items_stats() {
    
    compute() {
        tpc_practs="$(grep -o -P "(?<=0p.).*(?=\.p0)" "${log}" |tr '|' '\n')"
        tpc_practs_ok="$(grep -o -P "(?<=1p.).*(?=\.p1)" "${log}" |tr '|' '\n')"
        c_tpc_practs=$(grep -c '[^[:space:]]' <<< "${tpc_practs}")
        c_tpc_practs_ok=$(grep -c '[^[:space:]]' <<< "${tpc_practs_ok}")
        S1w1="$(grep -o -P "(?<=w1.).*(?=\.w1.<1>)" "${log}" |tr '|' '\n' |sed '/^$/d' |uniq)" # new words learned
        c_S1w1="$(grep -c '[^[:space:]]' <<< "$S1w1")"
        S1w2="$(grep -o -P "(?<=w2.).*(?=\.w2.<1>)" "${log}" |tr '|' '\n' |sed '/^$/d' |uniq)" # words learning (new)
        c_S1w2="$(grep -c '[^[:space:]]' <<< "$S1w2")"
        S1w3="$(grep -o -P "(?<=w3.).*(?=\.w3.<1>)" "${log}" |tr '|' '\n' |sed '/^$/d' |uniq)" # words learning (new)
        c_S1w3="$(grep -c '[^[:space:]]' <<< "$S1w3")"
        cc_S1w=$((c_S1w2+c_S1w3)) # words learning (new) x 2
        S5w1="$(grep -o -P "(?<=w1.).*(?=\.w1.<5>)" "${log}" |tr '|' '\n' |sed '/^$/d' |uniq)" # reviewed words
        c_S5w1="$(grep -c '[^[:space:]]' <<< "$S5w1")"
        S5w2="$(grep -o -P "(?<=w2.).*(?=\.w2.<5>)" "${log}" |tr '|' '\n' |sed '/^$/d' |uniq)" # forgotten words
        c_S5w2="$(grep -c '[^[:space:]]' <<< "$S5w2")"
        S5w3="$(grep -o -P "(?<=w3.).*(?=\.w3.<5>)" "${log}" |tr '|' '\n' |sed '/^$/d' |uniq)" # forgotten words
        c_S5w3="$(grep -c '[^[:space:]]' <<< "$S5w3")"
        cc_S5w=$((c_S5w2+c_S5w3)) # forgotten words x2 
        S6w1="$(grep -o -P "(?<=w1.).*(?=\.w1.<6>)" "${log}" |tr '|' '\n' |sed '/^$/d' |uniq)" # words reviewed
        c_S6w1="$(grep -c '[^[:space:]]' <<< "$S6w1")"
        S6w2="$(grep -o -P "(?<=w2.).*(?=\.w2.<6>)" "${log}" |tr '|' '\n' |sed '/^$/d' |uniq)" # Difficult Words to Remember
        c_S6w2="$(grep -c '[^[:space:]]' <<< "$S6w2")"
        S6w3="$(grep -o -P "(?<=w3.).*(?=\.w3.<6>)" "${log}" |tr '|' '\n' |sed '/^$/d' |uniq)" # Difficult Words to Remember
        c_S6w3="$(grep -c '[^[:space:]]' <<< "$S6w3")"
        cc_S6w=$((c_S6w2+c_S6w3)) # Difficult Words to Remember
        cc_S56w=$((c_S5w1+c_S6w1)) # assimilated words ok
        # new words learned | words learning (new) | forgotten words |
        # Difficult Words to Remember | words reviewed | test pass | pract act
        echo "${c_S1w1},${cc_S1w},${cc_S5w},${cc_S6w},${cc_S56w},${c_tpc_practs_ok},${c_tpc_practs}"
    }

    w=${dw}
    until [ ${w} -lt 0 ]; do
        if [[ -n "$(sqlite3 ${db} "select w from '${wtable}' where w is '${w}';")" ]]; then
            break
        else
            if [ ${w} = ${dw} -a $(date +%u) != 7 ]; then
                :
            else 
                echo ${w} >> "$DT/weekscnt"
            fi
        fi
        let w--
    done

    if [ -f "$DT/weekscnt" ]; then
        tac "$DT/weekscnt" |head -n12 |while read -r w; do
            export log="$DC/logs/${w}.log"
            if [ -f "${log}" ]; then rdata=$(compute); else rdata="0,0,0,0,0,0,0"; fi
            weeklbl=$(weekof $w)
            D0=$(cut -d ',' -f 1 <<< "${rdata}"); ! [[ ${D0} =~ $int ]] && D0=0
            D1=$(cut -d ',' -f 2 <<< "${rdata}"); ! [[ ${D1} =~ $int ]] && D1=0
            D2=$(cut -d ',' -f 3 <<< "${rdata}"); ! [[ ${D2} =~ $int ]] && D2=0
            D3=$(cut -d ',' -f 4 <<< "${rdata}"); ! [[ ${D3} =~ $int ]] && D3=0
            D4=$(cut -d ',' -f 5 <<< "${rdata}"); ! [[ ${D4} =~ $int ]] && D4=0
            D5=$(cut -d ',' -f 6 <<< "${rdata}"); ! [[ ${D5} =~ $int ]] && D5=0
            D6=$(cut -d ',' -f 7 <<< "${rdata}"); ! [[ ${D6} =~ $int ]] && D6=0
            sqlite3 "${db}" "insert into ${wtable} (w,week,val0,val1,val2,val3,val4,val5,val6) \
            values ('${w}','${weeklbl^}','${D0}','${D1}','${D2}','${D3}','${D4}','${D5}','${D6}');"
            cleanups "${log}"
        done
    fi
    cleanups "$DT/weekscnt"
}

function mk_tpc_stats() {
    
    exec 4< <(sqlite3 "$db" "select val0 FROM ${mtable}")
    exec 5< <(sqlite3 "$db" "select val1 FROM ${mtable}")
    exec 6< <(sqlite3 "$db" "select val2 FROM ${mtable}")
    exec 7< <(sqlite3 "$db" "select val3 FROM ${mtable}")
    exec 8< <(sqlite3 "$db" "select val4 FROM ${mtable}")
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
            cleanups ${pross}; break
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
    
    # words
    exec 4< <(sqlite3 "$db" "select week FROM ${wtable}" |tail -n17)
    exec 5< <(sqlite3 "$db" "select val0 FROM ${wtable}" |tail -n17)
    exec 6< <(sqlite3 "$db" "select val1 FROM ${wtable}" |tail -n17)
    exec 7< <(sqlite3 "$db" "select val2 FROM ${wtable}" |tail -n17)
    exec 8< <(sqlite3 "$db" "select val3 FROM ${wtable}" |tail -n17)
    exec 9< <(sqlite3 "$db" "select val4 FROM ${wtable}" |tail -n17)

    for m in {01..17}; do
        read week <&4
        read D0 <&5
        read D1 <&6
        read D2 <&7
        read D3 <&8
        read D4 <&9
        if [ -n "$week" ]; then
            ! [[ ${D0} =~ $int ]] && D0=0
            ! [[ ${D1} =~ $int ]] && D1=0
            ! [[ ${D2} =~ $int ]] && D2=0
            ! [[ ${D3} =~ $int ]] && D3=0
            ! [[ ${D4} =~ $int ]] && D4=0
            declare a$m="${week}"
            declare b$m=${D0}
            declare c$m=${D1}
            declare d$m=${D2}
            declare e$m=${D3}
            declare f$m=${D4}
        else
            declare a$m=" "
            declare b$m=0
            declare c$m=0
            declare d$m=0
            declare e$m=0
            declare f$m=0
        fi
    done
    
    a="$(sqlite3 "$db" "select val5 FROM ${wtable}" |tail -n17)"
    b="$(sqlite3 "$db" "select val6 FROM ${wtable}" |tail -n17)"
    
    for m in {1..17}; do
        D5="$(sed -n ${m}p <<< "$a")"
        D6="$(sed -n ${m}p <<< "$b")"
        if [ -n "$D5" ]; then
            ! [[ ${D5} =~ $int ]] && D5=0
            ! [[ ${D6} =~ $int ]] && D6=0
            declare g$m=${D5}
            declare h$m=${D6}
        else
            declare g$m=0
            declare h$m=0
        fi
    done
    
    fieldw="[\"$a01\",\"$a02\",\"$a03\",\"$a04\",\"$a05\",\"$a06\",\"$a07\",\"$a08\",\"$a09\",\"$a10\",\"$a11\",\"$a12\",\"$a13\",\"$a14\",\"$a15\",\"$a16\",\"$a17\"]"
    field0="[$b01,$b02,$b03,$b04,$b05,$b06,$b07,$b08,$b09,$b10,$b11,$b12,$b13,$b14,$b15,$b16,$b17]"
    field1="[$c01,$c02,$c03,$c04,$c05,$c06,$c07,$c08,$c09,$c10,$c11,$c12,$c13,$c14,$c15,$c16,$c17]"
    field2="[$d01,$d02,$d03,$d04,$d05,$d06,$d07,$d08,$d09,$d10,$d11,$d12,$d13,$d14,$d15,$d16,$d17]"
    field3="[$e01,$e02,$e03,$e04,$e05,$e06,$e07,$e08,$e09,$e10,$e11,$e12,$e13,$e14,$e15,$e16,$e17]"
    field4="[$f01,$f02,$f03,$f04,$f05,$f06,$f07,$f08,$f09,$f10,$f11,$f12,$f13,$f14,$f15,$f16,$f17]"
    field5="[$g1,$g2,$g3,$g4,$g5,$g6,$g7,$g8,$g9,$g10,$g11,$g12,$g13,$g14,$g15,$g16,$g17]"
    field6="[$h1,$h2,$h3,$h4,$h5,$h6,$h7,$h8,$h9,$h10,$h11,$h12,$h13,$h14,$h15,$h16,$h17]"
    echo -e "data2='[{\"wk\":$fieldw,\"f0\":$field0,\"f1\":$field1,\"f2\":$field2,\"f3\":$field3,\"f4\":$field4,\"f5\":$field5,\"f6\":$field6}]';" >> "${data}"
    cp -f "${data}" "${databk}"
}

# Variables
pross="$DM_tls/data/pre_data"
data="/tmp/.idiomind_stats"
no_data="${DM_tls}/data/no_data"
databk="${DM_tls}/data/idiomind_stats"
db="${DM_tls}/data/log.db"
int='^[0-9]+$'
week=$(date "+%b %d")
month=$(date +%b)
dtweek=$(date +%w)
dtmnth=$(date +%d)
mtable="M$(date +%y)"
wtable="W$(date +%y)"
dmonth=$(date +%m)
cdate=$(date +%m/%d/%Y)
if [ $(date +%W) = "00" ]; then dw=0
else dw=$(date +%W |sed 's/^0*//'); fi
check_dir "$DC_s/logs"

function chk_expire() {
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
        if [ $(date +%s) -gt $(date -d ${dte} +%s) ]; then
            if [ ${atable} = 'expire_month' ]; then
                newdate=$(date +%m/01/%Y "-d +1 month")
            elif [ ${atable} = 'expire_week' ]; then
                newdate=$(date +%m/%d/%Y -d "+${days} days")
            fi
            sqlite3 ${db} "update '${atable}' set date='${newdate}' where date='${dte}';">/dev/null 2>&1
            echo 0
        else 
            echo 1
        fi
    fi
}

function pre_comp() {
    echo -e "\n--- running stats..."
    if [ ! -f "$DC/topics_first_run" ]; then f_lock 1 "$DT/p_stats"; fi
    echo -n "create table if not exists 'expire_month' (date TEXT);" |sqlite3 "${db}"
    echo -n "create table if not exists 'expire_week' (date TEXT);" |sqlite3 "${db}"
    cleanups "$pross" "$data" "$no_data" "$databk"
    [ $(chk_expire 'expire_month' 31) = 0 ] && val1=1
    [ $(chk_expire 'expire_week' 7) = 0 ] && val2=1

    if [ ${val1} = 1 ] && [ ${val2} != 1 ]; then
        coll_tpc_stats 1
    elif [ ${val2} = 1 ]; then
        coll_tpc_stats ${val1}
        coll_items_stats
        echo -e "--- expire week\n"
    else
        coll_tpc_stats 0
    fi

    echo -e "\tstats ok\n"
    f_lock 3 "$DT/p_stats"
}

create_db

function stats() {
    if [ ! -e "${data}" -o -e "${pross}" ]; then
        f_lock 1 "$DT/p_stats"
        [ ! -e "${data}" ] && cp -f "${databk}" "${data}"
        [ ! -e "${pross}" ] && coll_tpc_stats 0
        mk_tpc_stats
        f_lock 3 "$DT/p_stats"
    fi
    if [ -f "${no_data}" ]; then
        source "$DS/ifs/cmns.sh"
        sleep 1 && msg "$(gettext "Insufficient data")\n" dialog-information "Idiomind" &
    fi
    titlew="$(gettext "Statistics")"
	uri_stats="$DS/default/pg1.html?lang=$intrf"
	export uri_stats titlew
	
python3 <<PY
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('WebKit2', '4.0')
from gi.repository import WebKit2, Gtk
import os
uri = os.environ['uri_stats']
titlew = os.environ['titlew']
class MainWin(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title = titlew, 
        skip_pager_hint=True, skip_taskbar_hint=True)
        self.set_icon_from_file("/usr/share/idiomind/images/logo.png")
        self.set_size_request(650, 450)
        self.view = WebKit2.WebView()
        self.view.load_uri("file://" + uri)
        box = Gtk.Box()
        self.add(box)
        box.pack_start(self.view, True, True, 0)
        self.show_all()
if __name__ == '__main__':
    mainwin = MainWin()
    Gtk.main()
PY
} >/dev/null 2>&1
