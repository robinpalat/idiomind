#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function create_tpcdb() {
    tpc="${2}"
    tpcdb="${DM_tl}/${2}/.conf/tpc"
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
    sqlite3 "${tpcdb}" "pragma busy_timeout=2000;\
    insert into id (name,slng,tlng,autr,cntt,\
    ctgy,ilnk,orig,dtec,dteu,dtei,nwrd,nsnt,nimg,naud,nsze,levl,stts) \
    values ('${tpc}','${slng}','${tlng}','','','','','',\
    '${dtec}','','','','','','','','','');"
    sqlite3 "${tpcdb}" "pragma busy_timeout=2000;\
    insert into config (words,sntcs,marks,learn,\
    diffi,rplay,audio,ntosd,loop,rword,acheck,repass) \
    values ('TRUE','TRUE','FALSE','FALSE','FALSE','FALSE',\
    'FALSE','FALSE','FALSE','FALSE','TRUE','0');"
    sqlite3 "${tpcdb}" "pragma busy_timeout=2000;\
    insert into reviews (date1) values ('');"
    echo -n "pragma foreign_keys=ON" |sqlite3 "${tpcdb}"

    return 0
}


case "$1" in
    tpc)
    create_tpcdb "$@" ;;
esac
