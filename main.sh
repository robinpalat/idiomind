#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  Copyright 2015-2022 Robin Palatnik
#  Email patapatass@hotmail.com
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston
#  MA 02110-1301, USA.
##

if [ ! -d "$HOME/.idiomind" ]; then
    /usr/share/idiomind/ifs/1u.sh & exit 1
fi

source /usr/share/idiomind/default/c.conf

if [ -z "${tlng}" -o -z "${slng}" -a ! -f "$DT/.langc" ]; then
    source "$DS/ifs/cmns.sh"
    if [ ! -d "$DT" ]; then mkdir "$DT"; fi
    msg "$(gettext "Please check the language settings in the preferences dialog.")
$(gettext "If necessary, close the program from the panel icon and start it again.")\n" \
    dialog-warning "$(gettext "Language settings")"
    "$DS/cnfg.sh"
    exit 1
fi

if [ -e "$DT/ps_lk" -o -e "$DT/el_lk" ]; then
    source "$DS/ifs/cmns.sh"
    msg "$(gettext "Please wait until the current process is finished")...\n" dialog-information
    (sleep 50; cleanups "$DT/ps_lk" "$DT/el_lk") & exit 1
fi

function new_session() {
    source "$DS/ifs/cmns.sh"
    echo "-- new session"
    export -f cdb
    d=$(date +%d)
    cdb ${cfgdb} 3 sess date ${d}

    # mkdir tmp dir
    if [ ! -d "$DT" ]; then mkdir "$DT"; fi
    if [ $? -ne 0 ]; then
    msg "$(gettext "An error occurred while trying to write on '/tmp'")\n" \
    error "$(gettext "Error")" & exit 1
    fi
    
    f_lock 1 "$DT/ps_lk"
    
    # list topics
    check_list
    # 
    if ls "$DC_s"/*.p 1> /dev/null 2>&1; then
    cd "$DC_s"/; rename 's/\.p$//' *.p; fi; cd /
    # check database
    if [ ! -e ${tlngdb} ]; then
        [ ! -d "$DM_tls/data" ] && mkdir -p "$DM_tls/data" 
        echo -n "create table if not exists Words \
        (Word TEXT, Example TEXT, Definition TEXT);" |sqlite3 ${tlngdb}
        echo -n "create table if not exists Config \
        (Study TEXT, Expire INTEGER);" |sqlite3 ${tlngdb}
        echo -n "PRAGMA foreign_keys=ON" |sqlite3 ${tlngdb}
        sqlite3 ${tlngdb} "alter table Words add column '${slng}' TEXT;"
    fi
    # log- practice
    if [ -f "$DC_s/log" ]; then
        if [[ "$(du -sb "$DC_s/log" |awk '{ print $1 }')" -gt 100000 ]]; then
        tail -n2000 < "$DC_s/log" > "$DT/log"
        mv -f "$DT/log" "$DC_s/log"; fi
    fi
    # update - topics
    if [ ! -f "${shrdb}" ]; then
        "$DS/ifs/mkdb.sh" share
    else
        for n in {1..4} 7; do 
        cdb ${shrdb} 6 T${n}; done
    fi
    echo -e "\n--- checking topics..."
    tdate=$(date +%Y%m%d)
    while read -r line; do
        if [ -n "$line" ]; then
            unset stts
            dir="$DM_tl/${line}/.conf"
            dim="$DM_tl/${line}"
            [ ! -d "${dir}" ] && continue
            stts=$(sed -n 1p "${dir}/stts")
            ! [[ ${stts} =~ $numer ]] && stts=1
            [[ ${stts} = 0 ]] && continue
            if grep -E '3|4|7|8|9|10' <<< "$stts" >/dev/null 2>&1; then

                calculate_review "${line}"
                
                if [[ $((stts%2)) = 0 ]]; then
                    if [ ${RM} -ge 180 -a ${stts} = 8 ]; then
                        echo 10 > "${dir}/stts"; touch "${dim}"
                        cdb ${shrdb} 2 T2 list "${line}"
                        
                    elif [ ${RM} -ge 100 -a ${stts} -lt 8 ]; then
                        echo 8 > "${dir}/stts"; touch "${dim}"
                        cdb ${shrdb} 2 T1 list "${line}"
                        
                    elif [ ${stts} = 8 ]; then
                        cdb ${shrdb} 2 T3 list "${line}"
                        
                    elif [ ${stts} = 10 ]; then
                        cdb ${shrdb} 2 T4 list "${line}"
                    fi
                    
                elif [[ $((stts%2)) = 1 ]]; then
                    if [ ${RM} -ge 180 -a ${stts} = 7 ]; then
                        echo 9 > "${dir}/stts"; touch "${dim}"
                        cdb ${shrdb} 2 T2 list "${line}"
                        
                    elif [ ${RM} -ge 100 -a ${stts} -lt 7 ]; then
                        echo 7 > "${dir}/stts"; touch "${dim}"
                        cdb ${shrdb} 2 T1 list "${line}"
                        
                    elif [ ${stts} = 7 ]; then
                        cdb ${shrdb} 2 T3 list "${line}"
                        
                    elif [ ${stts} = 9 ]; then
                        cdb ${shrdb} 2 T4 list "${line}"
                    fi
                fi
                
            elif [[ $((stts+stts%2)) = 6 ]]; then
            
                datedir=$(stat -c %y "$dir" |cut -d ' ' -f1)
                cdate=$(date -d $datedir +"%Y%m%d")
                if [ $((tdate-cdate)) -gt 20 ]; then
                    cdb ${shrdb} 2 T7 list "${line}"
                fi
            fi
        fi
    done < <(cd "$DM_tl"; find ./ -maxdepth 1 -mtime -80 -type d \
    -not -path '*/\.*' -exec ls -tNd {} + |sed 's|\./||g;/^$/d')
    rm -f "$DT/ps_lk"
    
    # run startups scripts
    for strt in "$DS/ifs/mods/start"/*; do
    ( sleep 5 && "${strt}" ); done &
    
    # make index
    "$DS/mngr.sh" mkmn 0 &
    echo -e "\ttopics ok\n"
    
    # statistics
    ( source "$DS/ifs/stats.sh"; sleep 5; export val1=0 val2=0; pre_comp ) &
}

if grep -o '.idmnd' <<<"${1: -6}" >/dev/null 2>&1; then
    if [ ! -d "$DT" ]; then mkdir "$DT"; fi
    slngcurrent="$slng"; tlngcurrent="$tlng"
    source "$DS/ifs/tls.sh"; check_format_1 "${1}"
    if [ $? != 19 ]; then
        msg "$(gettext "File format corrupted")\n" error "$(gettext "Information")" & exit 1
    fi
    file="${1}"
    lv=( "$(gettext "Beginner")" "$(gettext "Intermediate")" "$(gettext "Advanced")" )
    level="${lv[${levl}]}"
    itxt="<span font_desc='Droid Sans Bold 12'>$name</span><sup>\n$(gettext "Words") $nwrd  \
$(gettext "Sentences") $nsnt  $(gettext "Images") $nimg \n$(gettext "Level:") \
$level \n$(gettext "Language:") $(gettext "$tlng")  $(gettext "Translation:") $(gettext "$slng")$otranslations</sup>" 
    dclk="$DS/play.sh play_word"
    source "$DS/ifs/mods/main/items_list.sh"
    _lst() {
        while read -r line; do
        cut -d ':' -f1 <<< "${line}" |sed 's/\"*//;s/\"$//'
        cut -d ':' -f3 <<< "${line}" |sed 's/\"*//;s/\"$//;s/\",\"slch//'
        done < <(sed -n 2p "${file}"|sed 's/},/\n/g'|tr -d '\\'|sed '/^$/d')
    }

    export swind=$(cdb ${cfgdb} 1 opts swind) 
    sz=(580 560 540); [[ ${swind} = TRUE ]] && sz=(480 460 440)
    _lst | tpc_view
    ret=$?
        if [ $ret -eq 0 ]; then
            if [ -e "$DT/in_lk" ]; then
                msg "$(gettext "Please wait until the current process is finished")...\n" dialog-information
                sleep 15; cleanups "$DT/in_lk"; exit 1
            fi

            if [[ "$tlng" != "$tlngcurrent" ]]; then
                msg_2 "$(gettext "Please note the language of this Topic is:") <b>$tlng</b>
