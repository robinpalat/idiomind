#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source "$DS/default/sets.cfg"

msg_err1() {
    local info="$(gettext "Please check about voice synthesizer configuration in the settings dialog.")"
    source "$DS/ifs/cmns.sh"; msg "$info" error Info
}

play_word() {
    w="$(sed 's/<[^>]*>//g' <<<"${2}")"
    if [ -f "${DM_tls}/audio/${w,,}.mp3" ]; then
        play "${DM_tls}/audio/${w,,}.mp3" &
    elif [ -f "${DM_tlt}/$3.mp3" ]; then
        play "${DM_tlt}/$3.mp3" &
    elif [ -n "$synth" ]; then
        echo "${w}." |${synth}; [ $? != 0 ] && msg_err1
    else
        echo "${w}." |espeak -v ${lang[$lgtl]} \
        -a ${sAmplitude} -s ${sSpeed} -p ${sPitch} -g ${sWordgap} -b ${sEncoding} &
    fi
} >/dev/null 2>&1

play_sentence() {
    if ps -A | pgrep -f 'play'; then killall 'play'; fi
    if [ -f "${DM_tlt}/$2.mp3" ]; then
        play "${DM_tlt}/$2.mp3" &
    elif [ -n "$synth" ]; then
        sed 's/<[^>]*>//g' <<<"${trgt}." |${synth}; [ $? != 0 ] && msg_err1
    else
        sed 's/<[^>]*>//g' <<<"${trgt}." |espeak -v ${lang[$lgtl]} \
        -a ${sAmplitude} -s ${sSpeed} -p ${sPitch} -g ${sWordgap} -b ${sEncoding} &
    fi
} >/dev/null 2>&1

play_file() {
    if [ -e "${2}" ]; then
        if [[ ${mime} = 2 ]]; then
        mplayer "${2}" -noconsolecontrols -title "${3}"; else
        mplayer "${2}" -novideo -noconsolecontrols -title "${3}"; fi
    elif [ -n "$synth" ]; then
        sed 's/<[^>]*>//g' <<<"${3}." |${synth}; [ $? != 0 ] && msg_err1
    else
        sed 's/<[^>]*>//g' <<<"${3}." |espeak -v ${lang[$lgtl]} \
        -a ${sAmplitude} -s ${sSpeed} -p ${sPitch} -g ${sWordgap} -b ${sEncoding}
    fi
} >/dev/null 2>&1

