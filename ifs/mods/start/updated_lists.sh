#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
LOG="$DC_s/log"
tpclst=$(mktemp "$DT/tps.XXXX")
items=$(mktemp "$DT/w9.XXXX")
TOPICS=$(grep -o -P '(?<=tpc.).*(?=\.tpc)' "${LOG}" \
| sort | uniq -dc | sort -n -r | head -15 | sed -e 's/^ *//' -e 's/ *$//')
WORDS=$(grep -o -P '(?<=w9.).*(?=\.w9)' "${LOG}" |tr '|' '\n' \
| sort | uniq -dc | sort -n -r | sed 's/ \+/ /g')
QUOTES=$(grep -o -P '(?<=s9.).*(?=\.s9)' "${LOG}" |tr '|' '\n' \
| sort | uniq -dc | sort -n -r | sed 's/ \+/ /g')

n=1
while [ ${n} -le 15 ]; do

if [[ "$(sed -n "$n"p <<<"${TOPICS}" |awk '{print ($1)}')" -ge 3 ]]; then
echo "$(sed -n "$n"p <<<"${TOPICS}" |cut -d " " -f2-)" >> "${tpclst}"; fi
let n++
done

n=1
while [ ${n} -le 100 ]; do

if [[ $(sed -n "$n"p <<<"${WORDS}" | awk '{print ($1)}') -ge 3 ]]; then
    fwk=$(sed -n "$n"p <<<"${WORDS}" | awk '{print ($2)}')
    [ -n "${fwk}" ] && echo "${fwk}" >> "${items}"
fi
if [[ $(sed -n "$n"p <<<"${QUOTES}" | awk '{print ($1)}') -ge 1 ]]; then
    fwk=$(sed -n "$n"p <<<"${QUOTES}" | cut -c 4-)
    [ -n "${fwk}" ] && echo "${fwk}" >> "${items}"
fi
let n++
done

sed -i '/^$/d' "${items}"
if [ `wc -l < "${items}"` -gt 0 ]; then

while read -r tpc_lst; do

    DC_tlt="$DM_tl/${tpc_lst}/.conf"
    if [ -f "${DC_tlt}/1.cfg" ] && [ -d "${DC_tlt}/practice" ]; then
    if [[ $(grep -o set_1=\"[^\"]* "${DC_tlt}/id.cfg" |grep -o '[^"]*$') = TRUE ]]; then

    rm "${DC_tlt}/5.cfg"
    cd "${DC_tlt}/practice"
    cfg5="${DC_tlt}/5.cfg"
    cfg6=`cat "${DC_tlt}/6.cfg"`
    cd "$DC_tlt/practice"
    log3="$(cat ./log3 ./d.3)"
    log2="$(cat ./log2 ./d.2)"
    log1="$(cat ./log1 ./d.1)"
    img1='/usr/share/idiomind/images/1.png'
    img2='/usr/share/idiomind/images/2.png'
    img3='/usr/share/idiomind/images/3.png'
    img0='/usr/share/idiomind/images/0.png'
    
    while read -r item; do
    
        if grep -Fxo "${item}" <<<"${cfg6}">/dev/null 2>&1; then
        i="<b><big>${item}</big></b>";else i="${item}"; fi
        if grep -Fxo "${item}" < "$items"; then
            echo -e "TRUE\n${i}\n$img1" >> "${cfg5}"
            else
            if grep -Fxo "${item}" <<<"${log3}">/dev/null 2>&1; then
                echo -e "FALSE\n${i}\n$img3" >> "${cfg5}"
            elif grep -Fxo "${item}" <<<"${log1}">/dev/null 2>&1; then
                echo -e "FALSE\n${i}\n$img1" >> "${cfg5}"
            elif grep -Fxo "${item}" <<<"${log2}">/dev/null 2>&1; then
                echo -e "FALSE\n${i}\n$img2" >> "${cfg5}"
            else
                echo -e "FALSE\n${i}\n$img0" >> "${cfg5}"
            fi
        fi
    done < "${DC_tlt}/1.cfg"
    cd ~/
    
    fi
    fi

done < "${tpclst}"
fi
cd /
if [ "$(date +%u)" = 6 ]; then rm "$LOG"; touch "$LOG"; fi
rm -f "$tpclst" "$items" "$DT/list_a.tmp"
echo "--lists updated"

exit
