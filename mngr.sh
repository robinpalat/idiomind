#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
source "$DS/default/sets.cfg"
lgt=${tlangs[$tlng]}
lgs=${slangs[$slng]}
export lgt lgs
include "$DS/ifs/mods/mngr"

mkmn() {
    f_lock "$DT/mn_lk"
    cleanups "$DM_tl/images" "$DM_tl/.conf"
    dirimg='/usr/share/idiomind/images'
    > "$DM_tl"/.share/0.cfg

    while read -r tpc; do
        dir="$DM_tl/${tpc}/.conf"; unset stts
        [ ! -d "${dir}" ] && mkdir -p "${dir}"
        if [ ! -e "$dir/8.cfg" ]; then
            stts=13; echo ${stts} > "$dir/8.cfg"
        else
            stts=$(sed -n 1p "${dir}/8.cfg")
            ! [[ ${stts} =~ $numer ]] && stts=13
        fi
		echo -e "$dirimg/img.${stts}.png\n${tpc}" >> "$DM_tl/.share/0.cfg"

    done < <(cd "$DM_tl"; find ./ -maxdepth 1 -mtime -80 -type d \
    -not -path '*/\.*' -exec ls -tNd {} + |sed 's|\./||g;/^$/d'; \
    find ./ -maxdepth 1 -mtime +79 -type d -not -path '*/\.*' \
    -exec ls -tNd {} + |sed 's|\./||g;/^$/d')

    if [[ "$2" = 1 ]]; then
        source "$DS/ifs/stats.sh"; save_topic_stats 0
    fi
    cleanups "$DT/mn_lk"; exit 0
}