$(gettext "It is recommended to change your language preferences before installing it")" dialog-warning "$(gettext "Ignore")" "$(gettext "OK")" 
                if [ $? -eq 1 ]; then
                    cleanups "$DT/in_lk"; exit 1
                fi
            fi
            
            f_lock 1 "$DT/in_lk"
            listt="$(cd "$DM_tl"; find ./ -maxdepth 1 -type d \
            ! -path "./.share"  |sed 's|\./||g'|sed '/^$/d')"
            if [ $(wc -l <<< "$listt") -ge 120 ]; then
                msg "$(gettext "Maximum number of topics reached.")\n" \
                dialog-information "$(gettext "Information")" & exit 1
            fi
            cn=0
            if [[ $(grep -Fxo "${name}" <<< "${listt}" |wc -l) -ge 1 ]]; then
                cn=1
                for i in {1..50}; do
                    chck=$(grep -Fxo "${name} ($i)" <<< "${listt}")
                    [ -z "$chck" ] && break
                done
                name="${name} ($i)"
            fi
            export tpc="${name}"
            check_dir "$DM_t/$tlng" "$DM_t/$tlng/.share/images" \
            "$DM_t/$tlng/.share/audio" "$DM_t/$tlng/.share/data" \
            "$DM_t/$tlng/${name}/.conf/practice"
            DM_tlt="$DM_t/$tlng/${name}"
            DC_tlt="$DM_t/$tlng/${name}/.conf"
            export tpcdb="$DC_tlt/tpc"
            "$DS/ifs/mkdb.sh" tpc "${tpc}"
            tpc_db 9 id name "${name}"
            tpc_db 9 id slng "$slng"
            tpc_db 9 id tlng "$tlng"
            tpc_db 9 id autr "$autr"
            tpc_db 9 id ctgy "$ctgy"
            tpc_db 9 id ilnk "$ilnk"
            tpc_db 9 id orig "$orig"
            tpc_db 9 id dtec "$dtec"
            tpc_db 9 id dtei "$(date +%F)"
            tpc_db 9 id nwrd "$nwrd"
            tpc_db 9 id nsnt "$nsnt"
            tpc_db 9 id nimg "$nimg"
            tpc_db 9 id naud "$naud"
            tpc_db 9 id nsze "$nsze"
            tpc_db 9 id levl "$levl"
            check_file "${DC_tlt}/practice/log1" "${DC_tlt}/practice/log2" \
            "${DC_tlt}/practice/log3" "${DC_tlt}/note" "${DC_tlt}/download"
            sed -n 2p "${file}" |tr -d '\\' > "${DC_tlt}/data"
            sed -i 's/},/}\n/g;s|","|}|g;s|":"|{|g;s|":{"|}|g;s/"}/}/g' "${DC_tlt}/data"
            sed -i 's/^\s*./trgt{/g' "${DC_tlt}/data"
            sed -i '/^$/d' "${DC_tlt}/data"
            export data="${DC_tlt}/data"
