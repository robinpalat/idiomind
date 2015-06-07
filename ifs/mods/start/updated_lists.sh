#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[[ -z "$DM" ]] && source /usr/share/idiomind/ifs/c.conf

LOG="$DC_s/8.cfg"
tpclst=$(mktemp "$DT/tps.XXXX")
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
    echo "$(sed -n "$n"p <<<"$TOPICS" | cut -d " " -f2-)" >> "$tpclst"; fi
    let n++
done

n=1
while [[ $n -le 100 ]]; do

    if [[ $(sed -n "$n"p <<<"$WORDS" | awk '{print ($1)}') -ge 3 ]]; then
        fwk=$(sed -n "$n"p <<<"$WORDS" | awk '{print ($2)}')
        echo "$fwk" >> "$items"
    fi
    
    if [[ $(sed -n "$n"p <<<"$QUOTES" | awk '{print ($1)}') -ge 1 ]]; then
        fwk=$(sed -n "$n"p <<<"$QUOTES" | cut -c 4-)
        echo "$fwk" >> "$items"
    fi

    let n++
done

sed -i '/^$/d' "$items"
if [[ `wc -l < "$items"` -gt 0 ]]; then

    while read -r tpc_lst; do

            DC_tlt="$DM_tl/${tpc_lst}/.conf"
            if [[ -f "${DC_tlt}/1.cfg" ]] && [[ -d "${DC_tlt}/practice" ]]; then
                
                cd "${DC_tlt}/practice"; rm "${DC_tlt}/5.cfg"
                touch a.1 a.2 a.3
                s3=`awk '++A[$1]==2' ./*.3`
                s2=`awk '++A[$1]==2' ./*.2`
                s1=`awk '++A[$1]==3' ./*.1`
                m=`cat "${DC_tlt}/6.cfg"`
                cfg5="${DC_tlt}/5.cfg"
                img1='/usr/share/idiomind/images/1.png'
                img2='/usr/share/idiomind/images/2.png'
                img3='/usr/share/idiomind/images/3.png'
                img0='/usr/share/idiomind/images/0.png'
                
                while read -r item; do
                
                    if grep -Fxo "${item}" <<<"${m}">/dev/null 2>&1; then
                    i="<b><big>${item}</big></b>";else i="${item}"; fi
                    if grep -Fxo "${item}" < "$items"; then
                    echo -e "TRUE\n${i}\n$img1" >> "$cfg5"
                    else
                    if grep -Fxo "${item}" <<<"${s3}">/dev/null 2>&1; then
                        echo -e "FALSE\n${i}\n$img3" >> "$cfg5"
                    elif grep -Fxo "${item}" <<<"${s1}">/dev/null 2>&1; then
                        echo -e "FALSE\n${i}\n$img1" >> "$cfg5"
                    elif grep -Fxo "${item}" <<<"${s2}">/dev/null 2>&1; then
                        echo -e "FALSE\n${i}\n$img2" >> "$cfg5"
                    else
                        echo -e "FALSE\n${i}\n$img0" >> "$cfg5"
                    fi
                    fi
            
            done < "${DC_tlt}/1.cfg"
            fi

    done < "$tpclst"
fi

if [ "$(date +%u)" = 6 ]; then rm "$LOG"; touch "$LOG"; fi
rm -f "$tpclst" "$items" "$DT/list_a.tmp"
echo "--lists updated"
exit
