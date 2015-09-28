#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [ -z "${1}" ]; then exit 1; fi
source "$DS/ifs/mods/cmns.sh"
topic="${1}"
DC_tlt="$DM_tl/${topic}/.conf"
DM_tlt="$DM_tl/${topic}"

if grep -Fxo "${topic}" < <(ls "$DS/addons"/); then
    source "$DS/ifs/mods/topic/${topic}.sh"
    echo 2 > "$DC_s/5.cfg"
    export mode=2; ${topic} 2 & exit
    
elif [ "${topic}" = "$(gettext "Dictionary")" ]; then
    source "$DS/ifs/mods/topic/Dictionary.sh"
    echo 1 > "$DC_s/5.cfg"
    export mode=1; Dictionary & exit
else
    if [ -d "${DM_tlt}" ]; then
        if [ ! -d "${DC_tlt}" -o ! -e "${DC_tlt}/id.cfg" ]; then
            mkdir -p "${DM_tlt}/images"
            mkdir "${DC_tlt}"; cd "${DC_tlt}"
            c=0
            while [[ ${c} -le 10 ]]; do
                touch "${c}.cfg"; let c++
            done
            rm "${DC_tlt}/7.cfg" "${DC_tlt}/9.cfg"
            echo " " > "${DC_tlt}/info"
            echo 1 > "8.cfg"; cd /
        fi
        echo "${topic}" > "$DC_s/4.cfg"
        echo "${topic}" > "$DC_s/7.cfg"
        echo "${topic}" > "$DT/tpe"
        ( sleep 10 && "$DS/ifs/tls.sh" backup "${topic}" ) &
        if [[ ! -e "$DC_s/5.cfg" ]]; then
            echo 0 > "$DC_s/5.cfg"; fi
        if [[ `< "$DC_s/5.cfg"` != 0 ]]; then
            echo 0 > "$DC_s/5.cfg"; fi
        if [ ! -f "$DT/.n_s_pr" ]; then
            "$DS/ifs/tls.sh" check_index "${topic}"; fi
        if [[ $(grep -Fxon "${topic}" "${DM_tl}/.1.cfg" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p') -ge 100 ]]; then
            stts=$(sed -n 1p "${DC_tlt}/8.cfg")
        
            if [ -f "${DC_tlt}/9.cfg" ]; then
                calculate_review "${topic}"
                if [[ $((stts%2)) = 0 ]]; then
                    if [ ${RM} -ge 180 -a ${stts} = 8 ]; then
                        echo 10 > "${DM_tlt}/.conf/8.cfg"; touch "${DM_tlt}"
                    elif [ ${RM} -ge 100 -a ${stts} -lt 8 ]; then
                        echo 8 > "${DM_tlt}/.conf/8.cfg"; touch "${DM_tlt}"; fi
                else
                    if [ ${RM} -ge 180 -a ${stts} = 7 ]; then
                        echo 9 > "${DM_tlt}/.conf/8.cfg"; touch "${DM_tlt}"
                    elif [ ${RM} -ge 100 -a ${stts} -lt 7 ]; then
                        echo 7 > "${DM_tlt}/.conf/8.cfg"; touch "${DM_tlt}"; fi
                fi
            fi
            "$DS/mngr.sh" mkmn
        fi
        [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
        
        if [[ "$2" = 1 ]]; then
            ( sleep 2
            notify-send --icon=idiomind \
            "${topic}" "$(gettext "Is now your topic")" -t 4000 ) & exit
        elif [[ -z "$2" ]]; then 
            idiomind topic & exit
        fi
    else
        [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
        "$DS/mngr.sh" mkmn
        msg "$(gettext "No such file or directory")\n${topic}\n" error & exit 1
    fi
fi
