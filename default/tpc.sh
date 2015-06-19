#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
topic="${1}"
DC_tlt="$DM_tl/${topic}/.conf"
DM_tlt="$DM_tl/${topic}"
cfgfile="tname=\"${topic}\"
langs=\"${lgsl^}\"
langt=\"${lgtl^}\"
authr=\"$Author\"
cntct=\"$Mail\"
ctgry=\"$Ctgry\"
ilink=\"$link\"
datec=\"$(date +%F)\"
dateu=\"$dateu\"
datei=\"$datei\"
nword=\"$words\"
nsent=\"$sentences\"
nimag=\"$images\"
level=\"$level\"
set_1=\"FALSE\"
set_2=\"FALSE\""


if grep -Fxo "${topic}" < <(ls "$DS/addons"/); then
    "$DS/ifs/mods/topic/${topic}.sh" 2 & exit 1

else
    if [ -d "${DM_tlt}" ]; then

        if [ ! -d "${DC_tlt}" ]; then
        mkdir -p "${DM_tlt}/images"
        mkdir "${DC_tlt}"; cd "${DC_tlt}"
        c=0; while [[ $c -le 10 ]]; do
        touch "$c.cfg"; let c++
        done

        rm "${DC_tlt}/7.cfg" "${DC_tlt}/9.cfg"
        echo " " > "${DC_tlt}/info"
        echo -e "${cfgfile}" > "id.cfg"
        echo 1 > "8.cfg"
        fi
        cd /
        echo "${topic}" > "$DC_s/4.cfg"
        echo "${topic}" > "$DC_s/7.cfg"
        echo "${topic}" > "$DT/tpe"
        
        [ ! -d "$HOME/.idiomind/backup" ] && mkdir "$HOME/.idiomind/backup"
        if ! grep "${tpc}.bk" < <(cd "$HOME/.idiomind/backup" \
        find . -maxdepth 1 -name '*.bk' -mtime -1); then
        if [ -f "$(< "${DC_tlt}/0.cfg")" ]; then
        cp -f "${DC_tlt}/0.cfg" "$HOME/.idiomind/backup/${tpc}.bk"; fi
        cd /
        fi
        
        echo 0 > "$DC_s/5.cfg"
        
        if [[ `wc -l < "${DC_tlt}/id.cfg"` -lt 16 ]]; then
        echo -e "${cfgfile}" > "${DC_tlt}/id.cfg"; fi

        #if [ ! -f "$DT/.n_s_pr" ]; then
        #"$DS/ifs/tls.sh" check_index "${topic}"; fi
        
        stts=$(sed -n 1p "${DC_tlt}/8.cfg")
        if [[ $(grep -Fxon "${topic}" "${DM_tl}/.1.cfg" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p') -ge 50 ]]; then
        
            if [ -f "${DC_tlt}/9.cfg" ]; then
            
                calculate_review "${topic}"
                if [[ $((stts%2)) = 0 ]]; then
                
                    if [[ $RM -ge 180 ]]; then
                    echo 10 > "${DC_tlt}/8.cfg"
                    elif [[ $RM -ge 100 ]]; then
                    echo 8 > "${DC_tlt}/8.cfg"; fi
                    
                    else
                    if [[ $RM -ge 180 ]]; then
                    echo 9 > "${DC_tlt}/8.cfg"
                    elif [[ $RM -ge 100 ]]; then
                    echo 7 > "${DC_tlt}/8.cfg"; fi
                fi
            fi
            "$DS/mngr.sh" mkmn
        fi
        
        [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
        
        if [[ "$2" = 1 ]]; then
        
            (sleep 2
            notify-send --icon=idiomind \
            "${topic}" "$(gettext "Is now your topic")" -t 4000) & exit
            
        elif [[ -z "$2" ]]; then 
            idiomind topic & exit
        fi
        
    else
        [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
        msg "$(gettext "No such file or directory")\n${topic}\n" error & exit 1
    fi
fi
