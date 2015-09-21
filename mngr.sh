#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
include "$DS/ifs/mods/mngr"

mkmn() {
    f_lock "$DT/mn_lk"; cd "$DM_tl"
    [ -d "$DM_tl/images" ] && rm -r "$DM_tl/images"
    if ls -tNd */ 1> /dev/null 2>&1; then
        for i in "$(ls -tNd */ | cut -f1 -d'/')"; do 
            echo "${i%%/}"; done > "$DM_tl/.1.cfg"
    fi
    sed -i '/^$/d' "$DM_tl/.1.cfg"; > "$DM_tl/.0.cfg"
    
    head -100 < "$DM_tl/.1.cfg" | while read -r tpc; do
        unset stts
        [ ! -d "$DM_tl/${tpc}/.conf" ] && mkdir -p "$DM_tl/${tpc}/.conf"
        if [ ! -f "$DM_tl/${tpc}/.conf/8.cfg" ] \
        || [ ! "$DM_tl/${tpc}/.conf/0.cfg" ]; then
            stts=13; echo 13 > "$DM_tl/${tpc}/.conf/8.cfg"
        else stts=$(sed -n 1p "$DM_tl/${tpc}/.conf/8.cfg"); fi
        echo -e "/usr/share/idiomind/images/img.${stts}.png\n${tpc}" >> "$DM_tl/.0.cfg"
    done
    tail -n+101 < "$DM_tl/.1.cfg" | while read -r tpc; do
        unset stts
        [ ! -d "$DM_tl/${tpc}/.conf" ] && mkdir -p "$DM_tl/${tpc}/.conf"
        if [ ! -f "$DM_tl/${tpc}/.conf/8.cfg" ] \
        || [ ! "$DM_tl/${tpc}/.conf/0.cfg" ]; then
            stts=13; echo 13 > "$DM_tl/${tpc}/.conf/8.cfg"
        else stts=12; fi
        echo -e "/usr/share/idiomind/images/img.${stts}.png\n${tpc}" >> "$DM_tl/.0.cfg"
    done
    rm -f "$DT/mn_lk"; exit
}

