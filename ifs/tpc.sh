#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [ -z "${1}" ]; then exit 1; fi
source "$DS/ifs/cmns.sh"
topic="${1}"
mode="${2}"
activ="${3}"
DC_tlt="$DM_tl/${topic}/.conf"
DM_tlt="$DM_tl/${topic}"
export mode

chek_topic() {
    if [ ! -d "${DC_tlt}" -o ! -e "${DC_tlt}/id.cfg" ]; then
        mkdir -p "${DM_tlt}/images"
        mkdir "${DC_tlt}"; cd "${DC_tlt}"
        for i in {0..10}; do touch "${DC_tlt}/${i}.cfg"; done
        rm ./"7.cfg" ./"9.cfg"
        echo " " > "info"
        echo ${mode} > ./"8.cfg"; cd /
    fi
    
    if [ ! -e "$DT/n_s_pr" ]; then
        "$DS/ifs/tls.sh" check_index "${topic}"
    fi
}

active_topic() {
    if [[ ${activ} = 0 ]]; then
        :
        
    elif [[ ${activ} = 1 ]]; then
        echo "${topic}" > "$DC_s/4.cfg"
        ( sleep 1; notify-send -i idiomind "${topic}" "$(gettext "Is now your topic")" -t 4000 ) & exit
        
    elif [[ -z "$activ" ]]; then
        echo "${topic}" > "$DC_s/4.cfg"
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
        
            export mode="$(< "${DC_tlt}/8.bk")"
            rm "${DC_tlt}/8.bk"; echo ${mode} > "${DC_tlt}/8.cfg"
            touch "${DM_tlt}"
            
            export stts=${mode}
            if [ -f "${DC_tlt}/9.cfg" ]; then
                calculate_review "${topic}"
                if [[ $((stts%2)) = 0 ]]; then
                    if [ ${RM} -ge 180 -a ${stts} = 8 ]; then
                        echo 10 > "${DC_tlt}/8.cfg"; touch "${DM_tlt}"
                    elif [ ${RM} -ge 100 -a ${stts} -lt 8 ]; then
                        echo 8 > "${DC_tlt}/8.cfg"; touch "${DM_tlt}"
                    fi
                else
                    if [ ${RM} -ge 180 -a ${stts} = 7 ]; then
                        echo 9 > "${DC_tlt}/8.cfg"; touch "${DM_tlt}"
                    elif [ ${RM} -ge 100 -a ${stts} -lt 7 ]; then
                        echo 7 > "${DC_tlt}/8.cfg"; touch "${DM_tlt}"
                    fi
                fi
            fi
            
            if grep -E '3|4|7|8|9|10' <<<"$stts"; then
            > "${DC_tlt}/7.cfg"; fi
            
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
            echo "${tpc}" > "$DC_s/4.cfg"
            active_topic
        fi
    fi
    
else
    [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
    "$DS/mngr.sh" mkmn 0
    msg "$(gettext "No such file or directory")\n${topic}\n" error & exit 1
fi
