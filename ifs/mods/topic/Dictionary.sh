#!/bin/bash
# -*- ENCODING: UTF-8 -*-

find_cmd='@bash -c "item \"$0\""'
function item() {
    $DS/play.sh play_word "$1" &
    sed 's/<[^>]*>//g' <<<"$1" |xclip -i
} >/dev/null 2>&1
export -f item

function dictionary() {
    words=$(grep -o -P '(?<=w3.).*(?=\.w3)' "$DC_s/log" \
    |tr '|' '\n' | sort | uniq -dc | sort -n -r | sed 's/ \+/ /g')
    cmd_play="$DS/play.sh play_list"
    cdb="$DM_tls/data/${lgtl}.db"
    table="T`date +%m%y`"
    limit=0
    list1() {
        exec 3< <(sqlite3 "$cdb" "select Word FROM  ${table}" |tac)
        exec 4< <(sqlite3 "$cdb" "select ${lgsl} FROM ${table}"|tac)
        while :; do
            read word <&3
            read tran <&4
            if [ -n "$word" -a -n "$tran" ]; then
                echo "<span font_desc='Arial Bold 12'>$word</span>"
                echo "<span font_desc='Arial 12'>$tran</span>"
            fi
            [ ${limit} -gt 100 ] && break
            let limit++
        done
    }
    list2() {
       for n in {1..25}; do
        if [[ $(sed -n ${n}p <<<"${words}" |awk '{print ($1)}') -ge 0 ]]; then
            word=$(sed -n ${n}p <<<"${words}" |awk '{print ($2)}')
            if [ -n "${word}" ]; then
                echo "<span font_desc='Arial Bold 12'>$word</span>"
                word="$(sqlite3 ${cdb} "select ${lgsl} from Words where Word is '${word}';")"
                echo "<span font_desc='Arial 12'>$word</span>"
            fi
        fi
        done
    }

    fkey=$(($RANDOM * $$))
    list1 | yad --list \
    --text="$(gettext "New words")" \
    --dclick-action="$find_cmd" --tabnum=1 --plug="$fkey" \
    --no-headers --search-column=1 --regex-search --print-column=1 \
    --column="$(gettext "$lgtl")":TEXT \
    --column="$(gettext "$lgsl")":TEXT &
    if [ -n "$words" ]; then
    list2 | yad --list \
    --text="$(gettext "Difficult words")" \
    --dclick-action="$find_cmd" --tabnum=2 --plug="$fkey" \
    --no-headers --search-column=1 --regex-search --print-column=1 \
    --column="$(gettext "$lgtl")":TEXT \
    --column="$(gettext "$lgsl")":TEXT &
    else
    echo -e "\n"$(gettext "No se encontraron palabras dificiles")"" \
    | yad --text-info --text="$(gettext "Difficult words")" \
    --dclick-action="$find_cmd" --tabnum=2 --plug="$fkey" \
    --wrap --back='#FFFFFF' --fore='gray15' \
    --fontname='vendana 9' --margins=14  &
    fi
    yad --paned --key="$fkey" --title="$(gettext "Words")" \
    --orient=hor --align=right --image-on-top \
    --name=Idiomind --class=Idiomind \
    --orient=vert --window-icon=idiomind --on-top --center \
    --gtkrc="$DS/default/gtkrc.cfg" \
    --width=670 --height=470 --borders=5 --splitter=310 \
    --button="<small>$(gettext "Close")</small>":1
    
} >/dev/null 2>&1

dictionary
