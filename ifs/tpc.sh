#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [ -z "${1}" ]; then exit 1; fi
source "$DS/ifs/cmns.sh"
topic="${1}"
stts="${2}"
[[ ! ${stts} =~ $numer ]] && stts=13
activ="${3}"
DC_tlt="$DM_tl/${topic}/.conf"
DM_tlt="$DM_tl/${topic}"
export stts
export stts2=$((stts+stts%2))
tpcdb="${DC_tlt}/tpc"

chek_topic() {
    if [ ! -d "${DM_tlt}" -o ! -d "${DC_tlt}" ]; then
        check_dir "${DM_tlt}/images" "${DC_tlt}"
        echo " " > "${DC_tlt}/note"
        echo ${stts} > "${DC_tlt}/stts"
        touch "${DC_tlt}/data"
    fi
    
    if [ ! -f "${tpcdb}" ]; then
        "$DS/ifs/mkdb.sh" tpc "${topic}"
    fi
    if ! file "${tpcdb}" | grep 'SQLite'; then
        "$DS/ifs/mkdb.sh" tpc "${topic}"
    fi
    
    touch "${DC_tlt}/data"
    if [ ! -f "$DT/n_s_pr" ]; then
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

    if ((stts>=1 && stts<=10)); then
    
        chek_topic
        echo "${topic}" > "$DT/tpe"
        ( sleep 10 && "$DS/ifs/tls.sh" backup "${topic}" ) &
        [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
        active_topic
        
     elif [ ${stts} = 0 -o ${stts} = 12 ]; then
     
        msg_2 "$(gettext "Topic inactive. Do you want to enable it now?") " \
        dialog-question "$(gettext "Yes")" "$(gettext "Just open it")"
        if [ $? = 0 ]; then
            
            if [ -f "${DC_tlt}/stts.bk" ]; then
                stts="$(< "${DC_tlt}/stts.bk")"
            else
                stts=13
            fi
            
            [[ ! "${stts}" =~ $numer ]] && stts=13
            [ ${stts} = 12 -o ${stts} = 0 ] && stts=1

            export stts
            cleanups "${DC_tlt}/stts.bk"; echo ${stts} > "${DC_tlt}/stts"
            chek_topic
            
            touch "${DM_tlt}"
            
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
            
            "$DS/mngr.sh" mkmn 1
            ( sleep 10 && "$DS/ifs/tls.sh" backup "${topic}" ) &
            active_topic
        else
            active_topic
            idiomind topic & exit 0
        fi
    elif [ ${stts} = 13 ]; then
    
        chek_topic
        active_topic
        
    elif [ ${stts} = 14 ]; then
    
        chek_topic
        active_topic
        
    else
        if grep -Fxo "${topic}" < <(ls "$DS/addons"/); then
            source "$DS/ifs/mods/main/${topic}.sh"
            echo "${topic}" > "$DC_s/tpc"
            active_topic
        fi
    fi
else
    [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
    "$DS/mngr.sh" mkmn 0
    msg "$(gettext "No such file or directory")\n${topic}\n" error & exit 1
fi

