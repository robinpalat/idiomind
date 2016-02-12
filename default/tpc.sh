#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [ -z "${1}" ]; then exit 1; fi
source "$DS/ifs/mods/cmns.sh"
topic="${1}"
notif="${3}"
DC_tlt="$DM_tl/${topic}/.conf"
DM_tlt="$DM_tl/${topic}"
export mode=${2}

checkt() {
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
    if [ ! -f "$DT/.n_s_pr" ]; then
            "$DS/ifs/tls.sh" check_index "${topic}"; fi
        if [[ $(grep -Fxon "${topic}" "$DM_tl/.share/1.cfg" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p') -ge 100 ]]; then
            stts=$(sed -n 1p "${DC_tlt}/8.cfg")
        
            if [ -f "${DC_tlt}/9.cfg" ]; then
                calculate_review "${topic}"
                if [[ $((stts%2)) = 0 ]]; then
                    if [ ${RM} -ge 180 -a ${stts} = 8 ]; then
                        echo 10 > "${DM_tlt}/.conf/8.cfg"; touch "${DM_tlt}"
                    elif [ ${RM} -ge 100 -a ${stts} -lt 8 ]; then
                        echo 8 > "${DM_tlt}/.conf/8.cfg"; touch "${DM_tlt}"
                    fi
                else
                    if [ ${RM} -ge 180 -a ${stts} = 7 ]; then
                        echo 9 > "${DM_tlt}/.conf/8.cfg"; touch "${DM_tlt}"
                    elif [ ${RM} -ge 100 -a ${stts} -lt 7 ]; then
                        echo 7 > "${DM_tlt}/.conf/8.cfg"; touch "${DM_tlt}"
                    fi
                fi
            fi
            "$DS/mngr.sh" mkmn 1
        fi
}

shakeit() {
    if [[ ${notif} = 1 ]]; then
        ( sleep 1; notify-send -i idiomind "${topic}" "$(gettext "Is now your topic")" -t 4000 ) & exit
    elif [[ -z "$notif" ]]; then
        idiomind topic & exit
    fi
}

if [ -d "${DM_tlt}" ]; then

    if ((mode>=1 && mode<=10)); then
    
        checkt
        echo "${topic}" > "$DC_s/4.cfg"
        if [ ! -e "${DC_tlt}/feeds" ]; then
            echo "${topic}" > "$DT/tpe"; fi
        
        ( sleep 10 && "$DS/ifs/tls.sh" backup "${topic}" ) &

        [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
        
        shakeit
        
     elif [ ${mode} = 12 ]; then
     
        msg_2 "$(gettext "This topic is inactive, do you want to activate?")\n<b>$tname</b>\n" info "$(gettext "Yes")" "$(gettext "No")"
        
        if [ $? = 0 ]; then
        
            export mode="$(< "${DC_tlt}/8.bk")"
            rm "${DC_tlt}/8.bk"; echo ${mode} > "${DC_tlt}/8.cfg"
            touch "${DM_tlt}"
            echo "${topic}" > "$DC_s/4.cfg"
            checkt
            "$DS/mngr.sh" mkmn 1
            ( sleep 10 && "$DS/ifs/tls.sh" backup "${topic}" ) &
            
            shakeit
        else
            echo "${topic}" > "$DC_s/4.cfg"
            idiomind topic & exit 0
        fi

    elif [ ${mode} = 14 -o ${mode} = 13 ]; then
    
        checkt
        echo "${topic}" > "$DC_s/4.cfg"
        shakeit
        
    else
        if grep -Fxo "${topic}" < <(ls "$DS/addons"/); then
            source "$DS/ifs/mods/topic/${topic}.sh"
            echo "${tpc}" > "$DC_s/4.cfg"
        fi
    fi
    
else
    [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
    "$DS/mngr.sh" mkmn 0
    msg "$(gettext "No such file or directory")\n${topic}\n" error & exit 1
fi
