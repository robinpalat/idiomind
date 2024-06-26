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
    f_lock 1 "$DT/mn_lk"
    cleanups "$DM_tl/images" "$DM_tl/.conf"
    dirimg='/usr/share/idiomind/images'
    index="$DM_tl/.share/index"; > "$index"
    while read -r tpc; do
        dir="$DM_tl/${tpc}/.conf"; unset stts
        [ ! -d "${dir}" ] && mkdir -p "${dir}"
        if [ ! -e "$dir/stts" ]; then
            stts=13; echo ${stts} > "$dir/stts"
        else
            stts=$(sed -n 1p "${dir}/stts")
            ! [[ ${stts} =~ $numer ]] && stts=13
        fi
        echo -e "$dirimg/img.${stts}.png\n${tpc}" >> "$index"
    done < <(cd ~ && cd "$DM_tl"; find ./ -maxdepth 1 -mtime -80 -type d \
    -not -path '*/\.*' -exec ls -tNd {} + |sed 's|\./||g;/^$/d'; \
    find ./ -maxdepth 1 -mtime +79 -type d -not -path '*/\.*' \
    -exec ls -tNd {} + |sed 's|\./||g;/^$/d')
    [[ "$2" = 1 ]] && (source "$DS/ifs/stats.sh"; coll_tpc_stats 0) &
    f_lock 3 "$DT/mn_lk"; exit 0
}

