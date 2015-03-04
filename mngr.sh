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

#source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh

if [ "$1" = mkmn ]; then
    
    cd "$DM_tl"
    [[ -d ./images ]] && rm -r ./images
    [[ -d ./words ]] && rm -r ./words
    [[ -d ./practice ]] && rm -r ./practice
    for i in "$(ls -t -N -d */ | sed 's/\///g')"; do echo "${i%%/}"; done > $DM_tl/.cfg.1
    sed -i '/^$/d' $DM_tl/.cfg.1
    [[ -f $DC_s/cfg.0 ]] && mv -f $DC_s/cfg.0 $DC_s/cfg.16
    
    n=1
    while [ $n -le $(cat $DM_tl/.cfg.1 | head -50 | wc -l) ]; do
    
        tp=$(sed -n "$n"p $DM_tl/.cfg.1)
        i=$(cat "$DM_tl/$tp/.conf/cfg.8")
        if [ ! -f "$DM_tl/$tp/.conf/cfg.8" ] || \
        [ ! -f "$DM_tl/$tp/.conf/cfg.0" ] || \
        [ ! -f "$DM_tl/$tp/.conf/cfg.1" ] || \
        [ ! -f "$DM_tl/$tp/.conf/cfg.3" ] || \
        [ ! -f "$DM_tl/$tp/.conf/cfg.4" ] || \
        [ ! -d "$DM_tl/$tp" ]; then
            i=13
            echo "13" > "$DM_tl/$tp/.conf/cfg.8"
            cp -f $DS/default/tpc.sh "$DM_tl/$tp/tpc.sh"
            chmod +x "$DM_tl/$tp/tpc.sh"
        fi
        [ ! -f "$DM_tl/$tp/tpc.sh" ] && \
        cp -f $DS/default/tpc.sh "$DM_tl/$tp/tpc.sh"
        chmod +x "$DM_tl/$tp/tpc.sh"
        echo "/usr/share/idiomind/images/img.$i.png" >> $DC_s/cfg.0
        echo "$tp" >> $DC_s/cfg.0
        let n++
    done
    n=1
    while [ $n -le $(cat $DM_tl/.cfg.1 | tail -n+51 | wc -l) ]; do
        ff=$(cat $DM_tl/.cfg.1 | tail -n+51)
        tp=$(echo "$ff" | sed -n "$n"p)
        if [ ! -f "$DM_tl/$tp/.conf/cfg.8" ] || \
        [ ! -f "$DM_tl/$tp/tpc.sh" ] || \
        [ ! -f "$DM_tl/$tp/.conf/cfg.0" ] || \
        [ ! -f "$DM_tl/$tp/.conf/cfg.1" ] || \
        [ ! -f "$DM_tl/$tp/.conf/cfg.3" ] || \
        [ ! -f "$DM_tl/$tp/.conf/cfg.4" ] || \
        [ ! -d "$DM_tl/$tp" ]; then
            echo '/usr/share/idiomind/images/img.13.png' >> $DC_s/cfg.0
        else
            echo '/usr/share/idiomind/images/img.12.png' >> $DC_s/cfg.0
        fi
        echo "$tp" >> $DC_s/cfg.0
        let n++
    done
    exit 1

elif [ "$1" = edit ]; then
    ttl=$(sed -n 2p $DC_s/cfg.6)
    plg1=$(sed -n 1p $DC_s/cfg.3)
    #cfg.1="$DC_s/cfg.1"
    ti=$(cat "$DC_tlt/cfg.0" | wc -l)
    ni="$DC_tlt/cfg.1"
    bi=$(cat "$DC_tlt/cfg.2" | wc -l)
    nstll=$(grep -Fxo "$tpc" $DM_tl/.cfg.3)
    slct=$(mktemp $DT/slct.XXXX)
    
