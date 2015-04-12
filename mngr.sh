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

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"

function mkmn() {
    
    cd "$DM_tl"
    [ -d ./images ] && rm -r ./images
    [ -d ./words ] && rm -r ./words
    [ -d ./practice ] && rm -r ./practice
    for i in "$(ls -t -N -d */ | sed 's/\///g')"; do \
    echo "${i%%/}"; done > "$DM_tl/.1.cfg"
    sed -i '/^$/d' "$DM_tl/.1.cfg"
    > "$DC_s/0.cfg"
    
    n=1
    while [[ $n -le $(head -50 < "$DM_tl/.1.cfg" | wc -l) ]]; do
    
        tp=$(sed -n "$n"p "$DM_tl/.1.cfg")
        i=$(<"$DM_tl/$tp/.conf/8.cfg")
        if [ ! "$DM_tl/$tp/.conf/8.cfg" ] || \
        [ ! "$DM_tl/$tp/.conf/0.cfg" ] || \
        [ ! "$DM_tl/$tp/.conf/1.cfg" ] || \
        [ ! "$DM_tl/$tp/.conf/3.cfg" ] || \
        [ ! "$DM_tl/$tp/.conf/4.cfg" ] || \
        [ ! -d "$DM_tl/$tp" ]; then
        i=13; echo "13" > "$DM_tl/$tp/.conf/8.cfg"
        cp -f "$DS/default/tpc.sh" "$DM_tl/$tp/tpc.sh"
        chmod +x "$DM_tl/$tp/tpc.sh";fi
        
        [ ! -f "$DM_tl/$tp/tpc.sh" ] && \
        cp -f "$DS/default/tpc.sh" "$DM_tl/$tp/tpc.sh"
        chmod +x "$DM_tl/$tp/tpc.sh"
        echo "/usr/share/idiomind/images/img.$i.png" >> "$DC_s/0.cfg"
        echo "$tp" >> "$DC_s/0.cfg"
        let n++
    done
    n=1
    while [[ $n -le "$(tail -n+51 < "$DM_tl/.1.cfg" | wc -l)" ]]; do
        f=$(tail -n+51 < "$DM_tl/.1.cfg")
        tp=$(sed -n "$n"p <<<"$f")
        if [ ! -f "$DM_tl/$tp/.conf/8.cfg" ] || \
        [ ! "$DM_tl/$tp/tpc.sh" ] || \
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
        let n++
    done
    exit 1
}

function mark_as_learn() {
    
    include "$DS/ifs/mods/mngr"

    if [ "$tpc" != "$2" ]; then
    msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit; fi
    
    if [ $(wc -l < "$DC_tlt/0.cfg") -le 15 ]; then
    msg "$(gettext "Sorry, you must be at least 15 items.")\n " info & exit; fi

    kill -9 $(pgrep -f "yad --multi-progress ") &
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --form ") &
    kill -9 $(pgrep -f "yad --notebook ") &

    if grep -Fxo "$tpc" < "$DM_tl/.3.cfg"; then
    
        if [ $(< "$DC_tlt/8.cfg") = 7 ]; then
        
            calculate_review
            
            if [ "$RM" -ge 50 ]; then
                echo "8" > "$DC_tlt/8.cfg"
            else
                echo "6" > "$DC_tlt/8.cfg"
            fi
        else
            echo "6" > "$DC_tlt/8.cfg"
        fi
        rm -f "$DC_tlt/7.cfg"
    else
        if [ $(< "$DC_tlt/8.cfg") = 2 ]; then
        
            calculate_review
            
            if [ "$RM" -ge 50 ]; then
                echo "3" > "$DC_tlt/8.cfg"
            else
                echo "1" > "$DC_tlt/8.cfg"
            fi
        else
            echo "1" > "$DC_tlt/8.cfg"
        fi
        rm -f "$DC_tlt/7.cfg"
    fi
    cat "$DC_tlt/0.cfg" | awk '!array_temp[$0]++' > "$DT/0.cfg.tmp"
    sed '/^$/d' "$DT/0.cfg.tmp" > "$DC_tlt/0.cfg"
    rm -f "$DT/*.tmp"
    rm "$DC_tlt/2.cfg" "$DC_tlt/1.cfg"
    touch "$DC_tlt/2.cfg"
    cp -f "$DC_tlt/0.cfg" "$DC_tlt/1.cfg"

    "$DS/mngr.sh" mkmn &

    idiomind topic & exit 1
}

