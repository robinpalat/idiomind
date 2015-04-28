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
    
    restr="$(ls "$DS/addons/")"
    cd "$DM_tl"
    [ -d "$DM_tl/images" ] && rm -r "$DM_tl/images"
    [ -d "$DM_tl/words" ] && rm -r "$DM_tl/words"
    for i in "$(ls -t -N -d */ | sed 's/\///g')"; do \
    echo "${i%%/}"; done > "$DM_tl/.1.cfg"
    sed -i '/^$/d' "$DM_tl/.1.cfg"
    > "$DC_s/0.cfg"
    
    n=1
    while [[ $n -le "$(head -100 < "$DM_tl/.1.cfg" | wc -l)" ]]; do
    
        tp=$(sed -n "$n"p "$DM_tl/.1.cfg")
        if ! grep -Fxo "$tp" <<<"$restr"; then
        inx1=$(wc -l < "$DM_tl/$tp/.conf/1.cfg")
        inx2=$(wc -l < "$DM_tl/$tp/.conf/2.cfg")
        tooltips_1="$inx1 / $inx2"
        else tooltips_1=""
        fi
        if [ ! -f "$DM_tl/$tp/.conf/8.cfg" ]; then
        i=13; echo 13 > "$DM_tl/$tp/.conf/8.cfg"
        else i=$(sed -n 1p "$DM_tl/$tp/.conf/8.cfg"); fi
        
        if [ ! "$DM_tl/$tp/.conf/8.cfg" ] || \
        [ ! "$DM_tl/$tp/.conf/0.cfg" ] || \
        [ ! "$DM_tl/$tp/.conf/1.cfg" ] || \
        [ ! "$DM_tl/$tp/.conf/3.cfg" ] || \
        [ ! "$DM_tl/$tp/.conf/4.cfg" ] || \
        [ -z "$i" ] || [ ! -d "$DM_tl/$tp" ]; then
        [ -f "$DC_tlt/8.cfg" ] && stts_=$(< "$DC_tlt/8.cfg")
        if [ "$stts_" != 13 ]; then echo "$stts_" > "$DC_tlt/8.cfg_"; fi
        i=13; echo 13 > "$DM_tl/$tp/.conf/8.cfg";fi
        echo "/usr/share/idiomind/images/img.$i.png" >> "$DC_s/0.cfg"
        echo "$tp" >> "$DC_s/0.cfg"
        echo "$tooltips_1" >> "$DC_s/0.cfg"
        let n++
    done
    n=1
    while [[ $n -le "$(tail -n+101 < "$DM_tl/.1.cfg" | wc -l)" ]]; do
        f=$(tail -n+51 < "$DM_tl/.1.cfg")
        tp=$(sed -n "$n"p <<<"$f")
        if [ ! -f "$DM_tl/$tp/.conf/8.cfg" ]; then
        [ -f "$DC_tlt/8.cfg" ] && stts_=$(< "$DC_tlt/8.cfg")
        if [ "$stts_" != 13 ]; then echo "$stts_" > "$DC_tlt/8.cfg_"; fi
        i=13; echo 13 > "$DM_tl/$tp/.conf/8.cfg"
        else i=$(sed -n 1p "$DM_tl/$tp/.conf/8.cfg"); fi
        if [ ! -f "$DM_tl/$tp/.conf/8.cfg" ] || \
        [ ! "$DM_tl/$tp/.conf/0.cfg" ] || \
        [ ! "$DM_tl/$tp/.conf/1.cfg" ] || \
        [ ! "$DM_tl/$tp/.conf/3.cfg" ] || \
        [ ! "$DM_tl/$tp/.conf/4.cfg" ] || \
        [ ! -d "$DM_tl/$tp" ]; then
            echo '/usr/share/idiomind/images/img.13.png' >> "$DC_s/0.cfg"
        else
            echo '/usr/share/idiomind/images/img.12.png' >> "$DC_s/0.cfg"
        fi
        echo "$tp" >> "$DC_s/0.cfg"
        echo " / " >> "$DC_s/0.cfg"
        let n++
    done
    exit 1
}

