#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf

if [ 1 = 1 ]; then
    LOG="$DC_s/8.cfg"
    tmpfile=$(mktemp "$DT/tps.XXXX")
    items=$(mktemp "$DT/w9.XXXX")
    TOPICS=$(grep -o -P '(?<=tpcs.).*(?=\.tpcs)' "$LOG" \
    | sort | uniq -dc | sort -n -r | head -15 | sed -e 's/^ *//' -e 's/ *$//')
    WORDS=$(grep -o -P '(?<=w9.).*(?=\.w9)' "$LOG" | tr -s '|' '\n' \
    | sort | uniq -dc | sort -n -r | sed 's/ \+/ /g')
    QUOTES=$(grep -o -P '(?<=s9.).*(?=\.s9)' "$LOG" | tr -s '|' '\n' \
    | sort | uniq -dc | sort -n -r | sed 's/ \+/ /g')
    
    n=1
    while [[ $n -le 15 ]]; do
        
        if [[ "$(sed -n "$n"p <<<"$TOPICS" | awk '{print ($1)}')" -ge 3 ]]; then
        
            tpc=$(sed -n "$n"p <<<"$TOPICS" | cut -d " " -f2-)
            
                if [ -d "$DM_tl/$tpc" ]; then
                    echo "$tpc" >> "$tmpfile"
                    declare tpc$n="$tpc"
                    touch "$DM_tl/$tpc/.conf/1.cfg"
                    touch "$DM_tl/$tpc/.conf/2.cfg"
                    declare list_a$n="$DM_tl/$tpc/.conf/1.cfg"
                    declare list_b$n="$DM_tl/$tpc/.conf/2.cfg"
                else 
                    declare tpc$n=""
                fi
        fi
        let n++
    done

    n=1
    while [[ $n -le 100 ]]; do
    
        if [[ $(sed -n "$n"p <<<"$WORDS" | awk '{print ($1)}') -ge 3 ]]; then
            fwk=$(sed -n "$n"p <<<"$WORDS" | awk '{print ($2)}')
            q=1
            while [[ $q -le 15 ]]; do
            
                    tpc="tpc$q"
                    list_a="list_a$q"
                    if [ -n "${!tpc}" ];then
                        if grep -Fxo "$fwk" "${!list_a}"; then
                        echo "$fwk" >> "$items"
                        fi
                    fi
                let q++
            done
        fi
        
        if [[ $(sed -n "$n"p <<<"$QUOTES" | awk '{print ($1)}') -ge 1 ]]; then
            fwk=$(sed -n "$n"p <<<"$QUOTES" | cut -c 4-)
            q=1
            while [[ $q -le 15 ]]; do
            
                    tpc="tpc$q"
                    list_a="list_a$q"
                    if [ -n "${!tpc}" ];then
                        if grep -Fxo "$fwk" "${!list_a}"; then
                        echo "$fwk" >> "$items"
                        fi
                    fi
                let q++
            done
        fi
        
        let n++
    done
    
    sed -i '/^$/d' "$items"
    
    if [ "$(wc -l < "$items")" -gt 0 ]; then

    while read item; do
    
        n=1
        while [[ $n -le 15 ]]; do
        
            tpc="tpc$n"
            list_a="list_a$n"
            list_b="list_b$n"

            if [ -n "${!tpc}" ]; then
            
                if [ -f "${!list_a}" ]; then
                    if grep -Fxo "$item" "${!list_a}"; then
                        grep -vxF "$item" "${!list_a}" > "$DT/list_a.tmp"
                        sed '/^$/d' "$DT/list_a.tmp" > "${!list_a}"
                        if ! grep -Fxo "$item" "${!list_b}"; then
                        echo "$item" >> "$DM_tl/${!tpc}/.conf/5.cfg"
                        echo "$item" >> "${!list_b}"; printf "${!tpc}%s\n --> $item"
                        fi
                    fi
                fi
            fi
            let n++
        done
    
    done < "$items"
    
    if [ "$(wc -l < "$items")" -ge 5 ]; then
    echo "$(wc -l < "$items") $(gettext "items marked as learned")" >> "$DT/notify"
    fi
    fi
    
    if [ "$(date +%u)" = 6 ]; then rm "$LOG"; touch "$LOG"; fi
    rm -f "$tmpfile" "$items" "$DT/list_a.tmp"
    echo "--lists updated"
    exit
fi
