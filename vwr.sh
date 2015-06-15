#!/bin/bash
# -*- ENCODING: UTF-8 -*-
#
echo "_" >> "$DT/stats.tmp" &
[[ $1 = 1 ]] && index="${DC_tlt}/1.cfg" && item_name=`sed 's/<[^>]*>//g' <<<"${3}"`
[[ $1 = 2 ]] && index="${DC_tlt}/2.cfg" && item_name=`sed 's/<[^>]*>//g' <<<"${2}"`

re='^[0-9]+$'; index_pos="$3"
if ! [[ ${index_pos} =~ $re ]]; then
index_pos=`grep -Fxon -m 1 "${item_name}" "${index}" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
nll="_"; fi

item=`sed -n ${index_pos}p "${index}"`
pos=`grep -Fon -m 1 "trgt={${item}}" "$DC_tlt/.11.cfg" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
item=`sed -n ${pos}p "$DC_tlt/.11.cfg" |sed 's/},/}\n/g'`

type=`grep -oP '(?<=type={).*(?=})' <<<"${item}"`
trgt=`grep -oP '(?<=trgt={).*(?=})' <<<"${item}"`
srce=`grep -oP '(?<=srce={).*(?=})' <<<"${item}"`
exmp=`grep -oP '(?<=exmp={).*(?=})' <<<"${item}"`
defn=`grep -oP '(?<=defn={).*(?=})' <<<"${item}"`
note=`grep -oP '(?<=note={).*(?=})' <<<"${item}"`
grmr=`grep -oP '(?<=grmr={).*(?=})' <<<"${item}"`
tag=`grep -oP '(?<=tag={).*(?=})' <<<"${item}"`
mark=`grep -oP '(?<=mark={).*(?=})' <<<"${item}"`
lwrd=`grep -oP '(?<=wrds={).*(?=})' <<<"${item}" |tr '_' '\n'`
id=`grep -oP '(?<=id=\[).*(?=\])' <<<"${item}"`

cmd_listen="play '${DM_tlt}/$id.mp3'"
[ "$mark" = TRUE ] && trgt="<b>$trgt</b>" && grmr="<b>$grmr</b>"

if [ ${type} = 1 ]; then word_view
elif [ ${type} = 2 ]; then sentence_view
fi
ret=$?

    if [[ $ret -eq 4 ]]; then
        "$DS/mngr.sh" edit "$1" ${index_pos}
    
    elif [[ $ret -eq 2 ]]; then
    
        if [[ ${index_pos} = 1 ]]; then
        
        item=`tail -n 1 < "${index}"`
        [[ $1 = 1 ]] && "$DS/vwr.sh" "$1" "$nll" "${item}"
        [[ $1 = 2 ]] && "$DS/vwr.sh" "$1" "${item}"
        else
        
        ff=$((index_pos-1))
        "$DS/vwr.sh" "$1" "$nll" $ff &
        fi
    
    elif [[ $ret -eq 3 ]]; then
    
        ff=$((index_pos+1))
        "$DS/vwr.sh" "$1" "$nll" $ff &
    
    else 
        echo -e ".vwr.`wc -l < "$DT/stats.tmp"`.vwr." >> "$DC_s/8.cfg"
        rm -f "$DT/stats.tmp" & exit 1
    fi
    
exit
