#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if [ -z "${1}" ]; then exit 1; fi
source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
topic="${1}"
DC_tlt="$DM_tl/${topic}/.conf"
DM_tlt="$DM_tl/${topic}"

if grep -Fxo "${topic}" < <(ls "$DS/addons"/); then
    "$DS/ifs/mods/topic/${topic}.sh" 2 & exit 1

else
    if [ -d "${DM_tlt}" ]; then

        if [ ! -d "${DC_tlt}" ]; then
        
c1="tname=\"${topic}\"
langs=\"${lgsl^}\"
langt=\"${lgtl^}\"
authr=\"$Author\"
cntct=\"$Mail\"
ctgry=\"$Ctgry\"
ilink=\"$link\"
oname=\"${topic}\"
datec=\"$(date +%F)\"
dateu=\"$dateu\"
datei=\"$datei\"
nword=\"$words\"
nsent=\"$sentences\"
nimag=\"$images\"
naudi=\"$audio\"
nsize=\"$size\"
level=\"$level\"
set_1=\"\"
set_2=\"\"
set_3=\"\"
set_4=\"\""
c2="words=\"\"
sntcs=\"\"
marks=\"\"
wprct=\"\"
nsepi=\"\"
svepi=\"\"
rplay=\"\"
audio=\"\"
ntosd=\"\"
loop=\"0\"
rword=\"0\"
rsntc=\"0\""
        
            mkdir -p "${DM_tlt}/images"
            mkdir "${DC_tlt}"; cd "${DC_tlt}"
            c=0; while [[ $c -le 10 ]]; do
            touch "$c.cfg"; let c++
            done

            rm "${DC_tlt}/7.cfg" "${DC_tlt}/9.cfg"
            echo " " > "${DC_tlt}/info"
            echo -e "${c1}" > ./"id.cfg"
            echo -e "${c2}" > ./"10.cfg"
            
            echo 1 > "8.cfg"
        fi
        cd /
        echo "${topic}" > "$DC_s/4.cfg"
        echo "${topic}" > "$DC_s/7.cfg"
        echo "${topic}" > "$DT/tpe"
        
        [ ! -d "$HOME/.idiomind/backup" ] && mkdir "$HOME/.idiomind/backup"
        if ! grep "${topic}.bk" < <(cd "$HOME/.idiomind/backup" \
        find . -maxdepth 1 -name '*.bk' -mtime -1); then
        if [ -n "$(< "${DC_tlt}/0.cfg")" ]; then
        cp -f "${DC_tlt}/0.cfg" "$HOME/.idiomind/backup/${topic}.bk"; fi
        cd /; fi
        
        if [[ `< "$DC_s/5.cfg"` != 0 ]]; then
        echo 0 > "$DC_s/5.cfg"; fi
        
        if [[ `wc -l < "${DC_tlt}/id.cfg"` -lt 16 ]]; then
        echo -e "${cfgfile}" > "${DC_tlt}/id.cfg"; fi

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
        msg "$(gettext "No such file or directory")\n${topic}\n" error & exit 1
    fi
fi
