#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#
echo "_" >> "$DT/stats.tmp" &
[[ $1 = 1 ]] && index="${DC_tlt}/1.cfg" \
&& item_name=`sed 's/<[^>]*>//g' <<<"${3}"`
[[ $1 = 2 ]] && index="${DC_tlt}/2.cfg" \
&& item_name=`sed 's/<[^>]*>//g' <<<"${2}"`
re='^[0-9]+$'
index_pos="$3"
listen="$(gettext "Listen")"
if ! [[ $index_pos =~ $re ]]; then
index_pos=$(grep -Fxon "${item_name}" < "${index}" \
| sed -n 's/^\([0-9]*\)[:].*/\1/p')
nll=" "; fi
item="$(sed -n "$index_pos"p "${index}" |sed 's/<[^>]*>//g')"

if [ -z "${item}" ]; then
item="$(sed -n 1p "${index}")"
index_pos=1; fi
fname="$(echo -n "${item}" | md5sum | rev | cut -c 4- | rev)"
align=left
fs=22; bs=20

if [ -f "${DM_tlt}/words/${fname}.mp3" ]; then
cmd_listen="play '${DM_tlt}/words/${fname}.mp3'"
word_view
elif [ -f "${DM_tlt}/${fname}.mp3" ]; then
cmd_listen="'$DS/ifs/tls.sh' 'listen_sntnc' '${fname}'"
sentence_view
else
cmd_listen="'$DS/ifs/tls.sh' 'listen_sntnc' '${fname}'"
sentence_view
fi
ret=$?

    if [[ $ret -eq 4 ]]; then
    "$DS/mngr.sh" edit "$1" "$index_pos"
    
    elif [[ $ret -eq 2 ]]; then
    
        if [[ $index_pos = 1 ]]; then
        item=`tail -n 1 < "${index}"`
        "$DS/vwr.sh" "$1" "${item}" &
        else
        ff=$((index_pos-1))
        "$DS/vwr.sh" "$1" "$nll" $ff &
        fi
    
    elif [[ $ret -eq 3 ]]; then
    ff=$((index_pos+1))
    "$DS/vwr.sh" "$1" "$nll" $ff &
    
    else 
    printf "vwr.$(wc -l < "$DT/stats.tmp").vwr\n" >> "$DC_s/8.cfg"
    rm -f "$DT/stats.tmp" & exit 1
    fi
    
exit
