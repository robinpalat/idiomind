#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf

play_word() {

    if [ -f "$DM_tls/${2,,}.mp3" ]; then
    play "$DM_tls/${2,,}.mp3" >/dev/null 2>&1 &
    elif [ -n "$synth" ]; then
    sed 's/<[^>]*>//g' <<<"${2}." | $synth &
    else
    sed 's/<[^>]*>//g' <<<"${2}." | espeak -v $lg -s 150 &
    fi
}

play_sentence() {

    if [ -f "${DM_tlt}/$2.mp3" ]; then
    play "${DM_tlt}/$2.mp3" >/dev/null 2>&1 &
    elif [ -n "$synth" ]; then
    sed 's/<[^>]*>//g' <<<"${3}." | $synth &
    else
    sed 's/<[^>]*>//g' <<<"${3}." | espeak -v $lg -s 150 &
    fi
}

play_list() {
    
    if [ -z "$tpc" ]; then source "$DS/ifs/mods/cmns.sh"
    msg "$(gettext "No topic is active")\n" info & exit 1; fi
    tpc="$(sed -n 1p "$HOME/.config/idiomind/s/4.cfg")"
    DC_tlt="${DM_tl}/${tpc}/.conf"

    [ -n "$(< "$DC_s/1.cfg")" ] && cfg=1 || > "$DC_s/1.cfg"
    lbls=( 'Words' 'Sentences' 'Marked items' 'Difficult words' \
    'New episodes <i><small>Podcasts</small></i>' \
    'Saved episodes <i><small>Podcasts</small></i>' )
    sets=( 'gramr' 'wlist' 'trans' 'ttrgt' 'clipw' 'stsks' \
    'loop' 'rplay' 'audio' 'video' 'ntosd' \
    'langt' 'langs' 'synth' 'txaud' 'intrf' \
    'words' 'sntcs' 'marks' 'wprct' 'nsepi' 'svepi' )
    in=( 'in1' 'in2' 'in3' 'in4' 'in5' 'in6' )

    in1="$(grep -Fxvf "$DC_tlt/4.cfg" "$DC_tlt/1.cfg")"
    in2="$(grep -Fxvf "$DC_tlt/3.cfg" "$DC_tlt/1.cfg")"
    in3="$(grep -Fxvf "$DC_tlt/2.cfg" "$DC_tlt/6.cfg")"
    in4="$(grep -Fxvf "$DC_tlt/4.cfg" "$DC_tlt/practice/log.3")"
    [ -f "$DM_tl/Podcasts/.conf/1.lst" ] && \
    in5="$(tac "$DM_tl/Podcasts/.conf/1.lst")" || in5=""
    [ -f "$DM_tl/Podcasts/.conf/2.lst" ] && \
    in6="$(tac "$DM_tl/Podcasts/.conf/2.lst")" || in6=""
    [ ! -d "$DT" ] && mkdir "$DT"; cd "$DT"

    if [[ ${cfg} = 1 ]]; then

        n=16
        while [[ $n -lt 22 ]]; do
            get="${sets[$n]}"
            val=$(grep -o "$get"=\"[^\"]* "$DC_s/1.cfg" |grep -o '[^"]*$')
            declare ${sets[$n]}="$val"
            ((n=n+1))
        done
        
    else
        n=0; > "$DC_s/1.cfg"
        while [[ $n -lt 22 ]]; do
        echo -e "${sets[$n]}=\"\"" >> "$DC_s/1.cfg"
        ((n=n+1))
        done
    fi

    function setting_1() {
        n=0; 
        while [[ $n -le 5 ]]; do
                arr="in$((n+1))"
                [[ -z ${!arr} ]] \
                && echo "$DS/images/addi.png" \
                || echo "$DS/images/add.png"
            echo "  <span font_desc='Arial 11'>$(gettext "${lbls[$n]}")</span>"
            echo "${!sets[$((n+16))]}"
            let n++
        done
    }

    title="$tpc"
    if [ -f "$DT/.p_" ]; then
    tpp="$(sed -n 2p "$DT/.p_")"
    if grep TRUE <<<"$words$sntcs$marks$wprct"; then
    if [ "$tpp" != "$tpc" ]; then
    title="$(gettext "Playing:") $tpp"; fi
    fi
    fi

    slct="$(setting_1 | yad --list --title="$title" \
    --print-all --always-print-result --separator="|" \
    --class=Idiomind --name=Idiomind \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --align=right --center --on-top \
    --expand-column=2 --no-headers \
    --width=400 --height=300 --borders=5 \
    --column=IMG:IMG \
    --column=TXT:TXT \
    --column=CHK:CHK \
    --button="$(gettext "OK")":0 \
    --button="$(gettext "Cancel")":1)"
    ret=$?

    if [ $ret -eq 0 ]; then
        
        n=16; while [[ ${n} -lt 22 ]]; do
        
            val=$(sed -n $((n-15))p <<<"${slct}" | cut -d "|" -f3)
            [ -n "${val}" ] && \
            sed -i "s/${sets[${n}]}=.*/${sets[${n}]}=\"$val\"/g" "$DC_s/1.cfg"
            if [ "$val" = TRUE ]; then
            count=$((count+$(egrep -cv '#|^$' <<<"${!in[$((n-16))]}"))); fi
            
            ((n=n+1))
        done

            #if [ ${count} -lt 1 ]; then
            #notify-send "$(gettext "Nothing to play")" \
            #"$(gettext "Exiting...")" -i idiomind -t 3000 &
            #"$DS/stop.sh" 2 & exit 1; fi

    fi
    exit 0
}

play_file() {

    if [ -f "${2}" ]; then
        if grep ".mp3" <<<"${2: -4}"; then
            play "${2}"
        else
            mplayer "${2}"
        fi
    elif [ -n "$synth" ]; then
    sed 's/<[^>]*>//g' <<<"${3}." | $synth
    else
    sed 's/<[^>]*>//g' <<<"${3}." | espeak -v $lg -s 150
    fi
    
} >/dev/null 2>&1

case "$1" in
    play_word)
    play_word "$@" ;;
    play_sentence)
    play_sentence "$@" ;;
    play_list)
    play_list "$@" ;;
    play_file)
    play_file "$@" ;;
esac
