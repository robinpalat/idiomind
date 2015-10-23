#!/bin/bash
# -*- ENCODING: UTF-8 -*-

play_word() {
    w="$(sed 's/<[^>]*>//g' <<<"${2}")"
    if [ -f "${DM_tls}/audio/${w,,}.mp3" ]; then
        play "${DM_tls}/audio/${w,,}.mp3" &
    elif [ -f "${DM_tlt}/$3.mp3" ]; then
        play "${DM_tlt}/$3.mp3" &
    elif [ -n "$synth" ]; then
        echo "${w}." |$synth &
    else
        echo "${w}." |espeak -v $lg -s 150 &
    fi
} >/dev/null 2>&1

play_sentence() {
    if [ -f "${DM_tlt}/$2.mp3" ]; then
        play "${DM_tlt}/$2.mp3" &
    elif [ -n "$synth" ]; then
        sed 's/<[^>]*>//g' <<<"${trgt}." |$synth &
    else
        sed 's/<[^>]*>//g' <<<"${trgt}." |espeak -v $lg -s 150 &
    fi
} >/dev/null 2>&1

play_file() {
    if [ -f "${2}" ]; then
        mplayer "${2}" -novideo -noconsolecontrols -title "${3}"
    elif [ -n "$synth" ]; then
        sed 's/<[^>]*>//g' <<<"${3}." |$synth
    else
        sed 's/<[^>]*>//g' <<<"${3}." |espeak -v $lg -s 150
    fi
} >/dev/null 2>&1