python3 <<PY
import os, re, locale, sqlite3, sys
en = locale.getpreferredencoding()
data = os.environ['data']
data.encode(en)
tpcdb = os.environ['tpcdb']
tpcdb.encode(en)
db = sqlite3.connect(tpcdb)
db.text_factory = str
cur = db.cursor()
data = [line.strip() for line in open(data)]
for item in data:
    item = item.replace('}', '}\n')
    fields = re.split('\n',item)
    trgt = (fields[0].split('trgt{'))[1].split('}')[0]
    type = (fields[24].split('type{'))[1].split('}')[0]
    mark = (fields[18].split('mark{'))[1].split('}')[0]
    if type == '1':
        cur.execute("insert into words (list) values (?)", (trgt,))
    elif type == '2':
        cur.execute("insert into sentences (list) values (?)", (trgt,))
    if mark == 'TRUE':
        cur.execute("insert into marks (list) values (?)", (trgt,))
    cur.execute("insert into learning (list) values (?)", (trgt,))
db.commit()
db.close()
PY
            "$DS/ifs/tls.sh" colorize 1
            f_lock 3 "$DT/in_lk"
            
            slngtopic="$slng"; slng="$slngcurrent"
            cdb "${cfgdb}" 3 lang tlng "${tlng}"
            cdb "${cfgdb}" 3 lang slng "${slng}"
            if [[ "$slngtopic" != "$slng" ]]; then
                mkdir "${DC_tlt}/translations/"
                echo "$slngtopic" > "${DC_tlt}/translations/active"
                touch "${DC_tlt}/slng_err"
            fi
            if [[ "$tlng" != "$tlngcurrent" ]]; then
                if [[ -f "$DT/tray.pid" ]]; then
                    kill -9 $(cat $DT/tray.pid)
                    kill -9 $(pgrep -f "$DS/ifs/tls.sh itray")
                    rm -f "$DT/tray.pid"
                    $DS/ifs/tls.sh itray &
                fi
            fi
            echo 1 > "${DC_tlt}/stts"
            source /usr/share/idiomind/default/c.conf
            "$DS/mngr.sh" mkmn 1
            "$DS/ifs/tpc.sh" "${name}" 1 &
        fi
    exit 0