mark_to_learn() {
    
    include "$DS/ifs/mods/mngr"
    
    if [ "$tpc" != "$2" ]; then
    msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit; fi
    
    if [ "$(wc -l < "$DC_tlt/0.cfg")" -le 10 ]; then
    msg "$(gettext "Not enough items to perform the operation.")\n " \
    info "$(gettext "Not enough items")" & exit; fi

    if [ "$3" = 1 ]; then
    kill -9 $(pgrep -f "yad --multi-progress ") &
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --form ") &
    kill -9 $(pgrep -f "yad --notebook ") &
    fi

    if [ "$(sed '/^$/d' < "$DC_tlt/1.cfg" | wc -l )" -ge 1 ]; then
        include "$DS/ifs/mods/mngr"
    
        dialog_2
        ret=$(echo $?)
    
        if [[ $ret -eq 3 ]]; then
        
            rm -f "$DC_tlt/7.cfg"
            idiomind topic & exit 1
        fi
    fi

    stts=$(sed -n 1p "$DC_tlt/8.cfg")
    calculate_review "$tpc"
    
    if [[ $((stts%2)) = 0 ]]; then

        echo "6" > "$DC_tlt/8.cfg"
            
    else
        if [[ "$RM" -ge 50 ]]; then
        echo "5" > "$DC_tlt/8.cfg"
        else
        echo "1" > "$DC_tlt/8.cfg"
        fi
    fi
    
    rm -f "$DC_tlt/7.cfg"
    awk '!array_temp[$0]++' < "$DC_tlt/0.cfg" > "$DT/0.cfg.tmp"
    sed '/^$/d' "$DT/0.cfg.tmp" > "$DC_tlt/0.cfg"
    rm -f "$DT"/*.tmp
    rm "$DC_tlt/2.cfg" "$DC_tlt/1.cfg"
    touch "$DC_tlt/2.cfg"
    cp -f "$DC_tlt/0.cfg" "$DC_tlt/1.cfg"

    "$DS/mngr.sh" mkmn &

    [[ "$3" = 1 ]] && idiomind topic &
}

mark_as_learned() {

    include "$DS/ifs/mods/mngr"

    if [ "$tpc" != "$2" ]; then
    msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit; fi
    
    if [ "$(wc -l < "$DC_tlt/0.cfg")" -le 10 ]; then
    msg "$(gettext "Not enough items to perform the operation.")\n " \
    info "$(gettext "Not enough items")" & exit; fi
    
    if [ "$3" = 1 ]; then
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --form ") &
    kill -9 $(pgrep -f "yad --notebook ") &
    fi

    stts=$(sed -n 1p "$DC_tlt/8.cfg")

    if [ ! -f "$DC_tlt/7.cfg" ]; then
        if [ -f "$DC_tlt/9.cfg" ]; then
        
            calculate_review "$tpc"
            steps=$(sed '/^$/d' < "$DC_tlt/9.cfg" | wc -l)
            
            if [[ "$steps" = 4 ]]; then
            
                stts=$((stts+1)); fi
            
            if [[ "$RM" -ge 50 ]]; then
            
                if [[ "$steps" = 6 ]]; then
                echo -e "_\n_\n_\n_\n_\n$(date +%m/%d/%Y)" > "$DC_tlt/9.cfg"
                else
                echo "$(date +%m/%d/%Y)" >> "$DC_tlt/9.cfg"
                fi
            fi
            
        else
            echo "$(date +%m/%d/%Y)" > "$DC_tlt/9.cfg"
        fi

        > "$DC_tlt/7.cfg"
        if [[ $((stts%2)) = 0 ]]; then
        echo "4" > "$DC_tlt/8.cfg"
        else
        echo "3" > "$DC_tlt/8.cfg"
        fi
    fi
    rm "$DC_tlt/2.cfg" "$DC_tlt/1.cfg"
    touch "$DC_tlt/1.cfg"
    cp -f "$DC_tlt/0.cfg" "$DC_tlt/2.cfg"
    "$DS/mngr.sh" mkmn &

    [[ "$3" = 1 ]] && idiomind topic &
    exit 1
}

delete_item_confirm() {

    touch "$DT/ps_lk"
    include "$DS/ifs/mods/mngr"
    source "$DS/ifs/mods/cmns.sh"
    fname="${2}"

    if [ -f "$DM_tlt/words/$fname.mp3" ]; then
    file="$DM_tlt/words/$fname.mp3"
    trgt=$(eyeD3 "$file" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
        
    elif [ -f "$DM_tlt/$fname.mp3" ]; then
    file="$DM_tlt/$fname.mp3"
    trgt=$(eyeD3 "$file" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
    
    else
    trgt="${3}"
    fi

    [ -f "$file" ] && rm "$file"
    
    if [ -d "$DC_tlt/practice" ]; then
        dir="$DC_tlt/practice"
        if [ "$dir/fin" ]; then
        grep -vxF "$trgt" "$dir/fin" > "$dir/fin.tmp"
        sed '/^$/d' "$dir/fin.tmp" > "$dir/fin"; fi
        if [ "$dir/mcin" ]; then
        grep -vxF "$trgt" "$dir/mcin" > "$dir/mcin.tmp"
        sed '/^$/d' "$dir/mcin.tmp" > "$dir/mcin"; fi
        if [ "$dir/lwin" ]; then
        grep -vxF "$trgt" "$dir/lwin" > "$dir/lwin.tmp"
        sed '/^$/d' "$dir/lwin.tmp" > "$dir/lwin" ; fi
        if [ "$dir/lsin" ]; then
        grep -vxF "$trgt" "$dir/lsin" > "$dir/lsin.tmp"
        sed '/^$/d' "$dir/lsin.tmp" > "$dir/lsin"; fi
        if [ "$dir/iin" ]; then
        grep -vxF "$trgt" "$dir/iin" > "$dir/iin.tmp"
        sed '/^$/d' "$dir/iin.tmp" > "$dir/iin"; fi
        rm "$dir"/*.tmp
    fi
    
    if [ "$DC_tlt/.11.cfg" ]; then
    grep -vxF "$trgt" "$DC_tlt/.11.cfg" > "$DC_tlt/11.cfg.tmp"
    sed '/^$/d' "$DC_tlt/11.cfg.tmp" > "$DC_tlt/.11.cfg"; fi
    n=0
    while [ $n -le 4 ]; do
    if [ -f "$DC_tlt/$n.cfg" ]; then
    grep -vxF "$trgt" "$DC_tlt/$n.cfg" > "$DC_tlt/$n.cfg.tmp"
    sed '/^$/d' "$DC_tlt/$n.cfg.tmp" > "$DC_tlt/$n.cfg"; fi
    let n++
    done
    rm "$DC_tlt"/*.tmp
    rm -f "$DT/ps_lk" & exit 1
}

delete_item() {

    touch "$DT/ps_lk"
    include "$DS/ifs/mods/mngr"
    source "$DS/ifs/mods/cmns.sh"
    fname="${2}"

    if [ -f "$DM_tlt/words/$fname.mp3" ]; then 
    
    file="$DM_tlt/words/$fname.mp3"
    trgt=$(eyeD3 "$file" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
    msg_2 "$(gettext "Are you sure you want to delete this word?")\n" \
    gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"

    elif [ -f "$DM_tlt/$fname.mp3" ]; then
    
    file="$DM_tlt/$fname.mp3"
    trgt=$(eyeD3 "$file" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
    msg_2 "$(gettext "Are you sure you want to delete this sentence?")\n" \
    gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"

    else
    trgt="${3}"
    msg_2 "$(gettext "Are you sure you want to delete this item?")\n" \
    gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"

    fi
    ret=$(echo "$?")
        
    if [[ $ret -eq 0 ]]; then 
    
        (sleep 0.1 && kill -9 $(pgrep -f "yad --form "))

        [ -f "$file" ] && rm "$file"
        
        if [ -d "$DC_tlt/practice" ]; then
        dir="$DC_tlt/practice"
        if [ "$dir/fin" ]; then
        grep -vxF "$trgt" "$dir/fin" > "$dir/fin.tmp"
        sed '/^$/d' "$dir/fin.tmp" > "$dir/fin"; fi
        if [ "$dir/mcin" ]; then
        grep -vxF "$trgt" "$dir/mcin" > "$dir/mcin.tmp"
        sed '/^$/d' "$dir/mcin.tmp" > "$dir/mcin"; fi
        if [ "$dir/lwin" ]; then
        grep -vxF "$trgt" "$dir/lwin" > "$dir/lwin.tmp"
        sed '/^$/d' "$dir/lwin.tmp" > "$dir/lwin" ; fi
        if [ "$dir/lsin" ]; then
        grep -vxF "$trgt" "$dir/lsin" > "$dir/lsin.tmp"
        sed '/^$/d' "$dir/lsin.tmp" > "$dir/lsin"; fi
        if [ "$dir/iin" ]; then
        grep -vxF "$trgt" "$dir/iin" > "$dir/iin.tmp"
        sed '/^$/d' "$dir/iin.tmp" > "$dir/iin"; fi
        rm "$dir"/*.tmp; fi
            
        if [ -f "$DC_tlt/.11.cfg" ]; then
        grep -vxF "$trgt" "$DC_tlt/.11.cfg" > "$DC_tlt/11.cfg.tmp"
        sed '/^$/d' "$DC_tlt/11.cfg.tmp" > "$DC_tlt/.11.cfg"; fi
        n=0
        while [[ $n -le 4 ]]; do
        if [ -f "$DC_tlt/$n.cfg" ]; then
        grep -vxF "$trgt" "$DC_tlt/$n.cfg" > "$DC_tlt/$n.cfg.tmp"
        sed '/^$/d' "$DC_tlt/$n.cfg.tmp" > "$DC_tlt/$n.cfg"; fi
        let n++
        done
        rm "$DC_tlt"/*.tmp
    fi
    rm -f "$DT/ps_lk" & exit 1
}

delete_topic() {
    
    include "$DS/ifs/mods/mngr"
    
    if [ "$tpc" != "$2" ]; then
    msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit; fi
    
    if [ -f "$DT/.n_s_pr" ] && [ "$(sed -n 2p "$DT/.n_s_pr")" = "$tpc" ]; then
    msg "$(gettext "You can not delete at this time. Please try later ")\n" dialog-warning & exit 1; fi
    
    if [ -f "$DT/.p_" ] && [ "$(sed -n 2p "$DT/.p_")" = "$tpc" ]; then
    msg "$(gettext "You can not delete at this time. Please try later ")\n" dialog-warning & exit 1; fi
    
    msg_2 "$(gettext "Are you sure you want to delete this Topic?")\n" \
    gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"
    ret=$(echo "$?")
        
        if [[ $ret -eq 0 ]]; then

            if [ -d "$DM_tl/$tpc" ] && [ -n "$tpc" ]; then
            rm -r "$DM_tl/$tpc"; fi
            rm -f "$DC_s/4.cfg" "$DT/tpe"
            > "$DM_tl/.8.cfg"
            n=0
            while [[ $n -le 4 ]]; do
            if [ "$DM_tl/.$n.cfg" ]; then
            grep -vxF "$tpc" "$DM_tl/.$n.cfg" > "$DT/cfg.tmp"
            sed '/^$/d' "$DT/cfg.tmp" > "$DM_tl/.$n.cfg"; fi
            let n++
            done; rm "$DT/cfg.tmp"
            
            kill -9 $(pgrep -f "yad --list ") &
            kill -9 $(pgrep -f "yad --list ") &
            kill -9 $(pgrep -f "yad --form ") &
            kill -9 $(pgrep -f "yad --notebook ") &

            "$DS/mngr.sh" mkmn &
        fi
    
    rm -f "$DT/ps_lk" & exit 1

}

edit() {

    include "$DS/ifs/mods/mngr"
    wth=650; eht=540
    lgt=$(lnglss $lgtl)
    lgs=$(lnglss $lgsl)
    lists="$2";  item_pos="$3"
    if [ "$lists" = 1 ]; then
    index_1="$DC_tlt/1.cfg"
    index_2="$DC_tlt/2.cfg"
    elif [ "$lists" = 2 ]; then
    index_1="$DC_tlt/2.cfg"
    index_2="$DC_tlt/1.cfg"; fi
    dct="$DS/addons/Dics/cnfg.sh"
    file_tmp="$(mktemp "$DT/file_tmp.XXXX")"
    tpcs="$(egrep -v "$tpc" < "$DM_tl/.2.cfg" \
    | awk '{print substr($0,1,40)}' \
    | tr "\\n" '!' | sed 's/!\+$//g')"
    c=$(($RANDOM%10000))
    item="$(sed -n "$3"p "$index_1")"
    fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"
    audiofile_2="$DM_tlt/words/$fname.mp3"
    audiofile_1="$DM_tlt/$fname.mp3"
    
    if [ -f "$audiofile_2" ]; then
        
        file="$DM_tlt/words/$fname.mp3"
        tags="$(eyeD3 "$audiofile_2")"
        trgt="$(grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)' <<<"$tags")"
        srce="$(grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)' <<<"$tags")"
        fields="$(grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' <<<"$tags" | tr '_' '\n')"
        mark="$(grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)' <<<"$tags")"
        exmp="$(sed -n 1p <<<"$fields")"
        dftn="$(sed -n 2p <<<"$fields")"
        note="$(sed -n 3p <<<"$fields")"
        cmd_move="$DS/ifs/mods/mngr/mngr.sh 'position' '$item_pos' '$index_1'"
        cmd_delete="$DS/mngr.sh delete_item $fname"
        cmd_image="$DS/ifs/tls.sh set_image '$file' word"
        cmd_definition="/usr/share/idiomind/ifs/tls.sh definition '$trgt'"
        
        dlg_form_1 "$file_tmp"
        ret=$(echo "$?")
        
            if [ ! -f "$DM_tlt/words/$fname.mp3" ]; then
            "$DS/mngr.sh" edit "$lists" $((item_pos-1)) & exit; fi
            
            srce_mod="$(tail -12 < "$file_tmp" | sed -n 2p  \
            | sed 's/^ *//; s/ *$//g'| sed ':a;N;$!ba;s/\n/ /g')"
            tpc_mod="$(tail -12 < "$file_tmp" | sed -n 3p)"
            audio_mod="$(tail -12 < "$file_tmp" | sed -n 4p)"
            exmp_mod="$(tail -12 < "$file_tmp" | sed -n 5p)"
            dftn_mod="$(tail -12 < "$file_tmp" | sed -n 6p)"
            note_mod="$(tail -12 < "$file_tmp" | sed -n 7p)"
            mark_mod="$(tail -12 < "$file_tmp" | sed -n 9p)"
            source /usr/share/idiomind/ifs/c.conf
            include "$DS/ifs/mods/add"
            rm -f "$file_tmp"
            
            if [ "$mark" != "$mark_mod" ]; then
            
                if [ "$mark_mod" = "TRUE" ]; then
                echo "$trgt" >> "$DC_tlt/6.cfg"; else
                grep -vxv "$trgt" "$DC_tlt/6.cfg" > "$DC_tlt/6.cfg.tmp"
                sed '/^$/d' "$DC_tlt/6.cfg.tmp" > "$DC_tlt/6.cfg"
                rm "$DC_tlt/6.cfg.tmp"; fi
                tags_8 W "$mark_mod" "$DM_tlt/words/$fname".mp3
            fi
            
            if [ "$audio_mod" != "$audiofile_2" ]; then
            
                eyeD3 --write-images="$DT" "$audiofile_2"
                cp -f "$audio_mod" "$DM_tlt/words/$fname.mp3"
                tags_2 W "$trgt" "$srce_mod" "$DM_tlt/words/$fname.mp3"
                eyeD3 --add-image $DT/ILLUSTRATION.jpeg:ILLUSTRATION \
                "$DM_tlt/words/$fname.mp3"
                [ -d "$DT/idadtmptts" ] && rm -fr "$DT/idadtmptts"
            fi
            
            if [ "$srce_mod" != "$srce" ]; then
            
                tags_5 W "$srce_mod" "$audiofile_2"
            fi
            
            infm="$(echo $exmp_mod && echo $dftn_mod && echo $note_mod)"
            
            if [ "$infm" != "$fields" ]; then
            
                impr=$(echo "$infm" | tr '\n' '_')
                tags_6 W "$impr" "$audiofile_2"
                printf "eitm.$tpc.eitm\n" >> "$DC_s/8.cfg" &
            fi

            if [ "$tpc" != "$tpc_mod" ]; then
            
                cp -f "$audio_mod" "$DM_tl/$tpc_mod/words/$fname.mp3"
                index word "$trgt" "$tpc_mod" &
                "$DS/mngr.sh" delete_item_confirm "$fname"
                "$DS/vwr.sh" "$lists" "nll" $item_pos & exit 1
            fi
            
            if [[ $ret -eq 2 ]]; then
            
                "$DS/mngr.sh" edit "$lists" $((item_pos-1)) &
                
            else
                "$DS/vwr.sh" "$lists" "$trgt" "$item_pos" &
            fi
            
            exit
            
    elif [ -f "$audiofile_1" ]; then
    
        file="$DM_tlt/$fname.mp3"
        tags="$(eyeD3 "$audiofile_1")"
        mark="$(grep -o -P '(?<=ISI4I0I).*(?=ISI4I0I)' <<<"$tags")"
        trgt="$(grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' <<<"$tags")"
        srce="$(grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)' <<<"$tags")"
        lwrd="$(grep -o -P '(?<=IWI3I0I).*(?=IPWI3I0I)' <<<"$tags")"
        pwrds="$(grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' <<<"$tags")"
        cmd_move="$DS/ifs/mods/mngr/mngr.sh 'position' '$item_pos' '$index_1'"
        cmd_words="$DS/add.sh edit_list_words '$file' F $c"
        cmd_play="/usr/share/idiomind/ifs/tls.sh play '$DM_tlt/$fname.mp3'"
        cmd_delete="$DS/mngr.sh delete_item ${fname}"
        cmd_image="$DS/ifs/tls.sh set_image '$file' sentence"
        
        dlg_form_2 "$file_tmp"
        ret=$(echo "$?")

            if [ ! -f "$DM_tlt/$fname.mp3" ]; then
            "$DS/mngr.sh" edit "$lists" $((item_pos-1)) & exit; fi
            
            mark_mod="$(tail -7 < "$file_tmp" | sed -n 1p)"
            trgt_mod="$(tail -7 < "$file_tmp" | sed -n 2p | \
            sed 's/^ *//; s/ *$//g'| sed ':a;N;$!ba;s/\n/ /g')"
            srce_mod="$(tail -7 < "$file_tmp" | sed -n 3p | \
            sed 's/^ *//; s/ *$//g'| sed ':a;N;$!ba;s/\n/ /g')"
            tpc_mod="$(tail -7 < "$file_tmp" | sed -n 5p)"
            audio_mod="$(tail -7 < "$file_tmp" | sed -n 6p)"
            source /usr/share/idiomind/ifs/c.conf
            include "$DS/ifs/mods/add"
            rm -f "$file_tmp"
            
            if [ "$trgt_mod" != "$trgt" ] \
            && [ ! -z "${trgt_mod##+([[:space:]])}" ]; then
            
                temp="$(gettext "Processing")..."
                fname_mod="$(nmfile "$trgt_mod")"
                mv -f "$DM_tlt/$fname.mp3" "$DM_tlt/$fname_mod.mp3"
                index edit "${trgt}" "${tpc}" "${trgt_mod}"
                tags_1 S "$trgt_mod" "$temp" "$DM_tlt/$fname_mod.mp3"
                tags_3 W "$temp" " " "$trgt_mod" "$DM_tlt/$fname_mod.mp3"
                
                (internet
                srce_mod=$(translate "$trgt_mod" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')
                tags_1 S "$trgt_mod" "$srce_mod" "$DM_tlt/$fname_mod.mp3"
                source "$DS/default/dicts/$lgt"
                DT_r=$(mktemp -d "$DT/XXXX"); cd "$DT_r"
                trgt="$trgt_mod"; srce="$srce_mod"
                r=$(($RANDOM%1000))
                clean_3 "$DT_r" "$r"
                translate "$(sed '/^$/d' < $aw)" auto "$lg" | sed 's/,//g' \
                | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > "$bw"
                check_grammar_1 "$DT_r" "$r"
                list_words "$DT_r" "$r"
                grmrk=$(sed ':a;N;$!ba;s/\n/ /g' < "./g.$r")
                lwrds=$(< "./A.$r")
                pwrds=$(tr '\n' '_' < "./B.$r")
                tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$fname_mod.mp3"
                fetch_audio "$aw" "$bw" "$DT_r" "$DM_tls"
                [ "$DT_r" ] && rm -fr "$DT_r") &
                fname="$fname_mod"
            fi

            if [ "$mark" != "$mark_mod" ]; then
            
                if [ "$mark_mod" = "TRUE" ]; then
                echo "$trgt_mod" >> "$DC_tlt/6.cfg"; else
                grep -vxv "$trgt_mod" "$DC_tlt/6.cfg" > "$DC_tlt/6.cfg.tmp"
                sed '/^$/d' "$DC_tlt/6.cfg.tmp" > "$DC_tlt/6.cfg"
                rm "$DC_tlt/6.cfg.tmp"; fi
                tags_8 S "$mark_mod" "$DM_tlt/$fname.mp3"
            fi
            
            if [ -n "$audio_mod" ]; then
            
                if [ "$audio_mod" != "$audiofile_1" ]; then
                
                    (internet
                    cp -f "$audio_mod" "$DM_tlt/$fname.mp3"
                    eyeD3 --remove-all "$DM_tlt/$fname.mp3"
                    tags_1 S "$trgt_mod" "$srce_mod" "$DM_tlt/$fname.mp3"
                    source "$DS/default/dicts/$lgt"
                    DT_r=$(mktemp -d "$DT/XXXX"); cd "$DT_r"
                    trgt="$trgt_mod"; srce="$srce_mod"
                    r=$(($RANDOM%1000))
                    clean_3 "$DT_r" "$r"
                    translate "$(sed '/^$/d' < "$aw")" auto $lg | sed 's/,//g' \
                    | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > "$bw"
                    check_grammar_1 "$DT_r" $r
                    list_words "$DT_r" $r
                    grmrk=$(sed ':a;N;$!ba;s/\n/ /g' < "./g.$r")
                    lwrds=$(< "./A.$r")
                    pwrds=$(tr '\n' '_' < "./B.$r")
                    tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$fname.mp3"
                    fetch_audio "$aw" "$bw" "$DT_r" "$DM_tls"
                    [ "$DT_r" ] && rm -fr "$DT_r") &
                fi
            fi
            
            if [ -f "$DT/tmpau.mp3" ]; then
            
                cp -f "$DT/tmpau.mp3" "$DM_tlt/$fname.mp3"
                tags_1 S "$trgt_mod" "$srce_mod" "$DM_tlt/$fname.mp3"
                rm -f "$DT/tmpau.mp3"
            fi
            
            if [ "$srce_mod" != "$srce" ]; then
            
                tags_5 S "$srce_mod" "$audiofile_1"
            fi
            
            if [ "$tpc" != "$tpc_mod" ]; then

                cp -f "$audio_mod" "$DM_tl/$tpc_mod/$fname.mp3"
                DT_r=$(mktemp -d "$DT/XXXXXX"); cd "$DT_r"
               
                index sentence "$trgt_mod" "$tpc_mod" &
                "$DS/mngr.sh" delete_item_confirm "$fname"
                [ -d $DT_r ] && rm -fr "$DT_r"
                "$DS/vwr.sh" "$lists" "null" "$item_pos" & exit 1
            fi

            [ -d "$DT/$c" ] && "$DS/add.sh" edit_list_words "$fname" S $c "$trgt_mod" &
            
            if [[ $ret -eq 2 ]]; then

                "$DS/mngr.sh" edit "$lists" $((item_pos-1)) &
                
            else
                "$DS/vwr.sh" "$lists" "$trgt_mod" "$item_pos" &
            fi
            
    else
    dlg_form_3 "$file_tmp" #####################################################################################
    
    "$DS/vwr.sh" "$lists" "$trgt_mod" $((item_pos-1)) &
            
            
        exit
    fi
} >/dev/null 2>&1


rename_topic() {

    source "$DS/ifs/mods/add/add.sh"
    info2=$(wc -l < "$DM_tl/.1.cfg")
    restr="$(ls "$DS/addons/")"
    jlb="${2}"
    jlb="$(clean_2 "$jlb")"
    if grep -Fxo "$jlb" <<<"$restr"; then jlb="$jlb."; fi
    snm="$(grep -Fxo "$jlb" < "$DM_tl/.1.cfg" | wc -l)"
  
    if [ -f "$DT/.n_s_pr" ] && [ "$(sed -n 2p "$DT/.n_s_pr")" = "$tpc" ]; then
    msg "$(gettext "Unable to rename at this time. Please try later ")\n" \
    dialog-warning "$(gettext "Rename")" & exit 1; fi
        
    if [ -f "$DT/.p_" ] && [ "$(sed -n 2p "$DT/.p_")" = "$tpc" ]; then
    msg "$(gettext "Unable to rename at this time. Please try later ")\n" \
    dialog-warning "$(gettext "Rename")" & exit 1; fi

    if [[ ${#jlb} -gt 55 ]]; then
    msg "$(gettext "Sorry, the new name is too long.")\n" \
    info "$(gettext "Rename")" & exit 1; fi

    if [ "$snm" -ge 1 ]; then
    
        jlb="$jlb $snm"
        msg_2 "$(gettext "Another topic with the same name already exist.") \n$(gettext "Name for the new topic\:")\n<b>$jlb</b> \n" info "$(gettext "OK")" "$(gettext "Cancel")"
        ret="$?"
        if [[ $ret -eq 1 ]]; then exit 1; fi
        
    else 
        jlb="$jlb"
    fi
        
    if [ -n "$jlb" ]; then

        mv -f "$DM_tl/$tpc/.11.cfg" "$DT/.11.cfg"
        mv -f "$DM_tl/$tpc" "$DM_tl/$jlb"
        mv -f "$DT/.11.cfg" "$DM_tl/$jlb/.11.cfg"
        echo "$jlb" > "$DC_s/4.cfg"
        echo "$jlb" > "$DM_tl/.8.cfg"
        echo "$jlb" >> "$DM_tl/.1.cfg"
        echo "$jlb" >> "$DM_tl/.2.cfg"
        echo "$jlb" > "$DT/tpe"
        echo '0' >> "$DC_s/4.cfg" 
        echo '0' >> "$DM_tl/.8.cfg"
        
        n=1
        while [[ $n -le 3 ]]; do
        if [ -f "$DM_tl/.$n.cfg" ]; then
        grep -vxF "$tpc" "$DM_tl/.$n.cfg" > "$DM_tl/.$n.cfg.tmp"
        sed '/^$/d' "$DM_tl/.$n.cfg.tmp" > "$DM_tl/.$n.cfg"; fi
        let n++
        done
        rm "$DM_tl"/.*.tmp
        [ -d "$DM_tl/$tpc" ] && rm -r "$DM_tl/$tpc"
        
        "$DS/mngr.sh" mkmn & exit 1
    fi
}

case "$1" in
    mkmn)
    mkmn ;;
    mark_as_learned)
    mark_as_learned "$@" ;;
    mark_to_learn)
    mark_to_learn "$@" ;;
    delete_item_confirm)
    delete_item_confirm "$@" ;;
    delete_item)
    delete_item "$@" ;;
    delete_topic)
    delete_topic "$@" ;;
    edit)
    edit "$@" ;;
    rename_topic)
    rename_topic "$@" ;;
esac
