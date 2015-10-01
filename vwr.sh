#!/bin/bash
# -*- ENCODING: UTF-8 -*-
if [ ${1} = 3 ]; then
    trgt=${2}
    srce=${3}
    exmp="$(sed "s/${trgt,,}/<span background='#FDFBCF'>${trgt,,}<\/\span>/g" <<<"${4}")"
    cmd_listen="$DS/play.sh play_word "\"${trgt}\"" ${id}"
    word_view
else
[ ${1} = 1 ] && index="${DC_tlt}/1.cfg" && item_name="$(sed 's/<[^>]*>//g' <<<"${3}")"
[ ${1} = 2 ] && index="${DC_tlt}/2.cfg" && item_name="$(sed 's/<[^>]*>//g' <<<"${2}")"

re='^[0-9]+$'; index_pos="$3"
if ! [[ ${index_pos} =~ $re ]]; then
index_pos=`grep -Fxon -m 1 "${item_name}" "${index}" |sed -n 's/^\([0-9]*\)[:].*/\1/p'`
nll=""; fi

_item="$(sed -n ${index_pos}p "${index}")"
if [ -z "${_item}" ]; then
    _item="$(sed -n 1p "${index}")"; index_pos=1; fi
item="$(grep -F -m 1 "trgt={${_item}}" "$DC_tlt/0.cfg" |sed 's/},/}\n/g')"

type="$(grep -oP '(?<=type={).*(?=})' <<<"${item}")"
export trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
srce="$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")"
exmp="$(grep -oP '(?<=exmp={).*(?=})' <<<"${item}")"
defn="$(grep -oP '(?<=defn={).*(?=})' <<<"${item}")"
note="$(grep -oP '(?<=note={).*(?=})' <<<"${item}")"
grmr="$(grep -oP '(?<=grmr={).*(?=})' <<<"${item}")"
mark="$(grep -oP '(?<=mark={).*(?=})' <<<"${item}")"
link="$(grep -oP '(?<=link={).*(?=})' <<<"${item}")"
tag="$(grep -oP '(?<=tag={).*(?=})' <<<"${item}")"
lwrd="$(grep -oP '(?<=wrds={).*(?=})' <<<"${item}" |tr '_' '\n')"
exmp="$(sed "s/${trgt,,}/<span background='#FDFBCF'>${trgt,,}<\/\span>/g" <<<"$exmp")"
id="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${item}")"
text_missing=0

if [ ${type} = 1 ]; then
    cmd_listen="$DS/play.sh play_word "\"${trgt}\"" ${id}"
    [ "$mark" = TRUE ] && trgt="<b>$trgt</b>" && grmr="<b>$grmr</b>"
    word_view
elif [ ${type} = 2 ]; then
    cmd_listen="$DS/play.sh play_sentence ${id}"
    [ "$mark" = TRUE ] && trgt="<b>$trgt</b>" && grmr="<b>$grmr</b>"
    sentence_view
else
    trgt="${_item} [Text missing]"
    grmr="${trgt}"
    if [[ `wc -w <<< "${_item}"` -lt 2 ]]; then
        cmd_listen="$DS/play.sh play_word "\"${trgt}\"" ${id}"
        text_missing=1
        word_view
    else 
        cmd_listen="$DS/play.sh play_sentence ${id}"
        text_missing=2
        sentence_view
    fi
fi
    ret=$?
    if [ $ret -eq 4 ]; then
        "$DS/mngr.sh" edit ${1} ${index_pos} ${text_missing}
    elif [ $ret -eq 2 ]; then
        if [[ ${index_pos} = 1 ]]; then
            item=`tail -n 1 < "${index}"`
            [ ${1} = 1 ] && "$DS/vwr.sh" ${1} "" "${item}"
            [ ${1} = 2 ] && "$DS/vwr.sh" ${1} "${item}"
        else
            ff=$((index_pos-1))
            "$DS/vwr.sh" ${1} "" ${ff} &
        fi
    elif [ $ret -eq 3 ]; then
        ff=$((index_pos+1))
        "$DS/vwr.sh" ${1} "" ${ff} &
    else 
        exit 1
    fi
fi
exit
