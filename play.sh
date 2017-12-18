#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source "$DS/default/sets.cfg"

msg_err1() {
    local info="$(gettext "Please check about voice synthesizer configuration in the settings dialog.")"
    source "$DS/ifs/cmns.sh"; msg "$info" error Info
}

play_word() {
    w="$(sed 's/<[^>]*>//g' <<<"${2}")"
    if [ -f "${DM_tlt}/$3.mp3" ]; then
        play "${DM_tlt}/$3.mp3" &
    elif [ -f "${DM_tls}/audio/${w,,}.mp3" ]; then
        play "${DM_tls}/audio/${w,,}.mp3" &
    elif [ -n "$synth" ]; then
        echo "${w}." |${synth}; [ $? != 0 ] && msg_err1
    else
        echo "${w}." |espeak -v ${tlangs[$tlng]} \
        -a ${sAmplitude} -s ${sSpeed} -p ${sPitch} -g ${sWordgap} -b ${sEncoding} &
    fi
} >/dev/null 2>&1

play_sentence() {
    if ps -A | pgrep -f 'play'; then killall 'play'; fi
    if [ -f "${DM_tlt}/$2.mp3" ]; then
        play "${DM_tlt}/$2.mp3" &
    elif [ -n "$synth" ]; then
        sed 's/<[^>]*>//g' <<< "${trgt}." |${synth}; [ $? != 0 ] && msg_err1
    else
        sed 's/<[^>]*>//g' <<< "${trgt}." |espeak -v ${tlangs[$tlng]} \
        -a ${sAmplitude} -s ${sSpeed} -p ${sPitch} -g ${sWordgap} -b ${sEncoding} &
    fi
} >/dev/null 2>&1

play_file() {
    if [ -e "${2}" ]; then
        if [[ ${mime} = 0 ]]; then
            exit 1
        else
            mplayer "${2}" -novideo -noconsolecontrols -title "${3}"
        fi
    elif [ -n "$synth" ]; then
        sed 's/<[^>]*>//g' <<<"${3}." |${synth}; [ $? != 0 ] && msg_err1
    else
        sed 's/<[^>]*>//g' <<<"${3}." |espeak -v ${tlangs[$tlng]} \
        -a ${sAmplitude} -s ${sSpeed} -p ${sPitch} -g ${sWordgap} -b ${sEncoding}
    fi
} >/dev/null 2>&1