delete_item_ok() {
    f_lock 1 "$DT/ps_lk"
    trgt="${3}"; DM_tlt="$DM_tl/${2}"; DC_tlt="$DM_tl/${2}/.conf"
    item="$(grep -F -m 1 "trgt{${trgt}}" "$DC_tlt/data" |sed 's/}/}\n/g')"
    cdid=$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")

    if [ -n "${trgt}" ]; then
        cleanups "${DM_tlt}/$cdid.mp3" "${DM_tlt}/images/${trgt,,}.jpg"
        
        sed -i "/trgt{${trgt}}/d" "${DC_tlt}/data"
        
        if [ -d "${DC_tlt}/practice" ]; then
            cd ~ && cd "${DC_tlt}/practice"
            while read -r file_pr; do
                if grep -Fxq "${trgt}" "${file_pr}"; then
                    grep -vxF "${trgt}" "${file_pr}" > ./rm.tmp
                    sed '/^$/d' ./rm.tmp > "${file_pr}"
                fi
            done < <(ls ./*)
            rm ./*.tmp; cd /
        fi
        
        tas=('learning' 'learnt' 'words' 'sentences' 'marks')
        for ta in ${tas[@]}; do
            tpc_db 4 $ta list "${trgt}"
        done
        cleanups "${DC_tlt}/lst"
    fi
    if [[ $(wc -l < "${DC_tlt}/data") -lt 200 ]] && [ -f "${DC_tlt}/lk" ]; then
        cleanups "${DC_tlt}/lk"
    fi
    "$DS/ifs/tls.sh" colorize 1 &
    f_lock 3 "$DT/ps_lk" & exit 1
}

delete_item() {
    f_lock 1 "$DT/ps_lk"
    DM_tlt="$DM_tl/${2}"; DC_tlt="$DM_tl/${2}/.conf"
    
    if [ -n "${trgt}" ]; then
        msg_2 "$(gettext "Are you sure you want to delete this item?")\n" \
        edit-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"
        ret="$?"
        
        if [ $ret -eq 0 ]; then
            (sleep 0.1 && kill -9 $(pgrep -f "yad --form "))
            
            cleanups "${DM_tlt}/$cdid.mp3" "${DM_tlt}/images/${trgt,,}.jpg"
            sed -i "/trgt{${trgt}}/d" "${DC_tlt}/data"
            
            if [ -d "${DC_tlt}/practice" ]; then
                cd ~ && cd "${DC_tlt}/practice"
                while read file_pr; do
                    if grep -Fxq "${trgt}" "${file_pr}"; then
                        grep -vxF "${trgt}" "${file_pr}" > ./rm.tmp
                        sed '/^$/d' ./rm.tmp > "${file_pr}"; fi
                done < <(ls ./*)
                rm ./*.tmp; cd /
            fi

            tas=('learning' 'learnt' 'words' 'sentences' 'marks')
            for ta in ${tas[@]}; do
                tpc_db 4 $ta list "${trgt}"
            done
            
            if [[ $(wc -l < "${DC_tlt}/data") -lt 200 ]] \
            && [ -e "${DC_tlt}/lk" ]; then
                rm -f "${DC_tlt}/lk"; fi
            if [ -e "${DC_tlt}/feeds" ]; then
                echo "${trgt}" >> "${DC_tlt}/exclude"
            fi
            
            "$DS/ifs/tls.sh" colorize 1 &
        fi
    fi
    f_lock 3 "$DT/ps_lk" & return 0
}

edit_item() {
    [ -z ${2} ] || [ -z ${3} ] && exit 1
    list=${2}; item_pos=${3}; text_missing=${4}
    if [ ${list} = 1 ]; then
        index_1="$(tpc_db 5 learning)"
        index_2="$(tpc_db 5 learnt)"
        [ ${item_pos} -lt 1 ] && item_pos=${cfg1}
    elif [ ${list} = 2 ]; then
        index_1="$(tpc_db 5 learnt)"
        index_2="$(tpc_db 5 learning)"
        [ ${item_pos} -lt 1 ] && item_pos=${cfg2}
    fi
    item_trgt="$(sed -n ${item_pos}p <<< "${index_1}")"
    edit_pos=$(grep -Fon -m 1 "trgt{${item_trgt}}" "${DC_tlt}/data" |sed -n 's/^\([0-9]*\)[:].*/\1/p')
    if ! [[ ${edit_pos} =~ ${numer} ]]; then
        edit_pos="$(awk 'match($0,v){print NR; exit}' v="trgt{${item_trgt}}" "${DC_tlt}/data")"
    fi
    if ! [[ ${edit_pos} =~ ${numer} ]]; then $DS/vwr.sh ${list} "${trgt}" 1 & exit; fi
    get_item "$(sed -n ${edit_pos}p "${DC_tlt}/data")"

    [ -z "${cdid}" ] && cdid=""
    export query="$(sed "s/'/ /g" <<< "${trgt}")"
    mod_index=0; tomodify=0; colorize_run=0; transl_mark=0
    if ((stts>=1 && stts<=10)); then

    tpcs="$(cdb "${shrdb}" 5 topics)"
    tpcs="$(grep -vFx "${tpe}" <<< "$tpcs" |tr "\\n" '!' |sed 's/\!*$//g')"
    export tpc_list="${tpc}!${tpcs}"
    fi
    export cmd_delete="$DS/mngr.sh delete_item "\"${tpc}\""" \
    cmd_image="$DS/ifs/tls.sh set_image "\"${tpc}\"" ${cdid}" \
    cmd_def="'$DS/ifs/tls.sh' 'find_def' "\"${trgt}\""" \
    cmd_trad="'$DS/ifs/tls.sh' 'find_trad' "\"${trgt}\"""

    [ -z "${item}" ] && exit 1
    if [ ${text_missing} != 0 ]; then
        type=${text_missing}
    fi
    temp="...."
    if [[ "${srce}" = "${temp}" ]]; then
        if [ -e "$DT/${trgt}.edit" ]; then
            msg_4 "$(gettext "Please wait until the current process is finished.")" \
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
        if [ -z "${edit_dlg1}" ] && [ -z "${edit_dlg2}" ]; then
            item_pos=$((item_pos-1))
        fi
        if [ ${ret} -eq 0 ] || [ ${ret} -eq 2 ]; then
        
            include "$DS/ifs/mods/add"
            dlaud=$(cdb ${cfgdb} 1 opts dlaud) 

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
                ${edit_pos}s|srce{${srce}}|srce{$temp}|g" "${DC_tlt}/data"
                mod_index=1; colorize_run=1; tomodify=1
            fi
            if [ "${mark}" != "${mark_mod}" ]; then
                if [ "${mark_mod}" = "TRUE" ]; then
                    tomodify=1; tpc_db 2 marks list "${trgt}"; else
                    tpc_db 4 marks "${trgt}"
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
                    mv -f "${DM_tlt}/images/${trgt,,}.jpg" \
                    "$DM_tl/${tpc_mod}/images/${trgt_mod,,}.jpg"
                    "$DS/mngr.sh" delete_item_ok "${tpc}" "${trgt}"
                    trgt="${trgt_mod}"; srce="${srce_mod}"; tpe="${tpc_mod}"
                    exmp="${exmp_mod}"; defn="${defn_mod}"; note="${note_mod}"
                    wrds="${wrds_mod}"; grmr="${grmr_mod}";
                    mark="${mark_mod}"; link="${link_mod}"; cdid="${cdid_mod}"
                    index ${type_mod}; unset type trgt srce exmp defn note wrds grmr mark cdid
                elif [ "${tpc}" = "${tpc_mod}" ]; then
                    cfg0="${DC_tlt}/data"
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
                if [ ${type} != ${type_mod} ]; then
                    if [ ${type_mod} = 1 ]; then
                        tpc_db 4 sentences list "${trgt_mod}"
                        tpc_db 2 words list "${trgt_mod}"

                    elif [ ${type_mod} = 2 ]; then
                        tpc_db 4 words list "${trgt_mod}"
                        tpc_db 2 sentences list "${trgt_mod}"
                    fi
                fi
                
                [ -e "${DM_tlt}/images/${trgt,,}.jpg" ] && \
                mv -f "${DM_tlt}/images/${trgt,,}.jpg" \
                "${DM_tlt}/images/${trgt_mod,,}.jpg"
                cleanups "$DT_r" "$DT/${trgt_mod}.edit"
            ) &
            
                if [ "$defn" != "$defn_mod" ]; then
                    if [ -n "${defn_mod}" ]; then
                        sqlite3 ${tlngdb} \
                        "update Words set Definition='${defn_mod}'\
                         where Word='${trgt}';"
                    fi
                fi
                if [ "$exmp" != "$exmp_mod" ]; then
                    if [ -n "${exmp_mod}" ]; then
                        sqlite3 ${tlngdb} \
                        "update Words set Example='${exmp_mod}'\
                         where Word='${trgt}';"
                    fi
                fi
            fi

            if [ ${type} != ${type_mod} ] && [ ${type_mod} = 1 ]; then
                colorize_run=1
                ( img_word "${trgt}" "${srce}" ) fi &
                
            if [ ${colorize_run} = 1 ]; then 
                sleep 2 && "$DS/ifs/tls.sh" colorize 1 &
            fi

            if [ $ret -eq 2 ]; then $DS/mngr.sh edit ${list} $((item_pos+1)) &
            elif [ $ret -eq 0 ]; then 
                [ ${tomodify} = 1 ] && [ $ret -eq 0 ] && sleep 0.2
                $DS/vwr.sh ${list} "${trgt}" ${item_pos} & 
            fi
        else
            "$DS/vwr.sh" ${list} "${trgt}" ${item_pos} &
        fi
        exit 0
        
} >/dev/null 2>&1


