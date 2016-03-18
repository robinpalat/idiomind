#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ ${1} = 1 ] && index="${DC_tlt}/1.cfg" && item_name="$(sed 's/<[^>]*>//g' <<<"${3}")"
[ ${1} = 2 ] && index="${DC_tlt}/2.cfg" && item_name="$(sed 's/<[^>]*>//g' <<<"${2}")"

re='^[0-9]+$'; index_pos="$3"
if ! [[ ${index_pos} =~ $re ]]; then
index_pos=`grep -Fxon -m 1 "${item_name}" "${index}" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
nll=""
fi

_item="$(sed -n ${index_pos}p "${index}")"
if [ -z "${_item}" ]; then
    _item="$(sed -n 1p "${index}")"; index_pos=1
fi

item="$(grep -F -m 1 "trgt{${_item}}" "$DC_tlt/0.cfg" |sed 's/}/}\n/g')"
type="$(grep -oP '(?<=type{).*(?=})' <<<"${item}")"
export trgt="$(grep -oP '(?<=trgt{).*(?=})' <<<"${item}")"
export srce="$(grep -oP '(?<=srce{).*(?=})' <<<"${item}")"
export exmp="$(grep -oP '(?<=exmp{).*(?=})' <<<"${item}")"
export defn="$(grep -oP '(?<=defn{).*(?=})' <<<"${item}")"
export note="$(grep -oP '(?<=note{).*(?=})' <<<"${item}")"
export grmr="$(grep -oP '(?<=grmr{).*(?=})' <<<"${item}")"
export mark="$(grep -oP '(?<=mark{).*(?=})' <<<"${item}")"
export link="$(grep -oP '(?<=link{).*(?=})' <<<"${item}")"
export tags="$(grep -oP '(?<=tags{).*(?=})' <<<"${item}")"
export wrds="$(grep -oP '(?<=wrds{).*(?=})' <<<"${item}")"
export exmp="$(sed "s/${trgt,,}/<span background='#FDFBCF'>${trgt,,}<\/\span>/g" <<<"${exmp}")"
export cdid="$(grep -oP '(?<=cdid{).*(?=})' <<<"${item}")"
text_missing=0

if [ ${type} = 1 ]; then
    export cmd_listen="$DS/play.sh play_word "\"${trgt}\"" ${cdid}"
    [ "$mark" = TRUE ] && trgt="<b>$trgt</b>" && grmr="<b>$grmr</b>"
    word_view
elif [ ${type} = 2 ]; then
    export cmd_listen="$DS/play.sh play_sentence ${cdid}"
    [ "$mark" = TRUE ] && trgt="<b>$trgt</b>" && grmr="<b>$grmr</b>"
    sentence_view
else
    trgt="${_item} <small>[Text missing]</small>"
    grmr="${trgt}"
    if [[ $(wc -w <<< "${_item}") -lt 2 ]]; then
        export cmd_listen="$DS/play.sh play_word "\"${trgt}\"" ${cdid}"
        text_missing=1
        word_view
    else 
        export cmd_listen="$DS/play.sh play_sentence ${cdid}"
        text_missing=2
        sentence_view
    fi
fi
    ret=$?
    if ps -A | pgrep -f 'play'; then killall play & fi
    if [ $ret -eq 4 ]; then
        "$DS/mngr.sh" edit ${1} ${index_pos} ${text_missing} &
        
    elif [ $ret -eq 2 ]; then
        ff=$((index_pos+1))
        "$DS/vwr.sh" ${1} "" ${ff} &

    elif [ $ret -eq 3 ]; then
        ff=$((index_pos-1))
        "$DS/vwr.sh" ${1} "" ${ff} &
    else
        if ps -A | pgrep -f 'play'; then killall play & fi
        exit 1
    fi
    
exit
