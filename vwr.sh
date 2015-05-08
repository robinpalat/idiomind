#!/bin/bash
# -*- ENCODING: UTF-8 -*-

echo "_" >> "$DT/stats.tmp" &
[[ $1 = 1 ]] && index="$DC_tlt/1.cfg"
[[ $1 = 2 ]] && index="$DC_tlt/2.cfg"
re='^[0-9]+$'
item_name="$2"
index_pos="$3"
listen="$(gettext "Listen")"

if ! [[ $index_pos =~ $re ]]; then
index_pos=$(grep -Fxon "$item_name" < "$index" \
| sed -n 's/^\([0-9]*\)[:].*/\1/p')
nll=" "; fi

item="$(sed -n "$index_pos"p "$index")"
if [ -z "$item" ]; then
item="$(sed -n 1p "$index")"
index_pos=1; fi

fname="$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)"
align=left
fs=22; bs=20

if [ -f "$DM_tlt/words/$fname.mp3" ]; then
    cmd_listen="play '$DM_tlt/words/$fname.mp3'"
    word_view

elif [ -f "$DM_tlt/$fname.mp3" ]; then
    cmd_listen="'$DS/ifs/tls.sh' 'listen_sntnc' '$fname'"
    sentence_view
    
elif [ -f "$DM_tlt/_$fname.mp3" ]; then
    cmd_listen="'$DS/ifs/tls.sh' 'listen_sntnc' '_$fname'"
    missing "$index_pos"
    
else
    missing "$index_pos"
fi
    ret=$?
        
    if [[ $ret -eq 4 ]]; then
    "$DS/mngr.sh" edit "$1" "$index_pos"
    
    elif [[ $ret -eq 2 ]]; then
    ff=$((index_pos-1))
    "$DS/vwr.sh" "$1" "$nll" $ff &
    
    elif [[ $ret -eq 3 ]]; then
    ff=$((index_pos+1))
    "$DS/vwr.sh" "$1" "$nll" $ff &
    
    elif [[ $ret -eq 5 ]]; then
    DT_r=$(mktemp -d "$DT/XXXXXX"); cd "$DT_r"
    item=$(sed -n "$index_pos"p "$index")
    "$DS/add.sh" new_items "$DT_r" 2 "$item" & exit 1
    
    #elif [[ $ret -eq 6 ]]; then
    #DT_r=$(mktemp -d "$DT/XXXXXX"); cd "$DT_r"
    #item=$(sed -n "$index_pos"p "$index")
    #"$DS/add.sh" new_items "$DT_r" 2 "$item" & exit 1
    
    else 
    printf "vwr.$(wc -l < "$DT/stats.tmp").vwr\n" >> "$DC_s/8.cfg"
    rm -f "$DT/stats.tmp" & exit 1
    fi
    
exit