if ! grep -Fxo "$tpc" $DM_tl/.cfg.3; then
if [ "$ti" -ge 15 ]; then
dd="cmd1
$DS/images/ok.png
$(gettext "Mark as learned")
cmd2
$DS/images/rw.png
$(gettext "Review")
cmd3
$DS/images/rn.png
$(gettext "Rename")
cmd4
$DS/images/dlt.png
$(gettext "Delete")
cmd5
$DS/images/upd.png
$(gettext "Share")
cmd6
$DS/images/pdf.png
$(gettext "To PDF")"
else
dd="cmd3
$DS/images/rn.png
$(gettext "Rename")
cmd4
$DS/images/dlt.png
$(gettext "Delete")
cmd5
$DS/images/upd.png
$(gettext "Share")
cmd6
$DS/images/pdf.png
$(gettext "To PDF")"
fi
else
if [ "$ti" -ge 15 ]; then
dd="cmd1
$DS/images/ok.png
$(gettext "Mark as learned")
cmd2
$DS/images/rw.png
$(gettext "Review")
cmd3
$DS/images/rn.png
$(gettext "Rename")
cmd4
$DS/images/dlt.png
$(gettext "Delete")
cmd6
$DS/images/pdf.png
$(gettext "To PDF")"
else
dd="cmd3
$DS/images/rn.png
$(gettext "Rename")
cmd4
$DS/images/dlt.png
$(gettext "Delete")
cmd6
$DS/images/pdf.png
$(gettext "To PDF")"
fi
fi
    echo "$dd" | yad --list --on-top \
    --expand-column=2 --center --print-column=1 \
    --width=360 --name=idiomind --class=idiomind \
    --height=300 --title="$(gettext "Edit")" --skip-taskbar \
    --window-icon=idiomind --no-headers --hide-column=1 \
    --buttons-layout=end --borders=5 --button=OK:0 \
    --column=id:TEXT --column=icon:IMG --column=Action:TEXT > "$slct"
    ret=$?
    slt=$(cat "$slct")
    if  [[ "$ret" -eq 0 ]]; then
        if echo "$slt" | grep -o "cmd1"; then
            /usr/share/idiomind/mngr.sh mkok-
        elif echo "$slt" | grep -o "cmd2"; then
            /usr/share/idiomind/mngr.sh mklg-
        elif echo "$slt" | grep -o "cmd3"; then
            /usr/share/idiomind/add.sh new_topic name 2
        elif echo "$slt" | grep -o "cmd4"; then
            /usr/share/idiomind/mngr.sh delete_topic
        elif echo "$slt" | grep -o "cmd5"; then
            /usr/share/idiomind/ifs/upld.sh
        elif echo "$slt" | grep -o "cmd6"; then
            /usr/share/idiomind/ifs/tls.sh pdf_doc
        fi
        rm -f "$slct"

    elif [[ "$ret" -eq 1 ]]; then
        exit 1
    fi
    
    
