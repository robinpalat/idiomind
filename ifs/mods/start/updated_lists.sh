#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf

if [ TRUE = TRUE ]; then

    LOG="$DC_s/8.cfg"
    TPS=$(mktemp $DT/tps.XXXX)
    items=$(mktemp $DT/w9.XXXX)
    TPCS=$(grep -o -P '(?<=tpcs.).*(?=\.tpcs)' < "$LOG" \
    | sort | uniq -dc | sort -n -r | head -3 | sed -e 's/^ *//' -e 's/ *$//')
    W9INX=$(grep -o -P '(?<=w9.).*(?=\.w9)' < "$LOG" | tr -s ';' '\n' \
    | sort | uniq -dc | sort -n -r | sed 's/ \+/ /g')
    tpc1=$(sed -n 1p <<<"$TPCS" | cut -d " " -f2-)
    echo "$tpc1" > "$TPS"
    tpc1=$(sed -n 1p $TPS)
    if [ "$(sed -n 2p <<<"$TPCS" | awk '{print ($1)}')" -ge 3 ]; then
    tpc2=$(sed -n 2p <<<"$TPCS" | cut -d " " -f2-)
    echo "$tpc2" >> "$TPS"; tpc2=$(sed -n 2p $TPS); fi
    if [ "$(sed -n 3p <<<"$TPCS" | awk '{print ($1)}')" -ge 3 ]; then
    tpc3=$(sed -n 3p <<<"$TPCS" | cut -d " " -f2-)
    echo "$tpc3" >> "$TPS"; tpc3=$(sed -n 3p $TPS); fi

    if [ -n "$tpc3" ];then
    [ -f "$DM_tl/$tpc1/.conf/1.cfg" ] && list_a1="$DM_tl/$tpc1/.conf/1.cfg"
    [ -f "$DM_tl/$tpc2/.conf/1.cfg" ] && list_a2="$DM_tl/$tpc2/.conf/1.cfg"
    [ -f "$DM_tl/$tpc3/.conf/1.cfg" ] && list_a3="$DM_tl/$tpc3/.conf/1.cfg"
    touch "$DM_tl/$tpc1/.conf/2.cfg" && list_b1="$DM_tl/$tpc1/.conf/2.cfg"
    touch "$DM_tl/$tpc2/.conf/2.cfg" && list_b2="$DM_tl/$tpc2/.conf/2.cfg"
    touch "$DM_tl/$tpc3/.conf/2.cfg" && list_b3="$DM_tl/$tpc3/.conf/2.cfg"
    elif [ -n "$tpc2" ];then
    [ -f "$DM_tl/$tpc1/.conf/1.cfg" ] && list_a1="$DM_tl/$tpc1/.conf/1.cfg"
    [ -f "$DM_tl/$tpc2/.conf/1.cfg" ] && list_a2="$DM_tl/$tpc2/.conf/1.cfg"
    touch "$DM_tl/$tpc1/.conf/2.cfg" && list_b1="$DM_tl/$tpc1/.conf/2.cfg"
    touch "$DM_tl/$tpc2/.conf/2.cfg" && list_b2="$DM_tl/$tpc2/.conf/2.cfg"
    elif [ -n "$tpc1" ];then
    [ -f "$DM_tl/$tpc1/.conf/1.cfg" ] && list_a1="$DM_tl/$tpc1/.conf/1.cfg"
    touch "$DM_tl/$tpc1/.conf/2.cfg" && list_b1="$DM_tl/$tpc1/.conf/2.cfg"
    fi

    n=1
    while [ $n -le 15 ]; do
        if [[ $(sed -n "$n"p <<<"$W9INX" | awk '{print ($1)}') -ge 3 ]]; then
        
            fwk=$(sed -n "$n"p <<<"$W9INX" | awk '{print ($2)}')
            if [ -n "$tpc3" ];then
                if grep -o "$fwk" < "$list_a1"; then
                    echo "$fwk" >> "$items"
                    
                elif grep -o "$fwk" < "$list_a2"; then
                    echo "$fwk" >> "$items"
                    
                elif grep -o "$fwk" < "$list_a3"; then
                    echo "$fwk" >> "$items"
                fi
            elif [ -n "$tpc2" ]; then
                if grep -o "$fwk" < "$list_a1"; then
                    echo "$fwk" >> "$items"
                    
                elif grep -o "$fwk" < "$list_a2"; then
                    echo "$fwk" >> "$items"
                fi
            elif [ -n "$tpc1" ]; then
                if grep -o "$fwk" < "$list_a1"; then
                echo "$fwk" >> "$items"
                fi
            fi
        fi
        let n++
    done
    
    sed -i '/^$/d' "$items"
    
    if [ $(wc -l < "$items") -gt 0 ]; then
    notify-send -i idiomind "$(gettext "Update lists")" \
    "$(wc -l < "$items") $(gettext "item(s) marked as learned")" -t 8000

    while read item; do

        if [ -n "$tpc3" ];then
            if [ -f "$list_a1" ]; then
                if grep -o "$item" < "$list_a1"; then
                    grep -vxF "$item" "$list_a1" > "$DT/list_a.tmp"
                    sed '/^$/d' "$DT/list_a.tmp" > "$list_a1"
                    echo "$item" >> "$list_b1"; printf "$tpc1%s\n --> $item"
                fi
            fi
            if [ -f "$list_a2" ]; then
                if grep -o "$item" < "$list_a2"; then
                    grep -vxF "$item" "$list_a2" > "$DT/list_a.tmp"
                    sed '/^$/d' "$DT/list_a.tmp" > "$list_a2"
                    echo "$item" >> "$list_b2"; printf "$tpc2%s\n --> $item"
                fi
            fi
            if [ -f "$list_a3" ]; then
                if grep -o "$item" < "$list_a3"; then
                    grep -vxF "$item" "$list_a3" > "$DT/list_a.tmp"
                    sed '/^$/d' "$DT/list_a.tmp" > "$list_a3"
                    echo "$item" >> "$list_b3"; printf "$tpc3%s\n --> $item"
                fi
            fi
        elif [ -n "$tpc2" ];then
            if [ -f "$list_a1" ]; then
                if grep -o "$item" < "$list_a1"; then
                    grep -vxF "$item" "$list_a1" > "$DT/list_a.tmp"
                    sed '/^$/d' "$DT/list_a.tmp" > "$list_a1"
                    echo "$item" >> "$list_b1"; printf "$tpc1%s\n --> $item"
                fi
            fi
            if [ -f "$list_a2" ]; then
                if grep -o "$item" < "$list_a2"; then
                    grep -vxF "$item" "$list_a2" > "$DT/list_a.tmp"
                    sed '/^$/d' "$DT/list_a.tmp" > "$list_a2"
                    echo "$item" >> "$list_b2"; printf "$tpc2%s\n --> $item"
                fi
            fi
        elif [ -n "$tpc1" ];then
            if [ -f "$list_a1" ]; then
                if grep -o "$item" < "$list_a1"; then
                    grep -vxF "$item" "$list_a1" > "$DT/list_a.tmp"
                    sed '/^$/d' "$DT/list_a.tmp" > "$list_a1"
                    echo "$item" >> "$list_b1"; printf "$tpc1%s\n --> $item"
                fi
            fi
        fi
        
    done < "$items"
    fi
    rm -f "$TPS" "$items"
    exit 0
fi