play_list() {
    if [ -z "${tpc}" ]; then source "$DS/ifs/cmns.sh"
    msg "$(gettext "No topic is active")\n" dialog-information & exit 1; fi
    tpc="$(sed -n 1p "$HOME/.config/idiomind/tpc")"
    DC_tlt="${DM_tl}/${tpc}/.conf"
	tpcdb="$DC_tlt/tpc"
	[ ! -e "$tpcdb" ] && : # MAKE SURE
    [ ! -d "$DT" ] && mkdir "$DT"; cd "$DT"
    [ ! -e $DT/playlck ] && echo 0 > $DT/playlck
    btn1="$(gettext "Play"):0"
    if [ "$(< $DT/playlck)" = 0 ]; then
        title="$(gettext "Play")"
        [ ${mode} -ge 1 -a -n "${tpc}" ] && title="${tpc}"
    else
        tpp="$(gettext "Playing:") $(sed -n 1p "$DT/playlck") ..."
        title="${tpp}"
        btn1="$(gettext "Stop"):2"
    fi
    ntosd=""; audio=""
    lbls=( 'Words' 'Sentences' 'Marked items' 'Orange items' 'Red items' )
    in=( 'in0' 'in1' 'in2' 'in3' 'in4' )
    iteml=( "$(gettext "No repeat")" "$(gettext "Words")" "$(gettext "Sentences")" )
	sents="$(tpc_db 5 sentences)"
	words="$(tpc_db 5 words)"
	marks="$(tpc_db 5 marks)"
	learn="$(tpc_db 5 learning)"
	leart="$(tpc_db 5 learnt)"
    in0="$(grep -Fxv "${sents}" <<< "${learn}" |wc -l)"
    in1="$(grep -Fxv "${words}" <<< "${learn}" |wc -l)"
    in2="$(grep -Fxv "${leart}" <<< "${marks}" |wc -l)"
    in3="$(egrep -cv '#|^$' "${DC_tlt}/practice/log2")"
    in4="$(egrep -cv '#|^$' "${DC_tlt}/practice/log3")"
    
    opts="$(tpc_db 5 config |head -n9)"
	cfg=1
    if [ ${cfg} = 1 ]; then
        n=0; v=1
        while [ ${n} -le 9 ]; do
            val=$(sed -n ${v}p <<< "$opts")
            declare ${psets[$n]}="$val"
            let n++ v++
        done
    else
		: # TODO
    fi
    setting_1() {
        n=0
        while [ ${n} -le 4 ]; do
            arr="in${n}"
            [[ ${!arr} -lt 1 ]] && echo "$DS/images/ai.png" || echo "$DS/images/a.png"
            echo ${!psets[${n}]}
            echo "  $(gettext "${lbls[$n]}")"
            let n++
        done
        for ad in "$DS/ifs/mods/play"/*; do
            source "${ad}"
            for item in "${!items[@]}"; do
                echo "$DS/images/${items[$item]}.png"
                echo `grep -o ${items[$item]}=\"[^\"]* "${file_cfg}" |grep -o '[^"]*$'`
                echo "  $(gettext "${item}") <i><small>${aname}</small></i>"
            done
            unset items
        done
    }

    [ -z "$rword" ] && rword=0
    set="$(echo "${iteml[${rword}]}")"
    unset iteml[${rword}]
    lst=`for i in "${iteml[@]}"; do echo -n "!$i"; done`
    lst_opts1="$set$lst"
    tab1=$(mktemp "$DT/XXXXXX")
    tab2=$(mktemp "$DT/XXXXXX")
    c=$((RANDOM%100000)); KEY=$c
    [ ${ntosd} != TRUE -a ${audio} != TRUE ] && audio=TRUE
    setting_1 | yad --plug=$KEY --tabnum=1 --list \
    --print-all --always-print-result --separator="|" \
    --center --expand-column=3 --no-headers \
    --column=IMG:IMG \
    --column=CHK:CHK \
    --column=TXT:TXT > "$tab1" &
    yad --plug=$KEY --form --tabnum=2 \
    --align=right --center \
    --separator='|' --always-print-result --print-all \
    --field="$(gettext "Repeat")":CHK "$rplay" \
    --field="$(gettext "Play audio")":CHK "$audio" \
    --field="$(gettext "Use desktop notifications")":CHK "$ntosd" \
    --field="$(gettext "Pause between items (sec)")":SCL "$loop" \
    --field="$(gettext "Repeat sounding out")":CB "$lst_opts1" > "$tab2" &
    yad --notebook --key=$KEY --title="$title" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --window-icon=idiomind \
    --align=right --fixed --center --on-top \
    --tab-pos=right --tab-borders=0 \
    --tab=" $(gettext "Lists") " \
    --tab="$(gettext "Options")" \
    --width=400 --height=260 --borders=5 \
    --button="$btn1" --button="$(gettext "Close")":1
    ret=$?
        [ $ret -eq 0 ] && echo "${tpc}" > "$DT/playlck"
        [ $ret -eq 2 ] && echo "0" > "$DT/playlck"
        out1=$(< $tab1); out2=$(< $tab2)
        [ -f "$tab1" ] && rm -f "$tab1"; [ -f "$tab2" ] && rm -f "$tab2"
        f=1; n=0; count=0
        for co in "${psets[@]:0:5}"; do
            val=$(sed -n $((n+1))p <<< "${out1}" |cut -d "|" -f2)
            [ -n "${val}" ] && tpc_db 9 config "${co}" "${val}"
            [ "$val" = TRUE ] && count=$((count+$(wc -l |sed '/^$/d' <<< "${!in[${n}]}")))
            let n++
        done
        for ad in "$DS/ifs/mods/play"/*; do
            source "${ad}"
            for co in "${!items[@]}"; do
                val=$(sed -n $((n+1))p <<< "${out1}" |cut -d "|" -f2)
                co="${items[$co]}"
                [ -n "${val}" ] && tpc_db 9 config "${co}" "${val}"
                [ "$val" = TRUE ] && count=$((count+1))
                let n++
            done
            unset items
        done
        for co in "${psets[@]:5:9}"; do
            val="$(cut -d "|" -f${f} <<< "${out2}")"
            [ -n "${val}" ] && tpc_db 9 config "${co}" "${val}"
            let f++
        done
        pval="$(cut -d "|" -f5 <<< "${out2}")"
        if [[ "$pval" = "$(gettext "Words")" ]]; then  val=1
        elif [[ "$pval" = "$(gettext "Sentences")" ]]; then  val=2
        else  val=0; fi
        [ -n "${val}" ] && tpc_db 9 config "rword" "${val}"

        # cmd play
        if [ $ret -eq 0 ]; then
            if [ ${count} -lt 1 ]; then
                echo 0 > "$DT/playlck"
                notify-send "$(gettext "Nothing to play")" "$(gettext "Exiting...")" -t 3000 &
                "$DS/stop.sh" 2 & exit 1; fi
            if [ -d "${DM_tlt}" ] && [ -n "${tpc}" ]; then
                    if grep TRUE <<< "$words$sntcs$marks$wprct"; then
                        echo -e "${tpc}" > "$DT/playlck"
                    else 
                        echo 0 > "$DT/playlck"
                    fi
            else
                "$DS/stop.sh" 2 && exit 1
            fi
            [ -f "$DT/play2lck" ] && rm -f "$DT/play2lck"
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