play_list() {
    if [ -z "${tpc}" ]; then source "$DS/ifs/cmns.sh"
    msg "$(gettext "No topic is active")\n" dialog-information & exit 1; fi
    tpc="$(sed -n 1p "$HOME/.config/idiomind/4.cfg")"
    DC_tlt="${DM_tl}/${tpc}/.conf"; cfg=0
    [[ `wc -l < "${DC_tlt}/10.cfg"` = 11 ]] && cfg=1
    ntosd=""; audio=""
    lbls=( 'Words' 'Sentences' 'Marked items' 'Learning' 'Difficult' )
    in=( 'in0' 'in1' 'in2' 'in3' 'in4' )
    iteml=( "$(gettext "No repeat")" "$(gettext "Words")" "$(gettext "Sentences")" )
    in0="$(grep -Fxvf "${DC_tlt}/4.cfg" "${DC_tlt}/1.cfg" |wc -l)"
    in1="$(grep -Fxvf "${DC_tlt}/3.cfg" "${DC_tlt}/1.cfg" |wc -l)"
    in2="$(grep -Fxvf "${DC_tlt}/2.cfg" "${DC_tlt}/6.cfg" |wc -l)"
    in3="$(egrep -cv '#|^$' "${DC_tlt}/practice/log2")"
    in4="$(egrep -cv '#|^$' "${DC_tlt}/practice/log3")"
    [ ! -d "$DT" ] && mkdir "$DT"; cd "$DT"
    [ ! -e $DT/playlck ] && echo 0 > $DT/playlck

    if [ ${cfg} = 1 ]; then
        n=0
        while [ ${n} -le 9 ]; do
            get="${psets[$n]}"
            cfg="${DC_tlt}/10.cfg"
            val=$(grep -o "$get"=\"[^\"]* "${cfg}" |grep -o '[^"]*$')
            declare ${psets[$n]}="$val"
            let n++
        done
    else
        n=0; > "${DC_tlt}/10.cfg"
        for s in "${psets[@]}"; do
            echo -e "${s}=\"0\"" >> "${DC_tlt}/10.cfg"
        done
    fi
    setting_1() {
        n=0
        while [ ${n} -le 4 ]; do
            arr="in${n}"
            [[ ${!arr} -lt 1 ]] && echo "$DS/images/addi.png" || echo "$DS/images/add.png"
            echo "  <span font_desc='Arial 11'>$(gettext "${lbls[$n]}")</span>"
            echo ${!psets[${n}]}
            let n++
        done
        for ad in "$DS/ifs/mods/play"/*; do
            source "${ad}"
            for item in "${!items[@]}"; do
                echo "$DS/images/${items[$item]}.png"
                echo "  <span font_desc='Arial 11'>$(gettext "${item}") <i><small><small>${aname}</small></small></i></span>"
                echo `grep -o ${items[$item]}=\"[^\"]* "${file_cfg}" |grep -o '[^"]*$'`
            done
            unset items
        done
    }

    btn1="$(gettext "Play"):0"
    if [ "$(< $DT/playlck)" = 0  ]; then
        btn2="--center"
        title="$(gettext "Play")"
        [ ${mode} -gt 1 -a -n "${tpc}" ] \
        && title="$(gettext "Play") (${tpc})"
    else
        tpp="$(sed -n 1p "$DT/playlck")"
        title="${tpp}"
        btn2="--button=$(gettext "Stop"):2"
    fi
    [ -z "$rword" ] && rword=0
    set="$(echo "${iteml[${rword}]}")"
    unset iteml[${rword}]
    lst=`for i in "${iteml[@]}"; do echo -n "!$i"; done`
    lst_opts1="$set$lst"
    tab1=$(mktemp "$DT/XXX.p")
    tab2=$(mktemp "$DT/XXX.p")
    c=$((RANDOM%100000)); KEY=$c
    [ ${ntosd} != TRUE -a ${audio} != TRUE ] && audio=TRUE
    
    setting_1 | yad --plug=$KEY --tabnum=1 --list \
    --print-all --always-print-result --separator="|" \
    --expand-column=2 --no-headers --borders=0 \
    --column=IMG:IMG \
    --column=TXT:TXT \
    --column=CHK:CHK > $tab1 &
    yad --plug=$KEY --form --tabnum=2 --borders=5 \
    --align=right \
    --separator='|' --always-print-result --print-all \
    --field="$(gettext "Repeat")":CHK "$rplay" \
    --field="$(gettext "Play audio")":CHK "$audio" \
    --field="$(gettext "Use desktop notifications")":CHK "$ntosd" \
    --field="$(gettext "Pause between items (sec)")":SCL "$loop" \
    --field="$(gettext "Repeat sounding out")":CB "$lst_opts1" > $tab2 &
    yad --notebook --key=$KEY --title="$title" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --window-icon=idiomind \
    --align=right --center --on-top \
    --tab-pos=right --tab-borders=0 \
    --tab=" $(gettext "Lists") " \
    --tab="$(gettext "Options")" \
    --width=420 --height=300 --borders=0 \
    "$btn2" --button="$btn1" --button="$(gettext "Close")":1
    ret=$?
        tab1=$(< $tab1); tab2=$(< $tab2); rm -f "$DT"/*.p
        f=1; n=0; count=0
        for item in "${psets[@]:0:5}"; do
            val=$(sed -n $((n+1))p <<<"${tab1}" |cut -d "|" -f3)
            [ -n "${val}" ] && sed -i "s/$item=.*/$item=\"$val\"/g" "${DC_tlt}/10.cfg"
            [ "$val" = TRUE ] && count=$((count+$(wc -l |sed '/^$/d' <<<"${!in[${n}]}")))
            let n++
        done
        for ad in "$DS/ifs/mods/play"/*; do
            source "${ad}"
            for item in "${!items[@]}"; do
                val=$(sed -n $((n+1))p <<<"${tab1}" |cut -d "|" -f3)
                [ -n "${val}" ] && sed -i "s/${items[$item]}=.*/${items[$item]}=\"$val\"/g" "${file_cfg}"
                [ "$val" = TRUE ] && count=$((count+1))
                let n++
            done
            unset items
        done
        for item in "${psets[@]:5:9}"; do
            val="$(cut -d "|" -f${f} <<<"${tab2}")"
            [ -n "${val}" ] && sed -i "s/$item=.*/$item=\"$val\"/g" "${DC_tlt}/10.cfg"
            let f++
        done
        
        pval="$(cut -d "|" -f5 <<<"${tab2}")"
        if [[ "$pval" = "$(gettext "Words")" ]]; then  val=1
        elif [[ "$pval" = "$(gettext "Sentences")" ]]; then  val=2
        else  val=0; fi
        
        [ -n "${val}" ] && sed -i "s/rword=.*/rword=\"$val\"/g" "${DC_tlt}/10.cfg"
 
        # cmd play
        if [ $ret -eq 0 ]; then
            if [ ${count} -lt 1 ]; then
                notify-send "$(gettext "Nothing to play")" "$(gettext "Exiting...")" -t 3000 &
                echo 0 > "$DT/playlck"
                "$DS/stop.sh" 2 & exit 1; fi
                
            if [ -d "${DM_tlt}" ] && [ -n "${tpc}" ]; then
                    if grep TRUE <<<"$words$sntcs$marks$wprct"; then
                        echo -e "${tpc}" > "$DT/playlck"
                    else 
                        echo 0 > "$DT/playlck"
                    fi
            else
                "$DS/stop.sh" 2 && exit 1
            fi
                
            "$DS/stop.sh" 2
            "$DS/bcle.sh" &
            
        # cmd stop
        elif [ $ret -eq 2 ]; then
            [ -e "$DT/playlck" ] && echo 0 > "$DT/playlck"
            [ -e "$DT/index.m3u" ] && rm -f "$DT/index.m3u"
            "$DS/stop.sh" 2 &
        fi
    exit 0
}

case "$1" in
    play_word)
    play_word "$@" ;;
    play_sentence)
    play_sentence "$@" ;;
    play_file)
    play_file "$@" ;;
    play_list2)
    play_list2 "$@" ;;
    play_list)
    play_list "$@" ;;
esac
