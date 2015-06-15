#!/bin/bash
# -*- ENCODING: UTF-8 -*-

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
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"

mkmn() {
    
    cd "$DM_tl"
    [ -d "$DM_tl/images" ] && rm -r "$DM_tl/images"
    [ -d "$DM_tl/words" ] && rm -r "$DM_tl/words"
    for i in "$(ls -tNd */ | sed 's/\///g')"; do \
    echo "${i%%/}"; done > "$DM_tl/.1.cfg"
    sed -i '/^$/d' "$DM_tl/.1.cfg"
    > "$DC_s/0.cfg"
    
    n=1
    while [[ $n -le "$(head -100 < "$DM_tl/.1.cfg" | wc -l)" ]]; do
    
        tp=$(sed -n "$n"p "$DM_tl/.1.cfg")
        if ! grep -Fxo "${tp}" < <(ls "$DS/addons/"); then
        inx1=$(wc -l < "$DM_tl/${tp}/.conf/1.cfg")
        inx2=$(wc -l < "$DM_tl/${tp}/.conf/2.cfg")
        tooltips_1="$inx1 / $inx2"
        else tooltips_1=""
        fi
        if [ ! -f "$DM_tl/${tp}/.conf/8.cfg" ]; then
        i=13; echo 13 > "$DM_tl/${tp}/.conf/8.cfg"
        else i=$(sed -n 1p "$DM_tl/${tp}/.conf/8.cfg"); fi
        
        if [ ! "$DM_tl/${tp}/.conf/8.cfg" ] || \
        [ ! "$DM_tl/${tp}/.conf/0.cfg" ] || \
        [ ! "$DM_tl/${tp}/.conf/1.cfg" ] || \
        [ ! "$DM_tl/${tp}/.conf/3.cfg" ] || \
        [ ! "$DM_tl/${tp}/.conf/4.cfg" ] || \
        [ -z "$i" ] || [ ! -d "$DM_tl/${tp}" ]; then
        [ -f "${DC_tlt}/8.cfg" ] && stts_=$(< "${DC_tlt}/8.cfg")
        if [ "$stts_" != 13 ]; then echo "$stts_" > "${DC_tlt}/8.cfg_"; fi
        i=13; echo 13 > "$DM_tl/${tp}/.conf/8.cfg";fi
        echo -e "/usr/share/idiomind/images/img.$i.png\n${tp}\n$tooltips_1" >> "$DC_s/0.cfg"
        let n++
    done
    n=1
    while [[ $n -le "$(tail -n+101 < "$DM_tl/.1.cfg" | wc -l)" ]]; do
        f=$(tail -n+51 < "$DM_tl/.1.cfg")
        tp=$(sed -n "$n"p <<<"${f}")
        if [ ! -f "$DM_tl/${tp}/.conf/8.cfg" ]; then
        [ -f "${DC_tlt}/8.cfg" ] && stts_=$(< "${DC_tlt}/8.cfg")
        if [ "$stts_" != 13 ]; then echo "$stts_" > "${DC_tlt}/8.cfg_"; fi
        i=13; echo 13 > "$DM_tl/${tp}/.conf/8.cfg"
        else i=$(sed -n 1p "$DM_tl/${tp}/.conf/8.cfg"); fi
        if [ ! -f "$DM_tl/${tp}/.conf/8.cfg" ] || \
        [ ! "$DM_tl/${tp}/.conf/0.cfg" ] || \
        [ ! "$DM_tl/${tp}/.conf/1.cfg" ] || \
        [ ! "$DM_tl/${tp}/.conf/3.cfg" ] || \
        [ ! "$DM_tl/${tp}/.conf/4.cfg" ] || \
        [ ! -d "$DM_tl/${tp}" ]; then img=13; else img=12; fi
        echo -e "/usr/share/idiomind/images/img.$img.png\n${tp}\n " >> "$DC_s/0.cfg"
        let n++
    done
    exit 1
}