function mark_as_learned() {

    include "$DS/ifs/mods/mngr"

    if [ "$tpc" != "$2" ]; then
    msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit; fi
    
    if [ $(wc -l < "$DC_tlt/0.cfg") -le 15 ]; then
    msg "$(gettext "Sorry, you must be at least 15 items.")\n " info & exit; fi
    
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --form ") &
    kill -9 $(pgrep -f "yad --notebook ") &

    if [ -f "$DC_tlt/9.cfg" ]; then
    
        calculate_review
        
        if [ "$RM" -ge 50 ]; then
            if [ $(wc -l < "$DC_tlt/9.cfg") = 4 ]; then
                echo "_
                _
                _
                $(date +%m/%d/%Y)" > "$DC_tlt/9.cfg"
            else
                echo "$(date +%m/%d/%Y)" >> "$DC_tlt/9.cfg"
            fi
        fi
    else
        echo "$(date +%m/%d/%Y)" > "$DC_tlt/9.cfg"
    fi
    > "$DC_tlt/7.cfg"

    if grep -Fxo "$tpc" "$DM_tl/.3.cfg"; then
        echo "7" > "$DC_tlt/8.cfg"
    else
        echo "2" > "$DC_tlt/8.cfg"
    fi
    rm "$DC_tlt/2.cfg" "$DC_tlt/1.cfg"
    touch "$DC_tlt/1.cfg"
    cp -f "$DC_tlt/0.cfg" "$DC_tlt/2.cfg"
    "$DS/mngr.sh" mkmn &

    idiomind topic & exit 1
}

