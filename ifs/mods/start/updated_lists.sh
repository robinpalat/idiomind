#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf

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

#while read item; do

    #n=1
    #while [[ $n -le 15 ]]; do
    
        #tpc="tpc$n"
        #list_a="list_a$n"
        #list_b="list_b$n"

        ##if [ -n "${!tpc}" ]; then
        
            ##if [ -f "${!list_a}" ]; then
                ##if grep -Fxo "$item" "${!list_a}"; then
                    ##grep -vxF "$item" "${!list_a}" > "$DT/list_a.tmp"
                    ##sed '/^$/d' "$DT/list_a.tmp" > "${!list_a}"
                    ##if ! grep -Fxo "$item" "${!list_b}"; then
                    ##echo "$item" >> "$DM_tl/${!tpc}/.conf/5.cfg"
                    ##echo "$item" >> "${!list_b}"; printf "${!tpc}%s\n --> $item"
                    ##fi
                ##fi
            ##fi
        ##fi
        
        
        
        #DC_tlt="$DM_tl/${!tpc}/.conf"
        #cd "${DC_tlt}/practice"; rm "${DC_tlt}/5.cfg"
        #m=`cat "${DC_tlt}/6.cfg"`
        #cfg5="${DC_tlt}/5.cfg"
        #img1='/usr/share/idiomind/images/1.png'
        #img2='/usr/share/idiomind/images/2.png'
        #img3='/usr/share/idiomind/images/3.png'
        #img0='/usr/share/idiomind/images/0.png'
        

        #while read -r item; do
        
            #if grep -Fxo "$item" <<<"$items"; then
            #b=TRUE; else b=FALSE; fi
            #if grep -Fxo "$item" <<<"$m"; then
            #item="<b><big>$item</big></b>"; fi
            
            #if awk '++A[$1]==2' ./*.3 |grep -Fxo "$item"; then
                #echo -e "$img3\n$item\n$b" >> "$cfg5"
            #elif awk '++A[$1]==3' ./*.1 |grep -Fxo "$item"; then
                #echo -e "$img1\n$item\n$b" >> "$cfg5"
            #elif awk '++A[$1]==2' ./*.2 |grep -Fxo "$item"; then
                #echo -e "$img2\n$item\n$b" >> "$cfg5"
            #else
                #echo -e "$img0\n$item\n$b" >> "$cfg5"
            #fi
        #done < <(tac "${DC_tlt}/1.cfg")

        #let n++
    #done

#done < "$items"

if [ "$(wc -l < "$items")" -ge 5 ]; then
echo "$(wc -l < "$items") $(gettext "items marked as learnt")" >> "$DT/notify"
fi
fi

if [ "$(date +%u)" = 6 ]; then rm "$LOG"; touch "$LOG"; fi
rm -f "$tmpfile" "$items" "$DT/list_a.tmp"
echo "--lists updated"
exit