delete_item_ok() {

    touch "$DT/ps_lk"
    include "$DS/ifs/mods/mngr"
    source "$DS/ifs/mods/cmns.sh"
    item="${3}"
    id="$(nmfile "${3}")"
    DM_tlt="$DM_tl/${2}"
    DC_tlt="$DM_tl/${2}/.conf"

    if [ -f "${DM_tlt}/$id.mp3" ]; then
    file="${DM_tlt}/$id.mp3"
        
    elif [ -f "${DM_tlt}/$id.mp3" ]; then
    file="${DM_tlt}/$id.mp3"

    fi
    
    [ -f "${file}" ] && rm "${file}"

    if [ -d "${DC_tlt}/practice" ]; then
        cd "${DC_tlt}/practice"
        while read file_pr; do
            if grep -Fxq "${item}" "${file_pr}"; then
                grep -vxF "${item}" "${file_pr}" > ./rm.tmp
                sed '/^$/d' ./rm.tmp > "${file_pr}"; fi
        done < <(ls ./*)
        rm ./*.tmp
        cd /
    fi

    sed -i "${4}d" "${DC_tlt}/.11.cfg"
    "$DS/ifs/tls.sh" sanity_1 "${DC_tlt}/.11.cfg" &

    n=0
    while [ $n -le 6 ]; do
    if [ -f "${DC_tlt}/$n.cfg" ]; then
        grep -vxF "${item}" "${DC_tlt}/$n.cfg" > "${DC_tlt}/$n.cfg.tmp"
        sed '/^$/d' "${DC_tlt}/$n.cfg.tmp" > "${DC_tlt}/$n.cfg"; fi
        let n++
    done
    
    if [ -f "${DC_tlt}/lst" ]; then rm "${DC_tlt}/lst"; fi
    rm "${DC_tlt}"/*.tmp
    "$DS/ifs/tls.sh" colorize
    rm -f "$DT/ps_lk" & exit 1
}

delete_item() {

    touch "$DT/ps_lk"
    include "$DS/ifs/mods/mngr"
    source "$DS/ifs/mods/cmns.sh"
    item="${3}"
    id="$(nmfile "${3}")"
    DM_tlt="$DM_tl/${2}"
    DC_tlt="$DM_tl/${2}/.conf"

    if [ -f "${DM_tlt}/$id.mp3" ]; then 
    
    file="${DM_tlt}/$id.mp3"
    msg_2 "$(gettext "Are you sure you want to delete this word?")\n" \
    gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"

    elif [ -f "${DM_tlt}/$id.mp3" ]; then
    
    file="${DM_tlt}/$id.mp3"
    msg_2 "$(gettext "Are you sure you want to delete this sentence?")\n" \
    gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"

    else
    msg_2 "$(gettext "Are you sure you want to delete this item?")\n" \
    gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"
    fi
    ret=$(echo "$?")
    
    if [[ $ret -eq 0 ]]; then
        
        (sleep 0.1 && kill -9 $(pgrep -f "yad --form "))
        
        [ -f "${file}" ] && rm "${file}"
        
        if [ -d "${DC_tlt}/practice" ]; then
            cd "${DC_tlt}/practice"
            while read file_pr; do
                if grep -Fxq "${item}" "${file_pr}"; then
                    grep -vxF "${item}" "${file_pr}" > ./rm.tmp
                    sed '/^$/d' ./rm.tmp > "${file_pr}"; fi
            done < <(ls ./*)
            rm ./*.tmp
            cd /
        fi
        
        sed -i "${4}d" "${DC_tlt}/.11.cfg"
        "$DS/ifs/tls.sh" sanity_1 "${DC_tlt}/.11.cfg" &

        n=0
        while [[ $n -le 6 ]]; do
            if [ -f "${DC_tlt}/$n.cfg" ]; then
            grep -vxF "${item}" "${DC_tlt}/$n.cfg" > "${DC_tlt}/$n.cfg.tmp"
            sed '/^$/d' "${DC_tlt}/$n.cfg.tmp" > "${DC_tlt}/$n.cfg"; fi
            let n++
        done
        rm "${DC_tlt}"/*.tmp
    fi
    
    "$DS/ifs/tls.sh" colorize &
    rm -f "$DT/ps_lk" & exit 1
}


edit_item() {

    include "$DS/ifs/mods/mngr"
    lgt=$(lnglss $lgtl)
    lgs=$(lnglss $lgsl)
    lists="$2";  item_pos="$3"
    if [ "$lists" = 1 ]; then
    index_1="${DC_tlt}/1.cfg"
    index_2="${DC_tlt}/2.cfg"
    [[ $item_pos -lt 1 ]] && item_pos=$inx1
    elif [ "$lists" = 2 ]; then
    index_1="${DC_tlt}/2.cfg"
    index_2="${DC_tlt}/1.cfg"
    [[ $item_pos -lt 1 ]] && item_pos=$inx2; fi
    tpcs="$(egrep -v "${tpc}" "${DM_tl}/.2.cfg" |tr "\\n" '!' |sed 's/!\+$//g')"
    c=$((RANDOM%10000))

    item=`sed -n ${item_pos}p "${index_1}"`
    pos=`grep -Fon -m 1 "trgt={${item}}" "${DC_tlt}/.11.cfg" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
    item=`sed -n ${pos}p "${DC_tlt}/.11.cfg" |sed 's/},/}\n/g'`
    
    type=`grep -oP '(?<=type={).*(?=})' <<<"${item}"`
    trgt=`grep -oP '(?<=trgt={).*(?=})' <<<"$item"`
    grmr=`grep -oP '(?<=grmr={).*(?=})' <<<"$item"`
    srce=`grep -oP '(?<=srce={).*(?=})' <<<"$item"`
    exmp=`grep -oP '(?<=exmp={).*(?=})' <<<"$item"`
    defn=`grep -oP '(?<=defn={).*(?=})' <<<"$item"`
    note=`grep -oP '(?<=note={).*(?=})' <<<"$item"`
    grmr=`grep -oP '(?<=grmr={).*(?=})' <<<"$item"`
    wrds=`grep -oP '(?<=wrds={).*(?=})' <<<"$item"`
    mark=`grep -oP '(?<=mark={).*(?=})' <<<"$item"`
    id=`grep -oP '(?<=id=\[).*(?=\])' <<<"$item"`
    [ "${mark}" = FALSE ] && mark=""
    [ -z "${id}" ] && id=""
    
    audiofile="${DM_tlt}/$id.mp3"
    q_trad="$(sed "s/'/ /g" <<<"$trgt")"
    mod=0; col=0
    
    cmd_move="$DS/ifs/mods/mngr/mngr.sh 'position' ${item_pos} "\"${index_1}\"""
    cmd_delete="$DS/mngr.sh delete_item "\"${tpc}\"" "\"${trgt}\"" ${item_pos}"
    cmd_image="$DS/ifs/tls.sh set_image "\"${audiofile}\"" word"
    cmd_play="play "\"${DM_tlt}/$id.mp3\"""
    link1="https://translate.google.com/\#$lgt/$lgs/${q_trad}"
    link2="http://glosbe.com/$lgt/$lgs/${q_trad,,}"
    link3='https://www.google.com/search?q='$q_trad'&amp;tbm=isch'
    

    if [ ! -f "${audiofile}" ] && [ -z "${item}" ]; then exit 1; fi


    if  [ ${type} = 1 ]; then edit_dlg1=`dlg_form_1`
    elif [ ${type} = 2 ]; then edit_dlg2=`dlg_form_2`; fi
    ret=$?

        if [[ $ret -eq 0 ]] || [[ $ret -eq 2 ]]; then
        
            source /usr/share/idiomind/ifs/c.conf
            include "$DS/ifs/mods/add"
            
           if [ ${type} = 1 ]; then
                trgt_mod="$(cut -d "|" -f1 <<<"${edit_dlg1}" | clean_0)"
                srce_mod="$(cut -d "|" -f2 <<<"${edit_dlg1}" | clean_0)"
                tpc_mod="$(cut -d "|" -f3 <<<"${edit_dlg1}")"
                audio_mod="$(cut -d "|" -f4 <<<"${edit_dlg1}")"
                exmp_mod="$(cut -d "|" -f5 <<<"${edit_dlg1}" | clean_0)"
                defn_mod="$(cut -d "|" -f6 <<<"${edit_dlg1}" | clean_0)"
                note_mod="$(cut -d "|" -f7 <<<"${edit_dlg1}" | clean_0)"
                mark_mod="$(cut -d "|" -f9 <<<"${edit_dlg1}")"
                type_mod=1
                

            elif [ ${type} = 2 ]; then
                mark_mod="$(cut -d "|" -f1 <<<"${edit_dlg2}")"
                type_mod="$(cut -d "|" -f2 <<<"${edit_dlg2}")"
                trgt_mod="$(cut -d "|" -f3 <<<"${edit_dlg2}" | clean_1)"
                srce_mod="$(cut -d "|" -f5 <<<"${edit_dlg2}" | clean_1)"
                tpc_mod="$(cut -d "|" -f7 <<<"${edit_dlg2}")"
                audio_mod="$(cut -d "|" -f8 <<<"${edit_dlg2}")"
                grmr_mod="${grmr}"
                wrds_mod="${wrds}"
                
                
                [ "${type_mod}" = TRUE ] && type_mod=1
                [ "${type_mod}" = FALSE ] && type_mod=2
                [ -z "${type_mod}" ] && type_mod=2
                
            fi

  
            [ "${mark_mod}" = FALSE ] && mark_mod=""
            [ -z "${id_mod}" ] && id=""
            
            
            if [ "${trgt_mod}" != "${trgt}" ] && [ ! -z "${trgt_mod##+([[:space:]])}" ]; then
                temp="$(gettext "Processing")..."
                sed -i "${item_pos}s|trgt={${trgt}}|trgt={${trgt_mod}}|;
                ${item_pos}s|grmr={${grmr}}|grmr={${trgt_mod}}|;
                ${item_pos}s|srce={${srce}}|srce={$temp}|g" "$DC_tlt/.11.cfg"
                index edit "${trgt}" "${tpc}" "${trgt_mod}"
                ind=1; col=1; mod=1
            fi
            
            if [ "$mark" != "$mark_mod" ]; then
                if [ "$mark_mod" = "TRUE" ]; then
                echo "$trgt" >> "${DC_tlt}/6.cfg"; else
                grep -vxF "${trgt}" "${DC_tlt}/6.cfg" > "${DC_tlt}/6.cfg.tmp"
                sed '/^$/d' "${DC_tlt}/6.cfg.tmp" > "${DC_tlt}/6.cfg"
                rm "${DC_tlt}/6.cfg.tmp"; fi
                col=1; mod=1
            fi
            
            [ "${srce}" != "${srce_mod}" ] && mod=1
            [ "${exmp}" != "${exmp_mod}" ] && mod=1
            [ "${defn}" != "${defn_mod}" ] && mod=1
            [ "${note}" != "${note_mod}" ] && mod=1
            [ "${tpc}" != "${tpc_mod}" ] && mod=1

            # ========================================================= modifications proced
            if [ $mod = 1 ]; then
            (
                if [ $ind = 1 ]; then
                
                        DT_r=$(mktemp -d "$DT/XXXX")
                        
                    if [ ${type} = 1 ]; then
                        
                        "$DS/add.sh" new_word "${trgt_mod}" "$DT_r" "${srce_mod}" 0
                        srce="$temp"

                    elif [ ${type} = 2 ]; then
                        internet
                        srce_mod=$(translate "${trgt_mod}" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')
                        source "$DS/default/dicts/$lgt"
                        sentence_p "$DT_r" 2
                        fetch_audio "$aw" "$bw" "$DT_r" "$DM_tls"
                        srce="$temp"
                        grmr="$trgt_mod"
                    fi
                fi
            
                id_mod="$(nmfile "${type_mod}" "${trgt_mod}" "${srce_mod}" \
                "${exmp_mod}" "${defn_mod}" "${note_mod}" "${wrds_mod}" "${grmr_mod}")"


                if [ "${tpc}" != "${tpc_mod}" ]; then # lack move audio file and picture
                
                    cfg11="$DM_tl/${tpc_mod}/.conf/.11.cfg"
                    pos=$(grep -Fon -m 1 "trgt={}" "${cfg11}" |sed -n 's/^\([0-9]*\)[:].*/\1/p')
                    [ -f "${audio_mod}" ] && mv -f "${audio_mod}" "$DM_tl/${tpc_mod}/$id_mod.mp3"
                    sed -i "${pos}s|trgt={}|trgt={$trgt_mod}|g" "${cfg11}"
                    "$DS/mngr.sh" delete_item_ok "${tpc}" "${trgt}" ${item_pos}
                    index ${type} "${trgt_mod}" "${tpc_mod}"
                    unset type trgt srce exmp defn note wrds grmr mark id
                    

                elif [ "${tpc}" = "${tpc_mod}" ]; then
                    cfg11="$DC_tlt/.11.cfg"
                    pos=${item_pos}
                fi

                sed -i "${pos}s|type={$type}|type={$type_mod}|;
                ${pos}s|srce={$srce}|srce={$srce_mod}|;
                ${pos}s|exmp={$exmp}|exmp={$exmp_mod}|;
                ${pos}s|defn={$defn}|defn={$defn_mod}|;
                ${pos}s|note={$note}|note={$note_mod}|;
                ${pos}s|wrds={$wrds}|wrds={$wrds_mod}|;
                ${pos}s|grmr={$grmr}|grmr={$grmr_mod}|;
                ${pos}s|mark={$mark}|mark={$mark_mod}|;
                ${pos}s|id=\[$id\]|id=\[$id_mod\]|g" "${cfg11}"

                if [ "${audio_mod}" != "${audiofile}" ]; then
                cp -f "${audio_mod}" "${DM_tlt}/$id_mod.mp3"
                else
                mv -f "${DM_tlt}/$id.mp3" "${DM_tlt}/$id_mod.mp3"; fi
                
                if [ -f "${DM_tlt}/images/$id.jpg" ]; then
                mv -f "${DM_tlt}/images/$id.jpg" "${DM_tlt}/images/$id_mod.jpg"; fi
            ) &
            
            fi
            
            
            
            [[ $col = 1 ]] && ("$DS/ifs/tls.sh" colorize) &
            [[ $mod = 1 ]] && sleep 0.2
            [[ $ret -eq 0 ]] && "$DS/vwr.sh" "$lists" "${trgt}" ${item_pos} &
            [[ $ret -eq 2 ]] && "$DS/mngr.sh" edit "$lists" $((item_pos-1)) &
            
            
            
        else
            "$DS/vwr.sh" "$lists" "${trgt}" ${item_pos} &
        fi

    exit
    
} >/dev/null 2>&1