play_list() {
    if [ -z "${tpc}" ]; then source "$DS/ifs/mods/cmns.sh"
    msg "$(gettext "No topic is active")\n" info & exit 1; fi
    tpc="$(sed -n 1p "$HOME/.config/idiomind/s/4.cfg")"
    touch "${DC_tlt}/practice/log.3"
    DC_tlt="${DM_tl}/${tpc}/.conf"; cfg=0
    [[ `wc -l < "${DC_tlt}/10.cfg"` = 10 ]] && cfg=1
    
    lbls=( 'Words' 'Sentences' 'Marked items' 'Difficult words' )
    sets=( 'words' 'sntcs' 'marks' 'wprct' 'rplay' 'audio' 'ntosd' 'loop' 'rword' 'acheck' )
    in=( 'in0' 'in1' 'in2' 'in3' )
    iteml=( "$(gettext "No repeat")" "$(gettext "Words")" "$(gettext "Sentences")" )
    in0="$(grep -Fxvf "${DC_tlt}/4.cfg" "${DC_tlt}/1.cfg" |wc -l)"
    in1="$(grep -Fxvf "${DC_tlt}/3.cfg" "${DC_tlt}/1.cfg" |wc -l)"
    in2="$(grep -Fxvf "${DC_tlt}/2.cfg" "${DC_tlt}/6.cfg" |wc -l)"
    in3="$(grep -Fxvf "${DC_tlt}/4.cfg" "${DC_tlt}/practice/log3" |wc -l)"
    [ ! -d "$DT" ] && mkdir "$DT"; cd "$DT"

    if [ ${cfg} = 1 ]; then
        n=0
        while [ ${n} -le 8 ]; do
            get="${sets[$n]}"
            cfg="${DC_tlt}/10.cfg"
            val=$(grep -o "$get"=\"[^\"]* "${cfg}" |grep -o '[^"]*$')
            declare ${sets[$n]}="$val"
            ((n=n+1))
        done
    else
        n=0; > "${DC_tlt}/10.cfg"
        for s in "${sets[@]}"; do
            echo -e "${s}=\"0\"" >> "${DC_tlt}/10.cfg"
        done
    fi
    setting_1() {
        n=0
        while [ ${n} -le 3 ]; do
            arr="in${n}"
            [[ ${!arr} -lt 1 ]] && echo "$DS/images/addi.png" || echo "$DS/images/add.png"
            echo "  <span font_desc='Arial 11'>$(gettext "${lbls[$n]}")</span>"
            echo ${!sets[${n}]}
            let n++
        done
        for ad in "$DS/ifs/mods/play"/*; do
            source "${ad}"
            for item in "${!items[@]}"; do
                echo "$DS/images/add.png"
                echo "  <span font_desc='Arial 11'>$(gettext "${item}")</span>"
                grep -o ${items[$item]}=\"[^\"]* "${file_cfg}" |grep -o '[^"]*$'
            done
            unset items
        done
    }
    if grep -E 'vivid|wily' <<<"`lsb_release -a`" >/dev/null 2>&1; then
    btn1="gtk-media-play:0"; else
    btn1="$(gettext "Play"):0"; fi
    if [ ! -f "$DT/.p_" ]; then
        btn2="--center"
        title="$(gettext "Play")"
        [ ${mode} -gt 1 -a -n "${tpc}" ] \
        && title="$(gettext "Play") (${tpc})"
    else
        tpp="$(sed -n 1p "$DT/.p_")"
        title="${tpp}"
        btn2="--button=gtk-media-stop:2"
    fi
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
    --align=right --scroll \
    --separator='|' --always-print-result --print-all \
    --field="$(gettext "Repeat")":CHK "$rplay" \
    --field="$(gettext "Play audio")":CHK "$audio" \
    --field="$(gettext "Use desktop notifications")":CHK "$ntosd" \
    --field="$(gettext "Pause between items (sec)")":SCL "$loop" \
    --field="$(gettext "Repeat sounding out")":CB "$lst_opts1" > $tab2 &
    yad --notebook --key=$KEY --title="$title" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --window-icon="$DS/images/icon.png" \
    --align=right --center --on-top \
    --tab-pos=right --tab-borders=0 \
    --tab=" $(gettext "Lists") " \
    --tab="$(gettext "Options")" \
    --width=400 --height=300 --borders=0 \
    "$btn2" --button="$btn1" --button="$(gettext "Close")":1
    ret=$?
        if [ $ret -eq 1 ]; then rm -f "$DT"/*.p; exit 0; fi
        tab1=$(< $tab1); tab2=$(< $tab2); rm -f "$DT"/*.p
        f=1; n=0; count=0
        for item in "${sets[@]:0:4}"; do
            val=$(sed -n $((${n}+1))p <<<"${tab1}" |cut -d "|" -f3)
            [ -n "${val}" ] && sed -i "s/$item=.*/$item=\"$val\"/g" "${DC_tlt}/10.cfg"
            if [ "$val" = TRUE ]; then
                count=$((count+$(egrep -cv '#|^$' <<<"${!in[${n}]}"))); fi
            ((n=n+1))
        done
        for ad in "$DS/ifs/mods/play"/*; do
            source "${ad}"
            for item in "${!items[@]}"; do
                val=$(sed -n $((${n}+1))p <<<"${tab1}" |cut -d "|" -f3)
                [ -n "${val}" ] && sed -i "s/${items[$item]}=.*/${items[$item]}=\"$val\"/g" "${file_cfg}"
                count=$((count+1))
                ((n=n+1))
            done
            unset items
        done
        for item in "${sets[@]:4:8}"; do
            val="$(cut -d "|" -f${f} <<<"${tab2}")"
            [ -n "${val}" ] && sed -i "s/$item=.*/$item=\"$val\"/g" "${DC_tlt}/10.cfg"
            let f++
        done
        pval="$(cut -d "|" -f5 <<<"${tab2}")"
        if [[ "$pval" = "$(gettext "Words")" ]]; then  val=1
        elif [[ "$pval" = "$(gettext "Sentences")" ]]; then  val=2
        else  val=0; fi
        [ -n "${val}" ] && sed -i "s/rword=.*/rword=\"$val\"/g" "${DC_tlt}/10.cfg"
 
        if [ $ret -eq 0 ]; then
            if [ ${count} -lt 1 ]; then
                notify-send "$(gettext "Nothing to play")" \
                "$(gettext "Exiting...")" -i idiomind -t 3000 &
                [ -f "$DT/.p_" ] && rm -f "$DT/.p_"
                "$DS/stop.sh" 2 & exit 1; fi
            if [ -d "${DM_tlt}" ] && [ -n "${tpc}" ]; then
                    if grep TRUE <<<"$words$sntcs$marks$wprct"; then
                        echo -e "$tpc" > "$DT/.p_"
                    else 
                        > "$DT/.p_"
                    fi
                else
                    "$DS/stop.sh" 2 && exit 1
                fi
            "$DS/stop.sh" 2
            "$DS/bcle.sh" &
        elif [ $ret -eq 2 ]; then
            [ -f "$DT/.p_" ] && rm -f "$DT/.p_"
            [ -f "$DT/index.m3u" ] && rm -f "$DT/index.m3u"
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
    play_list)
    play_list "$@" ;;
esac
