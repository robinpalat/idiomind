#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [ -z "${1}" ]; then exit 1; fi
source "$DS/ifs/cmns.sh"
topic="${1}"
mode="${2}"
[[ ! ${mode} =~ $numer ]] && mode=13
activ="${3}"
DC_tlt="$DM_tl/${topic}/.conf"
DM_tlt="$DM_tl/${topic}"
export mode
export mode2=$((mode+mode%2))
tpcdb="${DC_tlt}/tpc"

create_cfgfile() {
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
	'','','','','','','','','','');"
	sqlite3 "${tpcdb}" "pragma busy_timeout=2000;\
	insert into config (words,sntcs,marks,learn,\
	diffi,rplay,audio,ntosd,loop,rword,acheck,repass) \
	values ('TRUE','TRUE','FALSE','FALSE','FALSE','FALSE',\
	'FALSE','FALSE','FALSE','FALSE','TRUE','0');"
	
	sqlite3 "${tpcdb}" "pragma busy_timeout=2000;\
	insert into reviews (date1) values ('');"
	
	echo -n "PRAGMA foreign_keys=ON" |sqlite3 "${tpcdb}"
}

chek_topic() {
    if [ ! -d "${DC_tlt}"  ]; then
        mkdir -p "${DM_tlt}/images"
        mkdir "${DC_tlt}"; cd "${DC_tlt}"
        [ ! -e "${DC_tlt}/note" ] && echo " " > "note"
        echo ${mode} > ./"stts"; cd /
    fi
    if [ ! -e "$tpcdb" ]; then
		create_cfgfile
    fi
    if [ ! -e "$DT/n_s_pr" ]; then
        "$DS/ifs/tls.sh" check_index "${topic}"
    fi
}

active_topic() {
    if [[ ${activ} = 0 ]]; then
        :
    elif [[ ${activ} = 1 ]]; then
        echo "${topic}" > "$DC_s/tpc"
        ( sleep 1; notify-send -i idiomind \
        "${topic}" "$(gettext "Is now your topic")" -t 4000 ) & exit
    elif [[ -z "$activ" ]]; then
        echo "${topic}" > "$DC_s/tpc"
        idiomind topic & exit
    fi
}

if [ -d "${DM_tlt}" ]; then

    if ((mode>=1 && mode<=10)); then
        chek_topic
        if [ ! -e "${DC_tlt}/feeds" ]; then
            echo "${topic}" > "$DT/tpe"
        fi
        ( sleep 10 && "$DS/ifs/tls.sh" backup "${topic}" ) &
        [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
        active_topic
        
     elif [ ${mode} = 12 ]; then
        msg_2 "$(gettext "Topic inactive. Do you want to enable it now?") " \
        dialog-question "$(gettext "Yes")" "$(gettext "Just open it")"
        if [ $? = 0 ]; then
            export mode="$(< "${DC_tlt}/stts.bk")"
            rm "${DC_tlt}/stts.bk"; echo ${mode} > "${DC_tlt}/stts"
            touch "${DM_tlt}"
            
            export stts=${mode}
            if echo "$stts" |grep -E '3|4|7|8|9|10'; then
                calculate_review "${topic}"
                if [[ $((stts%2)) = 0 ]]; then
                    if [ ${RM} -ge 180 -a ${stts} = 8 ]; then
                        stts=10;  touch "${DM_tlt}"
                        echo ${stts} > "${DC_tlt}/stts"
                    elif [ ${RM} -ge 100 -a ${stts} -lt 8 ]; then
                        stts=8; touch "${DM_tlt}"
                        echo ${stts} > "${DC_tlt}/stts"
                    fi
                else
                    if [ ${RM} -ge 180 -a ${stts} = 7 ]; then
                       stts=9; touch "${DM_tlt}"
                       echo ${stts} > "${DC_tlt}/stts"
                    elif [ ${RM} -ge 100 -a ${stts} -lt 7 ]; then
                       stts=7; touch "${DM_tlt}"
                       echo ${stts} > "${DC_tlt}/stts"
                    fi
                fi
            fi
            chek_topic
            "$DS/mngr.sh" mkmn 1
            ( sleep 10 && "$DS/ifs/tls.sh" backup "${topic}" ) &
            active_topic
        else
            active_topic
            idiomind topic & exit 0
        fi
    elif [ ${mode} = 13 ]; then
        chek_topic
        active_topic
    elif [ ${mode} = 14 ]; then
        chek_topic
        active_topic
    else
        if grep -Fxo "${topic}" < <(ls "$DS/addons"/); then
            source "$DS/ifs/mods/main/${topic}.sh"
            echo "${tpc}" > "$DC_s/tpc"
            active_topic
        fi
    fi
else
    [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
    "$DS/mngr.sh" mkmn 0
    msg "$(gettext "No such file or directory")\n${topic}\n" error & exit 1
fi