delete_topic() {
    
    include "$DS/ifs/mods/mngr"
    
    if [ "${tpc}" != "${2}" ]; then
    msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit; fi

    msg_2 "$(gettext "Are you sure you want to delete this Topic?")\n" \
    gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"
    ret=$(echo "$?")
        
        if [[ $ret -eq 0 ]]; then
            
            if [ -f "$DT/.n_s_pr" ] && [ "$(sed -n 2p "$DT/.n_s_pr")" = "${tpc}" ]; then
            "$DS/stop.sh" 5; fi
            
            if [ -f "$DT/.p_" ] && [ "$(sed -n 2p "$DT/.p_")" = "${tpc}" ]; then
            notify-send -i idiomind "$(gettext "Playback is stopped")" -t 5000 &
            "$DS/stop.sh" 2; fi
            
            if [ -d "$DM_tl/${tpc}" ] && [ -n "${tpc}" ]; then
            rm -r "$DM_tl/${tpc}"; fi
            rm -f "$DT/tpe"
            > "$DM_tl/.8.cfg"
            > "$DC_s/4.cfg"
            
            n=0
            while [[ $n -le 4 ]]; do
            if [ "$DM_tl/.$n.cfg" ]; then
            grep -vxF "${tpc}" "$DM_tl/.$n.cfg" > "$DT/cfg.tmp"
            sed '/^$/d' "$DT/cfg.tmp" > "$DM_tl/.$n.cfg"; fi
            let n++
            done; rm "$DT/cfg.tmp"
            
            kill -9 $(pgrep -f "yad --list ") &
            kill -9 $(pgrep -f "yad --list ") &
            kill -9 $(pgrep -f "yad --text-info ") &
            kill -9 $(pgrep -f "yad --form ") &
            kill -9 $(pgrep -f "yad --notebook ") &
            
            "$DS/mngr.sh" mkmn &
        fi
        
    rm -f "$DT/ps_lk" & exit 1
}