delete_item_ok() {
    f_lock "$DT/ps_lk"
    trgt="${3}"; DM_tlt="$DM_tl/${2}"; DC_tlt="$DM_tl/${2}/.conf"
    item="$(grep -F -m 1 "trgt={${trgt}}" "$DC_tlt/0.cfg" |sed 's/},/}\n/g')"
    id=`grep -oP '(?<=id=\[).*(?=\])' <<<"${item}"`

    if [ -n "${trgt}" ]; then
        [ -f "${DM_tlt}/$id.mp3" ] && rm "${DM_tlt}/$id.mp3"
        sed -i "/trgt={${trgt}}/d" "${DC_tlt}/0.cfg"

        if [ -d "${DC_tlt}/practice" ]; then
            cd "${DC_tlt}/practice"
            while read -r file_pr; do
                if grep -Fxq "${trgt}" "${file_pr}"; then
                    grep -vxF "${trgt}" "${file_pr}" > ./rm.tmp
                    sed '/^$/d' ./rm.tmp > "${file_pr}"; fi
            done < <(ls ./*)
            rm ./*.tmp; cd /
        fi
        for n in {1..6}; do
            if [ -f "${DC_tlt}/${n}.cfg" ]; then
            grep -vxF "${trgt}" "${DC_tlt}/${n}.cfg" > "${DC_tlt}/${n}.cfg.tmp"
            sed '/^$/d' "${DC_tlt}/${n}.cfg.tmp" > "${DC_tlt}/${n}.cfg"; fi
        done
        
        if [ -f "${DC_tlt}/lst" ]; then rm "${DC_tlt}/lst"; fi
        rm "${DC_tlt}"/*.tmp
    fi
    rm -f "$DT/ps_lk" & exit 1
}

delete_item() {
    f_lock "$DT/ps_lk"
    DM_tlt="$DM_tl/${2}"; DC_tlt="$DM_tl/${2}/.conf"
    if [ -n "${trgt}" ]; then
        msg_2 "$(gettext "Are you sure you want to delete this item?")\n" \
        gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"
        ret="$?"
        
        if [ $ret -eq 0 ]; then
            (sleep 0.1 && kill -9 $(pgrep -f "yad --form "))
            [ -f "${DM_tlt}/$id.mp3" ] && rm "${DM_tlt}/$id.mp3"
            sed -i "/trgt={${trgt}}/d" "${DC_tlt}/0.cfg"
            
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
                sed '/^$/d' "${DC_tlt}/${n}.cfg.tmp" > "${DC_tlt}/${n}.cfg"; fi
            done
            "$DS/ifs/tls.sh" colorize &
            rm "${DC_tlt}"/*.tmp
        fi
    fi
    rm -f "$DT/ps_lk" & exit 1
}

edit_item() {
    [ -z ${2} -o -z ${3} ] && exit 1
    temp="...."
    lgt=$(lnglss $lgtl)
    lgs=$(lnglss $lgsl)
    list="${2}";  item_pos=${3}; text_missing=${4}
    c=$((RANDOM%10000))
    if [ ${list} = 1 ]; then
        index_1="${DC_tlt}/1.cfg"
        index_2="${DC_tlt}/2.cfg"
        [ ${item_pos} -lt 1 ] && item_pos=${inx1}
    elif [ ${list} = 2 ]; then
        index_1="${DC_tlt}/2.cfg"
        index_2="${DC_tlt}/1.cfg"
        [ ${item_pos} -lt 1 ] && item_pos=${inx2}
    fi
    tpcs="$(egrep -v "${tpc}" "${DM_tl}/.2.cfg" |tr "\\n" '!' |sed 's/!\+$//g')"
    item_id="$(sed -n ${item_pos}p "${index_1}")"
    if [ ${text_missing} = 0 ]; then
        edit_pos=`grep -Fon -m 1 "trgt={${item_id}}" "${DC_tlt}/0.cfg" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
        item="$(sed -n ${edit_pos}p "${DC_tlt}/0.cfg" |sed 's/},/}\n/g')"
    else
        item="$(sed -n ${item_pos}p "${DC_tlt}/0.cfg" |sed 's/},/}\n/g')"
    fi
    type=`grep -oP '(?<=type={).*(?=})' <<<"${item}"`
    export trgt=`grep -oP '(?<=trgt={).*(?=})' <<<"${item}"`
    grmr=`grep -oP '(?<=grmr={).*(?=})' <<<"${item}"`
    srce=`grep -oP '(?<=srce={).*(?=})' <<<"${item}"`
    exmp=`grep -oP '(?<=exmp={).*(?=})' <<<"${item}"`
    defn=`grep -oP '(?<=defn={).*(?=})' <<<"${item}"`
    note=`grep -oP '(?<=note={).*(?=})' <<<"${item}"`
    grmr=`grep -oP '(?<=grmr={).*(?=})' <<<"${item}"`
    wrds=`grep -oP '(?<=wrds={).*(?=})' <<<"${item}"`
    mark=`grep -oP '(?<=mark={).*(?=})' <<<"${item}"`
    export id=`grep -oP '(?<=id=\[).*(?=\])' <<<"${item}"`
    [ -z "${id}" ] && id=""
    query="$(sed "s/'/ /g" <<<"${trgt}")"
    to_modify=0; colorize_run=0; transl_mark=0

    cmd_delete="$DS/mngr.sh delete_item "\"${tpc}\"""
    cmd_image="$DS/ifs/tls.sh set_image "\"${tpc}\"""
    cmd_words="$DS/add.sh list_words_edit "\"${wrds}\"" 1 ${c}"
    cmd_def="'$DS/ifs/tls.sh' 'find_def' "\"${trgt}\"""
    link1="https://translate.google.com/\#$lgt/$lgs/${query}"

    [ -z "${item}" ] && exit 1
    if [ ${text_missing} != 0 ]; then
        type=${text_missing}
        edit_pos=${item_pos}
    fi
    if [[ "${srce}" = "${temp}" ]]; then
    msg_2 "$(gettext "Translating...\nWait till the process is completed. ")\n" info OK gtk-stop "$(gettext "Warning")"
    if [ $? -eq 1 ]; then srce="" ;transl_mark=1 ; else "$DS/vwr.sh" ${list} "${trgt}" ${item_pos} & exit 1; fi; fi

    if [ -e "${DM_tlt}/$id.mp3" ]; then
        audf="${DM_tlt}/$id.mp3"
    else
        audf="${DM_tls}/${trgt,,}.mp3"; fi
        
    if [ ${type} = 1 ]; then
        edit_dlg1="$(dlg_form_1)"
    elif [ ${type} = 2 ]; then
        edit_dlg2="$(dlg_form_2)"
    fi
    
    ret=$?
        if [ -z "${edit_dlg1}" -a -z "${edit_dlg2}" ]; then
            item_pos=$((item_pos-1)); fi
            
        if [ ${ret} -eq 0  ]; then
            include "$DS/ifs/mods/add"
            if [ ${type} = 1 ]; then
                edit_dlg="${edit_dlg1}"
                tpc_mod="$(cut -d "|" -f3 <<<"${edit_dlg}")"
                trgt_mod="$(clean_1 "$(cut -d "|" -f1 <<<"${edit_dlg}")")"
                srce_mod="$(clean_0 "$(cut -d "|" -f2 <<<"${edit_dlg}")")"
                audf_mod="$(cut -d "|" -f4 <<<"${edit_dlg}")"
                exmp_mod="$(clean_0 "$(cut -d "|" -f5 <<<"${edit_dlg}")")"
                defn_mod="$(clean_0 "$(cut -d "|" -f6 <<<"${edit_dlg}")")"
                note_mod="$(clean_0 "$(cut -d "|" -f7 <<<"${edit_dlg}")")"
                mark_mod="$(cut -d "|" -f9 <<<"${edit_dlg}")"
                type_mod=1
            elif [ ${type} = 2 ]; then
                edit_dlg="${edit_dlg2}"
                tpc_mod="$(cut -d "|" -f6 <<<"${edit_dlg}")"
                mark_mod="$(cut -d "|" -f1 <<<"${edit_dlg}")"
                type_mod="$(cut -d "|" -f2 <<<"${edit_dlg}")"
                trgt_mod="$(clean_2 "$(cut -d "|" -f3 <<<"${edit_dlg}")")"
                srce_mod="$(clean_2 "$(cut -d "|" -f5 <<<"${edit_dlg}")")"
                audf_mod="$(cut -d "|" -f7 <<<"${edit_dlg}")"
                grmr_mod="${grmr}"
                wrds_mod="${wrds}"
                [ "${type_mod}" = TRUE ] && type_mod=1
                [ "${type_mod}" = FALSE ] && type_mod=2
                [ -z "${type_mod}" ] && type_mod=2
            fi
            
            if [ "${trgt_mod}" != "${trgt}" ] && [ ! -z "${trgt_mod##+([[:space:]])}" ]; then
            if [ ${text_missing} != 0 ]; then
                index edit "${item_id}" "${tpc}" "${trgt_mod}"
            else
                index edit "${trgt}" "${tpc}" "${trgt_mod}"
            fi
            sed -i "${edit_pos}s|trgt={${trgt}}|trgt={${trgt_mod}}|;
            ${edit_pos}s|grmr={${grmr}}|grmr={${trgt_mod}}|;
            ${edit_pos}s|srce={${srce}}|srce={$temp}|g" "${DC_tlt}/0.cfg"
            mod_index=1; colorize_run=1; to_modify=1
            fi
            if [ "${mark}" != "${mark_mod}" ]; then
                if [ "${mark_mod}" = "TRUE" ]; then
                    to_modify=1; echo "${trgt}" >> "${DC_tlt}/6.cfg"; else
                    sed -i "/${trgt}/d" "${DC_tlt}/6.cfg"; fi
                colorize_run=1; to_modify=1
            fi
            [[ "${transl_mark}" = 1 ]] && srce="$temp"
            [ "${type}" != "${type_mod}" ] && to_modify=1
            [ "${srce}" != "${srce_mod}" ] && to_modify=1
            [ "${exmp}" != "${exmp_mod}" ] && to_modify=1
            [ "${defn}" != "${defn_mod}" ] && to_modify=1
            [ "${note}" != "${note_mod}" ] && to_modify=1
            [ "${mark}" != "${mark_mod}" ] && to_modify=1
            [ "${audf}" != "${audf_mod}" ] && to_modify=1
            [ "${tpc}" != "${tpc_mod}" ] && to_modify=1

            if [ ${to_modify} = 1 ]; then
            (
                if [ ${mod_index} = 1 ]; then
                
                    DT_r=$(mktemp -d "$DT/XXXX")
                    internet
                    if [ ${type_mod} = 1 ]; then
                        srce_mod="$(clean_1 "$(translate "${trgt_mod}" $lgt $lgs)")"
                        audio="${trgt_mod,,}"
                        tts_word "${audio}" "$DT_r"
                        srce="$temp"
                    elif [ ${type_mod} = 2 ]; then
                        srce_mod="$(clean_2 "$(translate "${trgt_mod}" $lgt $lgs)")"
                        db="$DS/default/dicts/$lgt"
                        sentence_p "$DT_r" 2
                        fetch_audio "${aw}" "${bw}" "$DT_r" "${DM_tls}"
                        srce="$temp"
                        grmr="${trgt_mod}"
                    fi
                fi
                id_mod="$(set_name_file ${type_mod} "${trgt_mod}" "${srce_mod}" \
                "${exmp_mod}" "${defn_mod}" "${note_mod}" "${wrds_mod}" "${grmr_mod}")"

                if [ "${tpc}" != "${tpc_mod}" ]; then
                    if [ "${audf}" != "${audf_mod}" ]; then
                        if [ ${type_mod} = 1 ]; then
                            cp -f "${audf_mod}" "${DM_tls}/${trgt_mod,,}.mp3"
                        elif [ ${type_mod} = 2 ]; then
                            cp -f "${audf_mod}" "$DM_tl/${tpc_mod}/$id_mod.mp3"; fi
                    else
                        if [ ${type_mod} = 2 ]; then
                            [ -e "${DM_tlt}/$id.mp3" ] && mv -f "${DM_tlt}/$id.mp3" "$DM_tl/${tpc_mod}/$id_mod.mp3"
                        elif [ ${type_mod} = 1 ]; then
                            [ -e "${DM_tlt}/$id.mp3" ] && mv -f "${DM_tlt}/$id.mp3" "$DM_tl/${tpc_mod}/$id_mod.mp3"; fi
                    fi
                    "$DS/mngr.sh" delete_item_ok "${tpc}" "${trgt}"
                    index ${type_mod} "${tpc_mod}" "${trgt_mod}" "${srce_mod}" \
                    "${exmp_mod}" "${defn_mod}" "${wrds_mod}" "${grmr_mod}" "${id_mod}"
                    unset type trgt srce exmp defn note wrds grmr mark id

                elif [ "${tpc}" = "${tpc_mod}" ]; then
                    cfg0="${DC_tlt}/0.cfg"
                    pos=${edit_pos}
                    sed -i "${pos}s|type={$type}|type={$type_mod}|;
                    ${pos}s|srce={$srce}|srce={$srce_mod}|;
                    ${pos}s|exmp={$exmp}|exmp={$exmp_mod}|;
                    ${pos}s|defn={$defn}|defn={$defn_mod}|;
                    ${pos}s|note={$note}|note={$note_mod}|;
                    ${pos}s|wrds={$wrds}|wrds={$wrds_mod}|;
                    ${pos}s|grmr={$grmr}|grmr={$grmr_mod}|;
                    ${pos}s|mark={$mark}|mark={$mark_mod}|;
                    ${pos}s|id=\[$id\]|id=\[$id_mod\]|g" "${cfg0}"
                    
                    if [ "${audf}" != "${audf_mod}" ]; then
                        if [ ${type_mod} = 1 ]; then
                            cp -f "${audf_mod}" "${DM_tls}/${trgt_mod,,}.mp3"
                        elif [ ${type_mod} = 2 ]; then
                            [ -e "${DM_tlt}/$id.mp3" ] && rm "${DM_tlt}/$id.mp3"
                            cp -f "${audf_mod}" "${DM_tlt}/$id_mod.mp3"; fi
                    else
                        if [ ${type_mod} = 2 ]; then
                            [ -e "${DM_tlt}/$id.mp3" ] && mv -f "${DM_tlt}/$id.mp3" "${DM_tlt}/$id_mod.mp3"
                        elif [ ${type_mod} = 1 ]; then
                            [ -e "${DM_tlt}/$id.mp3" ] && mv -f "${DM_tlt}/$id.mp3" "${DM_tlt}/$id_mod.mp3"; fi
                    fi
                fi
                cleanups "$DT_r"
            ) &
            fi

            [ -d "$DT/$c" ] && "$DS/add.sh" list_words_edit "${wrds_mod}" 2 ${c} "${trgt_mod}" &
            [ ${type} != ${type_mod} -a ${type_mod} = 1 ] && ( img_word "${trgt}" "${srce}" ) &
            [ ${colorize_run} = 1 ] && "$DS/ifs/tls.sh" colorize &
            [ ${to_modify} = 1 ] && sleep 0.2
        fi
        "$DS/vwr.sh" ${list} "${trgt}" ${item_pos} &
    exit
} >/dev/null 2>&1

edit_list() {
    [ -e "$DT/add_lst" -o -e "$DT/el_lk" ] && exit
    [ $((inx3+inx4)) -le 1 ] && exit
    if [ -e "$DC_s/elist_first_run" ]; then 
    "$DS/ifs/tls.sh" first_run edit_list & fi
    [ $lgt = ja -o $lgt = 'zh-cn' -o $lgt = ru ] && c=c || c=w
    direc="$DM_tl/${2}/.conf"
    [ ! -s "${direc}/0.cfg" ] && exit 1
    lgt=$(lnglss $lgtl)
    lgs=$(lnglss $lgsl)
    > "$DT/_tmp1"
    tac "${direc}/0.cfg" | while read -r item_; do
        item="$(sed 's/},/}\n/g' <<<"${item_}")"
        trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
        [ -n "${trgt}" ] && echo "${trgt}" >> "$DT/_tmp1"
    done

    cat "$DT/_tmp1" |edit_list_list > "$DT/tmp1"
    ret=$?
    
    if [ $ret -eq 0 -o $ret -eq 2 ]; then
        [ $ret = 0 ] && cmd=tac && invrt_msg=FALSE
        [ $ret = 2 ] && cmd=cat && invrt_msg=TRUE
        include "$DS/ifs/mods/add"
        n=1; f_lock "$DT/el_lk"
        rm "${direc}/1.cfg" "${direc}/3.cfg" "${direc}/4.cfg"
        $cmd "$DT/tmp1" | while read -r trgt; do
            if grep -F -m 1 "trgt={${trgt}}" "${direc}/0.cfg"; then
                item="$(grep -F -m 1 "trgt={${trgt}}" "${direc}/0.cfg" |sed 's/},/}\n/g')"
                line="$(sed -n 's/^\([0-9]*\)[:].*/\1/p' <<<"${item}")"
                type="$(grep -oP '(?<=type={).*(?=})' <<<"${item}")"
                trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
                
                if [ ${type} = 1 ]; then
                    echo "${trgt}" >> "${direc}/3.cfg"
                elif [ ${type} = 2 ]; then
                    echo "${trgt}" >> "${direc}/4.cfg"; fi
                if ! grep -Fxo "${trgt}" "${direc}/2.cfg"; then
                    echo "${trgt}" >> "${direc}/1.cfg"; fi
                grep -F -m 1 "trgt={${trgt}}" "${direc}/0.cfg" | \
                sed "s/${line}\:\[/${n}\:\[/g" >> "$DT/tmp0"
            else
                if [ $(wc -$c <<<"${trgt}") = 1 ]; then
                    echo "${trgt}" >> "${direc}/3.cfg"; t=1
                else echo "${trgt}" >> "${direc}/4.cfg"; t=2; fi
                temp="...."
                item="${n}:[type={$t},trgt={$trgt},srce={$temp},exmp={},defn={},note={},wrds={},grmr={$trgt},].[tag={},mark={},].id=[]"
                echo "${item}" >> "$DT/tmp0"
                echo "${trgt}" >> "$DT/add_lst"
                echo "${trgt}" >> "${direc}/1.cfg"
            fi
            let n++
        done

        touch "${direc}/3.cfg" "${direc}/4.cfg"
        mv -f "$DT/tmp0" "${direc}/0.cfg"
        if [ -d "$DM_tl/${2}" -a `wc -l < "${direc}/0.cfg"` -ge 1 ]; then
        while read -r r_item; do
           id=`basename "${r_item}" |sed "s/\(.*\).\{4\}/\1/" |tr -d '.'`
           if ! grep "${id}" "${direc}/0.cfg"; then
           [ -f "${r_item}" ] && rm "${r_item}"; fi
        done < <(find "$DM_tl/${2}"/*.mp3); fi
        if [[ "$(cat "${direc}/1.cfg" "${direc}/2.cfg" |wc -l)" -lt 1 ]]; then
        > "${direc}/0.cfg"; fi
        "$DS/ifs/tls.sh" colorize
        rm -f "$DT/el_lk"

        if [ -f "$DT/add_lst" ]; then
            invrt_msg=FALSE
            DT_r=$(mktemp -d "$DT/XXXX")
            temp="...."
            internet
            while read -r trgt; do
                trgt_mod="${trgt}"
                pos=`grep -Fon -m 1 "trgt={${trgt}}" "${direc}/0.cfg" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
                item="$(sed -n ${pos}p "${direc}/0.cfg" |sed 's/},/}\n/g')"
                type=`grep -oP '(?<=type={).*(?=})' <<<"${item}"`
                trgt=`grep -oP '(?<=trgt={).*(?=})' <<<"${item}"`
                srce="$temp"
                if [ ${type} = 1 ]; then
                    srce_mod="$(clean_1 "$(translate "${trgt}" $lgt $lgs)")"
                    audio="${trgt,,}"
                    tts_word "${audio}" "$DT_r"
                elif [ ${type} = 2 ]; then
                    srce_mod="$(clean_2 "$(translate "${trgt}" $lgt $lgs)")"
                    db="$DS/default/dicts/$lgt"
                    sentence_p "$DT_r" 2
                    fetch_audio "${aw}" "${bw}" "$DT_r" "${DM_tls}"
                fi
                 
                id_mod="$(set_name_file ${type} "${trgt}" "${srce_mod}" \
                "${exmp_mod}" "${defn_mod}" "${note_mod}" "${wrds_mod}" "${grmr_mod}")"
                [ ${type} = 2 ] && cd "$DT_r"; tts "${trgt}" "$lgt" "$DT_r" "${DM_tlt}/$id_mod.mp3"
                
                sed -i "${pos}s|srce={$srce}|srce={$srce_mod}|;
                ${pos}s|wrds={}|wrds={$wrds_mod}|;
                ${pos}s|grmr={$trgt}|grmr={$grmr_mod}|;
                ${pos}s|id=\[\]|id=\[$id_mod\]|g" "${direc}/0.cfg"
            done < "$DT/add_lst"
        fi
    fi
    rm -f "$DT/tmp1" "$DT/_tmp1" "$DT/add_lst" "$DT_r"
    exit 1
} >/dev/null 2>&1


delete_topic() {
    if [ -z "${tpc}" ]; then exit 1; fi
    if [ "${tpc}" != "${2}" ]; then
        msg "$(gettext "Sorry, this topic is currently not active.")\n " info "$(gettext "Information")" & exit; fi
    msg_2 "$(gettext "Are you sure you want to delete this topic?")\n" \
    gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"
    ret="$?"
    if [ ${ret} -eq 0 ]; then
        f_lock "$DT/rm_lk"
        
        if [ -f "$DT/.n_s_pr" ]; then
            if [ "$(sed -n 1p "$DT/.n_s_pr")" = "${tpc}" ]; then
            "$DS/stop.sh" 5; fi
        fi
        if [ -f "$DT/.p_" ]; then
            if [ "$(sed -n 2p "$DT/.p_")" = "${tpc}" ]; then 
            "$DS/stop.sh" 2; fi
        fi
        [ -f "$DM/backup/${tpc}.bk" ] && rm "$DM/backup/${tpc}.bk"

        if [ -d "$DM_tl/${tpc}" ]; then
            rm -fr "$DM_tl/${tpc}"; fi
     
        if [ -d "$DM_tl/${tpc}" ]; then sleep 0.5
        msg "$(gettext "Could not remove the directory:")\n$DM_tl/${tpc}\n$(gettext "You must manually remove it.")" info "$(gettext "Information")"; fi
        
        rm -f "$DT/tpe"
        > "$DM_tl/.8.cfg"
        > "$DC_s/4.cfg"
        for n in {0..4}; do
            if [ -e "$DM_tl/.${n}.cfg" ]; then
            grep -vxF "${tpc}" "$DM_tl/.$n.cfg" > "$DM_tl/.${n}.cfg.tmp"
            sed '/^$/d' "$DM_tl/.$n.cfg.tmp" > "$DM_tl/.${n}.cfg"; fi
        done
        kill -9 $(pgrep -f "yad --list ") &
        kill -9 $(pgrep -f "yad --text-info ") &
        kill -9 $(pgrep -f "yad --form ") &
        kill -9 $(pgrep -f "yad --notebook ") &
        "$DS/mngr.sh" mkmn &
        
        if [ -e "$DM_tl/.5.cfg" ]; then
            tpd="$(< "$DM_tl/.5.cfg")"
            if grep -Fxq "${tpd}" "$DM_tl/.1.cfg"; then
            "$DS/default/tpc.sh" "${tpd}" 2; fi
        fi
        > "$DC_s/7.cfg"
    fi
    rm -f "$DT/rm_lk" "$DM_tl"/.*.tmp & exit 1
}

rename_topic() {
    source "$DS/ifs/mods/add/add.sh"
    info2=$(wc -l < "$DM_tl/.1.cfg")
    if grep -Fxo "${tpc}" < "$DM_tl/.3.cfg"; then i=1; fi
    jlb="$(clean_3 "${2}")"
    
    if grep -Fxo "${jlb}" < <(ls "$DS/addons/"); then jlb="${jlb} (1)"; fi
    chck="$(grep -Fxo "${jlb}" "$DM_tl/.1.cfg" | wc -l)"
    
    if [ ! -d "$DM_tl/${tpc}" ]; then exit 1; fi
  
    if [ -f "$DT/.n_s_pr" ] && [ "$(sed -n 1p "$DT/.n_s_pr")" = "${tpc}" ]; then
    msg "$(gettext "Unable to rename at this time. Please try later ")\n" \
    dialog-warning "$(gettext "Information")" & exit 1; fi
        
    if [ -f "$DT/.p_" ] && [ "$(sed -n 2p "$DT/.p_")" = "${tpc}" ]; then
    msg "$(gettext "Unable to rename at this time. Please try later ")\n" \
    dialog-warning "$(gettext "Information")" & exit 1; fi

    if [ ${#jlb} -gt 55 ]; then
    msg "$(gettext "Sorry, new name too long.")\n" \
    info "$(gettext "Information")" & exit 1; fi

    if [ ${chck} -ge 1 ]; then
        for i in {1..50}; do
        chck=$(grep -Fxo "${jlb} ($i)" "$DM_t/$language_target/.1.cfg")
        [ -z "${chck}" ] && break; done
        
        jlb="${jlb} ($i)"
        msg_2 "$(gettext "Another topic with the same name already exist.") \n$(gettext "Notice that the name for this one is now\:")\n<b>$jlb</b> \n" info "$(gettext "OK")" "$(gettext "Cancel")"
        ret="$?"
        if [ ${ret} -eq 1 ]; then exit 1; fi
    fi
    if [ -n "${jlb}" ]; then
        f_lock "$DT/rm_lk"
        mv -f "$DM_tl/${tpc}" "$DM_tl/${jlb}"
        sed -i "s/tname=.*/tname=\"${jlb}\"/g" "$DM_tl/${jlb}/.conf/id.cfg"
        echo "${jlb}" > "$DC_s/4.cfg"
        echo "${jlb}" > "$DM_tl/.8.cfg"
        echo "${jlb}" >> "$DM_tl/.1.cfg"
        list_inadd > "$DM_tl/.2.cfg"
        echo "${jlb}" > "$DT/tpe"
        echo 0 > "$DC_s/5.cfg"
        
        for n in {1..3}; do
        if [ -f "$DM_tl/.${n}.cfg" ]; then
        grep -vxF "${tpc}" "$DM_tl/.$n.cfg" > "$DM_tl/.${n}.cfg.tmp"
        sed '/^$/d' "$DM_tl/.$n.cfg.tmp" > "$DM_tl/.${n}.cfg"; fi
        done
        
        rm "$DM_tl"/.*.tmp
        [ -d "$DM_tl/${tpc}" ] && rm -r "$DM_tl/${tpc}"
        [ -f "$DM/backup/${tpc}.bk" ] && rm "$DM/backup/${tpc}.bk"
        [[ ${i} = 1 ]] &&  echo "${jlb}" >> "$DM_tl/.3.cfg"
        
        rm -f "$DT/rm_lk"; "$DS/mngr.sh" mkmn & exit 1
    fi
}

mark_to_learn_topic() {
    if [ "${tpc}" != "${2}" ]; then
    msg "$(gettext "Sorry, this topic is currently not active.")\n " info "$(gettext "Information")" & exit; fi
    
    [ ! -s "${DC_tlt}/0.cfg" ] && exit 1
    
    if [ $((inx3+inx4)) -le 10 ]; then
    msg "$(gettext "Not enough notes to perform the operation").\t\n " \
    info "$(gettext "Information")" & exit; fi

    (echo "5"
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
    rm "${DC_tlt}/7.cfg"
    touch "${DC_tlt}/5.cfg" "${DC_tlt}/2.cfg"
    
    while read -r item_; do
        item="$(sed 's/},/}\n/g' <<<"${item_}")"
        type="$(grep -oP '(?<=type={).*(?=})' <<<"${item}")"
        trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
        if [ -n "${trgt}" ]; then
            if [ ${type} -eq 1 ]; then
                echo "${trgt}" >> "${DC_tlt}/3.cfg"
            else 
                echo "${trgt}" >> "${DC_tlt}/4.cfg"
            fi
            echo "${trgt}" >> "${DC_tlt}/1.cfg"
        fi
    done < "${DC_tlt}/0.cfg"
    
    ) | progr_3

    if [[ ${3} = 1 ]]; then
    kill -9 $(pgrep -f "yad --multi-progress ") &
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --text-info ") &
    kill -9 $(pgrep -f "yad --form ") &
    kill -9 $(pgrep -f "yad --notebook ") & fi
    touch "${DM_tlt}"
    "$DS/mngr.sh" mkmn &
    [[ ${3} = 1 ]] && idiomind topic &
}

mark_as_learned_topic() {
    if [ "${tpc}" != "${2}" ]; then
    msg "$(gettext "Sorry, this topic is currently not active.")\n " info "$(gettext "Information")" & exit; fi
    
    [ ! -s "${DC_tlt}/0.cfg" ] && exit 1

    if [ $((inx3+inx4)) -le 10 ]; then
    msg "$(gettext "Not enough notes to perform the operation").\t\n " \
    info "$(gettext "Information")" & exit; fi
    
    (echo "5"
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
            echo "$(date +%m/%d/%Y)" > "${DC_tlt}/9.cfg"
        fi
        
        if [ -d "${DC_tlt}/practice" ]; then
            (cd "${DC_tlt}/practice"; rm .*; rm *
            touch ./log1 ./log2 ./log3); fi
        
        > "${DC_tlt}/7.cfg"
        if [[ $((stts%2)) = 0 ]]; then
            echo 4 > "${DC_tlt}/8.cfg"
        else
            echo 3 > "${DC_tlt}/8.cfg"
        fi
    fi
    
    rm "${DC_tlt}/1.cfg" "${DC_tlt}/2.cfg"
    touch "${DC_tlt}/1.cfg"
    
    while read item_; do
        item="$(sed 's/},/}\n/g' <<<"${item_}")"
        trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
        if [ -n "${trgt}" ]; then
            echo "${trgt}" >> "${DC_tlt}/2.cfg"
        fi
    done < "${DC_tlt}/0.cfg"
    
    ) | progr_3

    if [[ ${3} = 1 ]]; then
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --text-info ") &
    kill -9 $(pgrep -f "yad --form ") &
    kill -9 $(pgrep -f "yad --notebook ") & fi
    "$DS/mngr.sh" mkmn &
    [[ ${3} = 1 ]] && idiomind topic &
    exit 1
}

case "$1" in
    mkmn)
    mkmn ;;
    delete_item_ok)
    delete_item_ok "$@" ;;
    delete_item)
    delete_item "$@" ;;
    edit)
    edit_item "$@" ;;
    edit_list)
    edit_list "$@" ;;
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
esac