fi

function topic() {
    source "$DS/ifs/cmns.sh"
    f_lock 0 "$DT/tpc_lk"
    export -f tpc_db msg
    [ -f "${DC_tlt}/stts" ] && export stts=$(sed -n 1p "${DC_tlt}/stts")
    if ! [[ ${stts} =~ $numer ]]; then return 1; fi

    readd(){
        [ -z "${tpc}" ] && return 1
        source "$DS/ifs/mods/main/items_list.sh"
        n=1; tas=('learning' 'learnt' 'words' 'sentences')
        for ta in ${tas[@]}; do
            export ls${n}="$(tpc_db 5 "$ta")"; cnt="ls${n}"
            let n++
        done
        cfg0=$(wc -l < "${DC_tlt}/data")
        export cfg1="$(grep -c '[^[:space:]]' <<< "$ls1")"
        export cfg2="$(grep -c '[^[:space:]]' <<< "$ls2")"
        export cfg3="$(grep -c '[^[:space:]]' <<< "$ls3")"
        export cfg4="$(grep -c '[^[:space:]]' <<< "$ls4")"
        note="${DC_tlt}/note"
        autr=$(tpc_db 1 id autr)
        dtec=$(tpc_db 1 id dtec)
        dtei=$(tpc_db 1 id dtei)
        repass=$(tpc_db 1 config repass)
        acheck=$(tpc_db 1 config acheck)

        [ -z "$repass" ] && repass=0; export repass acheck
        ( sleep 2 && "$DS/ifs/tls.sh" promp_topic_info ) &
        c=$((RANDOM%100000)); export KEY=$c
        export cnf1=$(mktemp "$DT/cnf1.XXXXXX")
        export cnf3=$(mktemp "$DT/cnf3.XXXXXX")
        export cnf4=$(mktemp "$DT/cnf4.XXXXXX")
        if [ -n "$dtei" ]; then 
            export infolbl="$(gettext "Review") $repass  $(gettext "Installed on") $dtei\n$(gettext "Created by") $autr"
        else 
            export infolbl="$(gettext "Review") $repass  $(gettext "Created on") $dtec"
        fi
        export lbl1="<span font_desc='Free Sans 15'>${tpc}</span><sup>\n$(gettext "Sentences") $cfg4  $(gettext "Words") $cfg3\n$infolbl</sup>"
    }
    
    oclean() { cleanups "$cnf1" "$cnf3" "$cnf4" "$DT/tpc_lk"; }
    
    apply() {
            note_mod="$(< "${cnf3}")"
            if [ "${note_mod}" != "$(< "${note}")" ]; then
                if ! grep '^$' < <(sed -n '1p' "${cnf3}")
                then echo -e "\n${note_mod}" > "${note}"
                else echo "${note_mod}" > "${note}"; fi
            fi
            acheck_mod=$(cut -d '|' -f 3 < "${cnf4}")
            if [[ $acheck_mod != $acheck ]] && [ -n "$acheck_mod" ]; then
                tpc_db 3 config acheck "$acheck_mod"
            fi
            if [[ $acheck_mod = FALSE ]] && [[ $acheck != FALSE ]]; then
                "$DS/ifs/tls.sh" colorize 1; rm "${cnf1}"
            fi
            if grep TRUE "${cnf1}" >/dev/null 2>&1; then
                f_lock 1 "$DT/tpc_lk"
                export cnf1 tpcdb
python3 <<PY
import os, re, locale, sqlite3, sys
tags = re.compile(r'<[^>]+>')
en = locale.getpreferredencoding()
cnf1 = os.environ['cnf1']
cnf1.encode(en)
tpcdb = os.environ['tpcdb']
db = sqlite3.connect(tpcdb)
db.text_factory = str
cur = db.cursor()
cnf1 = [line.strip() for line in open(cnf1)]
for item in cnf1:
    if "|TRUE|" in item:
        trgt = item.replace("|TRUE|", "")
        trgt = tags.sub('', trgt)
        cur.execute("insert into learnt (list) values (?)", (trgt,))
        cur.execute("delete from learning where list=?", (trgt,))
db.commit()
db.close()
PY
                "$DS/ifs/tls.sh" colorize 1
                f_lock 3 "$DT/tpc_lk"
                source "$DS/ifs/stats.sh"
                coll_tpc_stats 0
            fi
            
            ntpc=$(cut -d '|' -f 1 < "${cnf4}")
            if [ "${tpc}" != "${ntpc}" -a -n "$ntpc" ]; then
            if [[ "${tpc}" != "$(sed -n 1p "$HOME/.config/idiomind/tpc")" ]]; then
            msg "$(gettext "Sorry, this topic is currently not active.")\n" \
            dialog-information "$(gettext "Information")"
            else "$DS/mngr.sh" rename_topic "${ntpc}"; fi; fi
        }
        
    if ((stts>=1 && stts<=10)); then
        if [ -f "${DC_tlt}/tpc-journal" ]; then exit 1; else readd; fi
        
        # empty topic
        if [ ${cfg0} -lt 1 ]; then
            echo "Empty topic N1 / ${cfg0} / ${cfg1} / ${cfg2}"
            notebook_1; ret=$?
            
            if [ ! -e "$DT/ps_lk" ] && [ $ret -eq 2 -o $ret -eq 3 ]; then apply; fi
            
            if [ $ret -eq 3 ]; then "$DS/practice/strt.sh" & fi

        elif [ ${cfg1} -ge 1 ] || [ ${cfg1} -gt 0 -a ${cfg0} -ge 10 ]; then
      
            if echo "$stts" |grep -E '3|4|7|8|9|10'; then
            
                calculate_review "${tpc}"; 

                if [[ ${RM} -ge 100 ]]; then

                    RM=100; dialog_1; ret=$?
                    
                    if [ $ret -eq 2 ]; then
                    
                        "$DS/mngr.sh" mark_to_learn "${tpc}" 0
                        
                        idiomind topic & oclean; return 1
                        
                    elif [ $ret -eq 3 ]; then
                    
                       oclean & return 1
                    fi
                fi
                
                pres="<u><b>$(gettext "Topic learnt")</b></u>  $(gettext "* however you have new notes") ($cfg1).\\n$(gettext "Time set to review:") $tdays $(gettext "days")"
                echo "N2 / ${cfg0} / ${cfg1} / ${cfg2}"
                notebook_2

            else
                echo "N1 / ${cfg0} / ${cfg1} / ${cfg2}"
                notebook_1
            fi
                ret=$?
                
                if [ ! -e "$DT/ps_lk" ] && [ $ret -eq 2 -o $ret -eq 3 ]; then apply; fi
                
                if [ $ret -eq 3 ]; then "$DS/practice/strt.sh" & fi

        elif [ ${cfg1} -eq 0 -a ${cfg0} -ge 10 ]; then
        
             if  ! echo "$stts" |grep -E '3|4|7|8|9|10'; then
            
                "$DS/mngr.sh" mark_as_learned "${tpc}" 0
                
            fi
            calculate_review "${tpc}"
            
            if [[ ${RM} -ge 100 ]]; then
            
                RM=100; dialog_1; ret=$?
                
                if [ $ret -eq 2 ]; then
                
                    "$DS/mngr.sh" mark_to_learn "${tpc}" 0
                    
                    idiomind topic & oclean; return 1
                    
                elif [ $ret -eq 3 ]; then
                
                    oclean & return 1
                fi 
            fi

            pres="<u><b>$(gettext "Topic learnt")</b></u>\\n$(gettext "Time set to review:") $tdays $(gettext "days")"
            echo "N2/ ${cfg0} / ${cfg1} / ${cfg2}"
            notebook_2; ret=$?
            
            if [ ! -e "$DT/ps_lk" ] && [ $ret -eq 2 -o $ret -eq 3 ]; then apply; fi

        fi

    elif [[ ${stts} = 0 ]]; then
    
        if [ -f "${DC_tlt}/tpc-journal" ]; then exit 1; else readd; fi
        
        if [ ${cfg0} -lt 1 ]; then
            echo "N2/ ${cfg0} / ${cfg1} / ${cfg2}"
            notebook_1; ret=$?
            
            if [ ! -e "$DT/ps_lk" ] && [ $ret -eq 2 -o $ret -eq 3 ]; then apply; fi
            
            if [ $ret -eq 3 ]; then "$DS/practice/strt.sh" & fi

        elif [ ${cfg1} -ge 1 ]; then
        
            if echo "$stts" |grep -E '3|4|7|8|9|10'; then
                echo "N2/ ${cfg0} / ${cfg1} / ${cfg2}"
                notebook_2
            else
                echo "N2/ ${cfg0} / ${cfg1} / ${cfg2}"
                notebook_1
            fi
            ret=$?
            
            if [ ! -e "$DT/ps_lk" ] && [ $ret -eq 2 -o $ret -eq 3 ]; then apply; fi
            
            if [ $ret -eq 3 ]; then "$DS/practice/strt.sh" & fi
            
        elif [[ ${cfg1} -eq 0 ]]; then
        
            calculate_review "${tpc}"
            
            pres="<u><b>$(gettext "Topic learnt")</b></u>\\n$(gettext "Time set to review:") $tdays $(gettext "days")"
            echo "N2/ ${cfg0} / ${cfg1} / ${cfg2}"
            notebook_2; ret=$?
        fi
        
    else
        tpa="$(sed -n 1p "$DC_s/tpc")"
        if [ -f "$DS/ifs/mods/main/${tpa}.sh" ] ; then
            source "$DS/ifs/mods/main/${tpa}.sh"; ${tpa} &
        else
            echo 13 > "${DC_tlt}/stts"
            > "$DC_s/tpc"
            "$DS/mngr.sh" mkmn 1
        fi
    fi
    
    oclean & return 0
}