edit_list_cmds() {
    if grep -o -E 'ja|zh-cn|ru' <<< "${lgt}"; then c=c; else c=w; fi
    direc="$DM_tl/${2}/.conf"
    if [ -e "$DT/transl_batch_out" ]; then
        msg_4 "$(gettext "Please wait until the current process is finished.")" \
        "face-worried" "$(gettext "OK")" "$(gettext "Stop")" \
        "$(gettext "Wait")" "$DT/transl_batch_out"
        ret=$?
        if [ $ret -eq 1 ]; then 
            cleanups "$DT/transl_batch_out"
        else
            return 1
        fi
    fi
    if [ $1 -eq 0 ] || [ $1 -eq 2 ] || [ $1 -eq 4 ]; then
        if [ $1 -eq 0 ]; then 
            cmd=cat && invrt_msg=FALSE
        elif [ $1 -eq 2 ]; then 
            cmd=tac && invrt_msg=TRUE
            mv -f "$DT/list_input" "$DT/list_output"
        elif [ $1 -eq 4 ]; then
            cmd=cat && invrt_msg=FALSE
            mv -f "$DT/list_input" "$DT/list_output"
        fi
        
        include "$DS/ifs/mods/add"
        dlaud=$(cdb ${cfgdb} 1 opts dlaud) 
        n=1; f_lock 1 "$DT/el_lk"
        
        learn="$(tpc_db 5 learning)"; leart="$(tpc_db 5 learnt)"
        tpc_db 6 'learning'; tpc_db 6 'learnt'; tpc_db 6 'words'; tpc_db 6 'sentences'
        
        $cmd "$DT/list_output" |sed '/^$/d;/(null)/d' |while read -r trgt; do
            if grep -F -m 1 "trgt{${trgt}}" "${direc}/data"; then
                item="$(grep -F -m 1 "trgt{${trgt}}" "${direc}/data" |sed 's/}/}\n/g')"
                get_item "${item}"
                if [ $1 -eq 4 ]; then
                    [ $(wc -$c <<< "${trgt}") -lt 5 ] && type=1
                fi

                if [ ${type} = 1 ]; then
                    tpc_db 8 words list "$trgt"
                elif [ ${type} = 2 ]; then
                    tpc_db 8 sentences list "$trgt"
                fi
                if grep -Fxo "${trgt}" <<< "${leart}"; then
                    tpc_db 8 learnt list "$trgt"
                fi
                if grep -Fxo "${trgt}" <<< "${learn}"; then
                    tpc_db 8 learning list "$trgt"
                fi
            else
                unset_item
                if [[ $(wc -$c <<< "${trgt}") = 1 ]]; then
                    tpc_db 8 words list "$trgt"; type=1
                else 
                    tpc_db 8 sentences list "$trgt"; type=2
                fi
                tpc_db 8 learning list "$trgt"
                temp="...."; grmr="${trgt}"; srce="${temp}"
                echo "${trgt}" >> "$DT/items_to_add"
            fi
            
            eval newline="$(sed -n 2p "$DS/default/vars")"
            echo "${newline}" >> "$DT/new_data"
            let n++
        done

        mv -f "$DT/new_data" "${direc}/data"

        if [ -d "$DM_tl/${2}" ] && [ $(wc -l < "${direc}/data") -ge 1 ]; then
            while read -r fname; do
                cdid=$(basename "${fname}" |sed "s/\(.*\).\{4\}/\1/" |tr -d '.')
                if ! grep "${cdid}" "${direc}/data"; then
                    cleanups "${fname}"
                fi
            done < <(find "$DM_tl/${2}"/*.mp3)
            while read -r fname; do
                trgt=$(basename "${fname}" |sed "s/\(.*\).\{4\}/\1/" |tr -d '.')
                if ! grep "trgt{${trgt^}}" "${direc}/data"; then
                    cleanups "${fname}"
                fi
            done < <(find "$DM_tl/${2}/images"/*.jpg)
        fi
        if [[ "$(echo "${learnt}${learn}" |wc -l)" -lt 1 ]]; then
        > "${direc}/data"; fi
        "$DS/ifs/tls.sh" colorize 1
        f_lock 3 "$DT/el_lk"
        if [ -e "$DT/items_to_add" ]; then
            invrt_msg=FALSE
            export DT_r=$(mktemp -d "$DT/XXXXXX")
            temp="...."
            
            while read -r trgt; do
                pos=$(grep -Fon -m 1 "trgt{${trgt}}" "${direc}/data" \
                |sed -n 's/^\([0-9]*\)[:].*/\1/p')
                if ! [[ ${pos} =~ ${numer} ]]; then
                    pos="$(awk 'match($0,v){print NR; exit}' v="trgt{${trgt}}" "${direc}/data")"
                fi
                item="$(sed -n ${pos}p "${direc}/data" |sed 's/}/}\n/g')"
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
                
                if [ ${type} = 2 ] && [ ${dlaud} = TRUE ]; then cd "$DT_r"
                tts_sentence "${trgt}" "$DT_r" "${DM_tlt}/$cdid_mod.mp3"; fi
                
                sed -i "${pos}s|srce{$srce}|srce{$srce_mod}|;
                ${pos}s|wrds{$wrds}|wrds{$wrds_mod}|;
                ${pos}s|grmr{$trgt}|grmr{$grmr_mod}|;
                ${pos}s|cdid{$cdid}|cdid{$cdid_mod}|g" "${direc}/data"
                cleanups "$DT/${trgt}.edit"
            done < "$DT/items_to_add"
        fi
    fi
    cleanups "$DT/list_output" "$DT/list_input" \
    "$DT/items_to_add" "$DT_r" "$DT/act_restfile" "$DT/edit_list_more"
    idiomind tasks
    return 1
    
} >/dev/null 2>&1


edit_list_more() {
    touch "$DT/edit_list_more"
    file="$HOME/.idiomind/backup/${tpc}.bk"

    dt1=$(grep '\----- newest' "${file}" |cut -d' ' -f3)
    dt2=$(grep '\----- oldest' "${file}" |cut -d' ' -f3)
    if [ -n "$dt2" ]; then
        cols2="!$(gettext "Restore backup:") $dt1!$(gettext "Restore backup:") $dt2"
    elif [ -n "$dt1" ]; then
        cols2="!$(gettext "Restore backup:") $dt1"
    else
        cols2=""
    fi

    optns="$(sed '/^$/d' <<< "$cols2")"
    
    more="$(yad --form --title="$(gettext "Backups")" \
    --field=":CB" "${optns}" --separator="" \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --name=Idiomind --class=Idiomind \
    --expand-column=2 --no-click --no-headers\
    --window-icon=$DS/images/logo.png --on-top --center \
    --width=390 --borders=5 \
    --column="":TXT \
    --button="$(gettext "Apply")"!gtk-apply:0 \
    --button="$(gettext "Cancel")":1)"
    ret="$?"
    if [ $ret = 0 ]; then
        _war(){ msg_2 "${more}\n" \
        dialog-question "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"; }

        if grep "$(gettext "Reverse items order")" <<< "${more}"; then
            _war; if [ $? = 0 ]; then
                yad_kill "yad --editable --list"
                "$DS/stop.sh" 5
                edit_list_cmds 2 "${tpc}"
                cleanups "$DT/edit_list_more"
            fi
        elif grep "$(gettext "Remove all items")" <<< "${more}"; then
            _war; if [ $? = 0 ]; then
                yad_kill "yad --editable --list"
                cleanups "$DT/list_output" "$DT/list_input"
                cleanups "${DC_tlt}/data" "${DC_tlt}/index"
                tpc_db 6 'sentences'; tpc_db 6 'words'
                tpc_db 6 'learning'; tpc_db 6 'learnt'
                tpc_db 6 'marks'
                touch "${DC_tlt}/data"
                cleanups "$DT/edit_list_more"
                [ -d "${DM_tlt}" ] && [ -n "$tpc" ] && rm "$DM_tlt"/*.mp3
            fi

        elif grep "$(gettext "Show short sentences in word's view")" <<< "${more}"; then
            _war; if [ $? = 0 ]; then
                yad_kill "yad --editable --list"
                edit_list_cmds 4 "${tpc}"
                cleanups "$DT/edit_list_more"
            fi
        elif grep "$(gettext "Restore backup:")" <<< "${more}"; then
             _war; if [ $? = 0 ]; then
                cleanups "$DT/list_output" "$DT/list_input"
                yad_kill "yad --editable --list"
                if grep ${dt1} <<< "${more}"; then
                    export line=1
                elif grep ${dt2} <<< "${more}"; then
                    export line=2
                fi
                "$DS/ifs/tls.sh" restore "${tpc}" ${line}
                cleanups "$DT/edit_list_more"
            fi
        elif [ -f "$DS/ifs/mods/topic/${more}.sh" ]; then 
            "$DS/ifs/mods/topic/${more}.sh" "${more}" # ADDON: $DS/ifs/mods/topic/ADDON.sh ADDON
        else
            cleanups "$DT/edit_list_more"
        fi
    else
        cleanups "$DT/items_to_add"  \
        "$DT/act_restfile" "$DT/edit_list_more"
    fi
    
} >/dev/null 2>&1


edit_list_dlg() {
    direc="$DM_tl/${2}/.conf"
    
    if [ -e "$DT/items_to_add" ] || [ -e "$DT/el_lk" ]; then
        if [ -e "$DT/items_to_add" ]; then
            msg_4 "$(gettext "Please wait until the current process is finished.")" \
            "face-worried" "$(gettext "OK")" "$(gettext "Stop")" \
            "$(gettext "Wait")" "$DT/items_to_add"
            ret=$?
        elif [ -e "$DT/el_lk" ]; then
            msg_4 "$(gettext "Please wait until the current process is finished.")" \
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
    
    lns=$(cat "${direc}/data" |wc -l)
    (n=1; echo "#"; cat "${direc}/data" | while read -r item_; do
        item="$(sed 's/}/}\n/g' <<< "${item_}")"
        trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
        [ -n "${trgt}" ] && echo "${trgt}" >> "$DT/list_input"
        let n++; echo $((100*n/lns-1))
    done ) | progr_3 "progress"

    edit_list_list < "$DT/list_input" > "$DT/list_output"
    ret=$?
    if [ $ret = 0 ]; then
        edit_list_cmds 0 "${tpc}"
    elif [ $ret = 2 ]; then
        "$DS/ifs/tls.sh" "translate"
    else
        if [ ! -e "$DT/edit_list_more" ]; then
            cleanups "$DT/list_input" "$DT/list_output"
        fi
    fi
}


restart_topic() {
		
	 msg_2 "<b>\"$tpc\"</b>\n\n$(gettext "Are you sure you want to restart topic status?")\n" \
	 gtk-refresh "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"
  
	if [ $? = 0 ]; then

		yad_kill "yad --editable --list"  "yad --notebook"
		"$DS/stop.sh" 5
		echo 1 > "${DC_tlt}/stts"
		tpc_db 6 'reviews'; tpc_db 6 'learnt'; tpc_db 6 'learning'
		sqlite3 "${tpcdb}" "pragma busy_timeout=2000; insert into reviews (date1) values ('');"
		
		while read -r item_; do
			item="$(sed 's/}/}\n/g' <<< "${item_}")"
			trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")"
			if [ -n "${trgt}" ]; then
				tpc_db 2 learning list "${trgt}"
			fi
		done < "${DC_tlt}/data"
		tpc_db 3 config repass 0
		"$DS/mngr.sh" mkmn 1
		cleanups "$DT/edit_list_more" "${DC_tlt}/practice"
		"$DS/ifs/tls.sh" colorize 0
		idiomind topic
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
        f_lock 1 "$DT/rm_lk"
        if [ -f "$DT/n_s_pr" ]; then
            if [ "$(sed -n 1p "$DT/n_s_pr")" = "${tpc}" ]; then
            "$DS/stop.sh" 5; fi
        fi
        if [ -e "$DT/playlck" ]; then
            if [ "$(sed -n 1p "$DT/playlck")" = "${tpc}" ]; then 
            "$DS/stop.sh" 2; fi
        fi
        cleanups "$DM/backup/${tpc}.bk" "$DT/tpe"
        if [ -d "$DM_tl/${tpc}" ]; then cleanups "$DM_tl/${tpc}"; fi
        if [ -d "$DM_tl/${tpc}" ]; then sleep 0.5
            msg "$(gettext "Could not remove the directory:")\n$DM_tl/${tpc}\n$(gettext "You must manually remove it.")" \
            dialog-information "$(gettext "Information")"
        fi
        > "$DC_s/tpc"
        
        for n in {1..10}; do 
            cdb "${shrdb}" 4 T${n} list "${tpc}"
        done
        cdb "${shrdb}" 4 topics list "${tpc}"
        idiomind tasks
        
        yad_kill "yad --editable --list" "yad --text-info " \
        "yad --form " "yad --notebook "
        "$DS/mngr.sh" mkmn 1 &
    fi
    f_lock 3 "$DT/rm_lk" & exit 1
}


rename_topic() {
    source "$DS/ifs/mods/add/add.sh"
    listt="$(cd ~ && cd "$DM_tl"; find ./ -maxdepth 1 -type d \
    ! -path "./.share"  |sed 's|\./||g'|sed '/^$/d')"
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
    if [ -n "${name##+([[:space:]])}" ]; then
        f_lock 1 "$DT/rm_lk"
        mv -f "$DM_tl/${tpc}" "$DM_tl/${name}"
        export DC_tlt="$DM_tl/${name}/.conf"
        tpc_db 3 id name "${name}"
        echo "${name}" > "$DC_s/tpc"
        echo "${name}" > "$DT/tpe"

        for n in {1..10}; do 
            cdb "${shrdb}" 7 T${n} "${name}" "${tpc}"
        done
        cdb "${shrdb}" 7 topics "${name}" "${tpc}"
        idiomind tasks
        
        check_list
        cleanups "$DM_tl/${tpc}" "$DM/backup/${tpc}.bk"
        f_lock 3 "$DT/rm_lk"
        "$DS/mngr.sh" mkmn 0 & exit 1
    fi
}


mark_to_learn_topic() {
	
    [ ! -s "${DC_tlt}/data" ] && exit 1
    if [ "${tpc}" != "${2}" ]; then
        msg "$(gettext "Sorry, this topic is currently not active.")\n " \
        dialog-information "$(gettext "Information")" & exit
    fi
    if [ $((cfg3+cfg4)) -lt 10 ]; then
        msg "$(gettext "Insufficient number of items to perform this action").\t\n " \
        dialog-information "$(gettext "Information")" & exit
    fi
    
    export lns=$(cat "${DC_tlt}/data" |wc -l)
    stts=$(sed -n 1p "${DC_tlt}/stts")
    ! [[ ${stts} =~ ${numer} ]] && stts=1
	count_date_reviews="$(tpc_db 5 reviews |grep -c '[^[:space:]]')"
	
    calculate_review "${tpc}"

    if [[ $count_date_reviews -ge 9 ]]; then
	    echo 2 > "${DC_tlt}/stts"
    elif [ $((stts%2)) = 0 ]; then
        echo 6 > "${DC_tlt}/stts"
    else
        echo 5 > "${DC_tlt}/stts"
    fi
    
    if [[ ${3} = 1 ]]; then
        yad_kill "yad --form " "yad --multi-progress " \
        "yad --editable --list" "yad --text-info " "yad --notebook "
    fi
    
    tpc_db 9 config repass ${count_date_reviews}
    export data="${DC_tlt}/data" tpcdb
    
python3 <<PY
import os, re, sqlite3, sys
data = os.environ['data']
tpcdb = os.environ['tpcdb']
db = sqlite3.connect(tpcdb)
db.text_factory = str
cur = db.cursor()
cur.execute("delete from learnt")
cur.execute("delete from learning")
db.commit()
data = [line.strip() for line in open(data)]
for item in data:
    item = item.replace('}', '}\n')
    fields = re.split('\n',item)
    trgt = (fields[0].split('trgt{'))[1].split('}')[0]
    if trgt and trgt != ' ':
        cur.execute("insert into learning (list) values (?)", (trgt,))
db.commit()
db.close()
PY

    if [ -e "${DC_tlt}/lk" ]; then rm "${DC_tlt}/lk"; fi
    touch "${DM_tlt}"
    ( sleep 1; mv -f "${DC_tlt}/note.bk" "${DC_tlt}/note" ) &
    "$DS/ifs/tls.sh" colorize 1
    "$DS/mngr.sh" mkmn 1 &
    [[ ${3} = 1 ]] && idiomind topic &
    
    for n in {1..10}; do
        sqlite3 ${shrdb} "delete from T${n} where list=\"${tpc}\";"
    done
    idiomind tasks
}

mark_as_learned_topic() {
	
    if [[ "${3}" != 0 ]]; then
        if [ "${tpc}" != "${2}" ]; then
			msg "$(gettext "Sorry, this topic is currently not active.")\n " \
			dialog-information "$(gettext "Information")" & exit
		fi
        if [ $((cfg3+cfg4)) -lt 10 ]; then
			msg "$(gettext "Insufficient number of items to perform this action").\t\n " \
			dialog-information "$(gettext "Information")" & exit
		fi
    fi
    
    [ ! -s "${DC_tlt}/data" ] && exit 1
    stts=$(sed -n 1p "${DC_tlt}/stts")
    ! [[ ${stts} =~ ${numer} ]] && stts=1

    if [ $stts = 1 ] || [ $stts = 5 ] || [ $stts = 6 ]; then

        calculate_review "${tpc}"
        date_current=$(date +%m/%d/%Y)
        count_date_reviews="$(tpc_db 5 reviews |grep -c '[^[:space:]]')"
        ! [[ ${count_date_reviews} =~ ${numer} ]] && count_date_reviews=0
        [ ${count_date_reviews} = 8 ] && mast=TRUE || mast=FALSE


        if [ ${count_date_reviews} -gt 0 ]; then
           
            if [ ${count_date_reviews} -eq 3 ]; then # cambiar de fresh to familiar tpc
                stts=$((stts+1))
            fi

			if [ ${count_date_reviews} -gt 8 ]; then # cambiar de familiar to mastered tpc
				tpc_db 9 reviews date9 ${date_current}
				echo 2 > "${DC_tlt}/stts"
			else
				count_date_reviews=$((count_date_reviews+1))
				tpc_db 9 reviews date${count_date_reviews} ${date_current}
				
				if [[ $((stts%2)) = 0 ]]; then
					echo 4 > "${DC_tlt}/stts"
				else
					echo 3 > "${DC_tlt}/stts"
				fi
			fi
        else
            tpc_db 9 reviews date1 ${date_current}
            echo 3 > "${DC_tlt}/stts"
        fi
        
        if [ -d "${DC_tlt}/practice" ]; then
            (cd ~ && cd "${DC_tlt}/practice"; rm ./.*; rm ./*
            touch ./log1 ./log2 ./log3)
        fi
    fi

    if [[ ${3} = 1 ]]; then
        yad_kill "yad --form " "yad --editable --list" \
        "yad --text-info " "yad --notebook "
    fi

    export data="${DC_tlt}/data" tpcdb mast
	
python3 <<PY
import os, re, locale, sqlite3, sys
en = locale.getpreferredencoding()
data = os.environ['data']
tpcdb = os.environ['tpcdb']
mast = os.environ['mast']
db = sqlite3.connect(tpcdb)
db.text_factory = str
cur = db.cursor()
cur.execute("delete from learnt")
cur.execute("delete from learning")
db.commit()
data = [line.strip() for line in open(data)]
for item in data:
    item = item.replace('}', '}\n')
    fields = re.split('\n',item)
    trgt = (fields[0].split('trgt{'))[1].split('}')[0]
    if trgt and trgt != ' ':
        if mast == 'TRUE':
            cur.execute("insert into learning (list) values (?)", (trgt,))
        else:
            cur.execute("insert into learnt (list) values (?)", (trgt,))
db.commit()
db.close()
PY
    cp -f "${DC_tlt}/note" "${DC_tlt}/note.bk"
    "$DS/mngr.sh" mkmn 1 &
    ( sleep 1; mv -f "${DC_tlt}/note.bk" "${DC_tlt}/note" ) &
    [[ ${3} = 1 ]] && idiomind topic &
    ( sleep 1; "$DS/ifs/tls.sh" colorize 0 ) &
    
    for n in {1..10}; do 
        sqlite3 ${shrdb} "delete from T${n} where list=\"${tpc}\";"
    done
    
    idiomind tasks
}

mark_as_learned_topic_ok() {
    tpc="${2}"
    DM_tlt="$DM_tl/${tpc}"
    DC_tlt="$DM_tl/${tpc}/.conf"
    
    [ ! -s "${DC_tlt}/data" ] && exit 1
    stts=$(sed -n 1p "${DC_tlt}/stts")
    ! [[ ${stts} =~ ${numer} ]] && stts=1

    if [ $stts = 1 ] || [ $stts = 5 ] || [ $stts = 6 ]; then
    
        calculate_review "${tpc}"
        date_current=$(date +%m/%d/%Y)
        count_date_reviews="$(tpc_db 5 reviews |grep -c '[^[:space:]]')"
        ! [[ ${count_date_reviews} =~ ${numer} ]] && count_date_reviews=0
        [ ${count_date_reviews} = 8 ] && mast=TRUE || mast=FALSE
        
        if [ ${count_date_reviews} -gt 0 ]; then
        
            if [ ${count_date_reviews} -eq 3 ]; then # cambiar de fresh to familiar tpc
                stts=$((stts+1))
            fi

            if [ ${count_date_reviews} -gt 8 ]; then # cambiar de familiar to mastered tpc
                tpc_db 9 reviews date9 ${date_current}
                echo 2 > "${DC_tlt}/stts"
            else
				count_date_reviews=$((count_date_reviews+1))
                tpc_db 9 reviews date${count_date_reviews} ${date_current}
                
                if [[ $((stts%2)) = 0 ]]; then
					echo 4 > "${DC_tlt}/stts"
				else
					echo 3 > "${DC_tlt}/stts"
				fi
            fi
        else
            tpc_db 9 reviews date1 ${date_current}
            echo 3 > "${DC_tlt}/stts"
        fi
        
        if [ -d "${DC_tlt}/practice" ]; then
            (cd ~ && cd "${DC_tlt}/practice"; rm ./.*; rm ./*
            touch ./log1 ./log2 ./log3)
        fi
    fi

    export data="${DC_tlt}/data" tpcdb mast
    
python3 <<PY
import os, re, sqlite3, sys
data = os.environ['data']
tpcdb = os.environ['tpcdb']
mast = os.environ['mast']
db = sqlite3.connect(tpcdb)
db.text_factory = str
cur = db.cursor()
cur.execute("delete from learnt")
cur.execute("delete from learning")
db.commit()
data = [line.strip() for line in open(data)]
for item in data:
    item = item.replace('}', '}\n')
    fields = re.split('\n',item)
    trgt = (fields[0].split('trgt{'))[1].split('}')[0]
    if trgt and trgt != ' ':
        if mast == 'TRUE':
            cur.execute("insert into learning (list) values (?)", (trgt,))
        else:
            cur.execute("insert into learnt (list) values (?)", (trgt,))
db.commit()
db.close()
PY
    cp -f "${DC_tlt}/note" "${DC_tlt}/note.bk"
    ( sleep 1; mv -f "${DC_tlt}/note.bk" "${DC_tlt}/note" ) &
    
    for n in {1..10}; do 
        sqlite3 ${shrdb} "delete from T${n} where list=\"${tpc}\";"
    done
    
    idiomind tasks
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
    restartTopic)
    restart_topic "$@" ;;
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
    mark_as_learned_ok)
    mark_as_learned_topic_ok "$@" ;;
    mark_to_learn)
    mark_to_learn_topic "$@" ;;
esac
