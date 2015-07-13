#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf

play_word() {

    if [ -f "$DM_tls/${2,,}.mp3" ]; then
    play "$DM_tls/${2,,}.mp3" &
    elif [ -n "$synth" ]; then
    echo "${2}." | $synth &
    else
    echo "${2}." | espeak -v $lg -s 150 &
    fi
} >/dev/null 2>&1

play_sentence() {

    if [ -f "${DM_tlt}/$2.mp3" ]; then
    play "${DM_tlt}/$2.mp3" &
    elif [ -n "$synth" ]; then
    echo "${3}." | $synth &
    else
    echo "${3}." | espeak -v $lg -s 150 &
    fi
} >/dev/null 2>&1

play_file() {

    if [ -f "${2}" ]; then
        if grep ".mp3" <<<"${2: -4}"; then
            play "${2}"
        else
            mplayer "${2}" -noconsolecontrols -title "${3}"
        fi
    elif [ -n "$synth" ]; then
    echo "${3}." | $synth
    else
    echo "${3}." | espeak -v $lg -s 150
    fi
} >/dev/null 2>&1

play_list() {
    
    if [ -z "$tpc" ]; then source "$DS/ifs/mods/cmns.sh"
    msg "$(gettext "No topic is active")\n" info & exit 1; fi
    
    tpc="$(sed -n 1p "$HOME/.config/idiomind/s/4.cfg")"
    DC_tlt="${DM_tl}/${tpc}/.conf"
    [[ -n "$(< "$DC_s/1.cfg")" ]] && cfg=1 || > "$DC_s/1.cfg"
    lbls=( 'Words' 'Sentences' 'Marked items' 'Difficult words' \
    'New episodes <i><small>Podcasts</small></i>' \
    'Saved episodes <i><small>Podcasts</small></i>' )
    sets=( 'gramr' 'wlist' 'trans' 'ttrgt' 'clipw' 'stsks' \
    'rplay' 'audio' 'video' 'ntosd' 'loop' \
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

        n=6
        while [ ${n} -lt 22 ]; do
            get="${sets[$n]}"
            val=$(grep -o "$get"=\"[^\"]* "$DC_s/1.cfg" |grep -o '[^"]*$')
            declare ${sets[$n]}="$val"
            ((n=n+1))
        done
        
    else
        n=0; > "$DC_s/1.cfg"
        while [ ${n} -lt 22 ]; do
        echo -e "${sets[$n]}=\"\"" >> "$DC_s/1.cfg"
        ((n=n+1))
        done
    fi

    function setting_1() {
        n=0; 
        while [ ${n} -le 5 ]; do
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
    if grep -E 'vivid|wily' <<<"`lsb_release -a`" >/dev/null 2>&1; then
    btn1="gtk-media-play:0"; else
    btn1="$(gettext "Play"):0"; fi
    
    if [ ! -f "$DT/.p_" ]; then
        btn2="--center"
    else
        tpp="$(sed -n 2p "$DT/.p_")"
        btn2="--button=gtk-media-stop:2"
        if grep TRUE <<<"$words$sntcs$marks$wprct"; then
        if [ "$tpp" != "$tpc" ]; then
        title="$(gettext "Playing:") $tpp"; fi
        fi
    fi
    
    tab1=$(mktemp "$DT/XXX.p")
    tab2=$(mktemp "$DT/XXX.p")
    c=$((RANDOM%100000)); KEY=$c
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
    --field="$(gettext "Only play videos")":CHK "$video" \
    --field="$(gettext "Use desktop notifications")":CHK "$ntosd" \
    --field="$(gettext "Pause between items (sec)")":SCL "$loop" > $tab2 &
    yad --notebook --key=$KEY --title="$title" \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --window-icon="$DS/images/icon.png" \
    --align=right --fixed --center --on-top \
    --tab-pos=bottom --tab-borders=0 \
    --tab=" $(gettext "Lists") " \
    --tab="$(gettext "Options")" \
    --width=400 --height=315 --borders=0 \
    "$btn2" --button="$btn1"
    ret=$?

    if [ $ret -eq 0 -o $ret -eq 2 ]; then
        
        tab1=$(< $tab1)
        tab2=$(< $tab2)
        rm -f "$DT"/*.p
        f=1; n=6
        while [ ${n} -lt 22 ]; do
        
            if [ ${n} -gt 5 -a ${n} -lt 11 ]; then
            
                sed -i "s/${sets[${n}]}=.*/${sets[${n}]}=\""$(cut -d "|" -f${f} <<<"$tab2")"\"/g" \
                "$DC_s/1.cfg"
                ((f=f+1))

            elif [ ${n} -ge 16 ]; then
            
                val=$(sed -n $((n-15))p <<<"${tab1}" | cut -d "|" -f3)
                [ -n "${val}" ] && \
                sed -i "s/${sets[${n}]}=.*/${sets[${n}]}=\"$val\"/g" "$DC_s/1.cfg"
                        
                if [ "$val" = TRUE ]; then
                count=$((count+$(egrep -cv '#|^$' <<<"${!in[$((n-16))]}"))); fi
            fi
            
            ((n=n+1))
        done

        if [ $ret -eq 0 ]; then
        
            if [ ${count} -lt 1 ]; then
            notify-send "$(gettext "Nothing to play")" \
            "$(gettext "Exiting...")" -i idiomind -t 3000 &
            "$DS/stop.sh" 2 & exit 1; fi

            "$DS/stop.sh" 2 &
            if [ -d "$DM_tlt" ] && [ -n "$tpc" ]; then
            echo -e "$DM_tlt\n$tpc" > "$DT/.p_"
            else "$DS/stop.sh" 2 && exit 1; fi
            
            echo -e "ply.$tpc.ply" >> "$DC_s/log" &
            sleep 1; "$DS/bcle.sh" &

        elif [ $ret -eq 2 ]; then

            [ -f "$DT/.p_" ] && rm -f "$DT/.p_"
            [ -f "$DT/index.m3u" ] && rm -f "$DT/index.m3u"
            "$DS/stop.sh" 2 &
        fi
    fi
    rm -f "$DT"/*.p
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