#--------------------------------
elif [ "$1" = mklg- ]; then
    
    include $DS/ifs/mods/mngr
    kill -9 $(pgrep -f "yad --icons")

    nstll=$(grep -Fxo "$tpc" "$DM_tl/.cfg.3")
    if [ -n "$nstll" ]; then
        if [ $(cat "$DC_tlt/cfg.8") = 7 ]; then
        
            calculate_review
            
            if [ "$RM" -ge 50 ]; then
                echo "8" > "$DC_tlt/cfg.8"
            else
                echo "6" > "$DC_tlt/cfg.8"
            fi
        else
            echo "6" > "$DC_tlt/cfg.8"
        fi
        rm -f "$DC_tlt/cfg.7"
    else
        if [ $(cat "$DC_tlt/cfg.8") = 2 ]; then
        
            calculate_review
            
            if [ "$RM" -ge 50 ]; then
                echo "3" > "$DC_tlt/cfg.8"
            else
                echo "1" > "$DC_tlt/cfg.8"
            fi
        else
            echo "1" > "$DC_tlt/cfg.8"
        fi
        rm -f "$DC_tlt/cfg.7"
    fi
    cat "$DC_tlt/cfg.0" | awk '!array_temp[$0]++' > $DT/cfg.0.tmp
    sed '/^$/d' $DT/cfg.0.tmp > "$DC_tlt/cfg.0"
    rm -f $DT/*.tmp
    rm "$DC_tlt/cfg.2" "$DC_tlt/cfg.1"
    touch "$DC_tlt/cfg.2"
    cp -f "$DC_tlt/cfg.0" "$DC_tlt/cfg.1"

    $DS/mngr.sh mkmn &

    idiomind topic & exit 1
    
#--------------------------------
elif [ "$1" = mkok- ]; then
    
    include $DS/ifs/mods/mngr
    kill -9 $(pgrep -f "yad --icons")

    if [ -f "$DC_tlt/cfg.9" ]; then
    
        calculate_review
        
        if [ "$RM" -ge 50 ]; then
            if [ $(cat "$DC_tlt/cfg.9" | wc -l) = 4 ]; then
                echo "_
                _
                _
                $(date +%m/%d/%Y)" > "$DC_tlt/cfg.9"
            else
                echo "$(date +%m/%d/%Y)" >> "$DC_tlt/cfg.9"
            fi
        fi
    else
        echo "$(date +%m/%d/%Y)" > "$DC_tlt/cfg.9"
    fi
    > "$DC_tlt/cfg.7"
    nstll=$(grep -Fxo "$tpc" "$DM_tl/.cfg.3")
    if [ -n "$nstll" ]; then
        echo "7" > "$DC_tlt/cfg.8"
    else
        echo "2" > "$DC_tlt/cfg.8"
    fi
    rm "$DC_tlt/cfg.2" "$DC_tlt/cfg.1"
    touch "$DC_tlt/cfg.1"
    cp -f "$DC_tlt/cfg.0" "$DC_tlt/cfg.2"
    $DS/mngr.sh mkmn &

    idiomind topic & exit 1
    
    
elif [ "$1" = delete_item_confirm ]; then

    touch $DT/ps_lk
    include $DS/ifs/mods/mngr
    source $DS/ifs/mods/cmns.sh
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
        [ -f ./fin ] && grep -vxF "$trgt" ./fin > \
        ./fin.tmp && sed '/^$/d' ./fin.tmp > ./fin
        [ -f ./mcin ] && grep -vxF "$trgt" ./mcin > \
        ./mcin.tmp && sed '/^$/d' ./mcin.tmp > ./mcin
        [ -f ./lwin ] && grep -vxF "$trgt" ./lwin > \
        ./lwin.tmp && sed '/^$/d' ./lwin.tmp > ./lwin
        [ -f ./lsin ] && grep -vxF "$trgt" ./lsin > \
        ./lsin.tmp && sed '/^$/d' ./lsin.tmp > ./lsin
        rm ./*.tmp; fi
    
    cd "$DC_tlt"
    [ -f .cfg.11 ] && grep -vxF "$trgt" ./.cfg.11 > \
    ./cfg.11.tmp && sed '/^$/d' ./cfg.11.tmp > ./.cfg.11
    [ -f cfg.0 ] && grep -vxF "$trgt" ./cfg.0 > \
    ./cfg.0.tmp && sed '/^$/d' ./cfg.0.tmp > ./cfg.0
    [ -f cfg.1 ] && grep -vxF "$trgt" ./cfg.1 > \
    ./cfg.1.tmp && sed '/^$/d' ./cfg.1.tmp > ./cfg.1
    [ -f cfg.2 ] && grep -vxF "$trgt" ./cfg.2 > \
    ./cfg.2.tmp && sed '/^$/d' ./cfg.2.tmp > ./cfg.2
    [ -f cfg.3 ] && grep -vxF "$trgt" ./cfg.3 > \
    ./cfg.3.tmp && sed '/^$/d' ./cfg.3.tmp > ./cfg.3
    [ -f cfg.4 ] && grep -vxF "$trgt" ./cfg.4 > \
    ./cfg.4.tmp && sed '/^$/d' ./cfg.4.tmp > ./cfg.4
    rm ./*.tmp

    (sleep 1 && rm -f $DT/ps_lk) & exit 1
    
    rm -f $DT/ps_lk & exit 1
    
    
elif [ "$1" = delete_item ]; then

    touch $DT/ps_lk
    include $DS/ifs/mods/mngr
    source $DS/ifs/mods/cmns.sh
    fname="${2}"
    
    
    if [ -f "$DM_tlt/words/$fname.mp3" ]; then 
    
        msg_2 "$(gettext "Are you sure you want to delete this word?")\n\n" \
        dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
        
        file="$DM_tlt/words/$fname.mp3"
        trgt=$(eyeD3 "$file" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
        
    elif [ -f "$DM_tlt/$fname.mp3" ]; then
    
        msg_2 "$(gettext "Are you sure you want to delete this sentence?")\n\n" \
        dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
        
        file="$DM_tlt/$fname.mp3"
        trgt=$(eyeD3 "$file" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
        
    else
    
        msg_2 "$(gettext "Are you sure you want to delete this item?")\n\n" \
        dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
        trgt="${3}"
        
    fi
    ret=$(echo "$?")
        
    if [ $ret -eq 0 ]; then 
    
        (sleep 0.1 && kill -9 $(pgrep -f "yad --form "))

        [ -f "$file" ] && rm "$file"
        
        if [ -d "$DC_tlt/practice" ]; then
        
            cd "$DC_tlt/practice"
            [ -f ./fin ] && grep -vxF "$trgt" ./fin > \
            ./fin.tmp && sed '/^$/d' ./fin.tmp > ./fin
            [ -f ./mcin ] && grep -vxF "$trgt" ./mcin > \
            ./mcin.tmp && sed '/^$/d' ./mcin.tmp > ./mcin
            [ -f ./lwin ] && grep -vxF "$trgt" ./lwin > \
            ./lwin.tmp && sed '/^$/d' ./lwin.tmp > ./lwin
            [ -f ./lsin ] && grep -vxF "$trgt" ./lsin > \
            ./lsin.tmp && sed '/^$/d' ./lsin.tmp > ./lsin
            rm ./*.tmp; fi
            
        cd "$DC_tlt"
        [ -f .cfg.11 ] && grep -vxF "$trgt" ./.cfg.11 > \
        ./cfg.11.tmp && sed '/^$/d' ./cfg.11.tmp > ./.cfg.11
        [ -f cfg.0 ] && grep -vxF "$trgt" ./cfg.0 > \
        ./cfg.0.tmp && sed '/^$/d' ./cfg.0.tmp > ./cfg.0
        [ -f cfg.1 ] && grep -vxF "$trgt" ./cfg.1 > \
        ./cfg.1.tmp && sed '/^$/d' ./cfg.1.tmp > ./cfg.1
        [ -f cfg.2 ] && grep -vxF "$trgt" ./cfg.2 > \
        ./cfg.2.tmp && sed '/^$/d' ./cfg.2.tmp > ./cfg.2
        [ -f cfg.3 ] && grep -vxF "$trgt" ./cfg.3 > \
        ./cfg.3.tmp && sed '/^$/d' ./cfg.3.tmp > ./cfg.3
        [ -f cfg.4 ] && grep -vxF "$trgt" ./cfg.4 > \
        ./cfg.4.tmp && sed '/^$/d' ./cfg.4.tmp > ./cfg.4
        rm ./*.tmp

        (sleep 1 && rm -f $DT/ps_lk) & exit 1
        
    else
        rm -f $DT/ps_lk & exit 1
    fi
    
#--------------------------------
elif [ "$1" = delete_topic ]; then
    include $DS/ifs/mods/mngr
    
    msg_2 "$(gettext "Are you sure you want to delete this Topic?")\n\n" \
    dialog-question "$(gettext "Yes")" "$(gettext "Not")" "$(gettext "Confirm")"
    ret=$(echo "$?")
        
        if [ $ret -eq 0 ]; then
        
            [[ -d "$DM_tl/$tpc" ]] && rm -r "$DM_tl/$tpc"
            [[ -d "$DC_tl/$tpc" ]] && rm -r "$DC_tl/$tpc"
            
            > $DC_s/cfg.6; rm $DC_s/cfg.8
            > $DC_tl/.cfg.8

            cd $DC_tl
            [ -f ./.cfg.1 ] && grep -vxF "$tpc" ./.cfg.1 > \
            ./.cfg.1.tmp && sed '/^$/d' ./.cfg.1.tmp > ./.cfg.1
            [ -f ./.cfg.2 ] && grep -vxF "$tpc" ./.cfg.2 > \
            ./.cfg.2.tmp && sed '/^$/d' ./.cfg.2.tmp > ./.cfg.2
            [ -f ./.cfg.3 ] && grep -vxF "$tpc" ./.cfg.3 > \
            ./.cfg.3.tmp && sed '/^$/d' ./.cfg.3.tmp > ./.cfg.3
            [ -f ./.cfg.5 ] && grep -vxF "$tpc" ./.cfg.5 > \
            ./.cfg.5.tmp && sed '/^$/d' ./.cfg.5.tmp > ./.cfg.5
            [ -f ./.cfg.6 ] && grep -vxF "$tpc" ./.cfg.6 > \
            ./.cfg.6.tmp && sed '/^$/d' ./.cfg.6.tmp > ./.cfg.6
            [ -f ./.cfg.7 ] && grep -vxF "$tpc" ./.cfg.7 > \
            ./.cfg.7.tmp && sed '/^$/d' ./.cfg.7.tmp > ./.cfg.7
            rm $DC_tl/.*.tmp 
            
            (sleep 1 && rm -f $DT/ps_lk) &
            $DS/mngr.sh mkmn
            exit 1
            
        else
            rm -f $DT/ps_lk & exit 1
        fi

#--------------------------------
elif [ "$1" = edt ]; then

    include $DS/ifs/mods/mngr
    wth=$(sed -n 7p $DC_s/cfg.18)
    eht=$(sed -n 8p $DC_s/cfg.18)
    dct="$DS/addons/Dics/cnfg.sh"
    cnf=$(mktemp $DT/cnf.XXXX)
    edta=$(sed -n 17p ~/.config/idiomind/s/cfg.1)
    tpcs=$(cat "$DM_tl/.cfg.2" | egrep -v "$tpc" | cut -c 1-40 \
    | tr "\\n" '!' | sed 's/!\+$//g')
    c=$(echo $(($RANDOM%10000)))
    re='^[0-9]+$'
    v="$2"
    fname="$3"
    ff="$4"
    wfile="$DM_tlt/words/$fname.mp3"
    sfile="$DM_tlt/$fname.mp3"
    
    if [ "$v" = v1 ]; then
        ind="$DC_tlt/cfg.1"
        inp="$DC_tlt/cfg.2"
        chk="$(gettext "Mark as learned")"
    elif [ "$v" = v2 ]; then
        ind="$DC_tlt/cfg.2"
        inp="$DC_tlt/cfg.1"
        chk="$(gettext "Review")"
    fi

    if [ -f "$wfile" ]; then
        
        tgs=$(eyeD3 "$wfile")
        TGT=$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')
        SRC=$(echo "$tgs" | grep -o -P '(?<=IWI2I0I).*(?=IWI2I0I)')
        inf=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
        mrk=$(echo "$tgs" | grep -o -P '(?<=IWI4I0I).*(?=IWI4I0I)')
        src=$(echo "$SRC")
        ok=$(echo "FALSE")
        exm1=$(echo "$inf" | sed -n 1p)
        dftn=$(echo "$inf" | sed -n 2p)
        ntes=$(echo "$inf" | sed -n 3p)
        dlte="$DS/mngr.sh delete_item ${fname}"
        imge="$DS/add.sh set_image '$TGT' word"
        sdefn="/usr/share/idiomind/ifs/tls.sh definition '$TGT'"
        
        # ===============================================
        dlg_form_1 $cnf
        ret=$(echo "$?")
        
            [ -f $DT/ps_lk ] && $DS/vwr.sh "$v" "nll" $ff && exit 1
            srce=$(cat $cnf | tail -12 | sed -n 2p  \
            | sed 's/^ *//; s/ *$//g'| sed ':a;N;$!ba;s/\n/ /g')
            topc=$(cat $cnf | tail -12 | sed -n 3p)
            audo=$(cat $cnf | tail -12 | sed -n 4p)
            exm1=$(cat $cnf | tail -12 | sed -n 5p)
            dftn=$(cat $cnf | tail -12 | sed -n 6p)
            ntes=$(cat $cnf | tail -12 | sed -n 7p)
            mrk2=$(cat $cnf | tail -12 | sed -n 8p)
            mrok=$(cat $cnf | tail -12 | sed -n 9p)
            source /usr/share/idiomind/ifs/c.conf
            include $DS/ifs/mods/add
            rm -f $cnf
            
            if [[ "$mrk" != "$mrk2" ]]; then
            
                if [[ "$mrk2" = "TRUE" ]]; then
                    echo "$TGT" >> "$DC_tlt/cfg.6"
                else
                    grep -vxv "$TGT" "$DC_tlt/cfg.6" > "$DC_tlt/cfg.6.tmp"
                    sed '/^$/d' "$DC_tlt/cfg.6.tmp" > "$DC_tlt/cfg.6"
                    rm "$DC_tlt/cfg.6.tmp"
                fi
                add_tags_8 W "$mrk2" "$DM_tlt/words/$fname".mp3 >/dev/null 2>&1
            fi
            
            if [[ "$audo" != "$wfile" ]]; then
            
                eyeD3 --write-images=$DT "$wfile"
                cp -f "$audo" "$DM_tlt/words/$fname.mp3"
                add_tags_2 W "$TGT" "$srce" "$DM_tlt/words/$fname.mp3" >/dev/null 2>&1
                eyeD3 --add-image $DT/ILLUSTRATION.jpeg:ILLUSTRATION \
                "$DM_tlt/words/$fname.mp3" >/dev/null 2>&1
                [[ -d $DT/idadtmptts ]] && rm -fr $DT/idadtmptts
            fi
            
            if [[ "$srce" != "$SRC" ]]; then
                add_tags_5 W "$srce" "$wfile" >/dev/null 2>&1
            fi
            
            infm="$(echo $exm1 && echo $dftn && echo $ntes)"
            
            if [ "$infm" != "$inf" ]; then
            
                impr=$(echo "$infm" | tr '\n' '_')
                add_tags_6 W "$impr" "$wfile" >/dev/null 2>&1
                printf "eitm.$tpc.eitm\n" >> $DC_s/cfg.30 &
            fi

            if [[ "$tpc" != "$topc" ]]; then
            
                cp -f "$audo" "$DM_tl/$topc/words/$fname.mp3"
                index word "$TGT" "$topc" &
                $DS/mngr.sh delete_item_confirm "$fname"
                $DS/vwr.sh "$v" "nll" $ff & exit 1
            fi
            
            if [[ "$mrok" = "TRUE" ]]; then
            
                grep -vxv "$TGT" "$ind" > $DT/tx
                sed '/^$/d' $DT/tx > "$ind"
                rm $DT/tx
                echo "$TGT" >> "$inp"
                printf "okim.1.okim\n" >> $DC_s/cfg.30 &
                $DS/vwr.sh "$v" "nll" $ff & exit 1
            fi
            
            $DS/vwr.sh "$v" "$TGT" $ff & exit 1
    
    
    elif [ -f "$sfile" ]; then
    
        file="$DM_tlt/$fname.mp3"
        tgs=$(eyeD3 "$sfile")
        mrk=$(echo "$tgs" | grep -o -P '(?<=ISI4I0I).*(?=ISI4I0I)')
        tgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
        src=$(echo "$tgs" | grep -o -P '(?<=ISI2I0I).*(?=ISI2I0I)')
        lwrd=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IPWI3I0I)')
        pwrds=$(echo "$tgs" | grep -o -P '(?<=IPWI3I0I).*(?=IPWI3I0I)')
        wrds="$DS/add.sh edit_list_words '$file' F $c"
        edau="/usr/share/idiomind/ifs/tls.sh edit_audio \
        '$DM_tlt/$fname.mp3' '$DM_tlt'"
        dlte="$DS/mngr.sh delete_item ${fname}"
        imge="$DS/add.sh set_image '$tgt' sentence"
        
        # ===============================================
        dlg_form_2 $cnf
        ret=$(echo "$?")
        
            [ -f $DT/ps_lk ] && $DS/vwr.sh "$v" "nll" $ff && exit 1
            mrok=$(cat $cnf | tail -8 | sed -n 1p)
            mrk2=$(cat $cnf | tail -8 | sed -n 2p)
            trgt=$(cat $cnf | tail -8 | sed -n 3p | \
            sed 's/^ *//; s/ *$//g'| sed ':a;N;$!ba;s/\n/ /g')
            srce=$(cat $cnf | tail -8 | sed -n 4p | \
            sed 's/^ *//; s/ *$//g'| sed ':a;N;$!ba;s/\n/ /g')
            topc=$(cat $cnf | tail -8 | sed -n 5p)
            audo=$(cat $cnf | tail -8 | sed -n 6p)
            source /usr/share/idiomind/ifs/c.conf
            include $DS/ifs/mods/add
            rm -f $cnf
            
            if [ "$trgt" != "$tgt" ]; then
            
                internet
                fname2="$(nmfile "$trgt")"
                sed -i "s/${tgt}/${trgt}/" "$DC_tlt/cfg.4"
                sed -i "s/${tgt}/${trgt}/" "$DC_tlt/cfg.1"
                sed -i "s/${tgt}/${trgt}/" "$DC_tlt/cfg.0"
                sed -i "s/${tgt}/${trgt}/" "$DC_tlt/cfg.2"
                sed -i "s/${tgt}/${trgt}/" "$DC_tlt/.cfg.11"
                sed -i "s/${tgt}/${trgt}/" "$DC_tlt/practice/lsin"
                mv -f "$DM_tlt/$fname".mp3 "$DM_tlt/$fname2".mp3
                srce=$(translate "$trgt" $lgt $lgs | sed ':a;N;$!ba;s/\n/ /g')
                add_tags_1 S "$trgt" "$srce" "$DM_tlt/$fname2.mp3" >/dev/null 2>&1
                source $DS/default/dicts/$lgt
                
                (
                DT_r=$(mktemp -d $DT/XXXXXX)
                cd $DT_r
                r=$(echo $(($RANDOM%1000)))
                clean_3 $DT_r $r
                translate "$(cat $aw | sed '/^$/d')" auto $lg | sed 's/,//g' \
                | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw
                check_grammar_1 $DT_r $r
                list_words $DT_r $r
                grmrk=$(cat g.$r | sed ':a;N;$!ba;s/\n/ /g')
                lwrds=$(cat A.$r)
                pwrds=$(cat B.$r | tr '\n' '_')
                add_tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$fname2".mp3 >/dev/null 2>&1
                fetch_audio $aw $bw
            
                [[ -d $DT_r ]] && rm -fr $DT_r
                ) &
                
                fname="$fname2"
                trgt="$trgt"
            else
                trgt="$tgt"
            fi

            if [ "$mrk" != "$mrk2" ]; then
            
                if [ "$mrk2" = "TRUE" ]; then
                    echo "$trgt" >> "$DC_tlt/cfg.6"
                else
                    grep -vxv "$trgt" "$DC_tlt/cfg.6" > "$DC_tlt/cfg.6.tmp"
                    sed '/^$/d' "$DC_tlt/cfg.6.tmp" > "$DC_tlt/cfg.6"
                    rm "$DC_tlt/cfg.6.tmp"
                fi
                add_tags_8 S "$mrk2" "$DM_tlt/$fname.mp3" >/dev/null 2>&1
            fi
            
            if [ -n "$audo" ]; then
            
                if [ "$audo" != "$sfile" ]; then
                
                    internet
                    cp -f "$audo" "$DM_tlt/$fname.mp3"
                    eyeD3 --remove-all "$DM_tlt/$fname.mp3"
                    add_tags_1 S "$trgt" "$srce" "$DM_tlt/$fname.mp3" >/dev/null 2>&1
                    source $DS/default/dicts/$lgt
                    
                    (
                    DT_r=$(mktemp -d $DT/XXXXXX)
                    cd $DT_r
                    r=$(echo $(($RANDOM%1000)))
                    clean_3 $DT_r $r
                    translate "$(cat $aw | sed '/^$/d')" auto $lg | sed 's/,//g' \
                    | sed 's/\?//g' | sed 's/\¿//g' | sed 's/;//g' > $bw
                    check_grammar_1 $DT_r $r
                    list_words $DT_r $r
                    grmrk=$(cat g.$r | sed ':a;N;$!ba;s/\n/ /g')
                    lwrds=$(cat A.$r)
                    pwrds=$(cat B.$r | tr '\n' '_')
                    add_tags_3 W "$lwrds" "$pwrds" "$grmrk" "$DM_tlt/$fname.mp3" >/dev/null 2>&1
                    fetch_audio $aw $bw
                    
                    [ -d $DT_r ] && rm -fr $DT_r
                    ) &
                fi
            fi
            
            if [ -f $DT/tmpau.mp3 ]; then
            
                cp -f $DT/tmpau.mp3 "$DM_tlt/$fname.mp3"
                add_tags_1 S "$trgt" "$srce" "$DM_tlt/$fname.mp3" >/dev/null 2>&1
                rm -f $DT/tmpau.mp3
            fi
            
            if [ "$srce" != "$src" ]; then
            
                add_tags_5 S "$srce" "$sfile"
            fi
            
            if [ "$tpc" != "$topc" ]; then

                cp -f "$audo" "$DM_tl/$topc/$fname.mp3"
                DT_r=$(mktemp -d $DT/XXXXXX); cd $DT_r
                clean_3 $DT_r $(echo $(($RANDOM%1000)))

                while read mp3; do
                    echo "$mp3.mp3" >> "$DM_tl/$topc/cfg.5"
                done < "$aw"
                
                index sentence "$trgt" "$topc" &
                $DS/mngr.sh delete_item_confirm "$fname"
                [ -d $DT_r ] && rm -fr $DT_r
                $DS/vwr.sh "$v" "null" $ff & exit 1
            fi
            
            if [ "$mrok" = "TRUE" ]; then
            
                grep -vxF "$trgt" "$ind" > $DT/tx
                sed '/^$/d' $DT/tx > "$ind"
                rm $DT/tx
                echo "$trgt" >> "$inp"
                printf "okim.1.okim\n" >> $DC_s/cfg.30 &
                
                $DS/vwr.sh "$v" "null" $ff & exit 1
            fi
            
            [ -d "$DT/$c" ] && $DS/add.sh edit_list_words "$fname" S $c "$trgt" &
            $DS/vwr.sh "$v" "$trgt" $ff & exit 1
    fi
fi
  