function delete_item_confirm() {

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
    
        cd "$DC_tlt/practice"
        [ ./fin ] && grep -vxF "$trgt" ./fin > \
        ./fin.tmp && sed '/^$/d' ./fin.tmp > ./fin
        [ ./mcin ] && grep -vxF "$trgt" ./mcin > \
        ./mcin.tmp && sed '/^$/d' ./mcin.tmp > ./mcin
        [ ./lwin ] && grep -vxF "$trgt" ./lwin > \
        ./lwin.tmp && sed '/^$/d' ./lwin.tmp > ./lwin
        [ ./lsin ] && grep -vxF "$trgt" ./lsin > \
        ./lsin.tmp && sed '/^$/d' ./lsin.tmp > ./lsin
        rm ./*.tmp; fi
    
    cd "$DC_tlt"
    [ "./.11.cfg" ] && grep -vxF "$trgt" "./.11.cfg" > \
    "./11.cfg.tmp" && sed '/^$/d' "./11.cfg.tmp" > "./.11.cfg"
    n=0
    while [ $n -le 4 ]; do
         [ -f "./$n.cfg" ] && grep -vxF "$trgt" "./$n.cfg" > \
        "./$n.cfg.tmp" && sed '/^$/d' "./$n.cfg.tmp" > "./$n.cfg"
        let n++
    done
    rm ./*.tmp

    (sleep 1 && rm -f "$DT/ps_lk") & exit 1
    
    rm -f "$DT/ps_lk" & exit 1
}

function delete_item() {

    touch "$DT/ps_lk"
    include "$DS/ifs/mods/mngr"
    source "$DS/ifs/mods/cmns.sh"
    fname="${2}"

    if [ -f "$DM_tlt/words/$fname.mp3" ]; then 
    
    file="$DM_tlt/words/$fname.mp3"
    trgt=$(eyeD3 "$file" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
    msg_2 "$(gettext "Are you sure you want to delete this word?")\n" \
    dialog-question "$(gettext "Yes")" "$(gettext "No")" "$(gettext "Confirm")"

    elif [ -f "$DM_tlt/$fname.mp3" ]; then
    
    file="$DM_tlt/$fname.mp3"
    trgt=$(eyeD3 "$file" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
    msg_2 "$(gettext "Are you sure you want to delete this sentence?")\n" \
    dialog-question "$(gettext "Yes")" "$(gettext "No")" "$(gettext "Confirm")"

    else
    
    trgt="${3}"
    msg_2 "$(gettext "Are you sure you want to delete this item?")\n" \
    dialog-question "$(gettext "Yes")" "$(gettext "No")" "$(gettext "Confirm")"

    fi
    ret=$(echo "$?")
        
    if [ $ret -eq 0 ]; then 
    
        (sleep 0.1 && kill -9 $(pgrep -f "yad --form "))

        [ -f "$file" ] && rm "$file"
        
        if [ -d "$DC_tlt/practice" ]; then
        
        cd "$DC_tlt/practice"
        [ ./fin ] && grep -vxF "$trgt" ./fin > \
        ./fin.tmp && sed '/^$/d' ./fin.tmp > ./fin
        [ ./mcin ] && grep -vxF "$trgt" ./mcin > \
        ./mcin.tmp && sed '/^$/d' ./mcin.tmp > ./mcin
        [ ./lwin ] && grep -vxF "$trgt" ./lwin > \
        ./lwin.tmp && sed '/^$/d' ./lwin.tmp > ./lwin
        [ ./lsin ] && grep -vxF "$trgt" ./lsin > \
        ./lsin.tmp && sed '/^$/d' ./lsin.tmp > ./lsin
        rm ./*.tmp; fi
            
        cd "$DC_tlt"
        [ -f "./.11.cfg" ] && grep -vxF "$trgt" "./.11.cfg" > \
        "./11.cfg.tmp" && sed '/^$/d' "./11.cfg.tmp" > "./.11.cfg"
        n=0
        while [ $n -le 4 ]; do
             [ -f "./$n.cfg" ] && grep -vxF "$trgt" "./$n.cfg" > \
            "./$n.cfg.tmp" && sed '/^$/d' "./$n.cfg.tmp" > "./$n.cfg"
            let n++
        done
        rm ./*.tmp

        (sleep 1 && rm -f "$DT/ps_lk") & exit 1
        
    else
        rm -f "$DT/ps_lk" & exit 1
    fi
}

function delete_topic() {
    
    include "$DS/ifs/mods/mngr"
    
    if [ "$tpc" != "$2" ]; then
    msg "$(gettext "Sorry, this topic is currently not active.")\n " info & exit; fi
    
    if [ "$DT/.n_s_pr" ] && [ "$(sed -n 2p "$DT/.n_s_pr")" = "$tpc" ]; then
    msg "$(gettext "You can not delete at this time. Please try later ")\n" dialog-warning & exit 1; fi
    
    if [ "$DT/.p_" ] && [ "$(sed -n 2p "$DT/.p_")" = "$tpc" ]; then
    msg "$(gettext "You can not delete at this time. Please try later ")\n" dialog-warning & exit 1; fi
    
    msg_2 "$(gettext "Are you sure you want to delete this Topic?")\n" \
    dialog-question "$(gettext "Yes")" "$(gettext "No")" "$(gettext "Confirm")"
    ret=$(echo "$?")
        
        if [ $ret -eq 0 ]; then

            if [ "$DM_tl/$tpc" ] &&  [ -n "$tpc" ]; then
            rm -r "$DM_tl/$tpc"; fi
            rm -f "$DC_s/4.cfg" "$DT/tpe"
            > "$DM_tl/.8.cfg"

            n=0
            while [ $n -le 4 ]; do
                 [ "$DM_tl/.$n.cfg" ] && grep -vxF "$tpc" "$DM_tl/.$n.cfg" > \
                "$DT/cfg.tmp" && sed '/^$/d' "$DT/cfg.tmp" > "$DM_tl/.$n.cfg"
                let n++
            done
            rm "$DT/cfg.tmp"
            
            (sleep 1 && rm -f "$DT/ps_lk") &
            "$DS/mngr.sh" mkmn

            kill -9 $(pgrep -f "yad --list ") &
            kill -9 $(pgrep -f "yad --list ") &
            kill -9 $(pgrep -f "yad --form ") &
            kill -9 $(pgrep -f "yad --notebook ") &
            exit 1
            
        else
            rm -f "$DT/ps_lk" & exit 1
        fi
}

function edit() {

    include "$DS/ifs/mods/mngr"
    wth=650; eht=580
    lgt=$(lnglss $lgtl)
    lgs=$(lnglss $lgsl)
    lists="$2";  item_pos="$3"
    if [ "$lists" = v1 ]; then
    index_1="$DC_tlt/1.cfg"
    index_2="$DC_tlt/2.cfg"
    elif [ "$lists" = v2 ]; then
    index_1="$DC_tlt/2.cfg"
    index_2="$DC_tlt/1.cfg"; fi
    dct="$DS/addons/Dics/cnfg.sh"
    file_tmp=$(mktemp $DT/file_tmp.XXXX)
    edta=$(sed -n 17p ~/.config/idiomind/s/1.cfg)
    tpcs=$(egrep -v "$tpc" < "$DM_tl/.2.cfg" | cut -c 1-40 \
    | tr "\\n" '!' | sed 's/!\+$//g')
    c=$(echo $(($RANDOM%10000)))
    item="$(sed -n "$3"p "$index_1")"
    fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"
    audiofile_2="$DM_tlt/words/$fname.mp3"
    audiofile_1="$DM_tlt/$fname.mp3"
    
    if [ -f "$audiofile_2" ]; then
        
        tags=$(eyeD3 "$audiofile_2")
        trgt=$(grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)' <<<"$tags")
        srce=$(grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)'<<<"$tags")
        fields=$(grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' <<<"$tags" | tr '_' '\n')
        mark=$(grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)' <<<"$tags")
        exm1=$(sed -n 1p <<<"$fields")
        dftn=$(sed -n 2p <<<"$fields")
        ntes=$(sed -n 3p <<<"$fields")
        dlte="$DS/mngr.sh delete_item ${fname}"
        imge="$DS/ifs/tls.sh set_image '$trgt' word"
        sdefn="/usr/share/idiomind/ifs/tls.sh definition '$trgt'"
        
        dlg_form_1 "$file_tmp"
        ret=$(echo "$?")
        
            [ -f "$DT/ps_lk" ] && "$DS/vwr.sh" "$lists" "nll" "$item_pos" && exit 1
            srce_mod=$(tail -12 < "$file_tmp" | sed -n 2p  \
            | sed 's/^ *//; s/ *$//g'| sed ':a;N;$!ba;s/\n/ /g')
            tpc_mod=$(tail -12 < "$file_tmp" | sed -n 3p)
            audio_mod=$(tail -12 < "$file_tmp" | sed -n 4p)
            exm1=$(tail -12 < "$file_tmp" | sed -n 5p)
            dftn=$(tail -12 < "$file_tmp" | sed -n 6p)
            ntes=$(tail -12 < "$file_tmp" | sed -n 7p)
            mark_mod=$(tail -12 < "$file_tmp" | sed -n 8p)
            source /usr/share/idiomind/ifs/c.conf
            include "$DS/ifs/mods/add"
            rm -f "$file_tmp"
            
            if [ "$mark" != "$mark_mod" ]; then
            
                if [ "$mark_mod" = "TRUE" ]; then
                echo "$trgt" >> "$DC_tlt/6.cfg"; else
                grep -vxv "$trgt" "$DC_tlt/6.cfg" > "$DC_tlt/6.cfg.tmp"
                sed '/^$/d' "$DC_tlt/6.cfg.tmp" > "$DC_tlt/6.cfg"
                rm "$DC_tlt/6.cfg.tmp"; fi
                add_tags_8 W "$mark_mod" "$DM_tlt/words/$fname".mp3 >/dev/null 2>&1
            fi
            
            if [ "$audio_mod" != "$audiofile_2" ]; then
            
                eyeD3 --write-images="$DT" "$audiofile_2"
                cp -f "$audio_mod" "$DM_tlt/words/$fname.mp3"
                add_tags_2 W "$trgt" "$srce_mod" "$DM_tlt/words/$fname.mp3" >/dev/null 2>&1
                eyeD3 --add-image $DT/ILLUSTRATION.jpeg:ILLUSTRATION \
                "$DM_tlt/words/$fname.mp3" >/dev/null 2>&1
                [ -d "$DT/idadtmptts" ] && rm -fr "$DT/idadtmptts"
            fi
            
            if [ "$srce_mod" != "$srce" ]; then
            
                add_tags_5 W "$srce_mod" "$audiofile_2" >/dev/null 2>&1
            fi
            
            infm="$(echo $exm1 && echo $dftn && echo $ntes)"
            
            if [ "$infm" != "$fields" ]; then
            
                impr=$(echo "$infm" | tr '\n' '_')
                add_tags_6 W "$impr" "$audiofile_2" >/dev/null 2>&1
                printf "eitm.$tpc.eitm\n" >> "$DC_s/8.cfg" &
            fi

            if [ "$tpc" != "$tpc_mod" ]; then
            
                cp -f "$audio_mod" "$DM_tl/$tpc_mod/words/$fname.mp3"
                index word "$trgt" "$tpc_mod" &
                "$DS/mngr.sh" delete_item_confirm "$fname"
                "$DS/vwr.sh" "$lists" "nll" $item_pos & exit 1
            fi
            
            if [ $ret -eq 2 ]; then
            
                "$DS/mngr.sh" edit "$lists" "$((item_pos-1))" &
                
            else
                "$DS/vwr.sh" "$lists" "$trgt" "$item_pos" &
            fi
            
            exit
            
    elif [ -f "$audiofile_1" ]; then
    
        file="$DM_tlt/$fname.mp3"
        tags=$(eyeD3 "$audiofile_1")
        mark=$(grep -o -P '(?<=ISI4I0I).*(?=ISI4I0I)' <<<"$tags")
        trgt=$(grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' <<<"$tags")
        srce=$(grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)' <<<"$tags")
        lwrd=$(grep -o -P '(?<=IWI3I0I).*(?=IPWI3I0I)' <<<"$tags")
        pwrds=$(grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)' <<<"$tags")
        word_list="$DS/add.sh edit_list_words '$file' F $c"
        edau="/usr/share/idiomind/ifs/tls.sh edit_audio \
        '$DM_tlt/$fname.mp3' '$DM_tlt'"
        lstau="/usr/share/idiomind/ifs/tls.sh play '$DM_tlt/$fname.mp3'"
        dlte="$DS/mngr.sh delete_item ${fname}"
        imge="$DS/ifs/tls.sh set_image '$file' sentence"
        
        dlg_form_2 "$file_tmp"
        ret=$(echo "$?")

            [ -f "$DT/ps_lk" ] && "$DS/vwr.sh" "$lists" "nll" "$item_pos" && exit 1
            mark_mod=$(tail -7 < "$file_tmp" | sed -n 1p)
            trgt_mod=$(tail -7 < "$file_tmp" | sed -n 2p | \
            sed 's/^ *//; s/ *$//g'| sed ':a;N;$!ba;s/\n/ /g')
            srce_mod=$(tail -7 < "$file_tmp" | sed -n 3p | \
            sed 's/^ *//; s/ *$//g'| sed ':a;N;$!ba;s/\n/ /g')
            tpc_mod=$(tail -7 < "$file_tmp" | sed -n 5p)
            audio_mod=$(tail -7 < "$file_tmp" | sed -n 6p)
            source /usr/share/idiomind/ifs/c.conf
            include "$DS/ifs/mods/add"
            rm -f "$file_tmp"
            
            if [ "$trgt_mod" != "$trgt" ]; then
            
                internet
                fname2="$(nmfile "$trgt_mod")"

                sed -i "s/${trgt}/${trgt_mod}/" "$DC_tlt/0.cfg"
                sed -i "s/${trgt}/${trgt_mod}/" "$DC_tlt/1.cfg"
                sed -i "s/${trgt}/${trgt_mod}/" "$DC_tlt/2.cfg"
                sed -i "s/${trgt}/${trgt_mod}/" "$DC_tlt/4.cfg"
                sed -i "s/${trgt}/${trgt_mod}/" "$DC_tlt/.11.cfg"
                sed -i "s/${trgt}/${trgt_mod}/" "$DC_tlt/practice/lsin"
                mv -f "$DM_tlt/$fname.mp3" "$DM_tlt/$fname2.mp3"
                srce_mod=$(translate "$trgt_mod" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')
                add_tags_1 S "$trgt_mod" "$srce_mod" "$DM_tlt/$fname2.mp3" >/dev/null 2>&1
                source "$DS/default/dicts/$lgt"
                
                (
                DT_r=$(mktemp -d $DT/XXXXXX); cd "$DT_r"
                r=$(echo $(($RANDOM%1000)))
                clean_3 "$DT_r $r"
                translate "$(sed '/^$/d' < $aw)" auto $lg | sed 's/,//g' \
                | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > "$bw"
                check_grammar_1 "$DT_r" $r
                list_words "$DT_r" $r
                grmrk=$(sed ':a;N;$!ba;s/\n/ /g' < g.$r)
                lwrds=$(<A.$r)
                pwrds=$(tr '\n' '_' < B.$r)
                add_tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$fname2.mp3" >/dev/null 2>&1
                fetch_audio "$aw" "$bw"
            
                [ "$DT_r" ] && rm -fr "$DT_r"
                ) &
                
                fname="$fname2"
                trgt_mod="$trgt_mod"
            else
                trgt_mod="$trgt"
            fi

            if [ "$mark" != "$mark_mod" ]; then
            
                if [ "$mark_mod" = "TRUE" ]; then
                echo "$trgt_mod" >> "$DC_tlt/6.cfg"; else
                grep -vxv "$trgt_mod" "$DC_tlt/6.cfg" > "$DC_tlt/6.cfg.tmp"
                sed '/^$/d' "$DC_tlt/6.cfg.tmp" > "$DC_tlt/6.cfg"
                rm "$DC_tlt/6.cfg.tmp"; fi
                add_tags_8 S "$mark_mod" "$DM_tlt/$fname.mp3" >/dev/null 2>&1
            fi
            
            if [ -n "$audio_mod" ]; then
            
                if [ "$audio_mod" != "$audiofile_1" ]; then
                
                    internet
                    cp -f "$audio_mod" "$DM_tlt/$fname.mp3"
                    eyeD3 --remove-all "$DM_tlt/$fname.mp3"
                    add_tags_1 S "$trgt_mod" "$srce_mod" "$DM_tlt/$fname.mp3" >/dev/null 2>&1
                    source "$DS/default/dicts/$lgt"
                    
                    (
                    DT_r=$(mktemp -d $DT/XXXXXX); cd "$DT_r"
                    r=$(echo $(($RANDOM%1000)))
                    clean_3 "$DT_r $r"
                    translate "$(sed '/^$/d' < "$aw")" auto $lg | sed 's/,//g' \
                    | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > "$bw"
                    check_grammar_1 "$DT_r" $r
                    list_words "$DT_r" $r
                    grmrk=$(sed ':a;N;$!ba;s/\n/ /g' < g.$r)
                    lwrds=$(< A.$r)
                    pwrds=$(tr '\n' '_' < B.$r)
                    add_tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$fname.mp3" >/dev/null 2>&1
                    fetch_audio "$aw" "$bw"
                    
                    [ "$DT_r" ] && rm -fr "$DT_r"
                    ) &
                fi
            fi
            
            if [ -f "$DT/tmpau.mp3" ]; then
            
                cp -f "$DT/tmpau.mp3" "$DM_tlt/$fname.mp3"
                add_tags_1 S "$trgt_mod" "$srce_mod" "$DM_tlt/$fname.mp3" >/dev/null 2>&1
                rm -f "$DT/tmpau.mp3"
            fi
            
            if [ "$srce_mod" != "$srce" ]; then
            
                add_tags_5 S "$srce_mod" "$audiofile_1"
            fi
            
            if [ "$tpc" != "$tpc_mod" ]; then

                cp -f "$audio_mod" "$DM_tl/$tpc_mod/$fname.mp3"
                DT_r=$(mktemp -d $DT/XXXXXX); cd "$DT_r"
                clean_3 "$DT_r" $(echo $(($RANDOM%1000)))

                while read mp3; do
                echo "$mp3.mp3" >> "$DM_tl/$tpc_mod/5.cfg"
                done < "$aw"
                
                index sentence "$trgt_mod" "$tpc_mod" &
                "$DS/mngr.sh" delete_item_confirm "$fname"
                [ -d $DT_r ] && rm -fr "$DT_r"
                "$DS/vwr.sh" "$lists" "null" $item_pos & exit 1
            fi

            [ -d "$DT/$c" ] && "$DS/add.sh" edit_list_words "$fname" S $c "$trgt_mod" &
            
            if [ $ret -eq 2 ]; then

                "$DS/mngr.sh" edit "$lists" "$((item_pos-1))" &
                
            else
                "$DS/vwr.sh" "$lists" "$trgt_mod" "$item_pos" &
            fi
            
        exit
    fi
} 


function rename_topic() {

    source "$DS/ifs/mods/add/add.sh"
    info2=$(wc -l < "$DM_tl/.1.cfg")
    jlb="${2}"
    jlb="$(clean_2 "$jlb")"
    snm=$(grep -Fxo "$jlb" < "$DM_tl/.1.cfg" | wc -l)
  
    if [ "$DT/.n_s_pr" ] && [ "$(sed -n 2p "$DT/.n_s_pr")" = "$tpc" ]; then
    msg "$(gettext "Unable to rename at this time. Please try later ")\n" dialog-warning & exit 1; fi
        
    if [ "$DT/.p_" ] && [ "$(sed -n 2p "$DT/.p_")" = "$tpc" ]; then
    msg "$(gettext "Unable to rename at this time. Please try later ")\n" dialog-warning & exit 1; fi

    if [ $snm -ge 1 ]; then
    
        jlb="$jlb $snm"
        msg_2 "$(gettext "You already have a topic with the same name.") \n$(gettext "The new it was renamed to\:")\n<b>$jlb</b> \n" info "$(gettext "OK")" "$(gettext "Cancel")"
        ret="$?"
        if [ "$ret" -eq 1 ]; then exit 1; fi
        
    else 
        jlb="$jlb"
    fi
        
    if [ -n "$jlb" ]; then

        mv -f "$DM_tl/$tpc/.11.cfg" "$DT/.11.cfg"
        mv -f "$DM_tl/$tpc" "$DM_tl/$jlb"
        mv -f "$DT/.11.cfg" "$DM_tl/$jlb/.11.cfg"
        
        echo "$jlb" > "$DC_s/4.cfg"
        echo "$jlb" > "$DM_tl/.8.cfg"
        echo "$jlb" > "$DT/tpe"
        
        if grep -Fxo "$tpc" < "$DM_tl/.3.cfg"; then
        echo "$jlb" >> "$DM_tl/.3.cfg"
        echo istll >> "$DC_s/4.cfg" 
        echo istll >> "$DM_tl/.8.cfg"; else
        echo "$jlb" >> "$DM_tl/.2.cfg"
        echo wn >> "$DC_s/4.cfg"
        echo wn >> "$DM_tl/.8.cfg"; fi

        n=1
        while [ $n -le 3 ]; do
             [ -f "$DM_tl/.$n.cfg" ] \
             && grep -vxF "$tpc" "$DM_tl/.$n.cfg" > \
             "$DM_tl/.$n.cfg.tmp" \
             && sed '/^$/d' "$DM_tl/.$n.cfg.tmp" > "$DM_tl/.$n.cfg"
            let n++
        done
        rm "$DM_tl"/.*.tmp

        [ "$DM_tl/$tpc" ] && rm -r "$DM_tl/$tpc"
        [ "$DM_tl/$tpc" ] && rm -r "$DM_tl/$tpc"
        
        "$DS/mngr.sh" mkmn & exit 1
    fi
}

case "$1" in
    mkmn)
    mkmn ;;
    mark_as_learned)
    mark_as_learned "$@" ;;
    mark_as_learn)
    mark_as_learn "$@" ;;
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