bground_session() {
    source "$DS/ifs/cmns.sh"
    sleep 5
    if [ ! -e "$DT/ps_lk" -a ! -d "$DT" ]; then
         new_session
    fi
    if [[ $(cdb ${cfgdb} 1 opts itray) = TRUE ]] && \
    ! pgrep -f "$DS/ifs/tls.sh itray"; then
    export cu=TRUE
    _start 0; fi
}

ipanel() {
    source "$DS/ifs/mods/main/items_list.sh"
    set_geom(){
        sleep 1
        spost=$(xwininfo -name Idiomind |grep geometry |cut -d ' ' -f 4)
        cdb ${cfgdb} 3 geom vals ${cpost}
        for n in {1..10}; do
            sleep 1
            cpost=$(xwininfo -name Idiomind |grep geometry |cut -d ' ' -f 4)
            if [ -z ${cpost} ]; then break; return 1; fi
            if [ ${spost} != ${cpost} ]; then
                spost=${cpost}
                cdb ${cfgdb} 3 geom vals ${cpost}
            fi
        done
    } >/dev/null 2>&1
    
    geometry=$(cdb ${cfgdb} 1 geom vals)
    if [ -n "$geometry" ]; then
    geometry="--geometry=$geometry"
    else geometry="--mouse"; fi
    export swind=$(cdb ${cfgdb} 1 opts swind)
    (panelini; if [ $? != 0 ] && ! pgrep -f "$DS/ifs/tls.sh itray"; then \
    "$DS/stop.sh" 1 & fi; exit ) & set_geom
}