delete_item_ok() {
    f_lock "$DT/ps_lk"
    trgt="${3}"; DM_tlt="$DM_tl/${2}"; DC_tlt="$DM_tl/${2}/.conf"
    item="$(grep -F -m 1 "trgt{${trgt}}" "$DC_tlt/0.cfg" |sed 's/}/}\n/g')"
    cdid=$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")

    if [ -n "${trgt}" ]; then
        cleanups "${DM_tlt}/$cdid.mp3" "${DM_tlt}/images/${trgt,,}.jpg"
        sed -i "/trgt{${trgt}}/d" "${DC_tlt}/0.cfg"

        if [ -d "${DC_tlt}/practice" ]; then
            cd "${DC_tlt}/practice"
            while read -r file_pr; do
                if grep -Fxq "${trgt}" "${file_pr}"; then
                    grep -vxF "${trgt}" "${file_pr}" > ./rm.tmp
                    sed '/^$/d' ./rm.tmp > "${file_pr}"
                fi
            done < <(ls ./*)
            rm ./*.tmp; cd /
        fi
        for n in {1..6}; do
            if [ -f "${DC_tlt}/${n}.cfg" ]; then
                grep -vxF "${trgt}" "${DC_tlt}/${n}.cfg" > "${DC_tlt}/${n}.cfg.tmp"
                sed '/^$/d' "${DC_tlt}/${n}.cfg.tmp" > "${DC_tlt}/${n}.cfg"
            fi
        done
        
        cleanups "${DC_tlt}/lst"
        rm "${DC_tlt}"/*.tmp
    fi
    if [[ $(wc -l < "${DC_tlt}/0.cfg") -lt 200 ]] && [ -e "${DC_tlt}/lk" ]; then
        cleanups "${DC_tlt}/lk"
    fi
    "$DS/ifs/tls.sh" colorize 1 &
    cleanups "$DT/ps_lk" & exit 1
}

delete_item() {
    f_lock "$DT/ps_lk"
    DM_tlt="$DM_tl/${2}"; DC_tlt="$DM_tl/${2}/.conf"
    if [ -n "${trgt}" ]; then
        msg_2 "$(gettext "Are you sure you want to delete this item?")\n" \
        edit-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"
        ret="$?"
        if [ $ret -eq 0 ]; then
            (sleep 0.1 && kill -9 $(pgrep -f "yad --form "))
            cleanups "${DM_tlt}/$cdid.mp3" "${DM_tlt}/images/${trgt,,}.jpg"
            sed -i "/trgt{${trgt}}/d" "${DC_tlt}/0.cfg"
            
            if [ -d "${DC_tlt}/practice" ]; then
                cd "${DC_tlt}/practice"
                while read file_pr; do
                    if grep -Fxq "${trgt}" "${file_pr}"; then
                        grep -vxF "${trgt}" "${file_pr}" > ./rm.tmp
                        sed '/^$/d' ./rm.tmp > "${file_pr}"; fi
                done < <(ls ./*)
                rm ./*.tmp; cd /
            fi
            for n in {1..6}; do
                if [ -f "${DC_tlt}/${n}.cfg" ]; then
                    grep -vxF "${trgt}" "${DC_tlt}/${n}.cfg" > "${DC_tlt}/${n}.cfg.tmp"
                    sed '/^$/d' "${DC_tlt}/${n}.cfg.tmp" > "${DC_tlt}/${n}.cfg"
                fi
            done
            if [[ $(wc -l < "${DC_tlt}/0.cfg") -lt 200 ]] \
            && [ -e "${DC_tlt}/lk" ]; then
                rm -f "${DC_tlt}/lk"; fi
            if [ -e "${DC_tlt}/feeds" ]; then
                echo "${trgt}" >> "${DC_tlt}/exclude"
            fi
            "$DS/ifs/tls.sh" colorize 1 &
            rm "${DC_tlt}"/*.tmp
        fi
    fi
    cleanups "$DT/ps_lk" & exit 1
}

edit_item() {
    [ -z ${2} -o -z ${3} ] && exit 1
    list="${2}"; item_pos=${3}; text_missing=${4}
    if [ ${list} = 1 ]; then
        index_1="${DC_tlt}/1.cfg"
        index_2="${DC_tlt}/2.cfg"
        [ ${item_pos} -lt 1 ] && item_pos=${cfg1}
    elif [ ${list} = 2 ]; then
        index_1="${DC_tlt}/2.cfg"
        index_2="${DC_tlt}/1.cfg"
        [ ${item_pos} -lt 1 ] && item_pos=${cfg2}
    fi
    item_trgt="$(sed -n ${item_pos}p "${index_1}")"
    edit_pos=$(grep -Fon -m 1 "trgt{${item_trgt}}" "${DC_tlt}/0.cfg" |sed -n 's/^\([0-9]*\)[:].*/\1/p')
    if ! [[ ${edit_pos} =~ ${numer} ]]; then
        edit_pos="$(awk 'match($0,v){print NR; exit}' v="trgt{${item_trgt}}" "${DC_tlt}/0.cfg")"
    fi
    if ! [[ ${edit_pos} =~ ${numer} ]]; then $DS/vwr.sh ${list} "${trgt}" 1 & exit; fi
    get_item "$(sed -n ${edit_pos}p "${DC_tlt}/0.cfg")"

    [ -z "${cdid}" ] && cdid=""
    export query="$(sed "s/'/ /g" <<< "${trgt}")"
    mod_index=0; tomodify=0; colorize_run=0; transl_mark=0
    if ((mode>=1 && mode<=10)); then
    tpcs="$(egrep -v "${tpc}" "$DM_tl/.share/2.cfg" |tr "\\n" '!' |sed 's/!\+$//g')"
    export tpc_list="${tpc}!${tpcs}"
    fi
    export cmd_delete="$DS/mngr.sh delete_item "\"${tpc}\"""
    export cmd_image="$DS/ifs/tls.sh set_image "\"${tpc}\"" ${cdid}"
    export cmd_def="'$DS/ifs/tls.sh' 'find_def' "\"${trgt}\"""
    export cmd_trad="'$DS/ifs/tls.sh' 'find_trad' "\"${trgt}\"""

    [ -z "${item}" ] && exit 1
    if [ ${text_missing} != 0 ]; then
        type=${text_missing}
    fi
    temp="...."
    if [[ "${srce}" = "${temp}" ]]; then
        if [ -e "$DT/${trgt}.edit" ]; then
            msg_4 "$(gettext "Wait till the process is completed.")" \
            "face-worried" "$(gettext "OK")" "$(gettext "Stop")" \
            "$(gettext "Wait")" "$DT/${trgt}.edit"
            if [ $? = 1 ]; then
                srce=""; transl_mark=1; rm -f "$DT/${trgt}.edit"
            else 
                $DS/vwr.sh ${list} "${trgt}" ${item_pos} & exit 1
            fi
        else
            srce=""; transl_mark=1
        fi
    fi
    if [ -e "${DM_tlt}/$cdid.mp3" ]; then
        audf="${DM_tlt}/$cdid.mp3"
    else
        audf="${DM_tls}/audio/${trgt,,}.mp3"
    fi
    if [ ${type} = 1 ]; then
        edit_dlg1="$(dlg_form_1)"
    elif [ ${type} = 2 ]; then
        edit_dlg2="$(dlg_form_2)"
    fi
    ret=$?
        if [ -z "${edit_dlg1}" -a -z "${edit_dlg2}" ]; then
            item_pos=$((item_pos-1))
        fi
        if [ ${ret} -eq 0 -o ${ret} -eq 2 ]; then
        
            include "$DS/ifs/mods/add"
            dlaud="$(grep -oP '(?<=dlaud=\").*(?=\")' "$DC_s/1.cfg")"
            if [ ${type} = 1 ]; then
                edit_dlg="${edit_dlg1}"
                trgt_mod="$(clean_9 "$(cut -d "|" -f1 <<< "${edit_dlg}")")"
                srce_mod="$(clean_9 "$(cut -d "|" -f2 <<< "${edit_dlg}")")"
                exmp_mod="$(clean_2 "$(cut -d "|" -f5 <<< "${edit_dlg}")")"
                defn_mod="$(clean_2 "$(cut -d "|" -f6 <<< "${edit_dlg}")")"
                note_mod="$(clean_2 "$(cut -d "|" -f11 <<< "${edit_dlg}")")"
                tpc_mod="$(cut -d "|" -f3 <<< "${edit_dlg}")"
                audf_mod="$(cut -d "|" -f9 <<< "${edit_dlg}")"
                mark_mod="$(cut -d "|" -f10 <<< "${edit_dlg}")"
                type_mod=1
            elif [ ${type} = 2 ]; then
                edit_dlg="${edit_dlg2}"
                trgt_mod="$(clean_2 "$(cut -d "|" -f3 <<< "${edit_dlg}")")"
                srce_mod="$(clean_2 "$(cut -d "|" -f4 <<< "${edit_dlg}")")"
                note_mod="$(clean_2 "$(cut -d "|" -f5 <<< "${edit_dlg}")")"
                audf_mod="$(cut -d "|" -f8 <<< "${edit_dlg}")"
                tpc_mod="$(cut -d "|" -f7 <<< "${edit_dlg}")"
                mark_mod="$(cut -d "|" -f1 <<< "${edit_dlg}")"
                type_mod="$(cut -d "|" -f2 <<< "${edit_dlg}")"
                grmr_mod="${grmr}"
                wrds_mod="${wrds}"
                [ "${type_mod}" = TRUE ] && type_mod=1
                [ "${type_mod}" = FALSE ] && type_mod=2
                [ -z "${type_mod}" ] && type_mod=2
            fi
            if [ "${trgt_mod}" != "${trgt}" ] && [ ! -z "${trgt_mod##+([[:space:]])}" ]; then
                trgt_mod="$(sed -e 's|/|\/|g' <<< "$trgt_mod")"
                if [ ${text_missing} != 0 ]; then trgt="${item_trgt}"; fi
                index edit "${tpc}"
                sed -i "${edit_pos}s|trgt{${trgt}}|trgt{${trgt_mod}}|;
                ${edit_pos}s|grmr{${grmr}}|grmr{${trgt_mod}}|;
                ${edit_pos}s|srce{${srce}}|srce{$temp}|g" "${DC_tlt}/0.cfg"
                mod_index=1; colorize_run=1; tomodify=1
            fi
            if [ "${mark}" != "${mark_mod}" ]; then
                if [ "${mark_mod}" = "TRUE" ]; then
                    tomodify=1; echo "${trgt}" >> "${DC_tlt}/6.cfg"; else
                    sed -i "/${trgt}/d" "${DC_tlt}/6.cfg"
                fi
                colorize_run=1; tomodify=1
            fi
            [[ "${transl_mark}" = 1 ]] && srce="$temp"
            [ "${type}" != "${type_mod}" ] && tomodify=1
            [ "${srce}" != "${srce_mod}" ] && tomodify=1
            [ "${exmp}" != "${exmp_mod}" ] && tomodify=1
            [ "${defn}" != "${defn_mod}" ] && tomodify=1
            [ "${note}" != "${note_mod}" ] && tomodify=1
            [ "${mark}" != "${mark_mod}" ] && tomodify=1
            [ "${audf}" != "${audf_mod}" ] && tomodify=1
            [ "${tpc}" != "${tpc_mod}" ] && tomodify=1 && item_pos=$((item_pos+1))

            if [ ${tomodify} = 1 ]; then
            
            ( if [ ${mod_index} = 1 ]; then
                
                    DT_r=$(mktemp -d "$DT/XXXXXX"); > "$DT/${trgt_mod}.edit"
                    
                    if [ ${type_mod} = 1 ]; then
                        srce_mod="$(clean_9 "$(translate "${trgt_mod}" $lgt $lgs)")"
                        [ -z "${srce_mod}" ] && internet
                        audio="${trgt_mod,,}"
                        [[ ${dlaud} = TRUE ]] && tts_word "${audio}" "$DT_r"
                        srce="$temp"
                    elif [ ${type_mod} = 2 ]; then
                        srce_mod="$(clean_2 "$(translate "${trgt_mod}" $lgt $lgs)")"
                        [ -z "${srce_mod}" ] && internet
                        db="$DS/default/dicts/$lgt"
                        export DT_r; sentence_p 2
                        [[ ${dlaud} = TRUE ]] && fetch_audio "${aw}" "${bw}"
                        srce="$temp"
                        grmr="${trgt_mod}"
                    fi
                fi
                cdid_mod="$(set_name_file ${type_mod} "${trgt_mod}" "${srce_mod}" \
                "${exmp_mod}" "${defn_mod}" "${note_mod}" "${wrds_mod}" "${grmr_mod}")"
                if [ "${tpc}" != "${tpc_mod}" ]; then
                    if [ "${audf}" != "${audf_mod}" ]; then
                        if [ ${type_mod} = 1 ]; then
                            cp -f "${audf_mod}" "${DM_tls}/audio/${trgt_mod,,}.mp3"
                        elif [ ${type_mod} = 2 ]; then
                            cp -f "${audf_mod}" "$DM_tl/${tpc_mod}/$cdid_mod.mp3"; fi
                    else
                        if [ ${type_mod} = 2 ]; then
                            [ -e "${DM_tlt}/$cdid.mp3" ] && \
                            mv -f "${DM_tlt}/$cdid.mp3" "$DM_tl/${tpc_mod}/$cdid_mod.mp3"
                        elif [ ${type_mod} = 1 ]; then
                            [ -e "${DM_tlt}/$cdid.mp3" ] && \
                            mv -f "${DM_tlt}/$cdid.mp3" "$DM_tl/${tpc_mod}/$cdid_mod.mp3"; fi
                    fi
                    [ -e "${DM_tlt}/images/${trgt,,}.jpg" ] && \
                    mv -f "${DM_tlt}/images/${trgt,,}.jpg" "$DM_tl/${tpc_mod}/images/${trgt_mod,,}.jpg"
                    "$DS/mngr.sh" delete_item_ok "${tpc}" "${trgt}"
                    trgt="${trgt_mod}"; srce="${srce_mod}"; tpe="${tpc_mod}"
                    exmp="${exmp_mod}"; defn="${defn_mod}"; note="${note_mod}"
                    wrds="${wrds_mod}"; grmr="${grmr_mod}";
                    mark="${mark_mod}"; link="${link_mod}"; cdid="${cdid_mod}"
                    index ${type_mod}; unset type trgt srce exmp defn note wrds grmr mark cdid
                elif [ "${tpc}" = "${tpc_mod}" ]; then
                    cfg0="${DC_tlt}/0.cfg"
                    edit_pos=$(grep -Fon -m 1 "trgt{${trgt_mod}}" "${cfg0}" |sed -n 's/^\([0-9]*\)[:].*/\1/p')
                    if ! [[ ${edit_pos} =~ ${numer} ]]; then 
                        edit_pos="$(awk 'match($0,v){print NR; exit}' v="trgt{${trgt_mod}}" "${cfg0}")"
                        if ! [[ ${edit_pos} =~ ${numer} ]]; then $DS/vwr.sh ${list} "${trgt}" 1 & exit; fi
                    fi
                    sed -i "${edit_pos}s|type{$type}|type{$type_mod}|;
                    ${edit_pos}s|srce{$srce}|srce{$srce_mod}|;
                    ${edit_pos}s|exmp{$exmp}|exmp{$exmp_mod}|;
                    ${edit_pos}s|defn{$defn}|defn{$defn_mod}|;
                    ${edit_pos}s|note{$note}|note{$note_mod}|;
                    ${edit_pos}s|wrds{$wrds}|wrds{$wrds_mod}|;
                    ${edit_pos}s|grmr{$grmr}|grmr{$grmr_mod}|;
                    ${edit_pos}s|mark{$mark}|mark{$mark_mod}|;
                    ${edit_pos}s|cdid{$cdid}|cdid{$cdid_mod}|g" "${cfg0}"
                    if [ "${audf}" != "${audf_mod}" ]; then
                        if [ ${type_mod} = 1 ]; then
                            cp -f "${audf_mod}" "${DM_tls}/audio/${trgt_mod,,}.mp3"
                        elif [ ${type_mod} = 2 ]; then
                            [ -e "${DM_tlt}/$cdid.mp3" ] && rm "${DM_tlt}/$cdid.mp3"
                            cp -f "${audf_mod}" "${DM_tlt}/$cdid_mod.mp3"; fi
                    else
                        if [ ${type_mod} = 2 ]; then
                            [ -e "${DM_tlt}/$cdid.mp3" ] && \
                            mv -f "${DM_tlt}/$cdid.mp3" "${DM_tlt}/$cdid_mod.mp3"
                        elif [ ${type_mod} = 1 ]; then
                            [ -e "${DM_tlt}/$cdid.mp3" ] && \
                            mv -f "${DM_tlt}/$cdid.mp3" "${DM_tlt}/$cdid_mod.mp3"; fi
                    fi
                fi
                if [ "$type" != "$type_mod" ]; then
                    if [ ${type_mod} = 1 ]; then
                        if grep -Fxq "${trgt_mod}" "${DC_tlt}/4.cfg"; then
                            grep -vxF "${trgt_mod}" "${DC_tlt}/4.cfg" > "${DC_tlt}/4.cfg.tmp"
                            sed '/^$/d' "${DC_tlt}/4.cfg.tmp" > "${DC_tlt}/4.cfg"
                        fi
                        echo "${trgt_mod}" >> "${DC_tlt}/3.cfg"
                        rm "${DC_tlt}"/*.tmp
                    elif [ ${type_mod} = 2 ]; then
                        if grep -Fxq "${trgt_mod}" "${DC_tlt}/3.cfg"; then
                            grep -vxF "${trgt_mod}" "${DC_tlt}/3.cfg" > "${DC_tlt}/3.cfg.tmp"
                            sed '/^$/d' "${DC_tlt}/3.cfg.tmp" > "${DC_tlt}/3.cfg"
                        fi
                        echo "${trgt_mod}" >> "${DC_tlt}/4.cfg"
                        rm "${DC_tlt}"/*.tmp
                    fi
                fi
                [ -e "${DM_tlt}/images/${trgt,,}.jpg" ] && \
                mv -f "${DM_tlt}/images/${trgt,,}.jpg" "${DM_tlt}/images/${trgt_mod,,}.jpg"
                cleanups "$DT_r" "$DT/${trgt_mod}.edit"
            ) &
            fi
            [ ${type} != ${type_mod} -a ${type_mod} = 1 ] && ( img_word "${trgt}" "${srce}" ) &
            [ ${colorize_run} = 1 ] && "$DS/ifs/tls.sh" colorize 1 &

            if [ $ret -eq 2 ]; then $DS/mngr.sh edit ${list} $((item_pos+1)) &
            elif [ $ret -eq 0 ]; then 
                [ ${tomodify} = 1 -a $ret -eq 0 ] && sleep 0.2
                $DS/vwr.sh ${list} "${trgt}" ${item_pos} & 
            fi
        else
            "$DS/vwr.sh" ${list} "${trgt}" $((item_pos+1)) &
        fi
        exit 0
} >/dev/null 2>&1

edit_list_cmds() {
    if grep -o -E 'ja|zh-cn|ru' <<< "${lgt}"; then c=c; else c=w; fi
    direc="$DM_tl/${2}/.conf"
    if [ -e "$DT/transl_batch_out" ]; then
        msg_4 "$(gettext "Please wait until the current actions are finished")" \
        "face-worried" "$(gettext "OK")" "$(gettext "Stop")" \
        "$(gettext "Wait")" "$DT/transl_batch_out"
        ret=$?
        if [ $ret -eq 1 ]; then 
            cleanups "$DT/transl_batch_out"
        else
            return 1
        fi
    fi
    if [ $1 -eq 0 -o $1 -eq 2 -o $1 -eq 4 ]; then
        if [ $1 -eq 0 ]; then 
            cmd=cat && invrt_msg=FALSE
        elif [ $1 -eq 2 ]; then 
            cmd=tac && invrt_msg=TRUE
            mv -f "$DT/list_input" "$DT/list_output"
        elif [ $1 -eq 4 ]; then
            cmd=cat && invrt_msg=FALSE
            mv -f "$DT/list_input" "$DT/list_output"
        fi
        
        dlaud="$(grep -oP '(?<=dlaud=\").*(?=\")' "$DC_s/1.cfg")"
        include "$DS/ifs/mods/add"
        n=1; f_lock "$DT/el_lk"
        cleanups "${direc}/1.cfg" "${direc}/3.cfg" "${direc}/4.cfg"

        $cmd "$DT/list_output" |sed '/^$/d;/(null)/d' |while read -r trgt; do
            if grep -F -m 1 "trgt{${trgt}}" "${direc}/0.cfg"; then
                item="$(grep -F -m 1 "trgt{${trgt}}" "${direc}/0.cfg" |sed 's/}/}\n/g')"
                get_item "${item}"
                if [ $1 -eq 4 ]; then
                    [ $(wc -$c <<< "${trgt}") -lt 5 ] && type=1
                fi
                if [ ${type} = 1 ]; then
                    echo "${trgt}" >> "${direc}/3.cfg"
                elif [ ${type} = 2 ]; then
                    echo "${trgt}" >> "${direc}/4.cfg"
                fi
                if ! grep -Fxo "${trgt}" "${direc}/2.cfg"; then
                    echo "${trgt}" >> "${direc}/1.cfg"
                fi
            else
                unset_item
                if [[ $(wc -$c <<< "${trgt}") = 1 ]]; then
                    echo "${trgt}" >> "${direc}/3.cfg"; type=1
                else 
                    echo "${trgt}" >> "${direc}/4.cfg"; type=2
                fi
                echo "${trgt}" >> "${direc}/1.cfg"
                temp="...."; grmr="${trgt}"; srce="${temp}"
                echo "${trgt}" >> "$DT/items_to_add"
            fi
            
            eval newline="$(sed -n 2p "$DS/default/vars")"
            echo "${newline}" >> "$DT/new_data"
            let n++
        done

        touch "${direc}/3.cfg" "${direc}/4.cfg"
        mv -f "$DT/new_data" "${direc}/0.cfg"

        if [ -d "$DM_tl/${2}" -a $(wc -l < "${direc}/0.cfg") -ge 1 ]; then
            while read -r fname; do
                cdid=$(basename "${fname}" |sed "s/\(.*\).\{4\}/\1/" |tr -d '.')
                if ! grep "${cdid}" "${direc}/0.cfg"; then
                    cleanups "${fname}"
                fi
            done < <(find "$DM_tl/${2}"/*.mp3)
            while read -r fname; do
                trgt=$(basename "${fname}" |sed "s/\(.*\).\{4\}/\1/" |tr -d '.')
                if ! grep "trgt{${trgt^}}" "${direc}/0.cfg"; then
                    cleanups "${fname}"
                fi
            done < <(find "$DM_tl/${2}/images"/*.jpg)
        fi
        
        if [[ "$(cat "${direc}/1.cfg" "${direc}/2.cfg" |wc -l)" -lt 1 ]]; then
        > "${direc}/0.cfg"; fi
        "$DS/ifs/tls.sh" colorize 1
        rm -f "$DT/el_lk"

        if [ -e "$DT/items_to_add" ]; then
            invrt_msg=FALSE
            export DT_r=$(mktemp -d "$DT/XXXXXX")
            temp="...."
            
            while read -r trgt; do
                pos=$(grep -Fon -m 1 "trgt{${trgt}}" "${direc}/0.cfg" \
                |sed -n 's/^\([0-9]*\)[:].*/\1/p')
                if ! [[ ${pos} =~ ${numer} ]]; then
                    pos="$(awk 'match($0,v){print NR; exit}' v="trgt{${trgt}}" "${direc}/0.cfg")"
                fi
                item="$(sed -n ${pos}p "${direc}/0.cfg" |sed 's/}/}\n/g')"
                type=$(grep -oP '(?<=type{).*(?=})' <<< "${item}")
                cdid=$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")
                trgt_mod="${trgt}"; grmr="${trgt}"; srce="$temp"
                > "$DT/${trgt}.edit"
                
                if [ ${type} = 1 ]; then
                    srce_mod="$(clean_9 "$(translate "${trgt}" $lgt $lgs)")"
                    [ -z "${srce_mod}" ] && internet
                    audio="${trgt,,}"
                    [[ ${dlaud} = TRUE ]] && tts_word "${audio}" "$DT_r"
                
                elif [ ${type} = 2 ]; then
                    srce_mod="$(clean_2 "$(translate "${trgt}" $lgt $lgs)")"
                    [ -z "${srce_mod}" ] && internet
                    db="$DS/default/dicts/$lgt"
                    export DT_r; sentence_p 2
                    [[ ${dlaud} = TRUE ]] && fetch_audio "${aw}" "${bw}"
                fi
                
                cdid_mod="$(set_name_file ${type} "${trgt}" "${srce_mod}" \
                "${exmp}" "${defn}" "${note}" "${wrds_mod}" "${grmr_mod}")"
                
                if [ ${type} = 2 -a ${dlaud} = TRUE ]; then cd "$DT_r"
                tts_sentence "${trgt}" "$DT_r" "${DM_tlt}/$cdid_mod.mp3"; fi
                
                sed -i "${pos}s|srce{$srce}|srce{$srce_mod}|;
                ${pos}s|wrds{$wrds}|wrds{$wrds_mod}|;
                ${pos}s|grmr{$trgt}|grmr{$grmr_mod}|;
                ${pos}s|cdid{$cdid}|cdid{$cdid_mod}|g" "${direc}/0.cfg"
                cleanups "$DT/${trgt}.edit"
            done < "$DT/items_to_add"
        fi
    fi
    cleanups "$DT/list_output" "$DT/list_input" \
    "$DT/items_to_add" "$DT_r" "$DT/act_restfile" "$DT/edit_list_more"
    return 1
} >/dev/null 2>&1


edit_list_more() {
    touch "$DT/edit_list_more"
    file="$HOME/.idiomind/backup/${tpc}.bk"
    cols1="$(gettext "Reverse items order")\n$(gettext "Remove all items")\n$(gettext "Restart topic status")\n$(gettext "Manage feeds")\n$(gettext "Show short sentences in word's view")"
    dt1=$(grep '\----- newest' "${file}" |cut -d' ' -f3)
    dt2=$(grep '\----- oldest' "${file}" |cut -d' ' -f3)
    if [ -n "$dt2" ]; then
        cols2="\n$(gettext "Restore backup:") $dt1\n$(gettext "Restore backup:") $dt2"
    elif [ -n "$dt1" ]; then
        cols2="\n$(gettext "Restore backup:") $dt1"
    else
        cols2=""
    fi
    
    more="$(echo -e "${cols1}${cols2}" |sed '/^$/d' \
    |yad --list --title="$(gettext "More options")" \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --name=Idiomind --class=Idiomind \
    --expand-column=2 --no-click --no-headers\
    --window-icon=idiomind --on-top --center \
    --width=400 --height=350 --borders=3 \
    --column="":TXT \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0)"
    ret="$?"
    
    if [ $ret = 0 ]; then
        _war(){ msg_2 "$(gettext "Confirm")\n" \
        dialog-question "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"; }

        if grep "$(gettext "Reverse items order")" <<< "${more}"; then
            _war; if [ $? = 0 ]; then
                yad_kill "yad --list --title="
                edit_list_cmds 2 "${tpc}"
            fi
        elif grep "$(gettext "Remove all items")" <<< "${more}"; then
            _war; if [ $? = 0 ]; then
                yad_kill "yad --list --title="
                cleanups "$DT/list_output" "$DT/list_input"
                cleanups "${DC_tlt}/0.cfg" "${DC_tlt}/1.cfg" "${DC_tlt}/2.cfg" \
                "${DC_tlt}/3.cfg" "${DC_tlt}/4.cfg" "${DC_tlt}/5.cfg" "${DC_tlt}/6.cfg"
                [ -d "${DM_tlt}" -a -n "$tpc" ] && rm "$DM_tlt"/*.mp3
            fi
        elif grep "$(gettext "Restart topic status")" <<< "${more}"; then
            _war; if [ $? = 0 ]; then
                yad_kill "yad --list --title="
                cleanups "$DT/list_output" "$DT/list_input"
                cleanups "${DC_tlt}/1.cfg" "${DC_tlt}/2.cfg" "${DC_tlt}/7.cfg" 
                echo 1 > "${DC_tlt}/8.cfg"; > "${DC_tlt}/9.cfg"
                while read -r item_; do
                    item="$(sed 's/}/}\n/g' <<< "${item_}")"
                    trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
                    [ -n "${trgt}" ] && echo "${trgt}" >> "${DC_tlt}/1.cfg"
                done < "${DC_tlt}/0.cfg"
                
                sed -i "s/repass=.*/repass=\"0\"/g" "${DC_tlt}/10.cfg"
                "$DS/mngr.sh" mkmn 1; "$DS/ifs/tls.sh" colorize 0
            fi
        elif grep "$(gettext "Manage feeds")" <<< "${more}"; then
            idiomind feeds
            
        elif grep "$(gettext "Show short sentences in word's view")" <<< "${more}"; then
            _war; if [ $? = 0 ]; then
                yad_kill "yad --list --title="
                edit_list_cmds 4 "${tpc}"
            fi
        elif grep "$(gettext "Restore backup:")" <<< "${more}"; then
             _war; if [ $? = 0 ]; then
                yad_kill "yad --list --title="
                cleanups "$DT/list_output" "$DT/list_input"
                if grep ${dt1} <<< "${more}"; then
                    export line=1
                elif grep ${dt2} <<< "${more}"; then
                    export line=2
                fi
                "$DS/ifs/tls.sh" restore "${tpc}" ${line}
            fi
        fi
    else
        cleanups "$DT/items_to_add"  \
        "$DT/act_restfile" "$DT/edit_list_more"
    fi
} >/dev/null 2>&1


edit_list_dlg() {
    direc="$DM_tl/${2}/.conf"
    
    if [ -e "$DT/items_to_add" -o -e "$DT/el_lk" ]; then
        if [ -e "$DT/items_to_add" ]; then
            msg_4 "$(gettext "Wait until it finishes a previous process")" \
            "face-worried" "$(gettext "OK")" "$(gettext "Stop")" \
            "$(gettext "Wait")" "$DT/items_to_add"
            ret=$?
        elif [ -e "$DT/el_lk" ]; then
            msg_4 "$(gettext "Wait until it finishes a previous process")" \
            "face-worried" "$(gettext "OK")" "$(gettext "Stop")" \
            "$(gettext "Wait")" "$DT/el_lk"
            ret=$?
        fi
        if [ $ret -eq 1 ]; then 
            cleanups "$DT/items_to_add" "$DT/el_lk"
        else 
            return 1
        fi
    fi
    if [ -e "$DC_s/elist_first_run" ]; then 
        "$DS/ifs/tls.sh" first_run edit_list &
    fi

    cleanups "$DT/list_output"; > "$DT/list_input"
    
    lns=$(cat "${direc}/0.cfg" |wc -l)
    (n=1; echo "#"; cat "${direc}/0.cfg" | while read -r item_; do
        item="$(sed 's/}/}\n/g' <<< "${item_}")"
        trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
        [ -n "${trgt}" ] && echo "${trgt}" >> "$DT/list_input"
        let n++; echo $((100*n/lns-1))
    done ) | progr_3 "progress"

    edit_list_list < "$DT/list_input" > "$DT/list_output"
    ret=$?
    
    if [ $ret = 0 ]; then
        edit_list_cmds 0 "${tpc}"
    else
        if [ ! -e "$DT/edit_list_more" ]; then
            cleanups "$DT/list_input" "$DT/list_output"
        fi
    fi
}


edit_feeds() {
    file="$DM_tl/${2}/.conf/feeds"
    feeds="$(< "${file}")"
    [ -n "$feeds" ] && btnf="--button="$(gettext "Fetch Content")":2" \
    || btnf="--center"
    export btnf; mods="$(echo "${feeds}" |edit_feeds_list)"
    ret="$?"
    if [ $ret != 1 -a $ret -le 2 ]; then
        if [ -z "${mods}" ]; then
            cleanups "${file}" "$DM_tl/${2}/.conf/exclude"
        elif [ "${feeds}" != "${mods}" ]; then
            touch "$DM_tl/${2}/.conf/exclude"
            echo "${mods}" |sed -e '/^$/d' > "${file}"
        fi
        if  [ $ret = 2 ]; then
            "$DS/add.sh" fetch_content "${tpc}" &
        fi
    fi
} >/dev/null 2>&1


delete_topic() {
    if [ -z "${tpc}" ]; then exit 1; fi
    if [ "${tpc}" != "${2}" ]; then
        msg "$(gettext "Sorry, this topic is currently not active.")\n " \
        dialog-information "$(gettext "Information")" & exit
    fi
    msg_2 "$(gettext "Are you sure you want to delete this topic?")\n" \
    edit-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"
    ret="$?"
    if [ ${ret} -eq 0 ]; then
        f_lock "$DT/rm_lk"
        
        if [ -f "$DT/n_s_pr" ]; then
            if [ "$(sed -n 1p "$DT/n_s_pr")" = "${tpc}" ]; then
            "$DS/stop.sh" 5; fi
        fi
        if [ -e "$DT/playlck" ]; then
            if [ "$(sed -n 1p "$DT/playlck")" = "${tpc}" ]; then 
            "$DS/stop.sh" 2; fi
        fi
        cleanups "$DM/backup/${tpc}.bk"

        if [ -d "$DM_tl/${tpc}" ]; then cleanups "$DM_tl/${tpc}"; fi
     
        if [ -d "$DM_tl/${tpc}" ]; then sleep 0.5
            msg "$(gettext "Could not remove the directory:")\n$DM_tl/${tpc}\n$(gettext "You must manually remove it.")" \
            dialog-information "$(gettext "Information")"
        fi
        
        rm -f "$DT/tpe"; > "$DC_s/4.cfg"
        for n in {0..6}; do
            if [ -e "$DM_tl/.share/${n}.cfg" ]; then
                grep -vxF "${tpc}" "$DM_tl/.share/${n}.cfg" > "$DM_tl/.share/${n}.cfg.tmp"
                sed '/^$/d' "$DM_tl/.share/${n}.cfg.tmp" > "$DM_tl/.share/${n}.cfg"
            fi
        done
        
        yad_kill "yad --list " "yad --text-info " \
        "yad --form " "yad --notebook "
        
        "$DS/mngr.sh" mkmn 1 &
    fi
    rm -f "$DT/rm_lk" "$DM_tl/.share"/*.tmp & exit 1
}


rename_topic() {
    source "$DS/ifs/mods/add/add.sh"
    listt="$(cd "$DM_tl"; find ./ -maxdepth 1 -type d \
    ! -path "./.share"  |sed 's|\./||g'|sed '/^$/d')"

    #if grep -Fxo "${tpc}" < "$DM_tl/.share/2.cfg"; then i=1; fi
    name="$(clean_3 "${2}")"
    
    if grep -Fxo "${name}" < <(ls "$DS/addons/"); then name="${name} (1)"; fi
    chck="$(grep -Fxo "${name}" <<< "${listt}" |wc -l)"
    
    if [ ! -d "$DM_tl/${tpc}" ]; then exit 1; fi
  
    if [ -e "$DT/n_s_pr" ] && [ "$(sed -n 1p "$DT/n_s_pr")" = "${tpc}" ]; then
        msg "$(gettext "Unable to rename at this time. Please try later ")\n" \
        dialog-warning "$(gettext "Information")" & exit 1
    fi
    if [ -e "$DT/playlck" ] && [ "$(sed -n 1p "$DT/playlck")" = "${tpc}" ]; then
        msg "$(gettext "Unable to rename at this time. Please try later ")\n" \
        dialog-warning "$(gettext "Information")" & exit 1
    fi
    if [ ${#name} -gt 55 ]; then
        msg "$(gettext "Sorry, the new name is too long.")\n" \
        dialog-information "$(gettext "Information")" & exit 1
    fi
    if [ ${chck} -ge 1 ]; then
        for i in {1..50}; do
        chck=$(grep -Fxo "${name} ($i)" <<< "${listt}")
        [ -z "${chck}" ] && break; done
        name="${name} ($i)"
    fi
    if [ -n "${name}" ]; then
        f_lock "$DT/rm_lk"
        mv -f "$DM_tl/${tpc}" "$DM_tl/${name}"
        sed -i "s/name=.*/name=\"${name}\"/g" "$DM_tl/${name}/.conf/id.cfg"
        echo "${name}" > "$DC_s/4.cfg"
        
        echo "${name}" > "$DT/tpe"; echo 0 > "$DC_s/5.cfg"
        
        for n in {1..6}; do
            if grep -Fxq "${tpc}" "$DM_tl/.share/${n}.cfg"; then
                grep -vxF "${tpc}" "$DM_tl/.share/${n}.cfg" > "$DM_tl/.share/${n}.cfg.tmp"
                sed '/^$/d' "$DM_tl/.share/${n}.cfg.tmp" > "$DM_tl/.share/${n}.cfg"
                echo "${name}" >> "$DM_tl/.share/${n}.cfg"
            fi
        done
        
        check_list > "$DM_tl/.share/2.cfg"
        rm "$DM_tl/.share"/*.tmp
        cleanups "$DM_tl/${tpc}" "$DM/backup/${tpc}.bk" "$DT/rm_lk"
        "$DS/mngr.sh" mkmn 0 & exit 1
    fi
}


mark_to_learn_topic() {
    [ ! -s "${DC_tlt}/0.cfg" ] && exit 1
    
    if [ "${tpc}" != "${2}" ]; then
        msg "$(gettext "Sorry, this topic is currently not active.")\n " \
        dialog-information "$(gettext "Information")" & exit
    fi
    if [ $((cfg3+cfg4)) -le 10 ]; then
        msg "$(gettext "Insufficient number of items to perform the action").\t\n " \
        dialog-information "$(gettext "Information")" & exit
    fi

    (echo "#"
    stts=$(sed -n 1p "${DC_tlt}/8.cfg")
    ! [[ ${stts} =~ ${numer} ]] && stts=1
    
    calculate_review "${tpc}"
    
    if [ $((stts%2)) = 0 ]; then
        echo 6 > "${DC_tlt}/8.cfg"
    else
        if [ ${RM} -ge 50 ]; then
            echo 5 > "${DC_tlt}/8.cfg"
        else
            echo 1 > "${DC_tlt}/8.cfg"
        fi
    fi

    for i in {1..4}; do rm "${DC_tlt}/${i}.cfg"; done
    rm "${DC_tlt}/7.cfg"; touch "${DC_tlt}/5.cfg" "${DC_tlt}/2.cfg"
    steps=$(egrep -cv '#|^$' < "${DC_tlt}/9.cfg")
    sed -i "s/repass=.*/repass=\"${steps}\"/g" "${DC_tlt}/10.cfg"
    
    while read -r item_; do
        item="$(sed 's/}/}\n/g' <<< "${item_}")"
        type="$(grep -oP '(?<=type{).*(?=})' <<< "${item}")"
        trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
        if [ -n "${trgt}" ]; then
            if [ ${type} -eq 1 ]; then
                echo "${trgt}" >> "${DC_tlt}/3.cfg"
            else 
                echo "${trgt}" >> "${DC_tlt}/4.cfg"
            fi
            echo "${trgt}" >> "${DC_tlt}/1.cfg"
        fi
    done < "${DC_tlt}/0.cfg" ) | progr_3 "pulsate"

    if [ -e "${DC_tlt}/lk" ]; then rm "${DC_tlt}/lk"; fi
    
    cp -f "${DC_tlt}/info" "${DC_tlt}/info.bk"
        
    if [[ ${3} = 1 ]]; then
        yad_kill "yad --form " "yad --multi-progress " "yad --list " \
        "yad --text-info " "yad --notebook "
    fi
    touch "${DM_tlt}"
    
    ( sleep 1; mv -f "${DC_tlt}/info.bk" "${DC_tlt}/info" ) &

    "$DS/mngr.sh" mkmn 1 &
    
    [[ ${3} = 1 ]] && idiomind topic &
}

mark_as_learned_topic() {
    if [[ "${3}" != 0 ]]; then
        if [ "${tpc}" != "${2}" ]; then
        msg "$(gettext "Sorry, this topic is currently not active.")\n " dialog-information "$(gettext "Information")" & exit; fi
        if [ $((cfg3+cfg4)) -le 15 ]; then
        msg "$(gettext "Insufficient number of items to perform the action").\t\n " \
        dialog-information "$(gettext "Information")" & exit; fi
    fi
    [ ! -s "${DC_tlt}/0.cfg" ] && exit 1
    (echo "#"
    stts=$(sed -n 1p "${DC_tlt}/8.cfg")
    ! [[ ${stts} =~ ${numer} ]] && stts=1

    if [ ! -e "${DC_tlt}/7.cfg" ]; then
        [ ! -e "${DC_tlt}/9.cfg" ] && touch "${DC_tlt}/9.cfg"
        calculate_review "${tpc}"
        steps=$(egrep -cv '#|^$' < "${DC_tlt}/9.cfg")
        
        if [ -s "${DC_tlt}/9.cfg" ]; then
            ! [[ ${steps} =~ ${numer} ]] && steps=1
            
            if [ ${steps} -eq 4 ]; then
                stts=$((stts+1)); fi
            
            if [ ${RM} -ge 50 ]; then
                if [ ${steps} -eq 8 ]; then
                    sed -i '$ d' "${DC_tlt}/9.cfg"
                    date "+%m/%d/%Y" >> "${DC_tlt}/9.cfg"
                elif [ ${steps} -gt 8 ]; then
                    dts="$(head -7 < "${DC_tlt}/9.cfg")"
                    echo -e "${dts}\n$(date +%m/%d/%Y)" > "${DC_tlt}/9.cfg"
                else
                    date "+%m/%d/%Y" >> "${DC_tlt}/9.cfg"
                fi
            fi
        else
            date +%m/%d/%Y > "${DC_tlt}/9.cfg"
        fi
        
        if [ -d "${DC_tlt}/practice" ]; then
            (cd "${DC_tlt}/practice"; rm ./.*; rm ./*
            touch ./log1 ./log2 ./log3); fi

        > "${DC_tlt}/7.cfg"
        if [[ $((stts%2)) = 0 ]]; then
            echo 4 > "${DC_tlt}/8.cfg"
        else
            echo 3 > "${DC_tlt}/8.cfg"
        fi
    fi
    cleanups "${DC_tlt}/1.cfg" "${DC_tlt}/2.cfg"
    touch "${DC_tlt}/1.cfg"
    
    while read -r item_; do
        item="$(sed 's/}/}\n/g' <<< "${item_}")"
        trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
        [ -n "${trgt}" ] && echo "${trgt}" >> "${DC_tlt}/2.cfg"
    done < "${DC_tlt}/0.cfg" ) | progr_3 "pulsate"
    
    cp -f "${DC_tlt}/info" "${DC_tlt}/info.bk"

    if [[ ${3} = 1 ]]; then
        yad_kill "yad --form " "yad --list " \
        "yad --text-info " "yad --notebook "
    fi
    "$DS/mngr.sh" mkmn 1 &
    
    ( sleep 1; mv -f "${DC_tlt}/info.bk" "${DC_tlt}/info" ) &
    
    [[ ${3} = 1 ]] && idiomind topic &
    ( sleep 1; "$DS/ifs/tls.sh" colorize 0 ) &
    exit
}

mark_to_learnt_topic_ok() {
        tpc="${2}"
        DM_tlt="$DM_tl/${tpc}"
        DC_tlt="$DM_tl/${tpc}/.conf"
        [ ! -s "${DC_tlt}/0.cfg" ] && exit 1
        stts=$(sed -n 1p "${DC_tlt}/8.cfg")
        ! [[ ${stts} =~ ${numer} ]] && stts=1
        if [ ! -e "${DC_tlt}/7.cfg" ]; then
            [ ! -e "${DC_tlt}/9.cfg" ] && touch "${DC_tlt}/9.cfg"
            calculate_review "${tpc}"
            steps=$(egrep -cv '#|^$' < "${DC_tlt}/9.cfg")
            if [ -s "${DC_tlt}/9.cfg" ]; then
                ! [[ ${steps} =~ ${numer} ]] && steps=1
                
                if [ ${steps} -eq 4 ]; then
                    stts=$((stts+1)); fi
                
                if [ ${RM} -ge 50 ]; then
                    if [ ${steps} -eq 8 ]; then
                        sed -i '$ d' "${DC_tlt}/9.cfg"
                        date "+%m/%d/%Y" >> "${DC_tlt}/9.cfg"
                    elif [ ${steps} -gt 8 ]; then
                        dts="$(head -7 < "${DC_tlt}/9.cfg")"
                        echo -e "${dts}\n$(date +%m/%d/%Y)" > "${DC_tlt}/9.cfg"
                    else
                        date "+%m/%d/%Y" >> "${DC_tlt}/9.cfg"
                    fi
                fi
            else
                date +%m/%d/%Y > "${DC_tlt}/9.cfg"
            fi
            
            if [ -d "${DC_tlt}/practice" ]; then
                (cd "${DC_tlt}/practice"; rm ./.*; rm ./*
                touch ./log1 ./log2 ./log3); fi

            > "${DC_tlt}/7.cfg"
            if [[ $((stts%2)) = 0 ]]; then
                echo 4 > "${DC_tlt}/8.cfg"
            else
                echo 3 > "${DC_tlt}/8.cfg"
            fi
        fi
        cleanups "${DC_tlt}/1.cfg" "${DC_tlt}/2.cfg"
        touch "${DC_tlt}/1.cfg"; > "${DC_tlt}/2.cfg"
        while read -r item_; do
            item="$(sed 's/}/}\n/g' <<< "${item_}")"
            trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
            [ -n "${trgt}" ] && echo "${trgt}" >> "${DC_tlt}/2.cfg"
        done < "${DC_tlt}/0.cfg"

        cp -f "${DC_tlt}/info" "${DC_tlt}/info.bk"
        ( sleep 1; mv -f "${DC_tlt}/info.bk" "${DC_tlt}/info" ) &
}

case "$1" in
    mkmn)
    mkmn "$@" ;;
    delete_item_ok)
    delete_item_ok "$@" ;;
    delete_item)
    delete_item "$@" ;;
    edit)
    edit_item "$@" ;;
    edit_list)
    edit_list_dlg "$@" ;;
    edit_list_cmds)
    edit_list_cmds "$@" ;;
    edit_list_more)
    edit_list_more ;;
    edit_feeds)
    edit_feeds "$@" ;;
    colorize)
    colorize "$@" ;;
    delete_topic)
    delete_topic "$@" ;;
    rename_topic)
    rename_topic "$@" ;;
    mark_as_learned)
    mark_as_learned_topic "$@" ;;
    mark_to_learn)
    mark_to_learn_topic "$@" ;;
    mark_to_learnt_ok)
    mark_to_learnt_topic_ok "$@" ;;
esac
