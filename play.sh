#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source "$DS/default/sets.cfg"

msg_err1() {
    local info="$(gettext "Please check about voice synthesizer configuration in the settings dialog.")"
    msg "$info" error Info
}

play_word() {
    w="$(sed 's/<[^>]*>//g' <<<"${2}")"
    
    if [ -f "$DT/${3}.mp3" ]; then play "$DT/${3}.mp3" &
    
    elif [ -f "${DM_tlt}/$3.mp3" ]; then play "${DM_tlt}/$3.mp3" &
        
    elif [ -f "${DM_tls}/audio/${w,,}.mp3" ]; then
        play "${DM_tls}/audio/${w,,}.mp3" &
        
    elif ls "$DC_d"/*."TTS offline.Convert text to audio".* 1> /dev/null 2>&1; then
        for Script in "$DC_d"/*."TTS offline.Convert text to audio".*; do
			Script="$DS_a/Resources/scripts/$(basename "${Script}")"
			[ -f "${Script}" ] && "${Script}" "${w}" "$DT/${3}.mp3"
			if [ -f "$DT/${3}.mp3" ]; then 
				play "$DT/${3}.mp3"
				rm -f "$DT/${3}.mp3"; break & exit
			fi
		done
		
    else
        echo "${w}." |espeak -v ${tlangs[$tlng]} \
        -a ${sAmplitude} -s ${sSpeed} -p ${sPitch} \
        -g ${sWordgap} -b ${sEncoding} &
    fi
} >/dev/null 2>&1

play_sentence() {
    if ps -A | pgrep -f 'play'; then killall 'play'; fi
    if [ -f "${DM_tlt}/$2.mp3" ]; then
        play "${DM_tlt}/$2.mp3" &
        
    elif ls "$DC_d"/*."TTS offline.Convert text to audio".* 1> /dev/null 2>&1; then
        for Script in "$DC_d"/*."TTS offline.Convert text to audio".*; do
			Script="$DS_a/Resources/scripts/$(basename "${Script}")"
			[ -f "${Script}" ] && "${Script}" "${trgt}." "$DT/${trgt}.mp3"
			if [ -f "$DT/${trgt}.mp3" ]; then 
				play "$DT/${trgt}.mp3"
				rm -f "$DT/${trgt}.mp3"; break & exit
			fi
		done
    else
        sed 's/<[^>]*>//g' <<< "${trgt}." |espeak -v ${tlangs[$tlng]} \
        -a ${sAmplitude} -s ${sSpeed} -p ${sPitch} \
        -g ${sWordgap} -b ${sEncoding} &
    fi
} >/dev/null 2>&1

play_file() {
    if [ -f "${2}" ]; then
        if [[ ${mime} = 0 ]]; then
            exit 1
        else
            mplayer "${2}" -novideo -noconsolecontrols -title "${3}"
        fi
    elif ls "$DC_d"/*."TTS offline.Convert text to audio".* 1> /dev/null 2>&1; then
        for Script in "$DC_d"/*."TTS offline.Convert text to audio".*; do
			Script="$DS_a/Resources/scripts/$(basename "${Script}")"
			[ -f "${Script}" ] && "${Script}" "${3}." "$DT/out.mp3"
			if [ -f "$DT/out.mp3" ]; then 
				play "$DT/out.mp3"
				rm -f "$DT/out.mp3"; break & exit
			fi
		done
    else
        sed 's/<[^>]*>//g' <<<"${3}." |espeak -v ${tlangs[$tlng]} \
        -a ${sAmplitude} -s ${sSpeed} -p ${sPitch} -g ${sWordgap} -b ${sEncoding}
    fi
} >/dev/null 2>&1

play_list() {
 
    tpc="$(sed -n 1p "$HOME/.config/idiomind/tpc")"
    DC_tlt="${DM_tl}/${tpc}/.conf"
    tpcdb="$DC_tlt/tpc"
    if [ -e "$DT/ps_lk" -o -e "$DT/el_lk" ]; then
        msg "$(gettext "Please wait until the current process is finished.")...\n" \
        dialog-information
        (sleep 50; cleanups "$DT/ps_lk" "$DT/el_lk") & exit 1
    fi
    if [ -z "${tpc}" ]; then
        msg "$(gettext "No topic is active")\n" dialog-information & exit 1
    fi

    [ ! -d "$DT" ] && mkdir "$DT"; cd ~ && cd "$DT"
    [ ! -e $DT/playlck ] && echo 0 > $DT/playlck
    
    btn1="!media-playback-start!$(gettext "Play"):0"
    title="$(gettext "Play")"
    [ ${stts} -ge 1 ] && [ -n "${tpc}" ] && title="$(gettext "Play") - ${tpc}"
    if [ "$(< $DT/playlck)" != 0 ]; then
        tpp="--text=<small>  \"$(sed -n 1p "$DT/playlck")\"</small>"
        title="$(gettext "Play")"
        btn1="!media-playback-stop!$(gettext "Stop"):2"
        title="$(gettext "Playing...")"
    fi
    ntosd=""; audio=""
    lbls=( 'Words' 'Sentences' 'Marked' 'Learning' 'Difficult' )
    in=( 'in0' 'in1' 'in2' 'in3' 'in4' )
    iteml=( "$(gettext "No repeat")" "$(gettext "Words")" "$(gettext "Sentences")" )
    
    
        sents=""; words=""; marks=""; learn=""; leart=""
        in0=0; in1=0; in2=0; in3=0; in4=0
        opts="$(tpc_db 5 config |head -n9)"
    
    if  echo "$stts" |grep -E '1|2|5|6'; then
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
        n=0
        while [ ${n} -le 9 ]; do
            val=$(sed -n $((n+1))p <<< "${opts}")
            declare ${psets[$n]}="$val"
            let n++
        done
    fi
    setting_1() {
		
	    if [ ${stts} -gt 10 ]; then # addons 1 (addon_name)
			for ad in "$DS/ifs/mods/play"/*; do # addons 2
				source "${ad}"
				for item in "${!items[@]}"; do 
					echo "$DS/images/${items[$item]}.png"
					grep -o ${items[$item]}=\"[^\"]* "${file_cfg}" |grep -o '[^"]*$'
					echo "  $(gettext "${item}")"
				done
				unset items
			done
		else
			n=0

			while [ ${n} -le 4 ]; do # sentences, words, ect.
				if ((stts==2 && n==3)); then break; fi
				arr="in${n}"
				[[ ${!arr} -lt 1 ]] && echo "$DS/images/ai0.png" ||echo "$DS/images/a0.png"
				echo "${!psets[${n}]}"
				echo "  $(gettext "${lbls[$n]}")"
				let n++
			done
			for ad in "$DS/ifs/mods/play"/*; do # including a type of addons (list_name)
				source "${ad}"
				if [ -z "$addon_name" ]; then
					for item in "${!items[@]}"; do
						echo "$DS/images/${items[$item]}.png"
						grep -o ${items[$item]}=\"[^\"]* "${file_cfg}" |grep -o '[^"]*$'
						echo "  $(gettext "${item}") <i><small>${list_name}</small></i>"
					done
					unset items
				fi
			done
        fi
    }

    [ -z "$rword" ] && rword=0
    set="$(echo "${iteml[${rword}]}")"
    unset iteml[${rword}]
    lst=`for i in "${iteml[@]}"; do echo -n "!$i"; done`
    lst_opts1="$set$lst"
    tab1=$(mktemp "$DT/XXXXXX")
    tab2=$(mktemp "$DT/XXXXXX")
    c=$((RANDOM%100000)); KEY=$c
    [[ ${ntosd} != TRUE ]] && [[ ${audio} != TRUE ]] && audio=TRUE
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
    --field="$(gettext "Pause between notes (sec)")":SCL "$loop" \
    --field="$(gettext "Repeat sounding out")":CB "$lst_opts1" > "$tab2" &
    yad --notebook --key=$KEY --title="$title" "$tpp"\
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all \
    --window-icon=$DS/images/logo.png \
    --align=right --fixed --center --on-top \
    --tab-pos=right --tab-borders=0 \
    --tab=" $(gettext "Lists") " \
    --tab="$(gettext "Options")" \
    --width=400 --height=260 --borders=5 \
    --button="$btn1" 
    ret=$?
        [ $ret -eq 1 ] && exit 0
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
            n=1; addons_count=0
            for item in "${!items[@]}"; do
                val=$(sed -n $((n))p <<< "${out1}" |cut -d "|" -f2)
                [ -n "${val}" ] && sed -i "s/${items[$item]}=.*/${items[$item]}=\"$val\"/g" "${file_cfg}"
                [ "$val" = TRUE ] && addons_count=$((addons_count+1))
                let n++
            done
            unset items
        done
        count=$((count+addons_count))
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
            "$DS/bcle.sh" "$2" &
            
        # cmd stop
        elif [ $ret -eq 2 ]; then
            [ -e "$DT/playlck" ] && echo 0 > "$DT/playlck"
            [ -e "$DT/index.m3u" ] && rm -f "$DT/index.m3u"
            "$DS/stop.sh" 2 &
        fi
    exit 0
}

play_stop() {
    source "/usr/share/idiomind/default/c.conf"
    if [ -f "$DT/playlck" ]; then
        if [ "$(< $DT/playlck)" = '0' ]; then
            "$DS/bcle.sh" &
        else
            "$DS/stop.sh" 2 &
        fi
    else
        "$DS/bcle.sh" &
    fi
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
    playstop)
    play_stop "$@" ;;
esac