rename_topic() {

    source "$DS/ifs/mods/add/add.sh"
    info2=$(wc -l < "$DM_tl/.1.cfg")
    if grep -Fxo "$tpc" < "$DM_tl/.3.cfg"; then i=1; fi
    jlb="$(clean_2 "${2}")"
    
    if grep -Fxo "${jlb}" < <(ls "$DS/addons/"); then jlb="$jlb."; fi
    chck="$(grep -Fxo "${jlb}" "$DM_tl/.1.cfg" | wc -l)"
  
    if [ -f "$DT/.n_s_pr" ] && [ "$(sed -n 2p "$DT/.n_s_pr")" = "$tpc" ]; then
    msg "$(gettext "Unable to rename at this time. Please try later ")\n" \
    dialog-warning "$(gettext "Rename")" & exit 1; fi
        
    if [ -f "$DT/.p_" ] && [ "$(sed -n 2p "$DT/.p_")" = "$tpc" ]; then
    msg "$(gettext "Unable to rename at this time. Please try later ")\n" \
    dialog-warning "$(gettext "Rename")" & exit 1; fi

    if [[ ${#jlb} -gt 55 ]]; then
    msg "$(gettext "Sorry, new name too long.")\n" \
    info "$(gettext "Rename")" & exit 1; fi

    if [ "$chck" -ge 1 ]; then
    
        for i in {1..50}; do
        chck=$(grep -Fxo "${jlb} ($i)" "$DM_t/$language_target/.1.cfg")
        [ -z "${chck}" ] && break; done
        
        jlb="${jlb} ($i)"
        msg_2 "$(gettext "Another topic with the same name already exist.") \n$(gettext "The name for the newest will be\:")\n<b>$jlb</b> \n" info "$(gettext "OK")" "$(gettext "Cancel")"
        ret="$?"
        if [[ $ret -eq 1 ]]; then exit 1; fi
    fi
    
    if [ -n "${jlb}" ]; then

        mv -f "$DM_tl/${tpc}/.11.cfg" "$DT/.11.cfg"
        mv -f "$DM_tl/${tpc}" "$DM_tl/${jlb}"
        mv -f "$DT/.11.cfg" "$DM_tl/${jlb}/.11.cfg"
        echo "$jlb" > "$DC_s/4.cfg"
        echo "$jlb" > "$DM_tl/.8.cfg"
        echo "$jlb" >> "$DM_tl/.1.cfg"
        list_inadd > "$DM_tl/.2.cfg"
        echo "${jlb}" > "$DT/tpe"
        echo 0 > "$DC_s/5.cfg"
        
        n=1
        while [[ $n -le 3 ]]; do
        if [ -f "$DM_tl/.$n.cfg" ]; then
        grep -vxF "${tpc}" "$DM_tl/.$n.cfg" > "$DM_tl/.$n.cfg.tmp"
        sed '/^$/d' "$DM_tl/.$n.cfg.tmp" > "$DM_tl/.$n.cfg"; fi
        let n++
        done
        rm "$DM_tl"/.*.tmp
        [ -d "$DM_tl/${tpc}" ] && rm -r "$DM_tl/${tpc}"
        [[ "$i" = 1 ]] &&  echo "${jlb}" >> "$DM_tl/.3.cfg"
        
        "$DS/mngr.sh" mkmn & exit 1
    fi
}


mark_to_learn_topic() {
    
    include "$DS/ifs/mods/mngr"
    
    if [ "${tpc}" != "$2" ]; then
    msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit; fi
    
    if [ "$(wc -l < "$DC_tlt/0.cfg")" -le 10 ]; then
    msg "$(gettext "Not enough items to perform the operation.")\n " \
    info "$(gettext "Not enough items")" & exit; fi

    if [ "$3" = 1 ]; then
    kill -9 $(pgrep -f "yad --multi-progress ") &
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --text-info ") &
    kill -9 $(pgrep -f "yad --form ") &
    kill -9 $(pgrep -f "yad --notebook ") &
    fi

    if [ "$(sed '/^$/d' < "${DC_tlt}/1.cfg" | wc -l )" -ge 1 ]; then
        include "$DS/ifs/mods/mngr"
    
        dialog_2
        ret=$(echo $?)
    
        if [[ $ret -eq 3 ]]; then
        
            rm -f "${DC_tlt}/7.cfg"
            idiomind topic & exit 1
        fi
    fi

    stts=$(sed -n 1p "${DC_tlt}/8.cfg")
    calculate_review "${tpc}"
    
    if [[ $((stts%2)) = 0 ]]; then

        echo 6 > "${DC_tlt}/8.cfg"
            
    else
        if [[ $RM -ge 50 ]]; then
        echo 5 > "${DC_tlt}/8.cfg"
        else
        echo 1 > "${DC_tlt}/8.cfg"
        fi
    fi
    
    rm -f "${DC_tlt}/7.cfg"
    awk '!array_temp[$0]++' < "${DC_tlt}/0.cfg" > "$DT/0.cfg.tmp"
    sed '/^$/d' "$DT/0.cfg.tmp" > "${DC_tlt}/0.cfg"
    rm -f "$DT"/*.tmp
    rm "${DC_tlt}/2.cfg" "${DC_tlt}/1.cfg"
    touch "${DC_tlt}/2.cfg"
    cp -f "${DC_tlt}/0.cfg" "${DC_tlt}/1.cfg"
    echo -e ".lrnt.$tpc.lrnt." >> "$DC_s/8.cfg" &
    touch "${DC_tlt}/5.cfg"
    "$DS/mngr.sh" mkmn &

    [[ "$3" = 1 ]] && idiomind topic &
}


mark_as_learned_topic() {

    include "$DS/ifs/mods/mngr"

    if [ "${tpc}" != "${2}" ]; then
    msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit; fi

    if [ "$(wc -l < "${DC_tlt}/0.cfg")" -le 10 ]; then
    msg "$(gettext "Not enough items to perform the operation.")\n " \
    info "$(gettext "Not enough items")" & exit; fi
    
    if [ "$((( $(date +%s) - $(date -d "$(sed -n 8p "${DC_tlt}/12.cfg" \
    | grep -o 'date_c="[^"]*' | grep -o '[^"]*$')" +%s) ) /(24 * 60 * 60 )))" -lt 5 ]; then
    msg_2 "$(gettext "Are you sure it's not too soon?")\n" \
    gtk-dialog-question "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"; fi
    ret=$(echo $?); if [ $ret = 1 ]; then exit 1; fi
    
    if [ $3 = 1 ]; then
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --text-info ") &
    kill -9 $(pgrep -f "yad --form ") &
    kill -9 $(pgrep -f "yad --notebook ") &
    fi

    stts=$(sed -n 1p "${DC_tlt}/8.cfg")

    if [ ! -f "${DC_tlt}/7.cfg" ]; then
        if [ -f "${DC_tlt}/9.cfg" ]; then
        
            calculate_review "${tpc}"
            steps=$(sed '/^$/d' < "${DC_tlt}/9.cfg" | wc -l)
            
            if [[ "$steps" = 4 ]]; then
            
                stts=$((stts+1)); fi
            
            if [[ $RM -ge 50 ]]; then
            
                if [[ $steps = 6 ]]; then
                echo -e "_\n_\n_\n_\n_\n$(date +%m/%d/%Y)" > "${DC_tlt}/9.cfg"
                else
                echo "$(date +%m/%d/%Y)" >> "${DC_tlt}/9.cfg"
                fi
            fi
            
        else
            echo "$(date +%m/%d/%Y)" > "${DC_tlt}/9.cfg"
        fi
        
        if [ -d "${DC_tlt}/practice" ]; then
        cd "${DC_tlt}/practice"; rm .*; rm *
        touch ./log.1 ./log.2 ./log.3; fi
        
        > "${DC_tlt}/7.cfg"
        if [[ $((stts%2)) = 0 ]]; then
        echo 4 > "${DC_tlt}/8.cfg"
        else
        echo 3 > "${DC_tlt}/8.cfg"
        fi
    fi
    rm "${DC_tlt}/2.cfg" "${DC_tlt}/1.cfg" "${DC_tlt}/lst" 
    touch "${DC_tlt}/1.cfg"
    cp -f "${DC_tlt}/0.cfg" "${DC_tlt}/2.cfg"
    echo -e ".lrdt.$tpc.lrdt." >> "$DC_s/8.cfg" &
    "$DS/mngr.sh" mkmn &

    [[ $3 = 1 ]] && idiomind topic &
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
