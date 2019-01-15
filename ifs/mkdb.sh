#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function create_tpcdb() {
    tpc="${2}"
    tpcdb="${DM_tl}/${2}/.conf/tpc"
    [ -f "$tpcdb" ] && rm "$tpcdb"
    dtec="$(date +%F)"
    
    echo -n "create table if not exists id \
    (name TEXT, slng TEXT, tlng TEXT, autr TEXT, cntt TEXT, ctgy TEXT, ilnk TEXT, \
    orig TEXT, dtec TEXT, dteu TEXT, dtei TEXT, nwrd TEXT, nsnt TEXT, nimg TEXT, \
    naud TEXT, nsze TEXT, levl TEXT, stts TEXT);" |sqlite3 "${tpcdb}"
    
    echo -n "create table if not exists config \
    (words TEXT, sntcs TEXT, marks TEXT, learn TEXT, diffi TEXT, rplay TEXT, audio TEXT, \
    ntosd TEXT, loop TEXT, rword TEXT, acheck TEXT, repass TEXT);" |sqlite3 "${tpcdb}"
    
    echo -n "create table if not exists reviews \
    (date1 TEXT,date2 TEXT,date3 TEXT,date4 TEXT,date5 TEXT,\
    date6 TEXT,date7 TEXT,date8 TEXT);" |sqlite3 "${tpcdb}"
    
    echo -n "create table if not exists learning \
    (list TEXT);" |sqlite3 "${tpcdb}"
    
    echo -n "create table if not exists learnt \
    (list TEXT);" |sqlite3 "${tpcdb}"
    
    echo -n "create table if not exists words \
    (list TEXT);" |sqlite3 "${tpcdb}"
    
    echo -n "create table if not exists sentences \
    (list TEXT);" |sqlite3 "${tpcdb}"
    
    echo -n "create table if not exists marks \
    (list TEXT);" |sqlite3 "${tpcdb}"
    

    echo -n "create table if not exists Data \
    (trgt TEXT, srce TEXT, \
    exmp TEXT, defn TEXT, note TEXT, refr TEXT, tags TEXT, link TEXT, \
    grmr TEXT, imag TEXT, mark TEXT, cdid TEXT, type TEXT);" |sqlite3 "${tpcdb}"
    
    echo -n "create table if not exists Translates \
    (trgt TEXT, \
    ch_srce TEXT, de_srce TEXT, en_srce TEXT, es_srce TEXT, \
    fr_srce TEXT, it_srce TEXT, ja_srce TEXT, pt_srce TEXT, \
    ru_srce TEXT, vi_srce TEXT);" |sqlite3 "${tpcdb}"
    
    
    sqlite3 "${tpcdb}" "pragma busy_timeout=2000;\
    insert into id (name,slng,tlng,autr,cntt,\
    ctgy,ilnk,orig,dtec,dteu,dtei,nwrd,nsnt,nimg,naud,nsze,levl,stts) \
    values ('${tpc}','${slng}','${tlng}','','','','','',\
    '${dtec}','','','','','','','','','');"
    sqlite3 "${tpcdb}" "pragma busy_timeout=2000;\
    insert into config (words,sntcs,marks,learn,\
    diffi,rplay,audio,ntosd,loop,rword,acheck,repass) \
    values ('FALSE','FALSE','FALSE','FALSE','FALSE','FALSE',\
    'FALSE','FALSE','FALSE','FALSE','TRUE','0');"
    sqlite3 "${tpcdb}" "pragma busy_timeout=2000;\
    insert into reviews (date1) values ('');"
    echo -n "pragma foreign_keys=ON" |sqlite3 "${tpcdb}"
    return 0
}

function create_shrdb() {
    echo -e "\n--- share database..."
    source /usr/share/idiomind/default/c.conf
    shrdb="$DM_tls/data/config"
    echo -n "create table if not exists topics (list TEXT);" |sqlite3 "${shrdb}"
    echo -n "create table if not exists T1 (list TEXT);" |sqlite3 "${shrdb}"
    echo -n "create table if not exists T2 (list TEXT);" |sqlite3 "${shrdb}"
    echo -n "create table if not exists T3 (list TEXT);" |sqlite3 "${shrdb}"
    echo -n "create table if not exists T4 (list TEXT);" |sqlite3 "${shrdb}"
    echo -n "create table if not exists T5 (list TEXT);" |sqlite3 "${shrdb}"
    echo -n "create table if not exists T6 (list TEXT);" |sqlite3 "${shrdb}"
    echo -n "create table if not exists T7 (list TEXT);" |sqlite3 "${shrdb}"
    echo -n "create table if not exists T8 (list TEXT);" |sqlite3 "${shrdb}"
    echo -n "create table if not exists T9 (list TEXT);" |sqlite3 "${shrdb}"
    echo -n "create table if not exists T10 (list TEXT);" |sqlite3 "${shrdb}"
    echo -e "\n--- share database created"
}

function create_cfgdb() {
    echo -e "\n--- config database..."
    cfgdb="$HOME/.config/idiomind/config"
    echo -n "pragma busy_timeout=800;create table if not exists opts \
    (gramr TEXT, trans TEXT, dlaud TEXT, ttrgt TEXT, itray TEXT, \
    swind TEXT, stsks TEXT, tlang TEXT, slang TEXT, \
    synth TEXT, txaud TEXT, intrf TEXT);" |sqlite3 "${cfgdb}"
    echo -n "pragma busy_timeout=500;create table if not exists lang \
    (tlng TEXT, slng TEXT);" |sqlite3 "${cfgdb}"
    echo -n "pragma busy_timeout=500; create table if not exists geom \
    (vals TEXT);" |sqlite3 "${cfgdb}"
    echo -n "pragma busy_timeout=500; create table if not exists user \
    (autr TEXT, pass TEXT);" |sqlite3 "${cfgdb}"
    echo -n "pragma busy_timeout=500; create table if not exists sess \
    (date TEXT);" |sqlite3 "${cfgdb}"
    echo -n "pragma busy_timeout=500; create table if not exists updt \
    (date TEXT,ignr TEXT);" |sqlite3 "${cfgdb}"
    sqlite3 "${cfgdb}" "pragma busy_timeout=500;\
    insert into opts (gramr,trans,dlaud,ttrgt,itray,\
    swind,stsks,tlang,slang,synth,txaud,intrf) \
    values ('"$2"','"$2"','"$2"','FALSE','FALSE',\
    'FALSE','"$2"','','','','','default');"
    sqlite3 "${cfgdb}" "insert into lang (tlng,slng) values ('','');"
    sqlite3 "${cfgdb}" "insert into user (autr,pass) values ('','');"
    sqlite3 "${cfgdb}" "insert into geom (vals) values ('');"
    v=$(date +%d)
    sqlite3 "${cfgdb}" "insert into sess (date) values ('${v}');"
    sqlite3 "${cfgdb}" "insert into updt (date) values ('${v}');"
    echo -e "\n--- config database created"
}

case "$1" in
    tpc)
    create_tpcdb "$@" ;;
    share)
    create_shrdb "$@" ;;
    config)
    create_cfgdb "$@" ;;
esac
