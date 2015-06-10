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
        echo "/usr/share/idiomind/images/img.$i.png" >> "$DC_s/0.cfg"
        echo "${tp}" >> "$DC_s/0.cfg"
        echo "$tooltips_1" >> "$DC_s/0.cfg"
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
        [ ! -d "$DM_tl/${tp}" ]; then
            echo '/usr/share/idiomind/images/img.13.png' >> "$DC_s/0.cfg"
        else
            echo '/usr/share/idiomind/images/img.12.png' >> "$DC_s/0.cfg"
        fi
        echo "${tp}" >> "$DC_s/0.cfg"
        echo " / " >> "$DC_s/0.cfg"
        let n++
    done
    exit 1
}


delete_item_ok() {

    touch "$DT/ps_lk"
    include "$DS/ifs/mods/mngr"
    source "$DS/ifs/mods/cmns.sh"
    item="${2}"
    fname="$(nmfile "${2}")"

    if [ -f "${DM_tlt}/words/$fname.mp3" ]; then
    file="${DM_tlt}/words/$fname.mp3"
        
    elif [ -f "${DM_tlt}/$fname.mp3" ]; then
    file="${DM_tlt}/$fname.mp3"

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

    if [ -f "${DC_tlt}/.11.cfg" ]; then
        grep -vxF "${item}" "${DC_tlt}/.11.cfg" > "${DC_tlt}/11.cfg.tmp"
        sed '/^$/d' "${DC_tlt}/11.cfg.tmp" > "${DC_tlt}/.11.cfg"; fi
    
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
    item="${2}"
    fname="$(nmfile "${2}")"

    if [ -f "${DM_tlt}/words/$fname.mp3" ]; then 
    
    file="${DM_tlt}/words/$fname.mp3"
    msg_2 "$(gettext "Are you sure you want to delete this word?")\n" \
    gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"

    elif [ -f "${DM_tlt}/$fname.mp3" ]; then
    
    file="${DM_tlt}/$fname.mp3"
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
        
        if [ -f "${DC_tlt}/.11.cfg" ]; then
            grep -vxF "${item}" "${DC_tlt}/.11.cfg" > "${DC_tlt}/11.cfg.tmp"
            sed '/^$/d' "${DC_tlt}/11.cfg.tmp" > "${DC_tlt}/.11.cfg"; fi
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
    file_tmp="$(mktemp "$DT/file_tmp.XXXX")"
    item="$(sed -n "$item_pos"p "${index_1}")"
    q_trad="$(sed "s/'/ /g" <<<"$item")"
    fname="$(echo -n "${item}" | md5sum | rev | cut -c 4- | rev)"
    audiofile_1="${DM_tlt}/words/$fname.mp3"
    audiofile_2="${DM_tlt}/$fname.mp3"
    
    if [ ! -f "${audiofile_1}" ] && [ ! -f "${audiofile_2}" ] \
    && [ -z "${item}" ]; then exit 1; fi

    if grep -Fxo "${item}" "${DC_tlt}/3.cfg"; then
    
        if [ -f "${audiofile_1}" ]; then
        tags="$(eyeD3 "${audiofile_1}")"
        trgt="$(grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)' <<<"${tags}")"
        srce="$(grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)' <<<"${tags}")"
        fields="$(grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' <<<"${tags}" | tr '_' '\n')"
        mark="$(grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)' <<<"${tags}")"
        exmp="$(sed -n 1p <<<"${fields}")"
        dftn="$(sed -n 2p <<<"${fields}")"
        note="$(sed -n 3p <<<"${fields}")"
        a=0; else trgt="${item}"; a=1; fi
        cmd_move="$DS/ifs/mods/mngr/mngr.sh 'position' '$item_pos' "\"${index_1}\"""
        cmd_delete="$DS/mngr.sh delete_item "\"${item}\"""
        cmd_image="$DS/ifs/tls.sh set_image "\"${audiofile_1}\"" word"
        cmd_play="play "\"${DM_tlt}/words/$fname.mp3\"""
        link1="https://translate.google.com/\#$lgt/$lgs/${q_trad}"
        link2="http://glosbe.com/$lgt/$lgs/${q_trad,,}"
        link3='https://www.google.com/search?q='$q_trad'&amp;tbm=isch'
        
        dlg_form_1 "$file_tmp"
        ret=$(echo "$?")
        
            if [ ! -f "${DM_tlt}/words/$fname.mp3" ] && [ $a != 1 ]; then
            rm -f "$file_tmp" & exit 1; fi
             
            if [[ $ret -eq 0 ]] || [[ $ret -eq 2 ]]; then
            
                source /usr/share/idiomind/ifs/c.conf
                include "$DS/ifs/mods/add"
                trgt_mod="$(clean_0 "$(tail -12 < "$file_tmp" | sed -n 1p)")"
                srce_mod="$(clean_0 "$(tail -12 < "$file_tmp" | sed -n 2p)")"
                tpc_mod="$(tail -12 < "$file_tmp" | sed -n 3p)"
                audio_mod="$(tail -12 < "$file_tmp" | sed -n 4p)"
                exmp_mod="$(tail -12 < "$file_tmp" | sed -n 5p)"
                dftn_mod="$(tail -12 < "$file_tmp" | sed -n 6p)"
                note_mod="$(tail -12 < "$file_tmp" | sed -n 7p)"
                mark_mod="$(tail -12 < "$file_tmp" | sed -n 9p)"
                rm -f "$file_tmp"
                
                if [ "$mark" != "$mark_mod" ]; then
                    p=$((item_pos))
                    if [ "$mark_mod" = "TRUE" ]; then
                    echo "$trgt" >> "${DC_tlt}/6.cfg"; else
                    grep -vxF "${trgt}" "${DC_tlt}/6.cfg" > "${DC_tlt}/6.cfg.tmp"
                    sed '/^$/d' "${DC_tlt}/6.cfg.tmp" > "${DC_tlt}/6.cfg"
                    rm "${DC_tlt}/6.cfg.tmp"; fi
                    tags_8 W "$mark_mod" "${DM_tlt}/words/$fname.mp3"
                    "$DS/ifs/tls.sh" colorize &
                fi
                
                if [ "${audio_mod}" != "${audiofile_1}" ]; then
                
                    eyeD3 --write-images="$DT" "${audiofile_1}"
                    cp -f "${audio_mod}" "${DM_tlt}/words/$fname.mp3"
                    tags_1 W "${trgt}" "${srce_mod}" "${DM_tlt}/words/$fname.mp3"
                    eyeD3 --add-image $DT/ILLUSTRATION.jpeg:ILLUSTRATION \
                    "${DM_tlt}/words/$fname.mp3"
                    [ -d "$DT/idadtmptts" ] && rm -fr "$DT/idadtmptts"
                fi
                
                if [ "${trgt_mod}" != "${trgt}" ] && [ ! -z "${trgt_mod##+([[:space:]])}" ]; then

                    fname_mod="$(nmfile "${trgt_mod}")"
                    if [ -f "${DM_tlt}/words/$fname.mp3" ]; then
                    mv -f "${DM_tlt}/words/$fname.mp3" "${DM_tlt}/words/$fname_mod.mp3"
                    else voice "${trgt_mod}" "$DT_r" "${DM_tlt}/words/$fname_mod.mp3"; fi
                    if [ -f "${DM_tlt}/words/images/$fname.jpg" ]; then
                    mv -f "${DM_tlt}/words/images/$fname.jpg" "${DM_tlt}/words/images/$fname_mod.jpg"; fi
                    temp="$(gettext "Processing")..."
                    tags_1 W "${trgt_mod}" "${temp}" "${DM_tlt}/words/$fname_mod.mp3"
                    index edit "${trgt}" "${tpc}" "${trgt_mod}"
                    "$DS/ifs/tls.sh" colorize &
                    (DT_r=$(mktemp -d "$DT/XXXX")
                    "$DS/add.sh" new_word "${trgt_mod}" "$DT_r" "${srce_mod}" 0) &
                    fname="$fname_mod"
                fi
                
                if [ "${srce_mod}" != "${srce}" ]; then
                
                    tags_5 W "${srce_mod}" "${DM_tlt}/words/$fname.mp3"
                fi
                
                infm="$(echo ${exmp_mod} && echo ${dftn_mod} && echo ${note_mod})"
                if [ "${infm}" != "${fields}" ]; then
                
                    impr=$(echo "${infm}" | tr '\n' '_')
                    tags_6 W "${impr}" "${DM_tlt}/words/$fname.mp3"
                fi

                if [ "${tpc}" != "${tpc_mod}" ]; then

                    mv -f "${audio_mod}" "$DM_tl/${tpc_mod}/words/$fname.mp3"
                    index word "${trgt_mod}" "${tpc_mod}" &
                    "$DS/mngr.sh" delete_item_ok "${item}"
                    "$DS/vwr.sh" "$lists" "nll" "$item_pos" & exit 1
                fi
                
                [[ $ret -eq 0 ]] && "$DS/vwr.sh" "$lists" "${trgt}" "$item_pos" &
            
                [[ $ret -eq 2 ]] && "$DS/mngr.sh" edit "$lists" $((item_pos-1)) &
                
            else
                rm -f "$file_tmp"
                "$DS/vwr.sh" "$lists" "${trgt}" "$item_pos" &
            fi
             
    else
        if [ -f "${audiofile_2}" ]; then
        tags="$(eyeD3 "${audiofile_2}")"
        mark="$(grep -o -P '(?<=ISI4I0I).*(?=ISI4I0I)' <<<"${tags}")"
        trgt="$(grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' <<<"${tags}")"
        srce="$(grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)' <<<"${tags}")"
        lwrd="$(grep -o -P '(?<=IWI3I0I).*(?=IPWI3I0I)' <<<"${tags}")"
        pwrds="$(grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' <<<"${tags}")"
        a=0; else a=1; fi
        cmd_move="$DS/ifs/mods/mngr/mngr.sh 'position' '$item_pos' "\"${index_1}\"""
        cmd_words="$DS/add.sh list_words_edit "\"${audiofile_2}\"" F $c"
        cmd_image="$DS/ifs/tls.sh set_image "\"${audiofile_2}\"" sentence"
        cmd_delete="$DS/mngr.sh delete_item "\"${item}\"""
        cmd_play="$DS/ifs/tls.sh play "\"${DM_tlt}/$fname.mp3\"""
        link1="https://translate.google.com/\#$lgt/$lgs/${q_trad}"
        [ -z "${trgt}" ] && trgt="${item}"
        
        dlg_form_2 "$file_tmp"
        ret=$(echo "$?")
        
            if [ ! -f "${DM_tlt}/$fname.mp3" ] && [ $a != 1 ]; then
            rm -f "$file_tmp" & exit 1; fi
            
            if [[ $ret -eq 0 ]] || [[ $ret -eq 2 ]]; then
            
                include "$DS/ifs/mods/add"
                source /usr/share/idiomind/ifs/c.conf
                mark_mod="$(tail -9 < "$file_tmp" | sed -n 1p)"
                type_mod="$(tail -9 < "$file_tmp" | sed -n 2p)"
                trgt_mod="$(clean_1 "$(tail -9 < "$file_tmp" | sed -n 3p)")"
                srce_mod="$(clean_1 "$(tail -9 < "$file_tmp" | sed -n 5p)")"
                tpc_mod="$(tail -9 < "$file_tmp" | sed -n 7p)"
                audio_mod="$(tail -9 < "$file_tmp" | sed -n 8p)"
                if [ $a = 1 ]; then trgt="_ _"; fi
                rm -f "$file_tmp"
                
                if [ "${trgt_mod}" != "${trgt}" ] && [ ! -z "${trgt_mod##+([[:space:]])}" ]; then

                    DT_r=$(mktemp -d "$DT/XXXXXX"); cd "$DT_r"
                    fname_mod="$(nmfile "$trgt_mod")"
                    if [ -f "${DM_tlt}/$fname.mp3" ]; then
                    mv -f "${DM_tlt}/$fname.mp3" "${DM_tlt}/$fname_mod.mp3"
                    else voice "${trgt_mod}" "$DT_r" "${DM_tlt}/$fname_mod.mp3"; fi
                    temp="$(gettext "Processing")..."
                    index edit "${trgt}" "${tpc}" "${trgt_mod}"
                    tags_1 S "${trgt_mod}" "$temp" "${DM_tlt}/$fname_mod.mp3"
                    tags_3 W "$temp" "$temp" "${trgt_mod}" "${DM_tlt}/$fname_mod.mp3"
                    
                    (internet
                    srce_mod=$(translate "${trgt_mod}" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')
                    tags_1 S "${trgt_mod}" "${srce_mod}" "${DM_tlt}/$fname_mod.mp3"
                    source "$DS/default/dicts/$lgt"
                    trgt="${trgt_mod}"; srce="${srce_mod}"
                    r=$((RANDOM%10000))
                    clean_3 "$DT_r" "$r"
                    translate "$(sed '/^$/d' < "$aw")" auto "$lg" | sed 's/,//g' \
                    | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > "$bw"
                    check_grammar_1 "$DT_r" "$r"
                    list_words "$DT_r" "$r"
                    tags_3 W "${lwrds}" "${pwrds}" "${grmrk}" "${DM_tlt}/$fname_mod.mp3"
                    fetch_audio "$aw" "$bw" "$DT_r" "$DM_tls"
                    "$DS/ifs/tls.sh" colorize &
                    [ "$DT_r" ] && rm -fr "$DT_r") &
                    fname="$fname_mod"
                fi

                if [ "$mark" != "$mark_mod" ]; then
                
                    if [ "$mark_mod" = "TRUE" ]; then
                    echo "${trgt_mod}" >> "${DC_tlt}/6.cfg"; else
                    grep -vxF "$trgt_mod" "${DC_tlt}/6.cfg" > "${DC_tlt}/6.cfg.tmp"
                    sed '/^$/d' "${DC_tlt}/6.cfg.tmp" > "${DC_tlt}/6.cfg"
                    rm "${DC_tlt}/6.cfg.tmp"; fi
                    tags_8 S "$mark_mod" "${DM_tlt}/$fname.mp3"
                    "$DS/ifs/tls.sh" colorize &
                fi
                
                if [ -n "${audio_mod}" ]; then
                
                    if [ "${audio_mod}" != "${audiofile_2}" ]; then
                    
                        (internet
                        cp -f "${audio_mod}" "${DM_tlt}/$fname.mp3"
                        eyeD3 --remove-all "${DM_tlt}/$fname.mp3"
                        tags_1 S "${trgt_mod}" "${srce_mod}" "${DM_tlt}/$fname.mp3"
                        source "$DS/default/dicts/$lgt"
                        DT_r=$(mktemp -d "$DT/XXXX"); cd "$DT_r"
                        trgt="${trgt_mod}"; srce="${srce_mod}"
                        r=$((RANDOM%10000))
                        clean_3 "$DT_r" "$r"
                        translate "$(sed '/^$/d' < "$aw")" auto "$lg" | sed 's/,//g' \
                        | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > "$bw"
                        check_grammar_1 "$DT_r" "$r"
                        list_words "$DT_r" "$r"
                        tags_3 W "${lwrds}" "${pwrds}" "${grmrk}" "${DM_tlt}/$fname.mp3"
                        fetch_audio "$aw" "$bw" "$DT_r" "$DM_tls"
                        [ "$DT_r" ] && rm -fr "$DT_r") &
                    fi
                fi
                
                if [ -f "$DT/tmpau.mp3" ]; then
                
                    mv -f "$DT/tmpau.mp3" "${DM_tlt}/$fname.mp3"
                    tags_1 S "${trgt_mod}" "${srce_mod}" "${DM_tlt}/$fname.mp3"
                fi
                
                if [ "${srce_mod}" != "${srce}" ]; then
                
                    tags_5 S "${srce_mod}" "${DM_tlt}/$fname.mp3"
                fi
                
                if [ "$type_mod" = TRUE ]; then
                
                    if [ $(wc -w <<<"$trgt_mod") -lt 3 ]; then
                    mv -f "${DM_tlt}/$fname.mp3" "${DM_tlt}/words/$fname.mp3"
                    tags_1 W "${trgt_mod}" "${srce_mod}" "${DM_tlt}/words/$fname.mp3"
                    dir="$DC_tlt/practice"; if [ "$dir/lsin" ]; then
                    grep -vxF "${trgt_mod}" "$dir/lsin" > "$dir/lsin.tmp"
                    sed '/^$/d' "$dir/lsin.tmp" > "$dir/lsin"; fi
                    grep -vxF "${trgt_mod}" "${DC_tlt}/4.cfg" > "$DT/4.cfg"
                    sed '/^$/d' "$DT/4.cfg" > "${DC_tlt}/4.cfg"
                    rm -f "$DT/4.cfg"
                    echo "${trgt_mod}" >> "${DC_tlt}/3.cfg"; fi
                fi
                
                if [ "${tpc}" != "${tpc_mod}" ]; then

                    mv -f "${audio_mod}" "$DM_tl/${tpc_mod}/$fname.mp3"
                    DT_r=$(mktemp -d "$DT/XXXXXX"); cd "$DT_r"
                    index sentence "${trgt_mod}" "${tpc_mod}" &
                    "$DS/mngr.sh" delete_item_ok "${item}"
                    [ -d $DT_r ] && rm -fr "$DT_r"
                    "$DS/vwr.sh" "$lists" "null" "$item_pos" & exit 1
                fi

                [ -d "$DT/$c" ] && "$DS/add.sh" list_words_edit "$fname" S "$c" "${trgt_mod}" &
            
                [[ $ret -eq 0 ]] && "$DS/vwr.sh" "$lists" "${trgt_mod}" "$item_pos" &
                
                [[ $ret -eq 2 ]] && "$DS/mngr.sh" edit "$lists" $((item_pos-1)) &

            else
                rm -f "$file_tmp"
                "$DS/vwr.sh" "$lists" "${trgt_mod}" "$item_pos" &
            fi
    fi
    [ -f "$file_tmp" ] && rm -f "$file_tmp"
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