_start() {
    source "$DS/ifs/cmns.sh"
    if [ ! -d "$DT" ] && [[ -z "$1" ]]; then 
        new_session
    fi
    if [ ! -f "$DT/tpe" ]; then
        cu=TRUE; touch "$DT/tpe"
    fi
    if [ "$(< "$DT/tpe")" != "${tpc}" ]; then
        touch "$DT/tpe"
    fi
    date=$(cdb ${cfgdb} 1 sess date)
    if [[ "$(date +%d)" != "$date" ]] && [[ -z "$1" ]]; then
        new_session; cu=TRUE
    fi
    ( if [[ "${cu}" = TRUE ]]; then
    "$DS/ifs/tls.sh" a_check_updates & fi ) &

    export swind=$(cdb ${cfgdb} 1 opts swind) 
    if [[ $(cdb ${cfgdb} 1 opts itray) = TRUE ]]; then
        if ! pgrep -f "$DS/ifs/tls.sh itray"; then
            $DS/ifs/tls.sh itray &
        else
            idiomind topic
        fi
    else
        if ! pgrep -f "yad --fixed --form --title="Idiomind""; then
            ipanel &
        else
            idiomind topic
        fi
    fi
}

case "$1" in
    -v|--version)
    source $DS/default/sets.cfg
    echo -n "$_version" ;;
    -s)
    new_session; idiomind ;;
    topic)
    topic ;;
    first_run)
    "$DS/ifs/tls.sh" "$@" ;;
    index)
    "$DS/mngr.sh" mkmn 0 ;;
    autostart)
    bground_session ;;
    --add)
   "$DS/add.sh" new_items "${dir}" 2 "${2}" ;;
    add)
    "$DS/add.sh" new_item '__cmd__' "${@}" ;;
    feeds)
    "$DS/mngr.sh" edit_feeds "${tpc}" ;;
    tasks)
    "$DS/ifs/mods/start/update_tasks.sh" ;;
    panel)
    ipanel ;;
    stop)
    "$DS/stop.sh" 2 ;;
    update_addons)
    "$DS/ifs/tls.sh" update_addons ;;
    *)
    _start ;;
esac
